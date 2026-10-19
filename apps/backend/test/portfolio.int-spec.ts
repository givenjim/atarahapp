import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import { StorageService } from '../src/storage/storage.service';
import { adminSignIn, bearer, createTestApp, loginMember, makeUser, uniq } from './helpers';

// Each test signs up and sets up several members (password hashing, onboarding), so allow more than 5 s.
jest.setTimeout(120_000);

describe('Portfolio, skills, experience, achievements, services and moderation (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];
  const keyPrefix = `portfolio-test/${uniq()}`;

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
    Object.assign(app.get(StorageService), {
      signedDownloadUrl: async (_b: string, key: string) => `https://signed.test/${key}`,
      remove: async () => undefined,
    });
  });
  afterAll(async () => {
    await prisma.notification.deleteMany({ where: { userId: { in: users } } });
    await prisma.user.deleteMany({ where: { id: { in: users } } });
    await prisma.mediaAsset.deleteMany({ where: { objectKey: { startsWith: keyPrefix } } });
    await app.close();
  });

  interface Member {
    id: string;
    token: string;
    handle: string;
  }

  async function member(name = 'Nia Wairimu'): Promise<Member> {
    const { user, email } = await makeUser(app, { fullName: name });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const handle = `m_${uniq().replace(/-/g, '_')}`;
    const patch = (b: object) =>
      http()
        .patch('/api/v1/me/onboarding')
        .set(...bearer(token))
        .send(b)
        .expect(200);
    const animation = await prisma.discipline.findFirstOrThrow({ where: { name: 'Animation' } });
    const nbi = await prisma.county.findFirstOrThrow({ where: { code: 'NBI' } });
    const skills = await prisma.skill.findMany({ take: 3 });
    await patch({ step: 'DISCIPLINE', disciplineId: animation.id });
    await patch({ step: 'SKILLS', skillIds: skills.map((s) => s.id) });
    await patch({ step: 'LOCATION', countyId: nbi.id, town: 'Kilimani' });
    await patch({ step: 'BASICS', handle, bio: 'Illustrator and 2D animator in Nairobi.' });
    await http()
      .post('/api/v1/me/onboarding/complete')
      .set(...bearer(token))
      .expect(200);
    return { id: user.id, token, handle };
  }

  const as = (t?: string) => ({
    get: (p: string) => {
      const r = http().get(`/api/v1${p}`);
      return t ? r.set(...bearer(t)) : r;
    },
    post: (p: string, b: object = {}) => {
      const r = http().post(`/api/v1${p}`).send(b);
      return t ? r.set(...bearer(t)) : r;
    },
    patch: (p: string, b: object) => {
      const r = http().patch(`/api/v1${p}`).send(b);
      return t ? r.set(...bearer(t)) : r;
    },
    put: (p: string, b: object) => {
      const r = http().put(`/api/v1${p}`).send(b);
      return t ? r.set(...bearer(t)) : r;
    },
    del: (p: string) => {
      const r = http().delete(`/api/v1${p}`);
      return t ? r.set(...bearer(t)) : r;
    },
  });

  const connect = async (a: Member, b: Member) => {
    const sent = (await as(a.token).post(`/creatives/${b.handle}/connect`).expect(200)).body.data;
    await as(b.token).post(`/connections/${sent.id}/accept`).expect(200);
  };

  /** A finished upload, as the media pipeline leaves it. */
  async function media(
    owner: Member,
    over: Partial<{
      kind: 'IMAGE' | 'VIDEO' | 'AUDIO' | 'DOCUMENT';
      bucket: 'PUBLIC' | 'PRIVATE';
      status: any;
    }> = {},
  ) {
    const kind = over.kind ?? 'IMAGE';
    const key = `${keyPrefix}/${uniq()}`;
    const row = await prisma.mediaAsset.create({
      data: {
        ownerId: owner.id,
        kind,
        bucket: over.bucket ?? 'PUBLIC',
        objectKey: key,
        mimeType: kind === 'IMAGE' ? 'image/jpeg' : kind === 'VIDEO' ? 'video/mp4' : 'audio/mpeg',
        sizeBytes: 1000,
        status: over.status ?? 'READY',
        variants: kind === 'IMAGE' ? { '600': `${key}-600` } : undefined,
      },
    });
    return row.id;
  }

  /** A published project with one image. */
  async function published(m: Member, over: Record<string, unknown> = {}) {
    const created = (await as(m.token).post('/me/projects', { title: 'Mama Mboga' }).expect(201))
      .body.data;
    const mediaId = await media(m);
    await as(m.token)
      .patch(`/me/projects/${created.id}`, { mediaIds: [mediaId], ...over })
      .expect(200);
    await as(m.token).post(`/me/projects/${created.id}/publish`).expect(200);
    return created.id as string;
  }

  const setSection = (m: Member, section: string, visibility: string) =>
    as(m.token).patch('/me/passport/visibility', { section, visibility }).expect(200);

  describe('projects', () => {
    it('autosaves a draft, refuses to publish an empty one, and publishes once it has something to show', async () => {
      const m = await member();
      const draft = (await as(m.token).post('/me/projects', {}).expect(201)).body.data;
      expect(draft).toMatchObject({ title: '', status: 'DRAFT', media: [], hidden: false });

      const saved = (
        await as(m.token)
          .patch(`/me/projects/${draft.id}`, {
            title: 'Mama Mboga',
            role: 'Lead animator',
            client: 'Kaka Studios',
            projectDate: '2026-03-14',
            category: 'MEDIA',
            description: 'A short film.',
            outcome: 'Shown at three festivals.',
          })
          .expect(200)
      ).body.data;
      expect(saved).toMatchObject({
        title: 'Mama Mboga',
        role: 'Lead animator',
        projectDate: '2026-03-14',
        category: 'MEDIA',
        status: 'DRAFT',
      });

      // Title and description are there but there is nothing to show and the description is short.
      await as(m.token).post(`/me/projects/${draft.id}/publish`).expect(400);

      const file = await media(m);
      await as(m.token)
        .patch(`/me/projects/${draft.id}`, { mediaIds: [file] })
        .expect(200);
      const done = (await as(m.token).post(`/me/projects/${draft.id}/publish`).expect(200)).body
        .data;
      expect(done.status).toBe('PUBLISHED');
      expect(done.publishedAt).not.toBeNull();
      expect(done.media[0]).toMatchObject({ kind: 'IMAGE', status: 'READY' });
      expect(done.media[0].url).toContain('signed.test');

      // The first published project completes the "Add your first project" step.
      const profile = (await as(m.token).get('/me/profile').expect(200)).body.data;
      expect(profile.completion.items.find((i: any) => i.key === 'project').done).toBe(true);
    });

    it('lists the owner’s drafts and published projects separately', async () => {
      const m = await member();
      const id = await published(m);
      await as(m.token).post('/me/projects', { title: 'Draft one' }).expect(201);
      const all = (await as(m.token).get('/me/projects').expect(200)).body.data;
      expect(all).toHaveLength(2);
      const drafts = (await as(m.token).get('/me/projects?listFilter=DRAFTS').expect(200)).body
        .data;
      expect(drafts.map((p: any) => p.title)).toEqual(['Draft one']);
      const pub = (await as(m.token).get('/me/projects?listFilter=PUBLISHED').expect(200)).body
        .data;
      expect(pub.map((p: any) => p.id)).toEqual([id]);
    });

    it('keeps a published project complete: edits cannot empty it', async () => {
      const m = await member();
      const id = await published(m);
      await as(m.token).patch(`/me/projects/${id}`, { title: ' ' }).expect(400);
      await as(m.token).patch(`/me/projects/${id}`, { mediaIds: [] }).expect(400);
      await as(m.token).patch(`/me/projects/${id}`, { title: 'Mama Mboga II' }).expect(200);
    });

    it('only accepts files that are yours, public, finished enough and of a project kind', async () => {
      const m = await member();
      const other = await member('Otieno Ouma');
      const id = (await as(m.token).post('/me/projects', { title: 'Files' }).expect(201)).body.data
        .id;
      const patch = (mediaIds: string[]) => as(m.token).patch(`/me/projects/${id}`, { mediaIds });

      await patch([await media(other)]).expect(400); // someone else's
      await patch([await media(m, { bucket: 'PRIVATE' })]).expect(400);
      await patch([await media(m, { status: 'REJECTED' })]).expect(400);
      await patch([await media(m, { kind: 'DOCUMENT' })]).expect(400);
      await patch([randomUuid()]).expect(400); // does not exist: same answer as "not yours"

      const many: string[] = [];
      for (let i = 0; i < 11; i++) many.push(await media(m));
      await patch(many).expect(400); // more than 10 is refused by validation
      await patch(many.slice(0, 10)).expect(200);

      // A file still uploading may be attached to a draft but blocks publishing.
      const pending = await media(m, { status: 'PROCESSING' });
      await patch([pending]).expect(200);
      await as(m.token).post(`/me/projects/${id}/publish`).expect(409);
    });

    it('does not let members touch each other’s projects, and answers 404 as if they did not exist', async () => {
      const a = await member();
      const b = await member('Otieno Ouma');
      const id = await published(a);
      await as(b.token).get(`/me/projects/${id}`).expect(404);
      await as(b.token).patch(`/me/projects/${id}`, { title: 'Mine now' }).expect(404);
      await as(b.token).post(`/me/projects/${id}/publish`).expect(404);
      await as(b.token).del(`/me/projects/${id}`).expect(404);
      await as(b.token).post(`/me/projects/${id}/collaborators`, { name: 'Sneaky' }).expect(404);
      await as().get('/me/projects').expect(401);
      await as().post('/me/projects', {}).expect(401);
    });

    it('validates fields, links and featured limits', async () => {
      const m = await member();
      const id = (await as(m.token).post('/me/projects', { title: 'Checks' }).expect(201)).body.data
        .id;
      await as(m.token).patch(`/me/projects/${id}`, { projectDate: '2026-02-30' }).expect(400);
      await as(m.token).patch(`/me/projects/${id}`, { projectDate: 'last week' }).expect(400);
      await as(m.token)
        .patch(`/me/projects/${id}`, { links: [{ label: 'Site', url: 'http://example.com' }] })
        .expect(400);
      await as(m.token)
        .patch(`/me/projects/${id}`, { skillIds: [randomUuid()] })
        .expect(400);
      await as(m.token).patch(`/me/projects/${id}`, { disciplineId: randomUuid() }).expect(400);
      await as(m.token).patch(`/me/projects/${id}`, { category: 'SCULPTURE' }).expect(400);
      // YouTube and Vimeo play through the embed; anything else does not.
      const res = await as(m.token)
        .patch(`/me/projects/${id}`, {
          links: [
            { label: 'Film', url: 'https://youtu.be/dQw4w9WgXcQ' },
            { label: 'Reel', url: 'https://vimeo.com/123456789' },
            { label: 'Site', url: 'https://example.com/work' },
            { label: 'Film again', url: 'https://youtu.be/dQw4w9WgXcQ' },
          ],
        })
        .expect(200);
      expect(res.body.data.links.map((l: any) => l.embedUrl)).toEqual([
        'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
        'https://player.vimeo.com/video/123456789',
        null,
      ]);

      for (let i = 0; i < 3; i++) {
        const p = (
          await as(m.token)
            .post('/me/projects', { title: `F${i}` })
            .expect(201)
        ).body.data;
        await as(m.token).patch(`/me/projects/${p.id}`, { featured: true }).expect(200);
      }
      await as(m.token).patch(`/me/projects/${id}`, { featured: true }).expect(409);
    });

    it('deleting a project removes it everywhere and drops completion', async () => {
      const m = await member();
      const id = await published(m);
      expect(
        (await as(m.token).get('/me/profile')).body.data.completion.next.map((i: any) => i.key),
      ).not.toContain('project');
      await as(m.token).del(`/me/projects/${id}`).expect(204);
      await as(m.token).get(`/me/projects/${id}`).expect(404);
      await as().get(`/creatives/${m.handle}/projects/${id}`).expect(404);
      const profile = (await as(m.token).get('/me/profile')).body.data;
      expect(profile.completion.items.find((i: any) => i.key === 'project').done).toBe(false);
    });
  });

  describe('visibility: what another account sees changes with the settings', () => {
    it('applies the Portfolio section and each project’s own audience, for every kind of viewer', async () => {
      const owner = await member();
      const stranger = await member('Stranger Danger');
      const friend = await member('Friendly Face');
      await connect(owner, friend);

      const open = await published(owner, { visibility: 'PUBLIC', title: 'Open work' });
      const membersOnly = await published(owner, { visibility: 'MEMBERS', title: 'Members work' });
      const secret = await published(owner, { visibility: 'PRIVATE', title: 'Private work' });
      await as(owner.token).post('/me/projects', { title: 'Unfinished' }).expect(201); // a draft

      const seen = async (t?: string, q = '') =>
        (await as(t).get(`/creatives/${owner.handle}/projects${q}`).expect(200)).body.data
          .map((p: any) => p.id)
          .sort();
      const ids = (...a: string[]) => [...a].sort();

      // Section PUBLIC (default): each project's own audience decides.
      expect(await seen()).toEqual(ids(open));
      expect(await seen(stranger.token)).toEqual(ids(open, membersOnly));
      expect(await seen(friend.token)).toEqual(ids(open, membersOnly));
      expect(await seen(owner.token)).toEqual(ids(open, membersOnly, secret)); // never the draft

      // Section MEMBERS: anonymous visitors lose the whole portfolio.
      await setSection(owner, 'PORTFOLIO', 'MEMBERS');
      await as().get(`/creatives/${owner.handle}/projects`).expect(404);
      expect(await seen(stranger.token)).toEqual(ids(open, membersOnly));

      // Section PRIVATE: everyone but the owner loses it, even the connection.
      await setSection(owner, 'PORTFOLIO', 'PRIVATE');
      await as(stranger.token).get(`/creatives/${owner.handle}/projects`).expect(404);
      await as(friend.token).get(`/creatives/${owner.handle}/projects`).expect(404);
      await as(friend.token).get(`/creatives/${owner.handle}/projects/${open}`).expect(404);
      expect(await seen(owner.token)).toEqual(ids(open, membersOnly, secret));

      // The owner can preview as the public or as members (and only the owner can).
      await setSection(owner, 'PORTFOLIO', 'PUBLIC');
      expect(await seen(owner.token, '?previewAs=PUBLIC')).toEqual(ids(open));
      expect(await seen(owner.token, '?previewAs=MEMBERS')).toEqual(ids(open, membersOnly));
      await as(stranger.token)
        .get(`/creatives/${owner.handle}/projects?previewAs=PUBLIC`)
        .expect(403);
    });

    it('gives a single project the same rules as the list, and reports counts on the profile', async () => {
      const owner = await member();
      const stranger = await member('Stranger Danger');
      const membersOnly = await published(owner, { visibility: 'MEMBERS' });
      await as().get(`/creatives/${owner.handle}/projects/${membersOnly}`).expect(404);
      const got = await as(stranger.token)
        .get(`/creatives/${owner.handle}/projects/${membersOnly}`)
        .expect(200);
      expect(got.body.data.hiddenReason).toBeNull();

      const asStranger = (await as(stranger.token).get(`/creatives/${owner.handle}`)).body.data;
      expect(asStranger.portfolioCount).toBe(1);
      const asAnon = (await as().get(`/creatives/${owner.handle}`)).body.data;
      expect(asAnon.portfolioCount).toBe(0);
      await setSection(owner, 'PORTFOLIO', 'PRIVATE');
      const locked = (await as(stranger.token).get(`/creatives/${owner.handle}`)).body.data;
      expect(locked.portfolioCount).toBeNull();
      expect(locked.lockedSections).toContain('PORTFOLIO');
    });

    it('filters by category and featured', async () => {
      const owner = await member();
      await published(owner, { category: 'MEDIA' });
      const featured = await published(owner, { category: 'PUBLICATION', featured: true });
      const media = (await as().get(`/creatives/${owner.handle}/projects?category=MEDIA`)).body
        .data;
      expect(media).toHaveLength(1);
      const only = (await as().get(`/creatives/${owner.handle}/projects?featuredOnly=true`)).body
        .data;
      expect(only.map((p: any) => p.id)).toEqual([featured]);
      // Featured projects come first.
      const all = (await as().get(`/creatives/${owner.handle}/projects`)).body.data;
      expect(all[0].id).toBe(featured);
    });

    it('applies Skills, Experience (with achievements) and Services sections to their own endpoints', async () => {
      const owner = await member();
      const stranger = await member('Stranger Danger');
      await as(owner.token)
        .post('/me/experience', {
          title: 'Animator',
          organisation: 'Kaka Studios',
          startDate: '2024-01-01',
          current: true,
        })
        .expect(201);
      await as(owner.token)
        .post('/me/achievements', { type: 'AWARD', title: 'Best Short' })
        .expect(201);
      await as(owner.token)
        .post('/me/services', { title: 'Logo animation', priceType: 'FIXED', priceMin: 15000 })
        .expect(201);

      // Defaults: skills and services PUBLIC, experience MEMBERS.
      await as().get(`/creatives/${owner.handle}/skills`).expect(200);
      await as().get(`/creatives/${owner.handle}/services`).expect(200);
      await as().get(`/creatives/${owner.handle}/experience`).expect(404);
      await as().get(`/creatives/${owner.handle}/achievements`).expect(404);
      expect(
        (await as(stranger.token).get(`/creatives/${owner.handle}/experience`)).body.data,
      ).toHaveLength(1);
      expect(
        (await as(stranger.token).get(`/creatives/${owner.handle}/achievements`)).body.data,
      ).toHaveLength(1);

      await setSection(owner, 'EXPERIENCE', 'PUBLIC');
      await as().get(`/creatives/${owner.handle}/experience`).expect(200);
      await setSection(owner, 'EXPERIENCE', 'PRIVATE');
      await as(stranger.token).get(`/creatives/${owner.handle}/experience`).expect(404);
      await as(stranger.token).get(`/creatives/${owner.handle}/achievements`).expect(404);
      await setSection(owner, 'SERVICES', 'MEMBERS');
      await as().get(`/creatives/${owner.handle}/services`).expect(404);
      await setSection(owner, 'SKILLS', 'PRIVATE');
      await as(stranger.token).get(`/creatives/${owner.handle}/skills`).expect(404);
      // Owner always sees their own.
      await as(owner.token).get(`/creatives/${owner.handle}/skills`).expect(200);
    });
  });

  describe('collaborators', () => {
    it('tags a member who must accept, shows free-text names at once, and lets the member leave', async () => {
      const owner = await member();
      const friend = await member('Wanjiru Kamau');
      const id = await published(owner);

      const tagged = (
        await as(owner.token)
          .post(`/me/projects/${id}/collaborators`, { userId: friend.id, role: 'Sound design' })
          .expect(201)
      ).body.data;
      expect(tagged.collaborators).toHaveLength(1);
      expect(tagged.collaborators[0]).toMatchObject({
        name: 'Wanjiru Kamau',
        status: 'PENDING',
        handle: friend.handle,
      });
      await as(owner.token)
        .post(`/me/projects/${id}/collaborators`, { userId: friend.id })
        .expect(409);
      await as(owner.token)
        .post(`/me/projects/${id}/collaborators`, { userId: owner.id })
        .expect(400);
      await as(owner.token)
        .post(`/me/projects/${id}/collaborators`, { userId: friend.id, name: 'Both' })
        .expect(400);
      await as(owner.token)
        .post(`/me/projects/${id}/collaborators`, { name: 'Baraka Mwangi', role: 'Voice' })
        .expect(201);

      // The member was told, and the invitation is not on the public project yet.
      const note = await prisma.notification.findFirstOrThrow({ where: { userId: friend.id } });
      expect(note).toMatchObject({ category: 'PROFILE', deepLink: '/portfolio' });
      const publicView = (await as().get(`/creatives/${owner.handle}/projects/${id}`)).body.data;
      expect(publicView.collaborators.map((c: any) => c.name)).toEqual(['Baraka Mwangi']);

      const mine = (await as(friend.token).get('/me/collaborations').expect(200)).body.data;
      expect(mine).toHaveLength(1);
      expect(mine[0]).toMatchObject({ status: 'PENDING', projectId: id, role: 'Sound design' });

      // Only the tagged member can answer.
      await as(owner.token).post(`/me/collaborations/${mine[0].id}/accept`).expect(404);
      await as(friend.token).post(`/me/collaborations/${mine[0].id}/accept`).expect(200);
      const after = (await as().get(`/creatives/${owner.handle}/projects/${id}`)).body.data;
      expect(after.collaborators.map((c: any) => c.name).sort()).toEqual([
        'Baraka Mwangi',
        'Wanjiru Kamau',
      ]);

      await as(friend.token).del(`/me/collaborations/${mine[0].id}`).expect(204);
      const left = (await as().get(`/creatives/${owner.handle}/projects/${id}`)).body.data;
      expect(left.collaborators.map((c: any) => c.name)).toEqual(['Baraka Mwangi']);
      await as(friend.token).post(`/me/collaborations/${mine[0].id}/accept`).expect(409);

      // The owner can tag them again, and remove a collaborator.
      await as(owner.token)
        .post(`/me/projects/${id}/collaborators`, { userId: friend.id })
        .expect(201);
      const own = (await as(owner.token).get(`/me/projects/${id}`)).body.data;
      const baraka = own.collaborators.find((c: any) => c.name === 'Baraka Mwangi');
      const removed = (
        await as(owner.token).del(`/me/projects/${id}/collaborators/${baraka.id}`).expect(200)
      ).body.data;
      expect(removed.collaborators.map((c: any) => c.name)).toEqual(['Wanjiru Kamau']);
    });

    it('finds members to tag by name or handle, never yourself', async () => {
      const owner = await member('Searcher Person');
      const friend = await member(`Findable${uniq().replace(/-/g, '')}`);
      const byName = (await as(owner.token).get(`/members/search?q=Findable`).expect(200)).body
        .data;
      expect(byName.map((h: any) => h.userId)).toContain(friend.id);
      const byHandle = (await as(owner.token).get(`/members/search?q=${friend.handle}`).expect(200))
        .body.data;
      expect(byHandle.map((h: any) => h.handle)).toContain(friend.handle);
      const self = (await as(owner.token).get(`/members/search?q=Searcher`).expect(200)).body.data;
      expect(self.map((h: any) => h.userId)).not.toContain(owner.id);
      await as(owner.token).get('/members/search?q=a').expect(400);
      await as().get('/members/search?q=Findable').expect(401);
    });
  });

  describe('skills', () => {
    it('adds, rates and removes skills, counting the published projects that use each', async () => {
      const m = await member();
      const skills = (await as(m.token).get('/me/skills').expect(200)).body.data;
      expect(skills).toHaveLength(3);
      expect(skills.every((s: any) => s.source === 'SELF_DECLARED' && s.projectCount === 0)).toBe(
        true,
      );

      const first = skills[0];
      const rated = (
        await as(m.token).put(`/me/skills/${first.id}`, { level: 'ADVANCED' }).expect(200)
      ).body.data;
      expect(rated).toMatchObject({ id: first.id, level: 'ADVANCED' });
      await as(m.token).put(`/me/skills/${first.id}`, { level: 'MASTER' }).expect(400);

      const extra = await prisma.skill.findFirstOrThrow({
        where: { id: { notIn: skills.map((s: any) => s.id) }, isActive: true },
      });
      const added = (
        await as(m.token).put(`/me/skills/${extra.id}`, { level: 'BEGINNER' }).expect(200)
      ).body.data;
      expect(added.name).toBe(extra.name);

      const id = await published(m, { skillIds: [first.id] });
      const counted = (await as(m.token).get('/me/skills')).body.data.find(
        (s: any) => s.id === first.id,
      );
      expect(counted.projectCount).toBe(1);
      expect((await as().get(`/creatives/${m.handle}/projects/${id}`)).body.data.skills[0].id).toBe(
        first.id,
      );

      await as(m.token).del(`/me/skills/${extra.id}`).expect(204);
      await as(m.token).del(`/me/skills/${extra.id}`).expect(404);
      await as(m.token).put(`/me/skills/${randomUuid()}`, { level: 'EXPERT' }).expect(404);
    });

    it('keeps a verified skill', async () => {
      const m = await member();
      const skill = (await as(m.token).get('/me/skills')).body.data[0];
      await prisma.creativeSkill.updateMany({
        where: { skillId: skill.id, profile: { userId: m.id } },
        data: { source: 'VERIFIED' },
      });
      await as(m.token).del(`/me/skills/${skill.id}`).expect(409);
    });
  });

  describe('experience and achievements', () => {
    it('validates dates, orders newest first and shows the current role first', async () => {
      const m = await member();
      const add = (b: object) => as(m.token).post('/me/experience', b);
      const base = { title: 'Animator', organisation: 'Kaka Studios', startDate: '2022-01-01' };

      await add({ ...base, current: false }).expect(400); // ended, but no end date
      await add({ ...base, current: true, endDate: '2023-01-01' }).expect(400);
      await add({ ...base, current: false, endDate: '2021-01-01' }).expect(400);
      await add({ ...base, startDate: '2022-13-01', current: true }).expect(400);

      const old = (await add({ ...base, current: false, endDate: '2023-01-01' }).expect(201)).body
        .data;
      await add({
        ...base,
        title: 'Senior animator',
        startDate: '2023-02-01',
        current: true,
      }).expect(201);
      const list = (await as(m.token).get('/me/experience')).body.data;
      expect(list.map((e: any) => e.title)).toEqual(['Senior animator', 'Animator']);

      const changed = (
        await as(m.token)
          .patch(`/me/experience/${old.id}`, { endDate: '', current: true })
          .expect(200)
      ).body.data;
      expect(changed).toMatchObject({ current: true, endDate: null });
      await as(m.token).patch(`/me/experience/${old.id}`, { current: false }).expect(400);

      const profile = (await as(m.token).get('/me/profile')).body.data;
      expect(profile.completion.items.find((i: any) => i.key === 'experience').done).toBe(true);
      await as(m.token).del(`/me/experience/${old.id}`).expect(204);
      await as(m.token).del(`/me/experience/${old.id}`).expect(404);
    });

    it('does not let members change each other’s experience, achievements or services', async () => {
      const a = await member();
      const b = await member('Otieno Ouma');
      const exp = (
        await as(a.token)
          .post('/me/experience', {
            title: 'Animator',
            organisation: 'Studio',
            startDate: '2022-01-01',
            current: true,
          })
          .expect(201)
      ).body.data;
      const ach = (
        await as(a.token).post('/me/achievements', { type: 'AWARD', title: 'Prize' }).expect(201)
      ).body.data;
      const svc = (
        await as(a.token)
          .post('/me/services', { title: 'Logos', priceType: 'ON_REQUEST' })
          .expect(201)
      ).body.data;
      await as(b.token).patch(`/me/experience/${exp.id}`, { title: 'Xx' }).expect(404);
      await as(b.token).del(`/me/experience/${exp.id}`).expect(404);
      await as(b.token).patch(`/me/achievements/${ach.id}`, { title: 'Xx' }).expect(404);
      await as(b.token).del(`/me/achievements/${ach.id}`).expect(404);
      await as(b.token).patch(`/me/services/${svc.id}`, { title: 'Xx' }).expect(404);
      await as(b.token).del(`/me/services/${svc.id}`).expect(404);
    });

    it('adds, edits and deletes manual achievements, and leaves Atarah’s own alone', async () => {
      const m = await member();
      const created = (
        await as(m.token)
          .post('/me/achievements', {
            type: 'CERTIFICATE',
            title: 'Motion basics',
            issuer: 'Skill school',
            achievedOn: '2026-05-01',
            url: 'https://example.com/cert',
          })
          .expect(201)
      ).body.data;
      expect(created).toMatchObject({ source: 'MANUAL', achievedOn: '2026-05-01' });
      await as(m.token)
        .post('/me/achievements', { type: 'AWARD', title: 'Bad link', url: 'http://x.co' })
        .expect(400);
      const edited = (
        await as(m.token)
          .patch(`/me/achievements/${created.id}`, { url: '', type: 'AWARD' })
          .expect(200)
      ).body.data;
      expect(edited).toMatchObject({ url: null, type: 'AWARD' });

      const system = await prisma.achievement.create({
        data: {
          profileId: (await prisma.creativeProfile.findUniqueOrThrow({ where: { userId: m.id } }))
            .id,
          type: 'CERTIFICATE',
          title: 'Skill Labs: Colour',
          source: 'SYSTEM',
        },
      });
      await as(m.token).patch(`/me/achievements/${system.id}`, { title: 'Edited' }).expect(409);
      await as(m.token).del(`/me/achievements/${system.id}`).expect(409);
      await as(m.token).del(`/me/achievements/${created.id}`).expect(204);
    });
  });

  describe('services', () => {
    it('stores prices in shillings, checks them by pricing type, and keeps them profile-only', async () => {
      const m = await member();
      const add = (b: object) => as(m.token).post('/me/services', b);
      await add({ title: 'Logo animation', priceType: 'FIXED' }).expect(400);
      await add({ title: 'Storyboards', priceType: 'RANGE', priceMin: 5000 }).expect(400);
      await add({
        title: 'Storyboards',
        priceType: 'RANGE',
        priceMin: 9000,
        priceMax: 5000,
      }).expect(400);
      await add({ title: 'Storyboards', priceType: 'FIXED', priceMin: -1 }).expect(400);

      const fixed = (
        await add({ title: 'Logo animation', priceType: 'FIXED', priceMin: 15000 }).expect(201)
      ).body.data;
      expect(fixed).toMatchObject({ priceMin: 15000, priceMax: null, status: 'PROFILE_ONLY' });
      const row = await prisma.profileService.findUniqueOrThrow({ where: { id: fixed.id } });
      expect(row.priceMin).toBe(1_500_000); // minor units in the database

      const range = (
        await add({
          title: 'Storyboards',
          priceType: 'RANGE',
          priceMin: 5000,
          priceMax: 9000,
        }).expect(201)
      ).body.data;
      expect(range).toMatchObject({ priceMin: 5000, priceMax: 9000 });
      const request = (
        await add({ title: 'Custom', priceType: 'ON_REQUEST', priceMin: 100 }).expect(201)
      ).body.data;
      expect(request).toMatchObject({ priceMin: null, priceMax: null });

      const changed = (
        await as(m.token).patch(`/me/services/${fixed.id}`, { priceType: 'ON_REQUEST' }).expect(200)
      ).body.data;
      expect(changed).toMatchObject({ priceType: 'ON_REQUEST', priceMin: null });
      await as(m.token).patch(`/me/services/${range.id}`, { priceMax: 1000 }).expect(400);
      expect((await as(m.token).get('/me/services')).body.data.map((s: any) => s.title)).toEqual([
        'Logo animation',
        'Storyboards',
        'Custom',
      ]);
      await as(m.token).del(`/me/services/${range.id}`).expect(204);
    });
  });

  describe('moderation', () => {
    it('lets a moderator hide and restore a project with an audit trail, and tells the owner', async () => {
      const owner = await member();
      const stranger = await member('Stranger Danger');
      const id = await published(owner, { title: 'Contentious piece' });
      const mod = await makeUser(app, { roles: ['MODERATOR'] });
      users.push(mod.user.id);
      const modToken = (await adminSignIn(app, mod.email)).session.accessToken;

      // Closed to members and to signed-out callers.
      await as(owner.token).get('/admin/projects').expect(403);
      await as(owner.token)
        .post(`/admin/projects/${id}/hide`, { reason: 'No reason given here' })
        .expect(403);
      await as().get('/admin/projects').expect(401);

      const found = (await as(modToken).get('/admin/projects?q=Contentious').expect(200)).body.data;
      expect(found.map((p: any) => p.id)).toContain(id);
      expect(found.find((p: any) => p.id === id)).toMatchObject({
        ownerHandle: owner.handle,
        hidden: false,
      });

      await as(modToken).post(`/admin/projects/${id}/hide`, { reason: 'no' }).expect(400);
      const hidden = (
        await as(modToken)
          .post(`/admin/projects/${id}/hide`, { reason: 'Uses someone else’s artwork.' })
          .expect(200)
      ).body.data;
      expect(hidden).toMatchObject({ hidden: true, hiddenReason: 'Uses someone else’s artwork.' });
      await as(modToken)
        .post(`/admin/projects/${id}/hide`, { reason: 'Again, for no reason' })
        .expect(409);

      // Gone for everyone else, including the portfolio count; the owner still sees it, with the reason.
      await as(stranger.token).get(`/creatives/${owner.handle}/projects/${id}`).expect(404);
      expect(
        (await as(stranger.token).get(`/creatives/${owner.handle}/projects`)).body.data,
      ).toHaveLength(0);
      expect(
        (await as(stranger.token).get(`/creatives/${owner.handle}`)).body.data.portfolioCount,
      ).toBe(0);
      const own = (await as(owner.token).get(`/me/projects/${id}`).expect(200)).body.data;
      expect(own).toMatchObject({ hidden: true, hiddenReason: 'Uses someone else’s artwork.' });
      const profile = (await as(owner.token).get('/me/profile')).body.data;
      expect(profile.completion.items.find((i: any) => i.key === 'project').done).toBe(false);
      const hiddenOnly = (await as(modToken).get('/admin/projects?hiddenOnly=true').expect(200))
        .body.data;
      expect(hiddenOnly.map((p: any) => p.id)).toContain(id);

      const told = await prisma.notification.findMany({
        where: { userId: owner.id, title: 'A project was hidden' },
      });
      expect(told).toHaveLength(1);
      expect(told[0]!.body).toContain('Uses someone else’s artwork.');

      const restored = (await as(modToken).post(`/admin/projects/${id}/restore`).expect(200)).body
        .data;
      expect(restored).toMatchObject({ hidden: false, hiddenReason: null });
      await as(modToken).post(`/admin/projects/${id}/restore`).expect(409);
      await as(stranger.token).get(`/creatives/${owner.handle}/projects/${id}`).expect(200);

      const audit = await prisma.auditLog.findMany({
        where: { entityType: 'project', entityId: id },
        orderBy: { createdAt: 'asc' },
      });
      expect(audit.map((a) => a.action)).toEqual([
        'portfolio.project.hide',
        'portfolio.project.restore',
      ]);
      expect(audit[0]!.actorId).toBe(mod.user.id);
    });

    it('does not show drafts to moderators', async () => {
      const owner = await member();
      const draft = (
        await as(owner.token).post('/me/projects', { title: 'Secret draft' }).expect(201)
      ).body.data;
      const mod = await makeUser(app, { roles: ['MODERATOR'] });
      users.push(mod.user.id);
      const modToken = (await adminSignIn(app, mod.email)).session.accessToken;
      await as(modToken).get(`/admin/projects/${draft.id}`).expect(404);
      await as(modToken)
        .post(`/admin/projects/${draft.id}/hide`, { reason: 'Not published yet' })
        .expect(404);
    });
  });
});

function randomUuid(): string {
  return crypto.randomUUID();
}
