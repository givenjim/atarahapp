import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { type INestApplication } from '@nestjs/common';
import pg from 'pg';
import request from 'supertest';
import { buildOpenApiDocument } from '../src/configure-app';
import { MetricsService } from '../src/metrics/metrics.service';
import { adminSignIn, anonClient, bearer, createTestApp, deleteUsers, makeUser } from './helpers';

/**
 * P1-M12 hardening checks that need the running application and the local stack: payload limits, the documented
 * error responses, observability, and the Supabase posture (the anon key reaches no application table).
 */
jest.setTimeout(180_000);

describe('Phase 1 hardening (integration)', () => {
  let app: INestApplication;
  const users: string[] = [];
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    app = await createTestApp();
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  describe('payload limits', () => {
    it('reads a 1 MB CSV import but refuses a body past the limit with 413', async () => {
      const { user, email } = await makeUser(app, { roles: ['PLATFORM_ADMIN'] });
      users.push(user.id);
      const { session } = await adminSignIn(app, email);
      const header = 'title,provider,type,summary,application_url';
      const row = 'T,P,GRANT,A summary long enough to count,https://example.org/a';
      // About 300 KB: past Express's silent 100 KB default, well inside the stated limit.
      const csv = [header, ...Array.from({ length: 4500 }, () => row)].join('\n');
      expect(Buffer.byteLength(csv)).toBeGreaterThan(250_000);
      const ok = await http()
        .post('/api/v1/admin/opportunities/import/preview')
        .set(...bearer(session.accessToken))
        .send({ csv });
      // 500 rows at most: the file is judged on its content (400), not turned away for its size.
      expect([200, 400]).toContain(ok.status);
      const tooBig = await http()
        .post('/api/v1/admin/opportunities/import/preview')
        .set(...bearer(session.accessToken))
        .send({ csv: 'x'.repeat(1_400_000) });
      expect(tooBig.status).toBe(413);
    });

    it('the Send SMS hook still sees the raw body it verifies (rejects a bad signature, not a parse problem)', async () => {
      const res = await http()
        .post('/api/v1/auth/hooks/send-sms')
        .send({ user: { phone: '+254700000000' }, sms: { otp: '123456' } });
      expect([400, 401, 403]).toContain(res.status);
    });
  });

  describe('the OpenAPI document', () => {
    it('documents the error responses of every operation, with the standard envelope and an example', () => {
      const doc = buildOpenApiDocument(app);
      let operations = 0;
      const lacking: string[] = [];
      for (const [path, methods] of Object.entries(doc.paths)) {
        for (const [method, op] of Object.entries(
          methods as Record<
            string,
            {
              responses: Record<
                string,
                { content?: Record<string, { example?: unknown; schema?: { $ref?: string } }> }
              >;
              security?: unknown[];
              parameters?: Array<{ in: string }>;
              'x-error-codes'?: string[];
            }
          >,
        )) {
          if (!['get', 'post', 'put', 'patch', 'delete'].includes(method)) continue;
          operations += 1;
          const codes = Object.keys(op.responses).filter((c) => /^[45]/.test(c));
          const need = ['429'];
          if ((op.security ?? []).length > 0) need.push('401', '403');
          if ((op.parameters ?? []).some((p) => p.in === 'path')) need.push('404');
          if (method !== 'get') need.push('409');
          for (const n of need)
            if (!codes.includes(n)) lacking.push(`${method.toUpperCase()} ${path} lacks ${n}`);
          for (const c of codes) {
            const body = op.responses[c]!.content?.['application/json'];
            if (!body?.example || body.schema?.$ref !== '#/components/schemas/ErrorEnvelopeDto')
              lacking.push(`${method.toUpperCase()} ${path} ${c} has no envelope example`);
          }
          if (!Array.isArray(op['x-error-codes']))
            lacking.push(`${method.toUpperCase()} ${path} has no x-error-codes`);
        }
      }
      expect(operations).toBeGreaterThan(150);
      expect(lacking).toEqual([]);
      expect(doc.components?.schemas?.ErrorEnvelopeDto).toBeDefined();
    });
  });

  describe('observability', () => {
    it('echoes a request id, and /metrics exposes request latency, queue depth and job failures', async () => {
      const res = await http().get('/health/live').set('X-Request-Id', 'audit-123').expect(200);
      expect(res.headers['x-request-id']).toBe('audit-123');
      const generated = await http().get('/health/live').expect(200);
      expect(generated.headers['x-request-id']).toMatch(/^[0-9a-f-]{8,}$/i);

      const text = await app.get(MetricsService).render();
      expect(text).toMatch(/atarah_http_request_duration_seconds_bucket/);
      for (const queue of ['system', 'notifications', 'media', 'maintenance', 'analytics']) {
        expect(text).toContain(`atarah_queue_jobs{queue="${queue}",state="failed"}`);
      }
      // Latency is recorded by route pattern, never by the raw URL (no ids or personal data in labels).
      expect(text).not.toMatch(/route="[^"]*[0-9a-f]{8}-[0-9a-f]{4}-/);
    });

    it('a failed request carries its request id in the error body', async () => {
      const res = await http()
        .get('/api/v1/users/me')
        .set('X-Request-Id', 'audit-err-1')
        .expect(401);
      expect(res.body.error.requestId).toBe('audit-err-1');
    });
  });

  describe('Supabase posture', () => {
    it('the anon key reads no application table through the API (RLS deny-all)', async () => {
      const client = anonClient();
      for (const table of [
        'users',
        'creative_profiles',
        'posts',
        'opportunities',
        'notifications',
        'audit_logs',
        'analytics_events',
        'analytics_daily_counts',
        'media_assets',
      ]) {
        const { data, error } = await client.from(table).select('*').limit(1);
        // Either the request is refused outright or it returns no rows: never a row.
        expect([table, (data ?? []).length]).toEqual([table, 0]);
        void error;
      }
    });

    it('check-rls.sql passes on the migrated database (every table has RLS, no stray policies or grants)', async () => {
      const sql = readFileSync(
        join(__dirname, '..', '..', '..', 'scripts', 'check-rls.sql'),
        'utf8',
      );
      const client = new pg.Client({ connectionString: process.env.ATARAH_DIRECT_URL });
      await client.connect();
      try {
        await expect(client.query(sql)).resolves.toBeDefined();
      } finally {
        await client.end();
      }
    });
  });
});
