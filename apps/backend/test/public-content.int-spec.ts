import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { FeatureFlagService } from '../src/feature-flags/feature-flag.service';
import { PrismaService } from '../src/prisma/prisma.service';
import { createTestApp } from './helpers';

describe('Public config and legal text', () => {
  let app: INestApplication;
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    app = await createTestApp();
  });
  afterAll(async () => {
    await app.close();
  });

  it('reports whether Google sign-in is on, without signing in', async () => {
    const flags = app.get(FeatureFlagService);
    await flags.set('google-sign-in', false, { id: '00000000-0000-4000-8000-000000000001' });
    expect((await http().get('/api/v1/config/public').expect(200)).body.data).toEqual({
      googleSignIn: false,
    });
    await flags.set('google-sign-in', true, { id: '00000000-0000-4000-8000-000000000001' });
    expect((await http().get('/api/v1/config/public').expect(200)).body.data.googleSignIn).toBe(
      true,
    );
    await flags.set('google-sign-in', false, { id: '00000000-0000-4000-8000-000000000001' });
  });

  it('serves the seeded Terms and Privacy drafts, labelled as drafts', async () => {
    for (const type of ['TERMS', 'PRIVACY']) {
      const res = await http().get(`/api/v1/legal/${type}`).expect(200);
      expect(res.body.data).toMatchObject({ type, isDraft: true });
      expect(res.body.data.title).toMatch(/DRAFT/);
      expect(res.body.data.body.length).toBeGreaterThan(20);
    }
  });

  it('serves the published version once the owner publishes one', async () => {
    const prisma = app.get(PrismaService);
    const created = await prisma.legalDocument.create({
      data: {
        type: 'TERMS',
        version: '2',
        title: 'Terms of Service',
        body: 'Reviewed text.',
        status: 'PUBLISHED',
      },
    });
    try {
      const res = await http().get('/api/v1/legal/TERMS').expect(200);
      expect(res.body.data).toMatchObject({ version: '2', isDraft: false, body: 'Reviewed text.' });
    } finally {
      // The test database is shared with other suites: remove what this test added, pass or fail.
      await prisma.legalDocument.delete({ where: { id: created.id } });
    }
  });

  it('refuses other document types', async () => {
    await http().get('/api/v1/legal/COMMUNITY_GUIDELINES').expect(400);
    await http().get('/api/v1/legal/nonsense').expect(400);
  });
});
