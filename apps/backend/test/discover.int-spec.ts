import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import { StorageService } from '../src/storage/storage.service';
import { adminSignIn, bearer, createTestApp, loginMember, makeUser, uniq } from './helpers';

// Each test signs up and sets up several members (password hashing, onboarding), so allow more than 5 s.
jest.setTimeout(120_000);

describe('Home, finding creatives, search and articles (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];
  const keyPrefix = `discover-test/${uniq()}`;

  interface Member {
    id: string;
    token: string;
    handle: string;
    name: string;
  }

  interface Options {
    name?: string;
    discipline?: string;
    skills?: string[];
    county?: string;
    finish?: boolean;
  }

  async function member(o: Options = {}): Promise<Member> {
    const name = o.name ?? `Tess ${uniq()}`;
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
    const discipline = await prisma.discipline.findFirstOrThrow({
      where: { name: o.discipline ?? 'Animation' },
    });
    const county = await prisma.county.findFirstOrThrow({ where: { code: o.county ?? 'NBI' } });
    const skills = o.skills
      ? await prisma.skill.findMany({ where: { name: { in: o.skills } } })
      : await prisma.skill.findMany({ take: 2, orderBy: { name: 'asc' } });
    await patch({ step: 'DISCIPLINE', disciplineId: discipline.id });
    await patch({ step: 'SKILLS', skillIds: skills.map((s) => s.id) });
    await patch({ step: 'LOCATION', countyId: county.id, town: 'Kilimani' });
    await patch({ step: 'BASICS', handle, bio: 'Creative in Kenya.' });
    if (o.finish !== false) {
      await http()
        .post('/api/v1/me/onboarding/complete')
        .set(...bearer(token))
        .expect(200);
    }
    return { id: user.id, token, handle, name };
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
    put: (p: string, b: object = {}) => {
      const r = http().put(`/api/v1${p}`).send(b);
      return t ? r.set(...bearer(t)) : r;
    },
    del: (p: string) => {
      const r = http().delete(`/api/v1${p}`);
      return t ? r.set(...bearer(t)) : r;
    },
  });

  const setSection = (m: Member, section: string, visibility: string) =>
    as(m.token).patch('/me/passport/visibility', { section, visibility }).expect(200);

  let editor: { id: string; token: string };
  async function contentAdmin() {
    const { user, email } = await makeUser(app, {
      roles: ['CONTENT_ADMIN'],
      fullName: 'Edith Editor',
    });
    users.push(user.id);
    const token = (await adminSignIn(app, email)).session.accessToken;
    return { id: user.id, token };
  }

  /** A finished upload, as the media pipeline leaves it. */
  async function image(ownerId: string, bucket: 'PUBLIC' | 'PRIVATE' = 'PUBLIC') {
    const key = `${keyPrefix}/${uniq()}`;
    const row = await prisma.mediaAsset.create({
      data: {
        ownerId,
        kind: 'IMAGE',
        bucket,
        objectKey: key,
        mimeType: 'image/jpeg',
        sizeBytes: 1000,
        status: 'READY',
        variants: { '600': `${key}-600`, '1200': `${key}-1200` },
      },
    });
    return row.id;
  }

  /** Writes and publishes an article through the CMS, the way an editor would. */
  async function article(
    over: { title?: string; tags?: string[]; publishAt?: string; publish?: boolean } = {},
  ) {
    const title = over.title ?? `Pricing your work ${uniq()}`;
    const created = (
      await as(editor.token)
        .post('/admin/articles', { title, authorName: 'Kiptoo Langat' })
        .expect(201)
    ).body.data;
    await as(editor.token)
      .patch(`/admin/articles/${created.id}`, {
        summary: 'Clients do not buy hours, they buy usage.',
        tags: over.tags ?? [],
        blocks: [
          { type: 'paragraph', text: 'Start with a day rate that covers your costs.' },
          { type: 'callout', title: 'Rule of thumb', text: 'Quote usage, not hours.' },
        ],
      })
      .expect(200);
    if (over.publish === false) return created as { id: string; slug: string };
    await as(editor.token).post(`/admin/articles/${created.id}/submit`).expect(200);
    const live = (
      await as(editor.token)
        .post(
          `/admin/articles/${created.id}/publish`,
          over.publishAt ? { publishAt: over.publishAt } : {},
        )
        .expect(200)
    ).body.data;
    return live as { id: string; slug: string };
  }

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
    Object.assign(app.get(StorageService), {
      signedDownloadUrl: async (_b: string, key: string) => `https://signed.test/${key}`,
      signedUploadUrl: async () => 'https://signed.test/put',
      remove: async () => undefined,
    });
    editor = await contentAdmin();
  });

  afterAll(async () => {
    await prisma.homeConfig.deleteMany();
    await prisma.article.deleteMany({ where: { createdById: editor.id } });
    await prisma.notification.deleteMany({ where: { userId: { in: users } } });
    await prisma.user.deleteMany({ where: { id: { in: users } } });
    await prisma.mediaAsset.deleteMany({ where: { objectKey: { startsWith: keyPrefix } } });
    await app.close();
  });

  // ---------------------------------------------------------------------------------------------------------
  describe('Home', () => {
    it('is empty and honest for a brand-new member in an empty community', async () => {
      await prisma.article.deleteMany();
      await prisma.homeConfig.deleteMany();
      const me = await member({ name: 'Newcomer Quietly', finish: false });
      // Nobody else has finished onboarding in the test database's own fixtures that this member could be shown
      // except those created by other suites, so only the shape is asserted for creatives.
      const home = (await as(me.token).get('/home').expect(200)).body.data;
      expect(home.firstName).toBe('Newcomer');
      expect(home.article).toBeNull();
      expect(home.recommended).toEqual([]);
      expect(home.unreadNotifications).toBe(0);
      expect(home.unavailable).toEqual([]);
      expect(home.completionPercent).toBeGreaterThanOrEqual(0);
      expect(home.creatives.every((c: { handle: string }) => c.handle !== me.handle)).toBe(true);
    });

    it('needs a signed-in member', async () => {
      await as().get('/home').expect(401);
    });

    it('explains every recommendation and every person it suggests, and counts unread notifications', async () => {
      await prisma.article.deleteMany();
      const me = await member({ name: 'Established Eve', discipline: 'Animation' });
      const sameField = await member({ name: `Sam Field ${uniq()}`, discipline: 'Animation' });
      const otherField = await member({ discipline: 'Music', county: 'MSA' });
      const friend = await member({ discipline: 'Animation' });
      // A friend is already known, so is not suggested.
      const sent = (await as(me.token).post(`/creatives/${friend.handle}/connect`).expect(200)).body
        .data;
      await as(friend.token).post(`/connections/${sent.id}/accept`).expect(200);

      const match = await article({ title: `Animation pricing ${uniq()}`, tags: ['animation'] });
      await article({ title: `Unrelated ${uniq()}`, tags: ['sculpture'] });
      const baseline = await prisma.notification.count({ where: { userId: me.id, readAt: null } });
      await prisma.notification.createMany({
        data: [
          { userId: me.id, category: 'SYSTEM', title: 'One', body: 'one' },
          { userId: me.id, category: 'SYSTEM', title: 'Two', body: 'two', readAt: new Date() },
        ],
      });

      const home = (await as(me.token).get('/home').expect(200)).body.data;
      expect(home.unreadNotifications).toBe(baseline + 1);
      expect(home.recommended).toHaveLength(1);
      expect(home.recommended[0]).toMatchObject({
        id: match.id,
        type: 'ARTICLE',
        path: `/articles/${match.slug}`,
        reason: 'Because you selected Animation',
      });
      const handles = home.creatives.map((c: { handle: string }) => c.handle);
      expect(handles).toContain(sameField.handle);
      expect(handles).toContain(otherField.handle);
      expect(handles).not.toContain(friend.handle);
      expect(handles).not.toContain(me.handle);
      expect(handles.indexOf(sameField.handle)).toBeLessThan(handles.indexOf(otherField.handle));
      const same = home.creatives.find((c: { handle: string }) => c.handle === sameField.handle);
      expect(same.reason).toBe('Also works in Animation');
      expect(home.creatives.every((c: { reason: string | null }) => !!c.reason)).toBe(true);
    });

    it('shows the pinned article, falls back to the newest, and drops one that is archived', async () => {
      await prisma.article.deleteMany();
      await prisma.homeConfig.deleteMany();
      const me = await member();
      const older = await article({ title: `Older ${uniq()}` });
      const newer = await article({ title: `Newer ${uniq()}` });
      const get = async () => (await as(me.token).get('/home').expect(200)).body.data.article;
      expect((await get()).id).toBe(newer.id);

      await as(editor.token).put('/admin/home', { featuredArticleId: older.id }).expect(200);
      expect((await get()).id).toBe(older.id);

      await as(editor.token).post(`/admin/articles/${older.id}/archive`).expect(200);
      expect((await get()).id).toBe(newer.id);
      expect(
        (await as(editor.token).get('/admin/home').expect(200)).body.data.featuredArticleId,
      ).toBeNull();
    });

    it('leaves a section out when it fails instead of failing the page', async () => {
      const me = await member();
      const spy = jest
        .spyOn(prisma.homeConfig, 'findUnique')
        .mockRejectedValueOnce(new Error('boom'));
      const home = (await as(me.token).get('/home').expect(200)).body.data;
      spy.mockRestore();
      expect(home.unavailable).toEqual(['article']);
      expect(home.article).toBeNull();
      expect(home.firstName).toBeTruthy();
    });
  });

  // ---------------------------------------------------------------------------------------------------------
  describe('Finding creatives', () => {
    it('filters by discipline, availability and verification, and reports the total for "Show n results"', async () => {
      const viewer = await member();
      const tag = uniq();
      const a = await member({ name: `Filtered ${tag} A`, discipline: 'Animation' });
      const b = await member({ name: `Filtered ${tag} B`, discipline: 'Music' });
      await as(b.token).patch('/me/profile', { openToCommissions: true }).expect(200);
      const music = await prisma.discipline.findFirstOrThrow({ where: { name: 'Music' } });

      const list = (q: string) => as(viewer.token).get(`/creatives?q=${tag}${q}`).expect(200);
      expect((await list('')).body.meta.total).toBe(2);
      const music1 = await list(`&disciplineId=${music.id}`);
      expect(music1.body.data.map((c: { handle: string }) => c.handle)).toEqual([b.handle]);
      expect(music1.body.meta.total).toBe(1);
      const open = await list('&available=true');
      expect(open.body.data.map((c: { handle: string }) => c.handle)).toEqual([b.handle]);
      expect((await list('&available=false')).body.meta.total).toBe(2);

      // Nobody is verified until verification exists, so the filter honestly finds no one.
      expect((await list('&verified=true')).body.meta.total).toBe(0);
      const profile = await prisma.creativeProfile.findFirstOrThrow({ where: { userId: a.id } });
      await prisma.creativeVerification.create({
        data: { profileId: profile.id, status: 'VERIFIED', verifiedAt: new Date() },
      });
      const verified = await list('&verified=true');
      expect(verified.body.data.map((c: { handle: string }) => c.handle)).toEqual([a.handle]);
      expect(verified.body.data[0].verified).toBe(true);
      expect(music1.body.data[0].verified).toBe(false);
    });

    it('sorts by recent, pages, and never lists the viewer, unfinished profiles or suspended accounts', async () => {
      const viewer = await member({ name: `Viewer Vee ${uniq()}` });
      const tag = uniq();
      const first = await member({ name: `Sorted ${tag} first` });
      const second = await member({ name: `Sorted ${tag} second` });
      const unfinished = await member({ name: `Sorted ${tag} unfinished`, finish: false });
      const suspended = await member({ name: `Sorted ${tag} suspended` });
      await prisma.user.update({ where: { id: suspended.id }, data: { status: 'SUSPENDED' } });

      const recent = (await as(viewer.token).get(`/creatives?q=${tag}&sort=recent`).expect(200))
        .body;
      expect(recent.data.map((c: { handle: string }) => c.handle)).toEqual([
        second.handle,
        first.handle,
      ]);
      const page2 = (
        await as(viewer.token).get(`/creatives?q=${tag}&sort=recent&limit=1&page=2`).expect(200)
      ).body;
      expect(page2.data.map((c: { handle: string }) => c.handle)).toEqual([first.handle]);
      expect(page2.meta.total).toBe(2);
      const mine = (
        await as(viewer.token)
          .get(`/creatives?q=${encodeURIComponent(viewer.name)}`)
          .expect(200)
      ).body;
      expect(mine.data.map((c: { handle: string }) => c.handle)).not.toContain(viewer.handle);
      void unfinished;
    });

    it('does not reveal or match what a member keeps private', async () => {
      const viewer = await member();
      const tag = uniq();
      const open = await member({
        name: `Private ${tag} open`,
        skills: ['Procreate'],
        county: 'KSM',
      });
      const closed = await member({
        name: `Private ${tag} closed`,
        skills: ['Procreate'],
        county: 'KSM',
      });
      await setSection(closed, 'SKILLS', 'PRIVATE');
      await setSection(closed, 'LOCATION', 'PRIVATE');
      const kisumu = await prisma.county.findFirstOrThrow({ where: { code: 'KSM' } });

      // County filter: only the member who shows their county is found, and their card says where.
      const byCounty = (
        await as(viewer.token).get(`/creatives?q=${tag}&countyId=${kisumu.id}`).expect(200)
      ).body;
      expect(byCounty.data.map((c: { handle: string }) => c.handle)).toEqual([open.handle]);
      expect(byCounty.data[0].location).toBe('Kisumu');
      const all = (await as(viewer.token).get(`/creatives?q=${tag}`).expect(200)).body.data;
      const closedCard = all.find((c: { handle: string }) => c.handle === closed.handle);
      expect(closedCard.location).toBeNull();
      expect(closedCard.tags).toEqual([]);

      // Skill search: matching on a hidden skill would reveal it, so it matches only the open profile.
      const skill = (
        await as(viewer.token).get(`/search?q=Procreate&type=creatives&limit=100`).expect(200)
      ).body.data.groups[0];
      const found = skill.items.map((i: { id: string }) => i.id);
      expect(found).toContain(open.handle);
      expect(found).not.toContain(closed.handle);
    });
  });

  // ---------------------------------------------------------------------------------------------------------
  describe('Search', () => {
    it('groups creatives and articles with counts, tolerates typos, and finds by headline and field', async () => {
      const viewer = await member();
      const target = await member({ name: 'Qwertyuiop Zuberi' });
      const art = await article({ title: 'Qwertyuiop on pricing for illustrators' });

      const exact = (await as(viewer.token).get('/search?q=Qwertyuiop').expect(200)).body.data;
      expect(exact.groups.map((g: { type: string }) => g.type)).toEqual(['creatives', 'articles']);
      const people = exact.groups[0];
      const pieces = exact.groups[1];
      expect(people.count).toBe(1);
      expect(people.items[0]).toMatchObject({
        type: 'creatives',
        id: target.handle,
        title: 'Qwertyuiop Zuberi',
        path: `/creatives/${target.handle}`,
      });
      expect(pieces.items[0]).toMatchObject({ id: art.id, path: `/articles/${art.slug}` });

      // A typo still finds them.
      const typo = (
        await as(viewer.token).get('/search?q=Qwertyuop%20Zuberi&type=creatives').expect(200)
      ).body.data;
      expect(typo.groups).toHaveLength(1);
      expect(typo.groups[0].items.map((i: { id: string }) => i.id)).toContain(target.handle);

      // Discipline name finds people in it.
      const byField = (
        await as(viewer.token).get('/search?q=Animation&type=creatives&limit=100').expect(200)
      ).body.data;
      expect(byField.groups[0].items.map((i: { id: string }) => i.id)).toContain(target.handle);
    });

    it('treats what was typed as words, not as patterns, and pages one type at a time', async () => {
      const viewer = await member();
      const tag = uniq();
      await member({ name: `Pager ${tag} one` });
      await member({ name: `Pager ${tag} two` });
      expect(
        (await as(viewer.token).get('/search?q=%25%25').expect(200)).body.data.groups[0].count,
      ).toBe(0);
      expect(
        (await as(viewer.token).get('/search?q=a_b_c_d').expect(200)).body.data.groups[0].count,
      ).toBe(0);
      const page1 = (
        await as(viewer.token).get(`/search?q=Pager%20${tag}&type=creatives&limit=1`).expect(200)
      ).body.data.groups[0];
      expect(page1.count).toBe(2);
      expect(page1.items).toHaveLength(1);
      const page2 = (
        await as(viewer.token)
          .get(`/search?q=Pager%20${tag}&type=creatives&limit=1&page=2`)
          .expect(200)
      ).body.data.groups[0];
      expect(page2.items).toHaveLength(1);
      expect(page2.items[0].id).not.toBe(page1.items[0].id);
    });

    it('returns no group for kinds that are not built yet, and refuses a query that is too short', async () => {
      const viewer = await member();
      expect(
        (await as(viewer.token).get('/search?q=Qwerty&type=opportunities').expect(200)).body.data
          .groups,
      ).toEqual([]);
      expect(
        (await as(viewer.token).get('/search?q=Qwerty&type=marketplace').expect(200)).body.data
          .groups,
      ).toEqual([]);
      await as(viewer.token).get('/search?q=a').expect(400);
      await as(viewer.token).get('/search?q=%20%20').expect(400);
      await as(viewer.token).get('/search?q=Qwerty&type=nonsense').expect(400);
      await as().get('/search?q=Qwerty').expect(401);
    });

    it('finds only articles that are live', async () => {
      const viewer = await member();
      const tag = uniq();
      const live = await article({ title: `Findable ${tag} live` });
      await article({ title: `Findable ${tag} draft`, publish: false });
      const soon = await article({
        title: `Findable ${tag} scheduled`,
        publishAt: new Date(Date.now() + 3600_000).toISOString(),
      });
      const archived = await article({ title: `Findable ${tag} archived` });
      await as(editor.token).post(`/admin/articles/${archived.id}/archive`).expect(200);

      const res = (
        await as(viewer.token).get(`/search?q=Findable%20${tag}&type=articles`).expect(200)
      ).body.data;
      expect(res.groups[0].items.map((i: { id: string }) => i.id)).toEqual([live.id]);
      await as(viewer.token).get(`/articles/${soon.slug}`).expect(404);
    });

    it('keeps each member’s recent searches, newest first, without duplicates, ten at most', async () => {
      const me = await member();
      const other = await member();
      for (const q of ['logo', 'Logo ', 'film', 'music']) {
        await as(me.token).post('/me/recent-searches', { query: q }).expect(200);
      }
      const list = (await as(me.token).get('/me/recent-searches').expect(200)).body.data;
      expect(list.map((r: { query: string }) => r.query)).toEqual(['music', 'film', 'Logo']);
      for (let i = 0; i < 12; i += 1) {
        await as(me.token)
          .post('/me/recent-searches', { query: `term ${i}` })
          .expect(200);
      }
      const capped = (await as(me.token).get('/me/recent-searches').expect(200)).body.data;
      expect(capped).toHaveLength(10);
      expect(capped[0].query).toBe('term 11');

      expect((await as(other.token).get('/me/recent-searches').expect(200)).body.data).toEqual([]);
      await as(other.token).del(`/me/recent-searches/${capped[0].id}`).expect(404);
      await as(me.token).del(`/me/recent-searches/${capped[0].id}`).expect(204);
      expect((await as(me.token).get('/me/recent-searches').expect(200)).body.data).toHaveLength(9);
      await as(me.token).del('/me/recent-searches').expect(204);
      expect((await as(me.token).get('/me/recent-searches').expect(200)).body.data).toEqual([]);
      await as(me.token).post('/me/recent-searches', { query: 'x' }).expect(400);
    });
  });

  // ---------------------------------------------------------------------------------------------------------
  describe('Articles', () => {
    it('moves draft to review to published to archived, audits each step, and only shows it live', async () => {
      const member1 = await member();
      const created = (
        await as(editor.token)
          .post('/admin/articles', {
            title: 'How to price commissioned illustration',
            authorName: 'Kiptoo Langat',
          })
          .expect(201)
      ).body.data;
      expect(created).toMatchObject({
        status: 'DRAFT',
        slug: expect.stringMatching(/^how-to-price/),
      });
      await as(member1.token).get(`/articles/${created.slug}`).expect(404);

      // Not ready: no summary, no content.
      await as(editor.token).post(`/admin/articles/${created.id}/submit`).expect(400);
      const hero = await image(editor.id);
      const edited = (
        await as(editor.token)
          .patch(`/admin/articles/${created.id}`, {
            summary: 'Most illustrators under-price because they quote by the hour.',
            heroMediaId: hero,
            tags: ['Visual Art', 'pricing'],
            blocks: [
              { type: 'heading', text: 'Start with a day rate' },
              {
                type: 'paragraph',
                text: 'Clients do not buy hours, they buy usage and reliability.',
              },
              {
                type: 'callout',
                title: 'Rule of thumb',
                text: 'An editorial spot is not a billboard.',
              },
              { type: 'quote', text: 'Price the usage.', attribution: 'Anonymous' },
              { type: 'image', mediaId: hero, caption: 'A rate card' },
            ],
          })
          .expect(200)
      ).body.data;
      expect(edited.tags).toEqual(['visual-art', 'pricing']);
      expect(edited.readMinutes).toBe(1);
      expect(edited.blocks).toHaveLength(5);

      await as(editor.token).post(`/admin/articles/${created.id}/publish`).expect(409); // must be reviewed first
      await as(editor.token).post(`/admin/articles/${created.id}/submit`).expect(200);
      await as(member1.token).get(`/articles/${created.slug}`).expect(404); // still not live
      await as(editor.token).post(`/admin/articles/${created.id}/return`).expect(200);
      await as(editor.token).post(`/admin/articles/${created.id}/submit`).expect(200);
      await as(editor.token).post(`/admin/articles/${created.id}/publish`).expect(200);

      const live = (await as(member1.token).get(`/articles/${created.slug}`).expect(200)).body.data;
      expect(live).toMatchObject({
        title: 'How to price commissioned illustration',
        source: 'ATARAH',
        authorName: 'Kiptoo Langat',
        saved: false,
        shareUrl: expect.stringContaining(`/articles/${created.slug}`),
      });
      expect(live.heroUrl).toContain('https://signed.test/');
      expect(live.blocks.map((b: { type: string }) => b.type)).toEqual([
        'heading',
        'paragraph',
        'callout',
        'quote',
        'image',
      ]);
      expect(live.blocks[2]).toMatchObject({ title: 'Rule of thumb' });
      expect(live.blocks[4].imageUrl).toContain('https://signed.test/');
      // Visitors can read it too (shared links work without an account).
      await as().get(`/articles/${created.slug}`).expect(200);
      const list = (await as().get('/articles').expect(200)).body;
      expect(list.data.map((a: { id: string }) => a.id)).toContain(created.id);

      await as(editor.token).post(`/admin/articles/${created.id}/archive`).expect(200);
      await as(member1.token).get(`/articles/${created.slug}`).expect(404);
      await as(editor.token)
        .patch(`/admin/articles/${created.id}`, { title: 'Changed' })
        .expect(409);
      await as(editor.token).post(`/admin/articles/${created.id}/restore`).expect(200);

      const actions = (
        await prisma.auditLog.findMany({ where: { entityType: 'article', entityId: created.id } })
      ).map((r) => r.action);
      expect(actions).toEqual(
        expect.arrayContaining([
          'content.article.create',
          'content.article.update',
          'content.article.submit',
          'content.article.return',
          'content.article.publish',
          'content.article.archive',
          'content.article.restore',
        ]),
      );
    });

    it('holds a scheduled article back until its time', async () => {
      const me = await member();
      const soon = await article({ publishAt: new Date(Date.now() + 3600_000).toISOString() });
      await as(me.token).get(`/articles/${soon.slug}`).expect(404);
      const row = (await as(editor.token).get(`/admin/articles/${soon.id}`).expect(200)).body.data;
      expect(row.scheduled).toBe(true);
      await prisma.article.update({
        where: { id: soon.id },
        data: { publishedAt: new Date(Date.now() - 1000) },
      });
      await as(me.token).get(`/articles/${soon.slug}`).expect(200);
      // A publish time that has long passed is a mistake.
      const another = await article({ publish: false });
      await as(editor.token).post(`/admin/articles/${another.id}/submit`).expect(200);
      await as(editor.token)
        .post(`/admin/articles/${another.id}/publish`, { publishAt: '2020-01-01T00:00:00Z' })
        .expect(400);
    });

    it('rejects bad blocks, private images, other people’s images and unlabelled partner content', async () => {
      const draft = await article({ publish: false });
      const patch = (b: object) => as(editor.token).patch(`/admin/articles/${draft.id}`, b);
      await patch({ blocks: [{ type: 'paragraph', text: '   ' }] }).expect(400);
      await patch({ blocks: [{ type: 'image' }] }).expect(400);
      await patch({ blocks: [{ type: 'carousel', text: 'x' }] }).expect(400);
      await patch({ title: 'x' }).expect(400);
      await patch({ tags: ['ok', 'a'.repeat(41)] }).expect(400);
      const priv = await image(editor.id, 'PRIVATE');
      await patch({ heroMediaId: priv }).expect(400);
      const stranger = await member();
      await patch({ heroMediaId: await image(stranger.id) }).expect(400);
      await patch({ heroMediaId: '00000000-0000-4000-8000-000000000000' }).expect(400);

      await patch({ source: 'PARTNER' }).expect(200);
      await as(editor.token).post(`/admin/articles/${draft.id}/submit`).expect(400);
      await patch({ sourceLabel: 'Creative Economy Kenya' }).expect(200);
      await as(editor.token).post(`/admin/articles/${draft.id}/submit`).expect(200);
    });

    it('keeps the CMS and Home pins for people who may manage articles', async () => {
      const plain = await member();
      await as(plain.token).get('/admin/articles').expect(403);
      await as(plain.token).put('/admin/home', {}).expect(403);
      const draft = await article({ publish: false });
      await as(editor.token).put('/admin/home', { featuredArticleId: draft.id }).expect(400);
      await as(editor.token).get('/admin/articles?status=DRAFT&q=pricing').expect(200);
      await as(editor.token)
        .get(`/admin/articles/00000000-0000-4000-8000-000000000000`)
        .expect(404);
    });

    it('lets an editor upload a public hero image, and keeps ordinary members out', async () => {
      const ticket = (
        await as(editor.token)
          .post('/admin/media/uploads', {
            kind: 'IMAGE',
            mimeType: 'image/jpeg',
            sizeBytes: 2048,
            visibility: 'PUBLIC',
          })
          .expect(201)
      ).body.data;
      expect(ticket.uploadUrl).toBeTruthy();
      const plain = await member();
      await as(plain.token)
        .post('/admin/media/uploads', {
          kind: 'IMAGE',
          mimeType: 'image/jpeg',
          sizeBytes: 2048,
          visibility: 'PUBLIC',
        })
        .expect(403);
      await prisma.mediaAsset.deleteMany({ where: { id: ticket.id } });
    });

    it('lets a member save and unsave an article, and drops it from their list once it is archived', async () => {
      const me = await member();
      const a = await article();
      const draft = await article({ publish: false });
      await as(me.token).put(`/me/saved/ARTICLE/${a.id}`).expect(204);
      await as(me.token).put(`/me/saved/ARTICLE/${a.id}`).expect(204); // again is fine
      await as(me.token).put(`/me/saved/ARTICLE/${draft.id}`).expect(404);
      await as(me.token).put(`/me/saved/POST/${a.id}`).expect(400);
      expect((await as(me.token).get(`/articles/${a.slug}`).expect(200)).body.data.saved).toBe(
        true,
      );
      const saved = (await as(me.token).get('/me/saved').expect(200)).body;
      expect(saved.data.map((s: { article: { id: string } }) => s.article.id)).toEqual([a.id]);
      expect(saved.meta.total).toBe(1);

      await as(editor.token).post(`/admin/articles/${a.id}/archive`).expect(200);
      expect((await as(me.token).get('/me/saved').expect(200)).body.data).toEqual([]);
      await as(editor.token).post(`/admin/articles/${a.id}/restore`).expect(200);

      await as(me.token).del(`/me/saved/ARTICLE/${a.id}`).expect(204);
      await as(me.token).del(`/me/saved/ARTICLE/${a.id}`).expect(204);
      expect((await as(me.token).get('/me/saved').expect(200)).body.data).toEqual([]);
      await as().put(`/me/saved/ARTICLE/${a.id}`).expect(401);
    });
  });
});
