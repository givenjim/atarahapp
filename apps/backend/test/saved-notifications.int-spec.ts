import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AccountJobsModule } from '../src/account/jobs/account-jobs.module';
import { AccountJobsService } from '../src/account/jobs/account-jobs.service';
import { NotificationsService } from '../src/notifications/notifications.service';
import { PrismaService } from '../src/prisma/prisma.service';
import {
  adminSignIn,
  bearer,
  createTestApp,
  deleteUsers,
  loginMember,
  makeUser,
  uniq,
} from './helpers';

// Each test sets up several real Supabase Auth members, so allow more than 5 s.
jest.setTimeout(180_000);

interface Member {
  id: string;
  token: string;
  email: string;
  handle: string;
  profileId: string;
}

const DAY = 86_400_000;
const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

describe('Saved, activity, notifications, help and broadcasts (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let jobs: AccountJobsService;
  let notifications: NotificationsService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];

  const as = (token?: string) => {
    const wrap = (r: request.Test) => (token ? r.set(...bearer(token)) : r);
    return {
      get: (p: string, query: object = {}) => wrap(http().get(`/api/v1${p}`).query(query)),
      post: (p: string, b: object = {}) => wrap(http().post(`/api/v1${p}`).send(b)),
      put: (p: string, b: object = {}) => wrap(http().put(`/api/v1${p}`).send(b)),
      patch: (p: string, b: object = {}) => wrap(http().patch(`/api/v1${p}`).send(b)),
      del: (p: string) => wrap(http().delete(`/api/v1${p}`)),
    };
  };

  beforeAll(async () => {
    app = await createTestApp([AccountJobsModule]);
    prisma = app.get(PrismaService);
    jobs = app.get(AccountJobsService);
    notifications = app.get(NotificationsService);
  });
  afterAll(async () => {
    // The legal-document tests publish versions through the admin API; the reference seed's drafts are all that other
    // suites (database baseline) expect to find.
    await app.get(PrismaService).legalDocument.deleteMany({
      where: { NOT: { title: { startsWith: 'DRAFT — pending legal review' } } },
    });
    await deleteUsers(app, users);
    await app.close();
  });

  async function member(
    o: { disciplineId?: string; countyCode?: string; name?: string } = {},
  ): Promise<Member> {
    const { user, email } = await makeUser(app, { fullName: o.name ?? `Tess ${uniq()}` });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const discipline = o.disciplineId
      ? { id: o.disciplineId }
      : await prisma.discipline.findFirstOrThrow({ where: { name: 'Film / Video' } });
    const county = await prisma.county.findFirstOrThrow({ where: { code: o.countyCode ?? 'NBI' } });
    const handle = `c_${uniq()}`.replace(/-/g, '_');
    const profile = await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle,
        displayName: o.name ?? 'Tess',
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        primaryDisciplineId: discipline.id,
        countryId: county.countryId,
        countyId: county.id,
      },
    });
    return { id: user.id, token, email, handle, profileId: profile.id };
  }

  async function staff(role: 'PLATFORM_ADMIN' | 'CONTENT_ADMIN' | 'MODERATOR') {
    const { user, email } = await makeUser(app, { roles: [role], fullName: `Staff ${uniq()}` });
    users.push(user.id);
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  const article = async (authorId: string, title = `Article ${uniq()}`) =>
    prisma.article.create({
      data: {
        slug: `a-${uniq()}`,
        title,
        summary: 'A short summary for the test article.',
        authorName: 'Atarah Editorial',
        status: 'PUBLISHED',
        publishedAt: new Date(Date.now() - 1000),
        createdById: authorId,
      },
    });

  const learning = async (over: object = {}) => {
    const category = await prisma.learningCategory.findFirstOrThrow();
    return prisma.learningContent.create({
      data: {
        slug: `l-${uniq()}`,
        type: 'TUTORIAL',
        title: `Tutorial ${uniq()}`,
        summary: 'A tutorial about something useful.',
        categoryId: category.id,
        status: 'PUBLISHED',
        publishedAt: new Date(),
        ...over,
      },
    });
  };

  // ---------------------------------------------------------------------------------------------------------------

  describe('saved items of every kind', () => {
    it('saves, lists, filters, files in collections and unsaves each kind through one pair of routes', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const me = await member();
      const other = await member();
      const art = await article(admin.id, 'Pricing illustration');
      const course = await learning({ title: 'Portfolio basics' });
      const post = (
        await as(other.token)
          .post('/posts', { type: 'UPDATE', body: 'A public update to save.' })
          .expect(201)
      ).body.data;
      const prov = await prisma.opportunityProvider.create({ data: { name: `Prov ${uniq()}` } });
      const opp = await prisma.opportunity.create({
        data: {
          providerId: prov.id,
          slug: `o-${uniq()}`,
          type: 'GRANT',
          title: 'Emerging fund',
          summary: 'Funding for emerging creatives.',
          status: 'PUBLISHED',
          publishedAt: new Date(),
          deadlineAt: new Date(Date.now() + 20 * DAY),
          applicationUrl: 'https://f.example.org/apply',
        },
      });

      await as(me.token).put(`/me/saved/ARTICLE/${art.id}`, { collection: 'Pricing' }).expect(204);
      await as(me.token).put(`/me/saved/LEARNING/${course.id}`).expect(204);
      await as(me.token).put(`/me/saved/POST/${post.id}`).expect(204);
      await as(me.token).put(`/me/saved/CREATIVE/${other.profileId}`).expect(204);
      await as(me.token).put(`/me/saved/OPPORTUNITY/${opp.id}`).expect(204);
      // Idempotent.
      await as(me.token).put(`/me/saved/ARTICLE/${art.id}`).expect(204);

      const all = (await as(me.token).get('/me/saved').expect(200)).body;
      expect(all.meta.total).toBe(5);
      const byType = Object.fromEntries(all.data.map((i: { type: string }) => [i.type, i]));
      expect(Object.keys(byType).sort()).toEqual([
        'ARTICLE',
        'CREATIVE',
        'LEARNING',
        'OPPORTUNITY',
        'POST',
      ]);
      expect(byType.ARTICLE).toMatchObject({
        title: 'Pricing illustration',
        collection: 'Pricing',
        path: `/articles/${art.slug}`,
      });
      expect(byType.ARTICLE.article.slug).toBe(art.slug);
      expect(byType.LEARNING).toMatchObject({
        title: 'Portfolio basics',
        path: `/learning/courses/${course.id}`,
      });
      expect(byType.POST).toMatchObject({ path: `/posts/${post.id}` });
      expect(byType.CREATIVE).toMatchObject({
        targetId: other.profileId,
        path: `/creatives/${other.handle}`,
      });
      expect(byType.OPPORTUNITY).toMatchObject({
        title: 'Emerging fund',
        path: `/opportunities/${opp.id}`,
      });

      for (const type of ['ARTICLE', 'LEARNING', 'POST', 'CREATIVE', 'OPPORTUNITY']) {
        const only = (await as(me.token).get('/me/saved', { type }).expect(200)).body;
        expect(only.data.map((i: { type: string }) => i.type)).toEqual([type]);
      }
      expect(
        (await as(me.token).get('/me/saved', { collection: 'Pricing' }).expect(200)).body.data,
      ).toHaveLength(1);
      const counts = (await as(me.token).get('/me/saved/counts').expect(200)).body.data;
      expect(counts).toMatchObject({
        total: 5,
        byType: { ARTICLE: 1, LEARNING: 1, POST: 1, CREATIVE: 1, OPPORTUNITY: 1 },
      });

      // An opportunity saved here is the same record the Opportunities screens use.
      expect((await as(me.token).get(`/opportunities/${opp.id}`).expect(200)).body.data.saved).toBe(
        true,
      );

      await as(me.token).del(`/me/saved/ARTICLE/${art.id}`).expect(204);
      await as(me.token).del(`/me/saved/OPPORTUNITY/${opp.id}`).expect(204);
      await as(me.token).del(`/me/saved/CREATIVE/${other.profileId}`).expect(204);
      expect((await as(me.token).get('/me/saved').expect(200)).body.meta.total).toBe(2);
      // Another member's list is unaffected.
      expect((await as(other.token).get('/me/saved').expect(200)).body.meta.total).toBe(0);
    });

    it('refuses what is not built yet, what does not exist and what the member cannot see', async () => {
      const me = await member();
      const other = await member();
      const random = '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b';
      await as(me.token).put(`/me/saved/LISTING/${random}`).expect(404); // built in P2-M3
      await as(me.token).put(`/me/saved/MENTOR/${random}`).expect(400);
      await as(me.token).get('/me/saved', { type: 'LISTING' }).expect(200);
      await as(me.token).put(`/me/saved/NOPE/${random}`).expect(400);
      await as(me.token).put(`/me/saved/ARTICLE/${random}`).expect(404);
      await as(me.token).put(`/me/saved/CREATIVE/${me.profileId}`).expect(404); // not yourself
      await as(me.token).put('/me/saved/ARTICLE/not-a-uuid').expect(400);
      await as(undefined).get('/me/saved').expect(401);

      // A post the member cannot see (connections only) and a creative who blocked them.
      const hidden = (
        await as(other.token)
          .post('/posts', { type: 'UPDATE', body: 'Connections only.', audience: 'CONNECTIONS' })
          .expect(201)
      ).body.data;
      await as(me.token).put(`/me/saved/POST/${hidden.id}`).expect(404);
      await prisma.block.create({ data: { blockerId: other.id, blockedId: me.id } });
      await as(me.token).put(`/me/saved/CREATIVE/${other.profileId}`).expect(404);
    });

    it('drops rows whose target was hidden since, and the nightly job deletes rows whose target is gone', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const me = await member();
      const a1 = await article(admin.id);
      const a2 = await article(admin.id);
      const course = await learning();
      await as(me.token).put(`/me/saved/ARTICLE/${a1.id}`).expect(204);
      await as(me.token).put(`/me/saved/ARTICLE/${a2.id}`).expect(204);
      await as(me.token).put(`/me/saved/LEARNING/${course.id}`).expect(204);

      // Archived: hidden from the list but kept (it may come back).
      await prisma.article.update({ where: { id: a1.id }, data: { status: 'ARCHIVED' } });
      expect((await as(me.token).get('/me/saved').expect(200)).body.meta.total).toBe(2);
      expect(await prisma.savedItem.count({ where: { userId: me.id } })).toBe(3);

      // Deleted for good: the job removes the dead row, and only that one.
      await prisma.savedItem.deleteMany({ where: { userId: me.id, type: 'LEARNING' } });
      await prisma.savedItem.create({
        data: { userId: me.id, type: 'LEARNING', targetId: '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b' },
      });
      const out = await jobs.cleanSaved();
      expect(out.removed).toBeGreaterThanOrEqual(1);
      expect(await prisma.savedItem.count({ where: { userId: me.id, type: 'LEARNING' } })).toBe(0);
      expect(await prisma.savedItem.count({ where: { userId: me.id, type: 'ARTICLE' } })).toBe(2);
    });
  });

  describe('activity and applications', () => {
    it('picks up where the member left off and counts what is behind each tile', async () => {
      const me = await member();
      const prov = await prisma.opportunityProvider.create({ data: { name: `Prov ${uniq()}` } });
      const gap = await prisma.opportunity.create({
        data: {
          providerId: prov.id,
          slug: `o-${uniq()}`,
          type: 'GRANT',
          title: 'Needs three projects',
          summary: 'A grant that needs a few projects.',
          status: 'PUBLISHED',
          publishedAt: new Date(),
          deadlineAt: new Date(Date.now() + 10 * DAY),
          applicationUrl: 'https://g.example.org/apply',
          rules: {
            create: [
              {
                ruleType: 'MIN_PROJECTS',
                params: { count: 3 },
                label: 'At least 3 projects',
                isBlocking: true,
              },
            ],
          },
        },
      });
      const fine = await prisma.opportunity.create({
        data: {
          providerId: prov.id,
          slug: `o-${uniq()}`,
          type: 'JOB',
          title: 'No rules',
          summary: 'A job with no rules at all.',
          status: 'PUBLISHED',
          publishedAt: new Date(),
          applicationUrl: 'https://g.example.org/job',
        },
      });
      await as(me.token).put(`/me/saved/OPPORTUNITY/${gap.id}`).expect(204);
      await as(me.token).post(`/opportunities/${fine.id}/track`, { status: 'APPLIED' }).expect(200);
      await prisma.project.create({
        data: { profileId: me.profileId, title: 'My half-finished piece', status: 'DRAFT' },
      });
      const course = await learning({ type: 'COURSE', title: 'A course' });
      await prisma.course.create({
        data: { contentId: course.id, lessonCount: 4, totalMinutes: 40 },
      });
      const lesson = await prisma.lesson.create({
        data: { courseId: course.id, sequence: 1, title: 'First lesson', durationMinutes: 10 },
      });
      const lesson2 = await prisma.lesson.create({
        data: { courseId: course.id, sequence: 2, title: 'Second lesson', durationMinutes: 10 },
      });
      await prisma.enrolment.create({ data: { userId: me.id, courseId: course.id } });
      await prisma.lessonProgress.create({
        data: { userId: me.id, lessonId: lesson.id, status: 'COMPLETED', completedAt: new Date() },
      });
      await prisma.lessonProgress.create({
        data: {
          userId: me.id,
          lessonId: lesson2.id,
          status: 'IN_PROGRESS',
          lastPositionSeconds: 90,
        },
      });

      const hub = (await as(me.token).get('/me/activity').expect(200)).body.data;
      const kinds = hub.resume.map((c: { kind: string }) => c.kind).sort();
      expect(kinds).toEqual(['DRAFT_PROJECT', 'LESSON', 'OPPORTUNITY_GAP']);
      const byKind = Object.fromEntries(hub.resume.map((c: { kind: string }) => [c.kind, c]));
      expect(byKind.LESSON).toMatchObject({
        title: 'Second lesson',
        subtitle: 'A course',
        progressPercent: 25,
        path: `/learning/courses/${course.id}`,
      });
      expect(byKind.OPPORTUNITY_GAP).toMatchObject({
        title: 'Needs three projects',
        subtitle: 'Missing 1 requirement',
        path: `/opportunities/${gap.id}`,
      });
      expect(byKind.DRAFT_PROJECT.title).toBe('My half-finished piece');
      expect(hub.counts).toMatchObject({
        saved: 1,
        applications: 1,
        learningInProgress: 1,
        portfolio: 0,
        pendingConnections: 0,
      });

      const apps = (await as(me.token).get('/me/applications').expect(200)).body;
      expect(apps.meta.total).toBe(1);
      expect(apps.data[0]).toMatchObject({ status: 'APPLIED' });
      expect(apps.data[0].metaLine).toMatch(/^Applied /);
      await as(me.token)
        .post(`/opportunities/${fine.id}/track`, { status: 'COMPLETED', outcome: 'AWARDED' })
        .expect(200);
      expect((await as(me.token).get('/me/applications').expect(200)).body.data[0].metaLine).toBe(
        'Completed · Awarded',
      );

      // A member with nothing in progress gets an empty hub, not an error.
      const fresh = await member();
      const empty = (await as(fresh.token).get('/me/activity').expect(200)).body.data;
      expect(empty.resume).toEqual([]);
      expect(empty.counts.saved).toBe(0);
    });
  });

  describe('the notification centre', () => {
    it('lists newest first with Today/Earlier groups, filters, counts unread and marks read', async () => {
      const me = await member();
      const other = await member();
      const old = await prisma.notification.create({
        data: {
          userId: me.id,
          category: 'COMMUNITY',
          title: 'Old news',
          body: 'From last week.',
          createdAt: new Date(Date.now() - 5 * DAY),
        },
      });
      await notifications.notify({
        userId: me.id,
        category: 'OPPORTUNITIES',
        type: 'opportunity.reminder',
        title: 'One week left',
        body: 'It closes soon.',
        deepLink: '/opportunities/abc',
      });
      await sleep(15);
      await notifications.notify({
        userId: me.id,
        category: 'COMMUNITY',
        type: 'community.comment',
        title: 'New comment',
        body: 'Someone replied.',
      });
      await notifications.notify({
        userId: other.id,
        category: 'SYSTEM',
        title: 'Not yours',
        body: 'Belongs to someone else.',
      });

      const list = (await as(me.token).get('/notifications').expect(200)).body;
      expect(list.data.map((n: { title: string }) => n.title)).toEqual([
        'New comment',
        'One week left',
        'Old news',
      ]);
      expect(list.meta).toMatchObject({ total: 3, unread: 3 });
      expect(list.data[0]).toMatchObject({
        group: 'TODAY',
        read: false,
        type: 'community.comment',
      });
      expect(list.data[1]).toMatchObject({
        deepLink: '/opportunities/abc',
        type: 'opportunity.reminder',
      });
      expect(list.data[2].group).toBe('EARLIER');

      const filtered = (
        await as(me.token).get('/notifications', { category: 'OPPORTUNITIES' }).expect(200)
      ).body;
      expect(filtered.data).toHaveLength(1);
      expect(filtered.meta.total).toBe(1);

      expect((await as(me.token).get('/notifications/unread-count').expect(200)).body.data).toEqual(
        { unread: 3, byCategory: { COMMUNITY: 2, OPPORTUNITIES: 1 } },
      );
      // The cached count follows writes.
      const marked = await as(me.token).post(`/notifications/${old.id}/read`).expect(200);
      expect(marked.body.data.unread).toBe(2);
      expect(
        (await as(me.token).get('/notifications/unread-count').expect(200)).body.data.unread,
      ).toBe(2);
      expect(
        (await as(me.token).get('/notifications', { unreadOnly: true }).expect(200)).body.meta
          .total,
      ).toBe(2);
      await notifications.notify({
        userId: me.id,
        category: 'SYSTEM',
        title: 'Fresh',
        body: 'Arrived after the count was cached.',
      });
      expect(
        (await as(me.token).get('/notifications/unread-count').expect(200)).body.data.unread,
      ).toBe(3);

      const some = (
        await as(me.token).post('/notifications/read-all', { category: 'COMMUNITY' }).expect(200)
      ).body.data;
      expect(some).toMatchObject({ marked: 1, unread: 2 });
      const rest = (await as(me.token).post('/notifications/read-all').expect(200)).body.data;
      expect(rest).toMatchObject({ marked: 2, unread: 0 });

      // Someone else's notification is a 404, never "marked".
      const theirs = await prisma.notification.findFirstOrThrow({ where: { userId: other.id } });
      await as(me.token).post(`/notifications/${theirs.id}/read`).expect(404);
      expect(
        (await prisma.notification.findUniqueOrThrow({ where: { id: theirs.id } })).readAt,
      ).toBeNull();
    });

    it('enforces preferences: push and email follow the category switches, in-app is always written, security notices ignore them', async () => {
      const me = await member();
      await as(me.token)
        .post('/devices', { token: `fcm-token-${uniq()}-abcdef`, platform: 'ANDROID' })
        .expect(200);
      const base = {
        userId: me.id,
        category: 'MARKETPLACE' as const,
        title: 'Hello',
        body: 'World',
      };

      expect((await notifications.notify(base)).channels.sort()).toEqual([
        'email',
        'in_app',
        'push',
      ]);

      await as(me.token)
        .put('/notifications/preferences', {
          preferences: [{ category: 'MARKETPLACE', pushEnabled: false, emailEnabled: true }],
        })
        .expect(200);
      expect((await notifications.notify(base)).channels.sort()).toEqual(['email', 'in_app']);

      await as(me.token)
        .put('/notifications/preferences', {
          preferences: [{ category: 'MARKETPLACE', pushEnabled: true, emailEnabled: false }],
        })
        .expect(200);
      expect((await notifications.notify(base)).channels.sort()).toEqual(['in_app', 'push']);

      await as(me.token)
        .put('/notifications/preferences', {
          preferences: [{ category: 'MARKETPLACE', pushEnabled: false, emailEnabled: false }],
        })
        .expect(200);
      const quiet = await notifications.notify(base);
      expect(quiet.channels).toEqual(['in_app']);
      expect(await prisma.notification.count({ where: { id: quiet.notificationId } })).toBe(1);

      // Another category is unaffected, and a critical notice goes out on every channel regardless.
      expect(
        (await notifications.notify({ ...base, category: 'COMMUNITY' })).channels.sort(),
      ).toEqual(['email', 'in_app', 'push']);
      expect((await notifications.notify({ ...base, critical: true })).channels.sort()).toEqual([
        'email',
        'in_app',
        'push',
      ]);
    });

    it('deletes notifications older than 180 days and keeps the rest', async () => {
      const me = await member();
      const mk = (days: number) =>
        prisma.notification.create({
          data: {
            userId: me.id,
            category: 'SYSTEM',
            title: `${days} days old`,
            body: '.',
            createdAt: new Date(Date.now() - days * DAY),
          },
        });
      await mk(10);
      await mk(179);
      await mk(181);
      await mk(400);
      const out = await jobs.notificationRetention();
      expect(out.removed).toBeGreaterThanOrEqual(2);
      const left = await prisma.notification.findMany({
        where: { userId: me.id },
        orderBy: { createdAt: 'desc' },
      });
      expect(left.map((n) => n.title)).toEqual(['10 days old', '179 days old']);
    });
  });

  describe('help and legal', () => {
    it('serves the Safety centre, the FAQ, search and the support contact, signed in or not', async () => {
      const safety = (await as(undefined).get('/help/articles/safety-centre').expect(200)).body
        .data;
      expect(safety).toMatchObject({ slug: 'safety-centre', title: 'Safety centre' });
      expect(
        safety.blocks.some(
          (b: { type: string; text: string }) => b.type === 'heading' && b.text === 'Block someone',
        ),
      ).toBe(true);
      await as(undefined).get('/help/articles/nope').expect(404);

      const faq = (await as(undefined).get('/help/faq').expect(200)).body.data;
      expect(faq.length).toBeGreaterThanOrEqual(6);
      const found = (await as(undefined).get('/help', { q: 'external applications' }).expect(200))
        .body.data;
      expect(found.faq.map((f: { question: string }) => f.question)).toContain(
        'Does Atarah process external applications?',
      );
      const safetyHit = (await as(undefined).get('/help', { q: 'block' }).expect(200)).body.data;
      expect(safetyHit.articles.map((a: { slug: string }) => a.slug)).toContain('safety-centre');
      expect((await as(undefined).get('/help', { q: 'zzzqqqxxx' }).expect(200)).body.data).toEqual({
        articles: [],
        faq: [],
      });
      expect((await as(undefined).get('/help/contact').expect(200)).body.data.email).toBe(
        'support@atarah.app',
      );
    });

    it('shows legal documents, labelling seeded drafts, and publishes versions through the console', async () => {
      const list = (await as(undefined).get('/legal').expect(200)).body.data;
      const terms = list.find((d: { type: string }) => d.type === 'TERMS');
      expect(terms).toMatchObject({ isDraft: true, draftLabel: 'DRAFT — pending legal review' });
      const doc = (await as(undefined).get('/legal/documents/COMMUNITY_GUIDELINES').expect(200))
        .body.data;
      expect(doc.isDraft).toBe(true);
      expect(doc.body.length).toBeGreaterThan(10);
      await as(undefined).get('/legal/documents/NOPE').expect(400);

      const content = await staff('CONTENT_ADMIN');
      const mod = await staff('MODERATOR');
      const v = `9.${uniq()}`;
      await as(mod.token)
        .post('/admin/legal-documents', {
          type: 'MENTOR_TERMS',
          version: v,
          title: 'Mentor Terms',
          body: 'x'.repeat(40),
        })
        .expect(403);
      const draft = (
        await as(content.token)
          .post('/admin/legal-documents', {
            type: 'MENTOR_TERMS',
            version: v,
            title: 'Mentor Terms',
            body: 'These are the real mentor terms. '.repeat(3),
          })
          .expect(201)
      ).body.data;
      expect(draft).toMatchObject({ status: 'DRAFT', isDraft: true });
      await as(content.token)
        .post('/admin/legal-documents', {
          type: 'MENTOR_TERMS',
          version: v,
          title: 'Again',
          body: 'y'.repeat(40),
        })
        .expect(409);
      await as(content.token)
        .patch(`/admin/legal-documents/${draft.id}`, { body: 'Edited mentor terms. '.repeat(3) })
        .expect(200);

      const live = (
        await as(content.token).post(`/admin/legal-documents/${draft.id}/publish`, {}).expect(200)
      ).body.data;
      expect(live).toMatchObject({ status: 'PUBLISHED', isDraft: false });
      const served = (await as(undefined).get('/legal/documents/MENTOR_TERMS').expect(200)).body
        .data;
      expect(served).toMatchObject({ version: v, isDraft: false, draftLabel: null });
      // A published version is never edited; the next change is a new version, and publishing it archives the old one.
      await as(content.token)
        .patch(`/admin/legal-documents/${draft.id}`, { body: 'Sneaky edit. '.repeat(3) })
        .expect(409);
      const v2 = (
        await as(content.token)
          .post('/admin/legal-documents', {
            type: 'MENTOR_TERMS',
            version: `${v}.1`,
            title: 'Mentor Terms',
            body: 'Second version of the terms. '.repeat(3),
          })
          .expect(201)
      ).body.data;
      await as(content.token).post(`/admin/legal-documents/${v2.id}/publish`, {}).expect(200);
      expect(
        (await prisma.legalDocument.findUniqueOrThrow({ where: { id: draft.id } })).status,
      ).toBe('ARCHIVED');
      expect(
        (await as(undefined).get('/legal/documents/MENTOR_TERMS').expect(200)).body.data.version,
      ).toBe(`${v}.1`);
      const audits = await prisma.auditLog.findMany({
        where: { entityType: 'legal_document', action: 'legal_document.publish' },
      });
      expect(audits.length).toBeGreaterThanOrEqual(2);
    });

    it('lets content admins manage help articles and the FAQ; moderators cannot', async () => {
      const content = await staff('CONTENT_ADMIN');
      const mod = await staff('MODERATOR');
      const slug = `how-to-${uniq()}`;
      await as(mod.token).get('/admin/help-articles').expect(403);
      await as(content.token)
        .post('/admin/help-articles', { slug: 'Bad Slug', title: 'Bad' })
        .expect(400);
      const a = (
        await as(content.token)
          .post('/admin/help-articles', {
            slug,
            title: 'How to add a project',
            summary: 'Step by step.',
            blocks: [{ type: 'paragraph', text: 'Open Portfolio and tap Add.' }],
          })
          .expect(201)
      ).body.data;
      expect(a.published).toBe(false);
      await as(undefined).get(`/help/articles/${slug}`).expect(404); // drafts are invisible
      await as(content.token)
        .post('/admin/help-articles', { slug, title: 'Duplicate' })
        .expect(409);
      await as(content.token)
        .post('/admin/help-articles', {
          slug: `${slug}-img`,
          title: 'Img',
          blocks: [{ type: 'image', mediaId: '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b' }],
        })
        .expect(400);
      await as(content.token)
        .patch(`/admin/help-articles/${a.id}`, { published: true })
        .expect(200);
      expect(
        (await as(undefined).get(`/help/articles/${slug}`).expect(200)).body.data.blocks[0].text,
      ).toBe('Open Portfolio and tap Add.');
      expect(
        (
          await as(undefined).get('/help', { q: 'add a project' }).expect(200)
        ).body.data.articles.map((x: { slug: string }) => x.slug),
      ).toContain(slug);

      const f = (
        await as(content.token)
          .post('/admin/faq', {
            question: 'Is the sky blue?',
            answer: 'Mostly, yes.',
            published: true,
            sortOrder: 99,
          })
          .expect(201)
      ).body.data;
      expect(
        (await as(undefined).get('/help/faq').expect(200)).body.data.map(
          (x: { id: string }) => x.id,
        ),
      ).toContain(f.id);
      await as(content.token).patch(`/admin/faq/${f.id}`, { published: false }).expect(200);
      expect(
        (await as(undefined).get('/help/faq').expect(200)).body.data.map(
          (x: { id: string }) => x.id,
        ),
      ).not.toContain(f.id);
      await as(content.token).del(`/admin/faq/${f.id}`).expect(204);
      await as(content.token).del(`/admin/help-articles/${a.id}`).expect(204);
      const trail = await prisma.auditLog.findMany({ where: { entityId: a.id } });
      expect(trail.map((t) => t.action).sort()).toEqual([
        'help_article.create',
        'help_article.delete',
        'help_article.update',
      ]);
    });
  });

  describe('staff broadcasts', () => {
    it('targets a discipline, sends once, respects scheduling and cancelling, and is audited', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const mod = await staff('MODERATOR');
      const discipline = await prisma.discipline.create({
        data: { slug: `d-${uniq()}`, name: `Test craft ${uniq()}`, icon: 'star' },
      });
      const inA = await member({ disciplineId: discipline.id });
      const inB = await member({ disciplineId: discipline.id });
      const outside = await member();

      await as(mod.token)
        .post('/admin/notifications/broadcasts', { title: 'Hi', body: 'There', target: 'ALL' })
        .expect(403);
      const fields = {
        title: 'New residency call',
        body: 'Applications are open.',
        deepLink: '/opportunities',
        target: 'DISCIPLINE',
        targetValue: discipline.id,
      };
      await as(admin.token)
        .post('/admin/notifications/broadcasts', { ...fields, deepLink: 'https://evil.example' })
        .expect(400);
      await as(admin.token)
        .post('/admin/notifications/broadcasts', { ...fields, target: 'COUNTY' })
        .expect(400);
      await as(admin.token)
        .post('/admin/notifications/broadcasts', { ...fields, targetValue: undefined })
        .expect(400);
      expect(
        (await as(admin.token).post('/admin/notifications/broadcasts/preview', fields).expect(200))
          .body.data.recipients,
      ).toBe(2);

      const b = (await as(admin.token).post('/admin/notifications/broadcasts', fields).expect(201))
        .body.data;
      expect(b).toMatchObject({
        status: 'SCHEDULED',
        targetLabel: discipline.name,
        recipientCount: 0,
      });
      const first = await jobs.dispatchBroadcasts();
      expect(first.sent).toBeGreaterThanOrEqual(1);
      for (const m of [inA, inB]) {
        const n = await prisma.notification.findFirstOrThrow({
          where: { userId: m.id, type: 'broadcast' },
        });
        expect(n).toMatchObject({
          title: 'New residency call',
          deepLink: '/opportunities',
          category: 'SYSTEM',
        });
      }
      expect(
        await prisma.notification.count({ where: { userId: outside.id, type: 'broadcast' } }),
      ).toBe(0);
      const done = (
        await as(admin.token).get(`/admin/notifications/broadcasts/${b.id}`).expect(200)
      ).body.data;
      expect(done).toMatchObject({ status: 'SENT', recipientCount: 2 });
      expect(done.sentAt).not.toBeNull();

      // Running again sends nothing twice, and a sent broadcast cannot be cancelled.
      await jobs.dispatchBroadcasts();
      expect(
        await prisma.notification.count({ where: { userId: inA.id, type: 'broadcast' } }),
      ).toBe(1);
      await as(admin.token).post(`/admin/notifications/broadcasts/${b.id}/cancel`).expect(409);

      // Scheduled for later: waits. Cancelled: never sent.
      const later = (
        await as(admin.token)
          .post('/admin/notifications/broadcasts', {
            ...fields,
            title: 'Later',
            scheduledAt: new Date(Date.now() + 2 * DAY).toISOString(),
          })
          .expect(201)
      ).body.data;
      await jobs.dispatchBroadcasts();
      expect(await prisma.notification.count({ where: { userId: inA.id, title: 'Later' } })).toBe(
        0,
      );
      expect(
        (await prisma.notificationBroadcast.findUniqueOrThrow({ where: { id: later.id } })).status,
      ).toBe('SCHEDULED');
      await as(admin.token).post(`/admin/notifications/broadcasts/${later.id}/cancel`).expect(200);
      // The scheduler would find it due in two days; a cancelled one never is.
      await jobs.dispatchBroadcasts();
      expect(await prisma.notification.count({ where: { userId: inA.id, title: 'Later' } })).toBe(
        0,
      );
      await as(admin.token)
        .post('/admin/notifications/broadcasts', {
          ...fields,
          scheduledAt: new Date(Date.now() - 3 * DAY).toISOString(),
        })
        .expect(400);

      const list = (await as(admin.token).get('/admin/notifications/broadcasts').expect(200)).body;
      expect(list.data.map((x: { id: string }) => x.id)).toEqual(
        expect.arrayContaining([b.id, later.id]),
      );
      const trail = await prisma.auditLog.findMany({
        where: { entityType: 'notification_broadcast', entityId: later.id },
      });
      expect(trail.map((t) => t.action).sort()).toEqual(['broadcast.cancel', 'broadcast.create']);
      await prisma.discipline.delete({ where: { id: discipline.id } }).catch(() => undefined);
    });

    it('a broadcast to everyone counts every active member (preview only: nobody is messaged)', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      await member();
      const n = (
        await as(admin.token)
          .post('/admin/notifications/broadcasts/preview', {
            title: 'Hello all',
            body: 'Everyone.',
            target: 'ALL',
          })
          .expect(200)
      ).body.data.recipients;
      expect(n).toBe(
        await prisma.user.count({
          where: {
            status: 'ACTIVE',
            deletedAt: null,
            OR: [{ statusReason: null }, { statusReason: { not: 'SYSTEM_PLACEHOLDER' } }],
          },
        }),
      );
    });
  });

  describe('membership view', () => {
    it('shows the Free plan, the price and the Free versus Pro table', async () => {
      const me = await member();
      const m = (await as(me.token).get('/me/membership').expect(200)).body.data;
      expect(m).toMatchObject({ plan: 'FREE', proPriceLabel: 'KES 1,200 a month' });
      expect(m.comparison).toHaveLength(6);
      expect(m.comparison[0]).toEqual({
        label: 'Creative Passport & portfolio',
        free: true,
        pro: true,
      });
      expect(
        m.comparison.find((r: { label: string }) => r.label === 'Mentorship booking'),
      ).toMatchObject({ free: false, pro: true });
      expect(m.scholarshipNote).toMatch(/scholarship|free Pro/i);
    });
  });
});
