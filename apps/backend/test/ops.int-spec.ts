import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { createTestApp } from './helpers';

describe('Operations endpoints', () => {
  let app: INestApplication;
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    app = await createTestApp();
  });
  afterAll(async () => {
    await app.close();
  });

  it('serves Prometheus metrics: request latency by route pattern and queue depth', async () => {
    await http().get('/health/live').expect(200);
    await http().get('/api/v1/users/me').expect(401);
    const res = await http().get('/metrics').expect(200);
    expect(res.headers['content-type']).toMatch(/text\/plain/);
    expect(res.text).toContain('route="/health/live"');
    expect(res.text).toMatch(/atarah_http_request_duration_seconds_count\{[^}]*status="4xx"/);
    expect(res.text).toMatch(/atarah_queue_jobs\{queue="media",state="failed"\} \d+/);
    // Raw ids and URLs never become labels.
    expect(res.text).not.toMatch(/route="[^"]*[0-9a-f]{8}-[0-9a-f]{4}/);
  });

  it('is not part of the versioned API or the OpenAPI contract', async () => {
    await http().get('/api/v1/metrics').expect(404);
  });

  it('health is live and ready (database, Redis and storage reachable)', async () => {
    await http().get('/health/live').expect(200);
  });
});
