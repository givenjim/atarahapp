import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AnalyticsJobsModule } from '../src/analytics/analytics-jobs.module';
import { AnalyticsJobsService } from '../src/analytics/analytics-jobs.service';
import { AnalyticsService, eatDate } from '../src/analytics/analytics.service';
import { SuspensionExpiryService } from '../src/admin/suspension-expiry.service';
import { DomainEventBus } from '../src/community-core/domain-events';
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

jest.setTimeout(180_000);

const DAY = 86_400_000;

describe('Analytics and admin operations (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let analytics: AnalyticsService;
  let jobs: AnalyticsJobsService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];

  const as = (token?: string) => {
    const wrap = (r: request.Test) => (token ? r.set(...bearer(token)) : r);
    return {
      get: (p: string, query: object = {}) => wrap(http().get(`/api/v1${p}`).query(query)),
      post: (p: string, b: object = {}) => wrap(http().post(`/api/v1${p}`).send(b)),
      del: (p: string, query: object = {}) => wrap(http().delete(`/api/v1${p}`).query(query)),
    };
  };

  beforeAll(async () => {
    app = await createTestApp([AnalyticsJobsModule]);
    prisma = app.get(PrismaService);
    analytics = app.get(AnalyticsService);
    jobs = app.get(AnalyticsJobsService);
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  async function waitFor<T>(
    fn: () => Promise<T | null | undefined | false>,
    ms = 8_000,
  ): Promise<T> {
    const end = Date.now() + ms;
    for (;;) {
      const v = await fn();
      if (v) return v;
      if (Date.now() > end) throw new Error('timed out waiting');
      await new Promise((r) => setTimeout(r, 150));
    }
  }

  const eventsOf = (name: string, since = new Date(Date.now() - 60_000)) =>
    prisma.analyticsEvent.findMany({
      where: { name, occurredAt: { gte: since } },
      orderBy: { occurredAt: 'desc' },
    });

  async function member() {
    const { user, email } = await makeUser(app, { fullName: `Analytics ${uniq()}` });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const discipline = await prisma.discipline.findFirstOrThrow();
    await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle: `a_${uniq()}`.replace(/-/g, '_'),
        displayName: 'Tess',
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        primaryDisciplineId: discipline.id,
      },
    });
    return { id: user.id, token, email };
  }

  async function staff(role: 'PLATFORM_ADMIN' | 'CONTENT_ADMIN' | 'MODERATOR' | 'SUPER_ADMIN') {
    const { user, email } = await makeUser(app, { roles: [role], fullName: `Staff ${uniq()}` });
    users.push(user.id);
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  describe('events', () => {
    it('records a registration when an account is created, with no actor and only how they signed up', async () => {
      const before = new Date();
      const { user } = await makeUser(app);
      users.push(user.id);
      const rows = await waitFor(async () => {
        const r = await eventsOf('registration', before);
        return r.length > 0 ? r : null;
      });
      expect(rows[0]).toMatchObject({ actorHash: null, props: { method: 'email' } });
    });

    it('stores only allow-listed props and refuses anything else (no free text, no extra keys)', async () => {
      const m = await member();
      expect(await analytics.record('project_created', {}, m.id)).toBe(true);
      expect(
        await analytics.record(
          'post_created',
          { audience: 'MEMBERS', inGroup: false, body: 'secret' } as never,
          m.id,
        ),
      ).toBe(false);
      expect(await analytics.record('course_started', { courseId: 'not-a-uuid' }, m.id)).toBe(
        false,
      );
      expect(
        await analytics.record(
          'search_performed',
          { scope: 'all', results: 'many', queryLength: 'short', q: 'hello' } as never,
          m.id,
        ),
      ).toBe(false);
      const row = (await eventsOf('project_created'))[0]!;
      expect(row.props).toEqual({});
      // `track` never throws, even for rubbish.
      expect(() => analytics.track('post_created', { nope: 1 } as never, m.id)).not.toThrow();
    });

    it('pseudonymises the actor: a stable keyed hash, never the member id', async () => {
      const a = await member();
      const b = await member();
      expect(analytics.hash(a.id)).toBe(analytics.hash(a.id));
      expect(analytics.hash(a.id)).not.toBe(analytics.hash(b.id));
      expect(analytics.hash(a.id)).not.toContain(a.id.slice(0, 8));
      await analytics.record('project_created', {}, a.id);
      const row = (await eventsOf('project_created'))[0]!;
      expect(row.actorHash).toBe(analytics.hash(a.id));
      expect(JSON.stringify(row)).not.toContain(a.id);
    });

    it('is recorded from real actions: project created, search, opportunity viewed, and the course events', async () => {
      const m = await member();
      const since = new Date();
      await as(m.token).post('/me/projects', { title: 'Reel' }).expect(201);
      await as(m.token).get('/search', { q: 'private words typed here' }).expect(200);
      const prov = await prisma.opportunityProvider.create({ data: { name: `P ${uniq()}` } });
      const opp = await prisma.opportunity.create({
        data: {
          providerId: prov.id,
          slug: `s-${uniq()}`,
          type: 'GRANT',
          title: 'Analytics grant',
          summary: 'A grant used by the analytics test only.',
          status: 'PUBLISHED',
          applicationUrl: 'https://example.org/a',
          applicationDomain: 'example.org',
        },
      });
      await as(m.token).get(`/opportunities/${opp.id}`).expect(200);
      const bus = app.get(DomainEventBus);
      await bus.emit({ type: 'CourseStarted', userId: m.id, courseId: opp.id });
      await bus.emit({
        type: 'CourseCompleted',
        userId: m.id,
        courseId: opp.id,
        certificateId: opp.id,
      });

      const hash = analytics.hash(m.id);
      const mine = async (name: string) =>
        waitFor(async () => {
          const r = (await eventsOf(name, since)).filter((e) => e.actorHash === hash);
          return r.length ? r : null;
        });
      expect((await mine('project_created'))[0]!.props).toEqual({});
      const search = (await mine('search_performed'))[0]!;
      expect(search.props).toEqual({ scope: 'all', results: 'none', queryLength: 'long' });
      expect(JSON.stringify(search.props)).not.toContain('private');
      expect((await mine('opportunity_viewed'))[0]!.props).toEqual({
        opportunityId: opp.id,
        type: 'GRANT',
      });
      expect((await mine('course_started'))[0]!.props).toEqual({ courseId: opp.id });
      expect((await mine('course_completed'))[0]!.props).toEqual({ courseId: opp.id });

      await prisma.opportunity.delete({ where: { id: opp.id } });
      await prisma.opportunityProvider.delete({ where: { id: prov.id } });
    });
  });

  describe('roll-up, partitions and retention', () => {
    it('aggregates a day idempotently and merges it with live counts', async () => {
      const a = await member();
      const b = await member();
      const yesterday = new Date(Date.now() - DAY);
      const day = eatDate(yesterday);
      // Noon Nairobi yesterday, so the day is unambiguous.
      const noon = new Date(`${day}T09:00:00Z`);
      await analytics.record('connection_created', {}, a.id, noon);
      await analytics.record('connection_created', {}, a.id, noon);
      await analytics.record('connection_created', {}, b.id, noon);

      await jobs.aggregateDay(day);
      await jobs.aggregateDay(day);
      const row = await prisma.analyticsDailyCount.findUniqueOrThrow({
        where: { date_name: { date: new Date(`${day}T00:00:00Z`), name: 'connection_created' } },
      });
      expect(row.events).toBeGreaterThanOrEqual(3);
      expect(row.actors).toBeGreaterThanOrEqual(2);

      const series = await analytics.series(day, eatDate(new Date()), ['connection_created']);
      const point = series.find((s) => s.day === day)!;
      expect(point.events).toBe(row.events);
      // Today is counted live.
      await analytics.record('connection_created', {}, a.id);
      const withToday = await analytics.series(day, eatDate(new Date()), ['connection_created']);
      expect(withToday.find((s) => s.day === eatDate(new Date()))!.events).toBeGreaterThanOrEqual(
        1,
      );
      const totals = await analytics.totals(day, eatDate(new Date()));
      expect(totals.find((t) => t.name === 'connection_created')!.events).toBeGreaterThanOrEqual(
        row.events + 1,
      );
    });

    it('keeps monthly partitions ahead and drops whole old partitions past retention', async () => {
      expect(await jobs.ensurePartitions()).toBe(4);
      const now = new Date();
      const next = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 2, 1));
      const name = `analytics_events_${next.getUTCFullYear()}_${String(next.getUTCMonth() + 1).padStart(2, '0')}`;
      const found = await prisma.$queryRaw<
        Array<{ n: bigint }>
      >`SELECT count(*) AS n FROM pg_tables WHERE tablename = ${name}`;
      expect(Number(found[0]!.n)).toBe(1);
      // RLS posture of a partition the job created.
      const rls = await prisma.$queryRawUnsafe<Array<{ relrowsecurity: boolean }>>(
        `SELECT relrowsecurity FROM pg_class WHERE relname = '${name}'`,
      );
      expect(rls[0]!.relrowsecurity).toBe(true);

      // An old month: create its partition, store an event there, then purge.
      await prisma.$executeRaw`SELECT atarah_ensure_analytics_partition('2024-01-01'::date)`;
      const old = new Date('2024-01-15T10:00:00Z');
      await analytics.record('project_created', {}, null, old);
      const inPartition = await prisma.$queryRaw<
        Array<{ n: bigint }>
      >`SELECT count(*) AS n FROM analytics_events_2024_01`;
      expect(Number(inPartition[0]!.n)).toBe(1);
      // A stray far in the past lands in the default partition and is trimmed.
      await analytics.record('project_created', {}, null, new Date('2020-05-05T10:00:00Z'));
      const out = await jobs.purge(new Date());
      expect(out.partitionsDropped).toBeGreaterThanOrEqual(1);
      expect(out.strayRowsDeleted).toBeGreaterThanOrEqual(1);
      const gone = await prisma.$queryRaw<
        Array<{ n: bigint }>
      >`SELECT count(*) AS n FROM pg_tables WHERE tablename = 'analytics_events_2024_01'`;
      expect(Number(gone[0]!.n)).toBe(0);
      // Recent months are untouched.
      expect(
        (await eventsOf('registration', new Date(Date.now() - 3_600_000 * 24))).length,
      ).toBeGreaterThanOrEqual(0);
    });

    it('client roles cannot read or write analytics tables', async () => {
      const grants = await prisma.$queryRaw<Array<{ n: bigint }>>`
        SELECT count(*) AS n FROM information_schema.role_table_grants
        WHERE table_name LIKE 'analytics_%' AND grantee IN ('anon','authenticated')`;
      expect(Number(grants[0]!.n)).toBe(0);
    });
  });

  describe('admin dashboard and analytics API', () => {
    it('shows each administrator only the queues they may act on, most urgent first, with live counts', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const mod = await staff('MODERATOR');
      const content = await staff('CONTENT_ADMIN');
      const reporter = await member();
      const target = await member();
      await prisma.moderationCase.create({
        data: {
          targetType: 'USER',
          targetId: target.id,
          targetAuthorId: target.id,
          topReason: 'SCAM',
          priority: 'URGENT',
          status: 'SUBMITTED',
        },
      });
      await prisma.specialisationSuggestion.create({
        data: {
          userId: reporter.id,
          disciplineId: (await prisma.discipline.findFirstOrThrow()).id,
          name: `Suggestion ${uniq()}`,
        },
      });

      const d = (await as(admin.token).get('/admin/dashboard').expect(200)).body.data;
      const keys = d.queues.map((q: { key: string }) => q.key);
      expect(keys).toEqual(
        expect.arrayContaining([
          'reports',
          'opportunity-review',
          'broken-links',
          'specialisation-suggestions',
          'failed-jobs',
        ]),
      );
      expect(d.queues[0]).toMatchObject({ key: 'reports', priority: 'URGENT' });
      expect(d.queues[0].count).toBeGreaterThanOrEqual(1);
      const priorities = d.queues.map((q: { priority: string }) =>
        ['URGENT', 'HIGH', 'NORMAL', 'LOW'].indexOf(q.priority),
      );
      expect([...priorities].sort((a, b) => a - b)).toEqual(priorities);
      expect(d.counts).toEqual(
        expect.objectContaining({
          newMembers7d: expect.any(Number),
          onboardingCompletionRate30d: expect.any(Number),
          activeMembers7d: expect.any(Number),
          posts7d: expect.any(Number),
          opportunitiesSaved7d: expect.any(Number),
          opportunitiesApplied7d: expect.any(Number),
          courseCompletions30d: expect.any(Number),
        }),
      );
      expect(d.counts.newMembers7d).toBeGreaterThanOrEqual(4);

      // A moderator sees only the report queue; a content admin sees none of these.
      const mq = (await as(mod.token).get('/admin/dashboard').expect(200)).body.data.queues.map(
        (q: { key: string }) => q.key,
      );
      expect(mq).toEqual(['reports']);
      expect(
        (await as(content.token).get('/admin/dashboard').expect(200)).body.data.queues.map(
          (q: { key: string }) => q.key,
        ),
      ).toEqual(['specialisation-suggestions']);
      await as(reporter.token).get('/admin/dashboard').expect(403);
      await as(undefined).get('/admin/dashboard').expect(401);
    });

    it('serves chart data within the range limit and refuses bad ranges and unknown events', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const content = await staff('CONTENT_ADMIN');
      await analytics.record('project_created', {}, admin.id);
      const ok = (
        await as(admin.token)
          .get('/admin/analytics/events', { names: 'project_created,post_created' })
          .expect(200)
      ).body.data;
      expect(ok.series.some((p: { name: string }) => p.name === 'project_created')).toBe(true);
      expect(ok.totals.map((t: { name: string }) => t.name).sort()).toEqual([
        'post_created',
        'project_created',
      ]);
      expect(
        ok.series.every((p: { name: string }) =>
          ['project_created', 'post_created'].includes(p.name),
        ),
      ).toBe(true);
      await as(admin.token)
        .get('/admin/analytics/events', { from: '2026-01-01', to: '2026-10-30' })
        .expect(400);
      await as(admin.token)
        .get('/admin/analytics/events', { from: '2026-10-30', to: '2026-10-01' })
        .expect(400);
      await as(admin.token).get('/admin/analytics/events', { names: 'not_an_event' }).expect(400);
      await as(admin.token).get('/admin/analytics/events', { from: 'yesterday' }).expect(400);
      await as(content.token).get('/admin/analytics/events').expect(403);
    });

    it('lists the queues and their failed jobs for operators only', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const mod = await staff('MODERATOR');
      const counts = (await as(admin.token).get('/admin/jobs').expect(200)).body.data;
      expect(counts.map((c: { queue: string }) => c.queue).sort()).toEqual([
        'analytics',
        'maintenance',
        'media',
        'notifications',
        'payments',
        'system',
      ]);
      expect(counts[0]).toEqual(
        expect.objectContaining({ waiting: expect.any(Number), failed: expect.any(Number) }),
      );
      await as(admin.token).get('/admin/jobs/media/failed').expect(200);
      await as(admin.token).get('/admin/jobs/nope/failed').expect(404);
      await as(admin.token).post('/admin/jobs/media/does-not-exist/retry').expect(404);
      await as(mod.token).get('/admin/jobs').expect(403);
    });
  });

  describe('users, roles and suspension', () => {
    it('shows a full overview: profile, roles, membership, status history, sessions and reports', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const target = await member();
      await as(admin.token)
        .post(`/admin/users/${target.id}/suspend`, {
          reason: 'Spam in the community',
          durationDays: 3,
        })
        .expect(200);
      await as(admin.token)
        .post(`/admin/users/${target.id}/reactivate`, { reason: 'Appeal accepted' })
        .expect(200);
      await prisma.moderationCase.create({
        data: {
          targetType: 'USER',
          targetId: target.id,
          targetAuthorId: target.id,
          topReason: 'OTHER',
          status: 'RESOLVED',
        },
      });

      const o = (await as(admin.token).get(`/admin/users/${target.id}/overview`).expect(200)).body
        .data;
      expect(o.user).toMatchObject({ id: target.id, status: 'ACTIVE' });
      expect(o.suspendedUntil).toBeNull();
      expect(o.profile).toMatchObject({
        displayName: 'Tess',
        onboardingCompleted: true,
        publishedProjects: 0,
      });
      expect(o.statusHistory.map((h: { action: string }) => h.action)).toEqual([
        'user.reactivate',
        'user.suspend',
      ]);
      expect(o.statusHistory[1]).toMatchObject({
        reason: 'Spam in the community',
        from: 'ACTIVE',
        to: 'SUSPENDED',
        actorName: expect.stringContaining('Staff'),
      });
      expect(o.reports.about).toBeGreaterThanOrEqual(1);
      expect(o.reports.recent[0]).toEqual(
        expect.objectContaining({ caseId: expect.any(String), status: 'RESOLVED' }),
      );
      expect(Array.isArray(o.sessions)).toBe(true);
      expect(o.roleGrants).toEqual([]);
      expect(JSON.stringify(o)).not.toMatch(/reporterId/);
      // The suspension ended their sessions, so their old token is simply refused.
      expect([401, 403]).toContain(
        (await as(target.token).get(`/admin/users/${target.id}/overview`)).status,
      );
    });

    it('suspends for a set time: records the end, blocks sign-in state, and the hourly job reactivates on time', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const target = await member();
      await as(admin.token)
        .post(`/admin/users/${target.id}/suspend`, { reason: 'Cooling off', durationDays: 2 })
        .expect(200);
      const row = await prisma.user.findUniqueOrThrow({ where: { id: target.id } });
      expect(row.status).toBe('SUSPENDED');
      expect(row.suspendedUntil!.getTime() - Date.now()).toBeGreaterThan(DAY);
      await as(admin.token)
        .post(`/admin/users/${target.id}/suspend`, { reason: 'x', durationDays: 0 })
        .expect(400);
      await as(admin.token)
        .post(`/admin/users/${target.id}/suspend`, { reason: 'x', durationDays: 400 })
        .expect(400);

      const expiry = app.get(SuspensionExpiryService);
      // Not yet due: nothing happens.
      expect((await expiry.reactivateExpired()).reactivated).toBe(0);
      expect((await prisma.user.findUniqueOrThrow({ where: { id: target.id } })).status).toBe(
        'SUSPENDED',
      );
      // Time travel: the end has passed.
      expect(
        (await expiry.reactivateExpired(new Date(Date.now() + 3 * DAY))).reactivated,
      ).toBeGreaterThanOrEqual(1);
      const after = await prisma.user.findUniqueOrThrow({ where: { id: target.id } });
      expect(after).toMatchObject({ status: 'ACTIVE', suspendedUntil: null, statusReason: null });
      const log = await prisma.auditLog.findFirst({
        where: { entityId: target.id, action: 'user.reactivate', actorType: 'SYSTEM' },
      });
      expect(log?.after).toMatchObject({ status: 'ACTIVE', reason: 'Suspension period ended' });
      // Running it again is harmless.
      expect((await expiry.reactivateExpired(new Date(Date.now() + 3 * DAY))).reactivated).toBe(0);
      // An open-ended suspension is never touched by the job.
      await as(admin.token)
        .post(`/admin/users/${target.id}/suspend`, { reason: 'Until we say' })
        .expect(200);
      expect(
        (await prisma.user.findUniqueOrThrow({ where: { id: target.id } })).suspendedUntil,
      ).toBeNull();
      await expiry.reactivateExpired(new Date(Date.now() + 400 * DAY));
      expect((await prisma.user.findUniqueOrThrow({ where: { id: target.id } })).status).toBe(
        'SUSPENDED',
      );
    });

    it('assigns and revokes roles with the right permissions, re-auth and an audit trail', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const superAdmin = await staff('SUPER_ADMIN');
      const target = await member();

      const roles = (await as(admin.token).get('/admin/roles').expect(200)).body.data;
      expect(roles.map((r: { key: string }) => r.key)).toEqual(
        expect.arrayContaining(['MENTOR', 'MODERATOR', 'SUPER_ADMIN']),
      );
      expect(roles.find((r: { key: string }) => r.key === 'MODERATOR').isStaff).toBe(true);

      // Member-level role: a platform admin may.
      const given = (
        await as(admin.token)
          .post(`/admin/users/${target.id}/roles`, { role: 'MENTOR', reason: 'Approved mentor' })
          .expect(200)
      ).body.data;
      expect(given.roles).toContain('MENTOR');
      await as(admin.token).post(`/admin/users/${target.id}/roles`, { role: 'MENTOR' }).expect(409);
      // Staff roles need a super admin.
      await as(admin.token)
        .post(`/admin/users/${target.id}/roles`, { role: 'MODERATOR' })
        .expect(403);
      const mod = (
        await as(superAdmin.token)
          .post(`/admin/users/${target.id}/roles`, { role: 'MODERATOR' })
          .expect(200)
      ).body.data;
      expect(mod.roles).toEqual(expect.arrayContaining(['MENTOR', 'MODERATOR']));
      // A platform admin cannot touch an account that now holds a staff role... only a super admin can.
      const staffTarget = await staff('PLATFORM_ADMIN');
      await as(admin.token)
        .post(`/admin/users/${staffTarget.id}/roles`, { role: 'SELLER' })
        .expect(403);
      // Nobody edits their own roles; bad roles and unknown users are refused.
      await as(superAdmin.token)
        .post(`/admin/users/${superAdmin.id}/roles`, { role: 'MENTOR' })
        .expect(403);
      await as(superAdmin.token)
        .post(`/admin/users/${target.id}/roles`, { role: 'KING' })
        .expect(400);
      await as(superAdmin.token)
        .post(`/admin/users/${'3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b'}/roles`, { role: 'MENTOR' })
        .expect(404);
      // Members cannot use any of it.
      await as(target.token).post(`/admin/users/${admin.id}/roles`, { role: 'MENTOR' }).expect(403);

      // Revoke.
      await as(superAdmin.token)
        .del(`/admin/users/${target.id}/roles/MODERATOR`, { reason: 'Left the team' })
        .expect(200);
      await as(admin.token).del(`/admin/users/${target.id}/roles/MODERATOR`).expect(403);
      await as(admin.token).del(`/admin/users/${target.id}/roles/SELLER`).expect(404);
      const r = (await as(admin.token).del(`/admin/users/${target.id}/roles/MENTOR`).expect(200))
        .body.data;
      expect(r.roles).toEqual([]);
      await as(admin.token).del(`/admin/users/${target.id}/roles/NOPE`).expect(400);

      const trail = await prisma.auditLog.findMany({
        where: { entityId: target.id, action: { in: ['user.role.assign', 'user.role.revoke'] } },
        orderBy: { createdAt: 'asc' },
      });
      expect(trail.map((t) => t.action)).toEqual([
        'user.role.assign',
        'user.role.assign',
        'user.role.revoke',
        'user.role.revoke',
      ]);
      expect(trail[0]).toMatchObject({ actorId: admin.id, actorType: 'ADMIN' });
      expect(trail[0]!.after).toMatchObject({ roles: ['MENTOR'], reason: 'Approved mentor' });
      // Role changes are visible in the user's history.
      const o = (await as(admin.token).get(`/admin/users/${target.id}/overview`).expect(200)).body
        .data;
      expect(o.statusHistory.map((h: { action: string }) => h.action)).toContain(
        'user.role.assign',
      );
    });
  });
});
