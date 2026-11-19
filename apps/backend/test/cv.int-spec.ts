import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { CvService } from '../src/cv/cv.service';
import { PdfRenderer } from '../src/cv/pdf-renderer';
import { PrismaService } from '../src/prisma/prisma.service';
import { StorageService } from '../src/storage/storage.service';
import { bearer, createTestApp, deleteUsers, loginMember, makeUser, uniq } from './helpers';

jest.setTimeout(180_000);

const SECRET_BIO = 'Members-only biography that a share link must not show.';

describe('Creative CV / EPK and sharing (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let cv: CvService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];
  const files = new Map<string, Buffer>();

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
    cv = app.get(CvService);
    Object.assign(app.get(StorageService), {
      write: async (_b: string, key: string, body: Buffer) => void files.set(key, body),
      remove: async (_b: string, key: string) => void files.delete(key),
      signedDownloadUrl: async (_b: string, key: string) => {
        if (!files.has(key)) throw new Error('missing');
        return `https://signed.test/${key}`;
      },
    });
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  interface Member {
    id: string;
    token: string;
    handle: string;
    profileId: string;
    publicProject: string;
    privateProject: string;
    verifiedSkill: string;
  }

  async function member(name = 'Nia Wairimu'): Promise<Member> {
    const { user, email } = await makeUser(app, { fullName: name });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const handle = `cv_${uniq().replace(/-/g, '_')}`;
    const profile = await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        displayName: name,
        handle,
        headline: 'Illustrator and animator',
        bio: SECRET_BIO,
        contactShowEmail: true,
      },
    });
    // The bio is members-only: it must stay out of public output unless the member says otherwise.
    await prisma.profileSectionVisibility.create({
      data: { profileId: profile.id, section: 'BIO', visibility: 'MEMBERS' },
    });
    const pub = await prisma.project.create({
      data: {
        profileId: profile.id,
        title: 'Mvua music video',
        role: 'Lead animator',
        status: 'PUBLISHED',
        visibility: 'PUBLIC',
        publishedAt: new Date(),
      },
    });
    const priv = await prisma.project.create({
      data: {
        profileId: profile.id,
        title: 'Unreleased client work',
        status: 'PUBLISHED',
        visibility: 'PRIVATE',
        publishedAt: new Date(),
      },
    });
    const skills = await prisma.skill.findMany({ take: 2, orderBy: { slug: 'asc' } });
    await prisma.creativeSkill.createMany({
      data: [
        { profileId: profile.id, skillId: skills[0]!.id, source: 'VERIFIED' },
        { profileId: profile.id, skillId: skills[1]!.id, source: 'SELF_DECLARED' },
      ],
    });
    return {
      id: user.id,
      token,
      handle,
      profileId: profile.id,
      publicProject: pub.id,
      privateProject: priv.id,
      verifiedSkill: skills[0]!.name,
    };
  }

  const as = (t?: string) => ({
    get: (p: string) => {
      const r = http().get(`/api/v1${p}`);
      return t ? r.set(...bearer(t)) : r;
    },
    put: (p: string, b: object) => {
      const r = http().put(`/api/v1${p}`).send(b);
      return t ? r.set(...bearer(t)) : r;
    },
    post: (p: string, b: object = {}) => {
      const r = http().post(`/api/v1${p}`).send(b);
      return t ? r.set(...bearer(t)) : r;
    },
    del: (p: string) => {
      const r = http().delete(`/api/v1${p}`);
      return t ? r.set(...bearer(t)) : r;
    },
  });

  it('needs a signed-in member', async () => {
    await as().get('/me/creative-cv/CV').expect(401);
    await as().get('/me/creative-cv/formats').expect(401);
  });

  it('lists the four formats and returns defaults with verified marks only from real data', async () => {
    const m = await member();
    const formats = await as(m.token).get('/me/creative-cv/formats').expect(200);
    expect(formats.body.data.map((f: { format: string }) => f.format)).toEqual([
      'CV',
      'BIO',
      'EPK',
      'DECK',
    ]);
    const s = (await as(m.token).get('/me/creative-cv/CV').expect(200)).body.data;
    expect(s.info.label).toBe('Creative CV');
    expect(s.config.sections).toEqual(expect.arrayContaining(['BIO', 'PORTFOLIO', 'SKILLS']));
    // Default selection lists only the public project.
    expect(s.config.projectIds).toEqual([m.publicProject]);
    expect(s.projects.map((p: { id: string }) => p.id).sort()).toEqual(
      [m.publicProject, m.privateProject].sort(),
    );
    expect(s.preview.displayName).toBe('Nia Wairimu');
    expect(s.preview.subtitle).toBe('Creative CV');
    // The members-only bio is withheld from the preview.
    expect(s.preview.summary).toBeNull();
    expect(s.preview.withheld).toContain('BIO');
    const verified = s.preview.skills.filter((k: { verified: boolean }) => k.verified);
    expect(verified.map((k: { name: string }) => k.name)).toEqual([m.verifiedSkill]);
    expect(s.preview.skills).toHaveLength(2);
  });

  it('validates choices: format sections, own published projects, and explicit allow for non-public ones', async () => {
    const m = await member();
    const other = await member('Other Person');
    // BIO format does not list projects.
    await as(m.token)
      .put('/me/creative-cv/BIO', { projectIds: [m.publicProject] })
      .expect(400);
    // Someone else's project.
    await as(m.token)
      .put('/me/creative-cv/CV', { projectIds: [other.publicProject] })
      .expect(400);
    // A section the format cannot show.
    await as(m.token)
      .put('/me/creative-cv/BIO', { sections: ['PORTFOLIO'] })
      .expect(400);
    // Unknown format is a 400 at the route.
    await as(m.token).get('/me/creative-cv/RESUME').expect(400);
    // A private project without the explicit allow is refused...
    await as(m.token)
      .put('/me/creative-cv/CV', { projectIds: [m.publicProject, m.privateProject] })
      .expect(400);
    // ...and accepted with it.
    const ok = await as(m.token)
      .put('/me/creative-cv/CV', {
        projectIds: [m.publicProject, m.privateProject],
        restricted: ['PORTFOLIO'],
      })
      .expect(200);
    expect(ok.body.data.preview.work.map((w: { title: string }) => w.title)).toEqual([
      'Mvua music video',
      'Unreleased client work',
    ]);
  });

  it('includes a members-only section only after the member explicitly allows it', async () => {
    const m = await member();
    const before = (await as(m.token).get('/me/creative-cv/EPK').expect(200)).body.data;
    expect(before.preview.summary).toBeNull();
    const after = (
      await as(m.token)
        .put('/me/creative-cv/EPK', { sections: ['BIO', 'PORTFOLIO'], restricted: ['BIO'] })
        .expect(200)
    ).body.data;
    expect(after.preview.summary).toBe(SECRET_BIO);
    expect(after.preview.withheld).not.toContain('BIO');
  });

  it('builds a PDF in the worker job, stores it privately and hands out a signed link', async () => {
    const m = await member();
    const other = await member('Other Person');
    for (const format of ['CV', 'BIO', 'EPK', 'DECK']) {
      const gen = await as(m.token).post(`/me/creative-cv/${format}/generate`).expect(202);
      expect(gen.body.data.status).toBe('QUEUED');
      // The same request again while one is queued reuses it.
      const again = await as(m.token).post(`/me/creative-cv/${format}/generate`).expect(202);
      expect(again.body.data.id).toBe(gen.body.data.id);

      // The worker's job body (the queue itself is not consumed in tests).
      const built = await cv.build(gen.body.data.id);
      const status = (
        await as(m.token).get(`/me/creative-cv/renders/${gen.body.data.id}`).expect(200)
      ).body.data;
      if (app.get(PdfRenderer).isAvailable()) {
        expect(built.status).toBe('READY');
        expect(status.status).toBe('READY');
        const key = `cv/${m.profileId}/${gen.body.data.id}.pdf`;
        expect(files.get(key)?.subarray(0, 5).toString('latin1')).toBe('%PDF-');
        const dl = await as(m.token)
          .post(`/me/creative-cv/renders/${gen.body.data.id}/download`)
          .expect(200);
        expect(dl.body.data.url).toBe(`https://signed.test/${key}`);
        // Another member cannot see or download it.
        await as(other.token).get(`/me/creative-cv/renders/${gen.body.data.id}`).expect(404);
        await as(other.token)
          .post(`/me/creative-cv/renders/${gen.body.data.id}/download`)
          .expect(404);
      } else {
        // BLOCKED path: no browser on this host. The member is told, nothing is stored.
        expect(built.status).toBe('FAILED');
        expect(status.status).toBe('FAILED');
        expect(status.error).toMatch(/not available/);
        await as(m.token).post(`/me/creative-cv/renders/${gen.body.data.id}/download`).expect(409);
      }
    }
  });

  it('does not offer a download for a build that is not ready', async () => {
    const m = await member();
    const gen = await as(m.token).post('/me/creative-cv/CV/generate').expect(202);
    await as(m.token).post(`/me/creative-cv/renders/${gen.body.data.id}/download`).expect(409);
  });

  it('serves a share link as HTML, filtered by visibility, and answers 404 once revoked or expired', async () => {
    const m = await member();
    const other = await member('Other Person');

    const created = await as(m.token)
      .post('/me/creative-cv/CV/shares', { expiresInDays: 30 })
      .expect(201);
    const { url, id, hint, status } = created.body.data;
    expect(status).toBe('ACTIVE');
    const token = url.split('/cv/')[1] as string;
    expect(url).toBe(`https://atarah.app/${m.handle}/cv/${token}`);
    expect(token.slice(-4)).toBe(hint);

    // Opens in a browser at the share path, without signing in.
    const page = await http().get(`/${m.handle}/cv/${token}`).expect(200);
    expect(page.headers['content-type']).toMatch(/text\/html/);
    expect(page.headers['cache-control']).toBe('no-store');
    expect(page.text).toContain('Nia Wairimu');
    expect(page.text).toContain('Mvua music video');
    expect(page.text).toContain(`${m.verifiedSkill} ✓`);
    // Members-only bio and the private project never appear.
    expect(page.text).not.toContain(SECRET_BIO);
    expect(page.text).not.toContain('Unreleased client work');

    // The handle must match the document, and a made-up token is a 404.
    await http().get(`/${other.handle}/cv/${token}`).expect(404);
    await http()
      .get(`/${m.handle}/cv/${'a'.repeat(43)}`)
      .expect(404);
    await http().get(`/${m.handle}/cv/not-a-token`).expect(404);

    // The list never contains the token itself.
    const list = (await as(m.token).get('/me/creative-cv/CV/shares').expect(200)).body.data;
    expect(list).toHaveLength(1);
    expect(JSON.stringify(list)).not.toContain(token);

    // Only the owner can revoke.
    await as(other.token).del(`/me/creative-cv/shares/${id}`).expect(404);
    await http().get(`/${m.handle}/cv/${token}`).expect(200);

    const revoked = await as(m.token).del(`/me/creative-cv/shares/${id}`).expect(200);
    expect(revoked.body.data.status).toBe('REVOKED');
    const gone = await http().get(`/${m.handle}/cv/${token}`).expect(404);
    expect(gone.text).toContain('not available');
    expect(gone.text).not.toContain('Nia Wairimu');
    // Revoking twice is harmless.
    await as(m.token).del(`/me/creative-cv/shares/${id}`).expect(200);

    // Expiry.
    const second = await as(m.token)
      .post('/me/creative-cv/CV/shares', { expiresInDays: 1 })
      .expect(201);
    const token2 = second.body.data.url.split('/cv/')[1] as string;
    await http().get(`/${m.handle}/cv/${token2}`).expect(200);
    await prisma.documentShareLink.update({
      where: { id: second.body.data.id },
      data: { expiresAt: new Date(Date.now() - 1000) },
    });
    await http().get(`/${m.handle}/cv/${token2}`).expect(404);
    const states = (await as(m.token).get('/me/creative-cv/CV/shares').expect(200)).body.data;
    expect(states.map((s: { status: string }) => s.status).sort()).toEqual(['EXPIRED', 'REVOKED']);
  });

  it('applies a later change of audience to links that already exist', async () => {
    const m = await member();
    await as(m.token)
      .put('/me/creative-cv/CV', { sections: ['BIO'], restricted: ['BIO'] })
      .expect(200);
    const created = await as(m.token).post('/me/creative-cv/CV/shares').expect(201);
    const token = created.body.data.url.split('/cv/')[1] as string;
    expect((await http().get(`/${m.handle}/cv/${token}`).expect(200)).text).toContain(SECRET_BIO);
    // The member withdraws the explicit allow: the same link no longer shows the bio.
    await as(m.token).put('/me/creative-cv/CV', { restricted: [] }).expect(200);
    expect((await http().get(`/${m.handle}/cv/${token}`).expect(200)).text).not.toContain(
      SECRET_BIO,
    );
  });

  it('stops serving links of an account that is no longer active', async () => {
    const m = await member();
    const created = await as(m.token).post('/me/creative-cv/BIO/shares').expect(201);
    const token = created.body.data.url.split('/cv/')[1] as string;
    await http().get(`/${m.handle}/cv/${token}`).expect(200);
    await prisma.user.update({ where: { id: m.id }, data: { status: 'SUSPENDED' } });
    await http().get(`/${m.handle}/cv/${token}`).expect(404);
  });

  it('requires a username to share', async () => {
    const m = await member();
    await prisma.creativeProfile.update({ where: { id: m.profileId }, data: { handle: null } });
    await as(m.token).post('/me/creative-cv/CV/shares').expect(409);
  });

  it('counts generated, shared, downloaded and viewed events without identity or content', async () => {
    const m = await member();
    const since = new Date(Date.now() - 1000);
    const created = await as(m.token).post('/me/creative-cv/DECK/shares').expect(201);
    const token = created.body.data.url.split('/cv/')[1] as string;
    await http().get(`/${m.handle}/cv/${token}`).expect(200);
    await as(m.token).post('/me/creative-cv/DECK/generate').expect(202);
    const count = async (name: string) =>
      Number(
        (
          await prisma.$queryRaw<Array<{ n: bigint }>>`
            SELECT count(*)::bigint AS n FROM analytics_events
            WHERE name = ${name} AND "occurredAt" >= ${since} AND props->>'format' = 'DECK'`
        )[0]!.n,
      );
    // Events are written in the background.
    for (
      let i = 0;
      i < 30 &&
      ((await count('cv_shared')) < 1 ||
        (await count('cv_viewed')) < 1 ||
        (await count('cv_generated')) < 1);
      i++
    ) {
      await new Promise((r) => setTimeout(r, 200));
    }
    expect(await count('cv_shared')).toBeGreaterThanOrEqual(1);
    expect(await count('cv_viewed')).toBeGreaterThanOrEqual(1);
    expect(await count('cv_generated')).toBeGreaterThanOrEqual(1);
    // The view has no actor at all, and no event carries anything but the format.
    const rows = await prisma.$queryRaw<
      Array<{ name: string; actorHash: string | null; props: object }>
    >`
      SELECT name, "actorHash", props FROM analytics_events
      WHERE name LIKE 'cv\_%' AND "occurredAt" >= ${since}`;
    for (const r of rows) expect(Object.keys(r.props)).toEqual(['format']);
    expect(rows.filter((r) => r.name === 'cv_viewed').every((r) => r.actorHash === null)).toBe(
      true,
    );
  });
});
