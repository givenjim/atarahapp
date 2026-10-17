import { Inject, Injectable } from '@nestjs/common';
import { type Prisma } from '@prisma/client';
import { Redis } from 'ioredis';
import { AuditService } from '../audit/audit.service';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';

const CACHE_TTL_SECONDS = 60;
const cacheKey = (key: string) => `ps:${key}`;

/**
 * Runtime-tunable values (Pro price, cancellation window, SLA days...). Application code reads them
 * here with a typed fallback; it never hard-codes the number.
 */
@Injectable()
export class PlatformSettingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async get<T>(key: string, fallback: T): Promise<T> {
    try {
      const cached = await this.redis.get(cacheKey(key));
      if (cached !== null) return JSON.parse(cached) as T;
    } catch {
      // fall through
    }
    const row = await this.prisma.platformSetting.findUnique({
      where: { key },
      select: { value: true },
    });
    if (!row) return fallback;
    await this.redis
      .set(cacheKey(key), JSON.stringify(row.value), 'EX', CACHE_TTL_SECONDS)
      .catch(() => undefined);
    return row.value as T;
  }

  async set(
    key: string,
    value: Prisma.InputJsonValue,
    actor: { id: string; ip?: string; requestId?: string },
    description?: string,
  ): Promise<void> {
    const before = await this.prisma.platformSetting.findUnique({ where: { key } });
    await this.prisma.transaction(async (tx) => {
      await tx.platformSetting.upsert({
        where: { key },
        create: { key, value, description, updatedById: actor.id },
        update: { value, updatedById: actor.id, ...(description ? { description } : {}) },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.id,
          action: 'platform_setting.set',
          entityType: 'PlatformSetting',
          entityId: key,
          before: before ? { value: before.value } : null,
          after: { value },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    await this.redis.del(cacheKey(key)).catch(() => undefined);
  }
}
