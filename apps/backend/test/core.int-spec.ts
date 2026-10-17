import { getQueueToken } from '@nestjs/bullmq';
import { Controller, Get, type INestApplication, Module, Post, Body } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { Throttle } from '@nestjs/throttler';
import { IsString, MinLength } from 'class-validator';
import { Queue, QueueEvents } from 'bullmq';
import request from 'supertest';
import { Public } from '../src/access/decorators';
import { AppModule } from '../src/app.module';
import { AuditService } from '../src/audit/audit.service';
import { Paged } from '../src/common/response-envelope.interceptor';
import { AppConfigService } from '../src/config/app-config.service';
import { configureApp } from '../src/configure-app';
import { FeatureFlagService } from '../src/feature-flags/feature-flag.service';
import { FLAG_REGISTRY } from '../src/feature-flags/flags.registry';
import { PrismaService } from '../src/prisma/prisma.service';
import { redisConnectionFromUrl } from '../src/queues/redis-connection';
import { SystemProcessor } from '../src/queues/system.processor';
import { StorageService } from '../src/storage/storage.service';
import { applyTestEnv } from './test-env';

class CreateThingDto {
  @IsString()
  @MinLength(3)
  name!: string;
}

@Public()
@Controller('probe')
class ProbeController {
  @Get('ok')
  ok() {
    return { hello: 'atarah' };
  }
  @Get('paged')
  paged() {
    return new Paged([1, 2, 3], { page: 1, limit: 20, total: 3 });
  }
  @Get('boom')
  boom(): never {
    throw new Error('SELECT * FROM secrets WHERE token = abc');
  }
  @Post('things')
  create(@Body() dto: CreateThingDto) {
    return { name: dto.name };
  }
  @Throttle({ default: { limit: 3, ttl: 60_000 } })
  @Get('limited')
  limited() {
    return { ok: true };
  }
}

@Module({ controllers: [ProbeController] })
class ProbeModule {}

/** Storage stub: the real S3 adapter is exercised against a real S3 server in P0-M9. */
const storage = {
  up: true,
  onModuleInit: async () => undefined,
  check: async () => {
    if (!storage.up) throw new Error('down');
  },
};

describe('Backend core (real PostgreSQL + Redis)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  beforeAll(async () => {
    applyTestEnv();
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule, ProbeModule],
      providers: [SystemProcessor],
    })
      .overrideProvider(StorageService)
      .useValue(storage)
      .compile();
    app = moduleRef.createNestApplication();
    configureApp(app, { useLogger: false });
    await app.init();
    prisma = app.get(PrismaService);
  });

  afterAll(async () => {
    await app.close();
  });

  describe('envelopes', () => {
    it('wraps success as { data }', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/probe/ok').expect(200);
      expect(res.body).toEqual({ data: { hello: 'atarah' } });
    });

    it('carries meta for paged responses', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/probe/paged').expect(200);
      expect(res.body).toEqual({ data: [1, 2, 3], meta: { page: 1, limit: 20, total: 3 } });
    });

    it('returns RESOURCE_NOT_FOUND for unknown routes, echoing the request id header', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/does-not-exist')
        .set('X-Request-Id', 'trace-abcdef12')
        .expect(404);
      expect(res.body.error.code).toBe('RESOURCE_NOT_FOUND');
      expect(res.body.error.requestId).toBe('trace-abcdef12');
      expect(res.headers['x-request-id']).toBe('trace-abcdef12');
    });

    it('returns VALIDATION_ERROR with per-field details', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/probe/things')
        .send({ name: 'ab' })
        .expect(400);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
      expect(res.body.error.details.fields[0].field).toBe('name');
    });

    it('rejects unknown properties', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/probe/things')
        .send({ name: 'valid', isAdmin: true })
        .expect(400);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
    });

    it('masks unexpected errors as INTERNAL_ERROR without leaking internals', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/probe/boom').expect(500);
      expect(res.body.error.code).toBe('INTERNAL_ERROR');
      expect(JSON.stringify(res.body)).not.toMatch(/SELECT|secrets|token/);
    });

    it('sets security headers', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/probe/ok');
      expect(res.headers['x-content-type-options']).toBe('nosniff');
      expect(res.headers['x-powered-by']).toBeUndefined();
    });
  });

  describe('rate limiting (Redis-backed)', () => {
    it('returns 429 RATE_LIMITED with Retry-After after the limit is exceeded', async () => {
      const agent = request(app.getHttpServer());
      const hit = () => agent.get('/api/v1/probe/limited').set('X-Test-Throttle', 'on');
      for (let i = 0; i < 3; i++) await hit().expect(200);
      const res = await hit().expect(429);
      expect(res.body.error.code).toBe('RATE_LIMITED');
      expect(res.headers['retry-after']).toBeDefined();
    });
  });

  describe('health', () => {
    it('live is always ok and is not under /api/v1', async () => {
      const res = await request(app.getHttpServer()).get('/health/live').expect(200);
      expect(res.body).toEqual({ data: { status: 'ok' } });
    });

    it('ready reports every dependency up', async () => {
      storage.up = true;
      const res = await request(app.getHttpServer()).get('/health/ready').expect(200);
      expect(res.body.data.checks).toEqual({ postgres: 'up', redis: 'up', storage: 'up' });
    });

    it('ready returns 503 and names the failing dependency', async () => {
      storage.up = false;
      const res = await request(app.getHttpServer()).get('/health/ready').expect(503);
      storage.up = true;
      expect(res.body.error.code).toBe('EXTERNAL_SERVICE_ERROR');
      expect(res.body.error.details.checks).toEqual({
        postgres: 'up',
        redis: 'up',
        storage: 'down',
      });
    });
  });

  describe('audit log', () => {
    it('records entries, scrubbing secrets', async () => {
      const audit = app.get(AuditService);
      const { id } = await audit.record({
        actorType: 'ADMIN',
        action: 'test.action',
        entityType: 'Thing',
        entityId: '1',
        after: { password: 'hunter2', note: 'ok' },
      });
      const row = await prisma.auditLog.findUniqueOrThrow({ where: { id } });
      expect(row.after).toEqual({ password: '[redacted]', note: 'ok' });
    });

    it('is append-only at the database level (UPDATE, DELETE and TRUNCATE are rejected)', async () => {
      const { id } = await app.get(AuditService).record({
        actorType: 'SYSTEM',
        action: 'test.immutable',
        entityType: 'Thing',
      });
      await expect(
        prisma.$executeRaw`UPDATE audit_logs SET action = 'tampered' WHERE id = ${id}::uuid`,
      ).rejects.toThrow(/append-only/);
      await expect(
        prisma.$executeRaw`DELETE FROM audit_logs WHERE id = ${id}::uuid`,
      ).rejects.toThrow(/append-only/);
      await expect(prisma.$executeRawUnsafe('TRUNCATE audit_logs')).rejects.toThrow(/append-only/);
      expect(await prisma.auditLog.count({ where: { id } })).toBe(1);
    });
  });

  describe('feature flags', () => {
    const flags = () => app.get(FeatureFlagService);

    it('seeds the registry on startup without duplicating on re-sync', async () => {
      await flags().syncRegistry();
      expect(await prisma.featureFlag.count()).toBe(FLAG_REGISTRY.length);
      expect(await flags().syncRegistry()).toBe(0);
    });

    it('treats unknown flags as off and later-phase flags as off by default', async () => {
      expect(await flags().isEnabled('no-such-flag')).toBe(false);
      expect(await flags().isEnabled('mentorship')).toBe(false);
    });

    it('toggles a flag, audits the change, and busts the cache', async () => {
      expect(await flags().isEnabled('google-sign-in')).toBe(false); // primes the cache
      await flags().set('google-sign-in', true, { id: '00000000-0000-4000-8000-000000000001' });
      expect(await flags().isEnabled('google-sign-in')).toBe(true);
      const audit = await prisma.auditLog.findFirstOrThrow({
        where: { action: 'feature_flag.set', entityId: 'google-sign-in' },
      });
      expect(audit.before).toEqual({ enabled: false });
      expect(audit.after).toEqual({ enabled: true });
      await flags().set('google-sign-in', false, { id: '00000000-0000-4000-8000-000000000001' });
    });

    it('refuses to set a flag that does not exist', async () => {
      await expect(flags().set('nope', true, { id: 'x' })).rejects.toMatchObject({ status: 404 });
    });
  });

  describe('queues and worker', () => {
    it('processes a job end to end through BullMQ and Redis', async () => {
      const config = app.get(AppConfigService);
      const queue = app.get<Queue>(getQueueToken('system'));
      const events = new QueueEvents('system', {
        connection: redisConnectionFromUrl(config.redisUrl) as never,
        prefix: `atarah:${config.environment}`,
      });
      await events.waitUntilReady();
      const job = await queue.add('ping', { echo: 'hi' });
      const result = await job.waitUntilFinished(events, 15_000);
      await events.close();
      expect(result).toEqual({ pong: true, echo: 'hi' });
    });
  });
});
