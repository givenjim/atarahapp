import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { SafeFetcher } from '../src/community/jobs/safe-fetch';
import { OpportunityJobsModule } from '../src/opportunities/jobs/opportunity-jobs.module';
import { OpportunityJobsService } from '../src/opportunities/jobs/opportunity-jobs.service';
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
}

const DAY = 86_400_000;
const inDays = (n: number) => new Date(Date.now() + n * DAY);

describe('Opportunities (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let jobs: OpportunityJobsService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];
  const created = { providers: [] as string[], opportunities: [] as string[] };

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
    app = await createTestApp([OpportunityJobsModule]);
    prisma = app.get(PrismaService);
    jobs = app.get(OpportunityJobsService);
  });
  afterAll(async () => {
    await prisma.opportunity.deleteMany({ where: { id: { in: created.opportunities } } });
    await prisma.opportunityProvider.deleteMany({ where: { id: { in: created.providers } } });
    await deleteUsers(app, users);
    await app.close();
  });

  async function member(
    o: { countyCode?: string; discipline?: string; projects?: number; skills?: string[] } = {},
  ): Promise<Member> {
    const { user, email } = await makeUser(app, { fullName: `Tess ${uniq()}` });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const discipline = await prisma.discipline.findFirstOrThrow({
      where: { name: o.discipline ?? 'Film / Video' },
    });
    const county = await prisma.county.findFirstOrThrow({ where: { code: o.countyCode ?? 'NBI' } });
    const profile = await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle: `c_${uniq()}`.replace(/-/g, '_'),
        displayName: 'Tess',
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        primaryDisciplineId: discipline.id,
        countryId: county.countryId,
        countyId: county.id,
        disciplines: { create: [{ disciplineId: discipline.id, isPrimary: true }] },
      },
    });
    for (let i = 0; i < (o.projects ?? 0); i += 1) {
      await prisma.project.create({
        data: {
          profileId: profile.id,
          title: `Project ${i}`,
          status: 'PUBLISHED',
          publishedAt: new Date(),
        },
      });
    }
    for (const skillId of o.skills ?? []) {
      await prisma.creativeSkill.create({ data: { profileId: profile.id, skillId } });
    }
    return { id: user.id, token, email };
  }

  async function staff(role: 'PLATFORM_ADMIN' | 'CONTENT_ADMIN' | 'OPPORTUNITY_PROVIDER') {
    const { user, email } = await makeUser(app, { roles: [role], fullName: `Staff ${uniq()}` });
    users.push(user.id);
    if (role === 'OPPORTUNITY_PROVIDER') {
      return { id: user.id, token: (await loginMember(app, email)).accessToken };
    }
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  async function provider(
    admin: { token: string },
    name = `Provider ${uniq()}`,
    extra: object = {},
  ) {
    const res = await as(admin.token)
      .post('/admin/opportunity-providers', { name, type: 'NGO', ...extra })
      .expect(201);
    created.providers.push(res.body.data.id);
    return res.body.data as { id: string; name: string };
  }

  const fields = (providerId: string, over: object = {}) => ({
    providerId,
    title: `Opportunity ${uniq()}`,
    type: 'GRANT',
    summary: 'A fund for creatives who want to make something new this year.',
    applicationUrl: 'https://funds.example.org/apply',
    deadlineAt: inDays(30).toISOString(),
    ...over,
  });

  /** Creates a listing as staff and (by default) publishes it. */
  async function listing(
    admin: { token: string },
    providerId: string,
    over: object = {},
    publish = true,
  ) {
    const res = await as(admin.token)
      .post('/admin/opportunities', fields(providerId, over))
      .expect(201);
    const id = res.body.data.id as string;
    created.opportunities.push(id);
    if (publish) await as(admin.token).post(`/admin/opportunities/${id}/publish`).expect(200);
    return res.body.data as { id: string; title: string };
  }

  // ---------------------------------------------------------------------------------------------------------------

  describe('discovery', () => {
    it('a draft is invisible; publishing makes it appear; filters and sorts work', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const mombasa = await prisma.county.findFirstOrThrow({ where: { code: 'MSA' } });
      const tag = `zz${uniq()}`;

      const draft = await listing(admin, prov.id, { title: `${tag} draft` }, false);
      await as(m.token).get(`/opportunities/${draft.id}`).expect(404);
      const none = await as(m.token).get('/opportunities', { q: tag }).expect(200);
      expect(none.body.meta.total).toBe(0);

      const grant = await listing(admin, prov.id, {
        title: `${tag} grant soonest`,
        type: 'GRANT',
        deadlineAt: inDays(5).toISOString(),
        valueMin: 100000,
        valueMax: 500000,
      });
      const job = await listing(admin, prov.id, {
        title: `${tag} job remote`,
        type: 'JOB',
        workMode: 'REMOTE',
        deadlineAt: inDays(20).toISOString(),
        valueText: 'Paid stipend',
      });
      const gig = await listing(admin, prov.id, {
        title: `${tag} gig mombasa`,
        type: 'GIG',
        countyId: mombasa.id,
        deadlineAt: inDays(40).toISOString(),
      });
      const rolling = await listing(admin, prov.id, {
        title: `${tag} rolling`,
        type: 'GRANT',
        deadlineAt: null,
      });

      const all = await as(m.token).get('/opportunities', { q: tag }).expect(200);
      expect(all.body.meta.total).toBe(4);
      // Deadline: soonest first, a rolling deadline last.
      expect(all.body.data.map((o: { id: string }) => o.id)).toEqual([
        grant.id,
        job.id,
        gig.id,
        rolling.id,
      ]);
      const first = all.body.data[0];
      expect(first).toMatchObject({
        valueLabel: 'KES 100,000 to 500,000',
        urgency: 'URGENT',
        trust: 'EXTERNAL_SOURCE',
        saved: false,
        closed: false,
      });
      expect(first.provider).toMatchObject({ id: prov.id, verified: false });

      const grants = await as(m.token).get('/opportunities', { q: tag, type: 'GRANT' }).expect(200);
      expect(grants.body.meta.total).toBe(2);
      const remote = await as(m.token).get('/opportunities', { q: tag, remote: true }).expect(200);
      expect(remote.body.data.map((o: { id: string }) => o.id)).toEqual([job.id]);
      const within14 = await as(m.token)
        .get('/opportunities', { q: tag, deadline: '14d' })
        .expect(200);
      expect(within14.body.data.map((o: { id: string }) => o.id)).toEqual([grant.id]);
      const msa = await as(m.token)
        .get('/opportunities', { q: tag, countyId: mombasa.id })
        .expect(200);
      // Mombasa, plus remote and nationwide (no county) listings.
      expect(msa.body.meta.total).toBe(4);
      const verified = await as(m.token)
        .get('/opportunities', { q: tag, trust: 'VERIFIED' })
        .expect(200);
      expect(verified.body.meta.total).toBe(0);
      const recent = await as(m.token)
        .get('/opportunities', { q: tag, sort: 'recent' })
        .expect(200);
      expect(recent.body.data[0].id).toBe(rolling.id);
      const relevance = await as(m.token)
        .get('/opportunities', { q: tag, sort: 'relevance' })
        .expect(200);
      expect(relevance.body.meta.total).toBe(4);

      const paged = await as(m.token)
        .get('/opportunities', { q: tag, limit: 2, page: 2 })
        .expect(200);
      expect(paged.body.data).toHaveLength(2);
      expect(paged.body.meta).toMatchObject({ page: 2, limit: 2, total: 4 });

      const detail = await as(m.token).get(`/opportunities/${job.id}`).expect(200);
      expect(detail.body.data).toMatchObject({
        applicationMethod: 'EXTERNAL_WEBSITE',
        applicationUrl: 'https://funds.example.org/apply',
        applicationDomain: 'funds.example.org',
        valueLabel: 'Paid stipend',
        locationLabel: 'Remote',
      });
      await as(undefined).get('/opportunities').expect(401);
    });

    it('home: categories, closing soon with urgency, featured, recent and the saved count', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const urgent = await listing(admin, prov.id, {
        type: 'COMPETITION',
        deadlineAt: inDays(3).toISOString(),
      });
      const soon = await listing(admin, prov.id, {
        type: 'FESTIVAL',
        deadlineAt: inDays(10).toISOString(),
      });
      const far = await listing(admin, prov.id, {
        type: 'INTERNSHIP',
        deadlineAt: inDays(60).toISOString(),
      });

      await as(admin.token)
        .post(`/admin/opportunities/${far.id}/feature`, { until: inDays(7).toISOString() })
        .expect(200);
      await as(m.token).put(`/opportunities/${urgent.id}/save`).expect(200);

      const home = (await as(m.token).get('/opportunities/home').expect(200)).body.data;
      expect(home.savedCount).toBe(1);
      expect(home.categories.map((c: { type: string }) => c.type)).toEqual([
        'FUNDING',
        'GRANT',
        'JOB',
        'INTERNSHIP',
        'GIG',
        'COMPETITION',
        'FESTIVAL',
        'PARTNERSHIP',
      ]);
      expect(
        home.categories.find((c: { type: string }) => c.type === 'COMPETITION').count,
      ).toBeGreaterThanOrEqual(1);
      const closing = home.closingSoon.map((c: { id: string }) => c.id);
      expect(closing).toEqual(expect.arrayContaining([urgent.id, soon.id]));
      expect(closing).not.toContain(far.id);
      expect(closing.indexOf(urgent.id)).toBeLessThan(closing.indexOf(soon.id));
      const byId = Object.fromEntries(
        home.closingSoon.map((c: { id: string; urgency: string }) => [c.id, c.urgency]),
      );
      expect(byId[urgent.id]).toBe('URGENT');
      expect(byId[soon.id]).toBe('SOON');
      expect(home.featured.map((c: { id: string }) => c.id)).toContain(far.id);
      expect(home.featured.find((c: { id: string }) => c.id === far.id).featured).toBe(true);
      expect(home.recent.length).toBeGreaterThan(0);

      // Once applied, a listing stops being "closing soon" for that member only.
      await as(m.token)
        .post(`/opportunities/${urgent.id}/track`, { status: 'APPLIED' })
        .expect(200);
      const after = (await as(m.token).get('/opportunities/home').expect(200)).body.data;
      expect(after.closingSoon.map((c: { id: string }) => c.id)).not.toContain(urgent.id);
      const other = await member();
      const otherHome = (await as(other.token).get('/opportunities/home').expect(200)).body.data;
      expect(otherHome.closingSoon.map((c: { id: string }) => c.id)).toContain(urgent.id);
      expect(otherHome.savedCount).toBe(0);
    });

    it('search returns an opportunities group with the open matches only', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const word = `Quillfund${uniq()}`.replace(/[^a-z0-9]/gi, '');
      const open = await listing(admin, prov.id, { title: `${word} residency call` });
      await listing(admin, prov.id, { title: `${word} hidden draft` }, false);
      const res = await as(m.token).get('/search', { q: word, type: 'opportunities' }).expect(200);
      expect(res.body.data.groups).toHaveLength(1);
      const group = res.body.data.groups[0];
      expect(group.type).toBe('opportunities');
      expect(group.count).toBe(1);
      expect(group.items[0]).toMatchObject({ id: open.id, path: `/opportunities/${open.id}` });
      const mixed = await as(m.token).get('/search', { q: word }).expect(200);
      expect(mixed.body.data.groups.map((g: { type: string }) => g.type)).toContain(
        'opportunities',
      );
    });
  });

  describe('profile-gap check', () => {
    it('is computed on the server from the member’s own profile, and refresh sees edits', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const film = await prisma.discipline.findFirstOrThrow({ where: { name: 'Film / Video' } });
      const skill = await prisma.skill.findFirstOrThrow();
      const prov = await provider(admin);
      const opp = await listing(admin, prov.id, {
        title: `Gap ${uniq()}`,
        rules: [
          {
            ruleType: 'MIN_PROJECTS',
            params: { count: 3 },
            label: 'At least 3 published projects',
          },
          { ruleType: 'SKILL_IN', params: { skillIds: [skill.id] }, label: 'A relevant skill' },
          {
            ruleType: 'DISCIPLINE_IN',
            params: { disciplineIds: [film.id] },
            label: 'Film or video',
          },
          { ruleType: 'RESIDENCY', params: { countryCode: 'KE' }, label: 'Based in Kenya' },
          { ruleType: 'AGE_RANGE', params: { min: 18, max: 35 }, label: 'Aged 18 to 35' },
        ],
      });
      const m = await member({ projects: 1 });

      const first = (await as(m.token).get(`/opportunities/${opp.id}`).expect(200)).body.data
        .profileGap;
      expect(first).toMatchObject({
        verdict: 'MISSING',
        metCount: 2,
        missingCount: 2,
        unknownCount: 1,
        blockingMissingCount: 2,
      });
      const projectsRule = first.rules.find(
        (r: { ruleType: string }) => r.ruleType === 'MIN_PROJECTS',
      );
      expect(projectsRule).toMatchObject({
        state: 'MISSING',
        detail: 'You have 1 of 3 published projects.',
        fix: { label: 'Add', path: '/portfolio/new/edit' },
      });
      expect(first.rules.find((r: { ruleType: string }) => r.ruleType === 'AGE_RANGE').state).toBe(
        'UNKNOWN',
      );

      // The member fixes two things. Within 5 minutes the cached result is served until they ask for a refresh.
      const profile = await prisma.creativeProfile.findUniqueOrThrow({ where: { userId: m.id } });
      await prisma.creativeSkill.create({ data: { profileId: profile.id, skillId: skill.id } });
      for (let i = 0; i < 2; i += 1) {
        await prisma.project.create({
          data: {
            profileId: profile.id,
            title: `Extra ${i}`,
            status: 'PUBLISHED',
            publishedAt: new Date(),
          },
        });
      }
      const cached = (await as(m.token).get(`/opportunities/${opp.id}`).expect(200)).body.data
        .profileGap;
      expect(cached.missingCount).toBe(2);
      const fresh = (
        await as(m.token).get(`/opportunities/${opp.id}`, { refresh: true }).expect(200)
      ).body.data.profileGap;
      expect(fresh).toMatchObject({
        verdict: 'READY',
        metCount: 4,
        missingCount: 0,
        unknownCount: 1,
      });

      // A different member gets their own answer, never someone else's profile.
      const other = await member({ projects: 0 });
      const theirs = (await as(other.token).get(`/opportunities/${opp.id}`).expect(200)).body.data
        .profileGap;
      expect(theirs.missingCount).toBe(2);
      expect(JSON.stringify(theirs)).not.toContain(m.id);
    });

    it('a listing with no rules says so', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const opp = await listing(admin, prov.id);
      const gap = (await as(m.token).get(`/opportunities/${opp.id}`).expect(200)).body.data
        .profileGap;
      expect(gap).toMatchObject({ verdict: 'NO_RULES', rules: [] });
    });

    it('invalid rule settings are refused when staff save them', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const prov = await provider(admin);
      const res = await as(admin.token)
        .post(
          '/admin/opportunities',
          fields(prov.id, {
            rules: [{ ruleType: 'MIN_PROJECTS', params: { count: 0 }, label: 'Bad' }],
          }),
        )
        .expect(400);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
    });
  });

  describe('saving and tracking', () => {
    it('follows SAVED → IN_PROGRESS → APPLIED → COMPLETED and refuses the rest', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const a = await listing(admin, prov.id);
      const b = await listing(admin, prov.id);

      // Save is idempotent; un-save removes the record.
      const s1 = await as(m.token).put(`/opportunities/${a.id}/save`).expect(200);
      expect(s1.body.data.status).toBe('SAVED');
      await as(m.token).put(`/opportunities/${a.id}/save`).expect(200);
      expect(
        await prisma.opportunityTracking.count({ where: { userId: m.id, opportunityId: a.id } }),
      ).toBe(1);
      await as(m.token).del(`/opportunities/${a.id}/save`).expect(204);
      expect(
        await prisma.opportunityTracking.count({ where: { userId: m.id, opportunityId: a.id } }),
      ).toBe(0);
      await as(m.token).del(`/opportunities/${a.id}/save`).expect(204);

      // Cannot complete before applying.
      await as(m.token).post(`/opportunities/${a.id}/track`, { status: 'COMPLETED' }).expect(409);
      await as(m.token).put(`/opportunities/${a.id}/save`).expect(200);
      await as(m.token).post(`/opportunities/${a.id}/track`, { status: 'IN_PROGRESS' }).expect(200);
      // Started: un-saving is no longer allowed.
      const refuse = await as(m.token).del(`/opportunities/${a.id}/save`).expect(409);
      expect(refuse.body.error.code).toBe('INVALID_STATE');
      await as(m.token).post(`/opportunities/${a.id}/track`, { status: 'COMPLETED' }).expect(409);
      const applied = await as(m.token)
        .post(`/opportunities/${a.id}/track`, { status: 'APPLIED', notes: 'Sent portfolio' })
        .expect(200);
      expect(applied.body.data.status).toBe('APPLIED');
      expect(applied.body.data.appliedAt).not.toBeNull();
      // No going back; the same step again is harmless.
      await as(m.token).post(`/opportunities/${a.id}/track`, { status: 'SAVED' }).expect(409);
      await as(m.token).post(`/opportunities/${a.id}/track`, { status: 'APPLIED' }).expect(200);
      // An outcome only belongs to a completed application.
      await as(m.token)
        .post(`/opportunities/${a.id}/track`, { status: 'APPLIED', outcome: 'AWARDED' })
        .expect(400);
      const done = await as(m.token)
        .post(`/opportunities/${a.id}/track`, { status: 'COMPLETED', outcome: 'AWARDED' })
        .expect(200);
      expect(done.body.data).toMatchObject({ status: 'COMPLETED', outcome: 'AWARDED' });
      await as(m.token).post(`/opportunities/${a.id}/track`, { status: 'APPLIED' }).expect(409);

      // "Leave to apply" straight from a card that was never saved records APPLIED in one step.
      const direct = await as(m.token)
        .post(`/opportunities/${b.id}/track`, { status: 'APPLIED' })
        .expect(200);
      expect(direct.body.data.status).toBe('APPLIED');

      const detail = (await as(m.token).get(`/opportunities/${a.id}`).expect(200)).body.data;
      expect(detail.tracking.status).toBe('COMPLETED');
      expect(detail.saved).toBe(false);
      expect(detail.urgency).toBeNull();

      // Nobody else is affected.
      const other = await member();
      const theirs = (await as(other.token).get(`/opportunities/${a.id}`).expect(200)).body.data;
      expect(theirs.tracking).toBeNull();
    });

    it('My opportunities: tabs, counts, and the empty states', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const closing = await listing(admin, prov.id, { deadlineAt: inDays(4).toISOString() });
      const later = await listing(admin, prov.id, { deadlineAt: inDays(45).toISOString() });
      const applied = await listing(admin, prov.id);
      const finished = await listing(admin, prov.id);

      const empty = await as(m.token).get('/me/opportunities', { tab: 'completed' }).expect(200);
      expect(empty.body.data).toEqual([]);
      expect(empty.body.meta.counts).toEqual({
        all: 0,
        closing: 0,
        applied: 0,
        completed: 0,
        saved: 0,
      });

      await as(m.token).put(`/opportunities/${closing.id}/save`).expect(200);
      await as(m.token).put(`/opportunities/${later.id}/save`).expect(200);
      await as(m.token)
        .post(`/opportunities/${applied.id}/track`, { status: 'APPLIED' })
        .expect(200);
      await as(m.token)
        .post(`/opportunities/${finished.id}/track`, { status: 'APPLIED' })
        .expect(200);
      await as(m.token)
        .post(`/opportunities/${finished.id}/track`, {
          status: 'COMPLETED',
          outcome: 'NOT_SELECTED',
        })
        .expect(200);

      const ids = async (tab: string) =>
        (await as(m.token).get('/me/opportunities', { tab }).expect(200)).body.data.map(
          (r: { opportunity: { id: string } }) => r.opportunity.id,
        );
      expect((await ids('all')).sort()).toEqual(
        [closing.id, later.id, applied.id, finished.id].sort(),
      );
      expect(await ids('closing')).toEqual([closing.id]);
      expect(await ids('applied')).toEqual([applied.id]);
      expect(await ids('completed')).toEqual([finished.id]);
      expect((await ids('saved')).sort()).toEqual([closing.id, later.id].sort());
      const counts = (await as(m.token).get('/me/opportunities').expect(200)).body.meta.counts;
      expect(counts).toEqual({ all: 4, closing: 1, applied: 1, completed: 1, saved: 2 });
      const completed = (
        await as(m.token).get('/me/opportunities', { tab: 'completed' }).expect(200)
      ).body.data[0];
      expect(completed.tracking).toMatchObject({ status: 'COMPLETED', outcome: 'NOT_SELECTED' });
    });

    it('an expired listing stays reachable for members tracking it, but nobody can start tracking it', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const other = await member();
      const prov = await provider(admin);
      const opp = await listing(admin, prov.id, { deadlineAt: inDays(2).toISOString() });
      await as(m.token).put(`/opportunities/${opp.id}/save`).expect(200);
      await as(m.token).post(`/opportunities/${opp.id}/track`, { status: 'APPLIED' }).expect(200);

      // The deadline passes and the hourly job runs.
      await prisma.opportunity.update({
        where: { id: opp.id },
        data: { deadlineAt: new Date(Date.now() - 3_600_000) },
      });
      const ran = await jobs.expireOverdue();
      expect(ran.expired).toBeGreaterThanOrEqual(1);
      expect((await prisma.opportunity.findUniqueOrThrow({ where: { id: opp.id } })).status).toBe(
        'EXPIRED',
      );

      await as(other.token).get(`/opportunities/${opp.id}`).expect(404);
      await as(other.token).put(`/opportunities/${opp.id}/save`).expect(404);
      const kept = (await as(m.token).get(`/opportunities/${opp.id}`).expect(200)).body.data;
      expect(kept.closed).toBe(true);
      // The member can still record that they finished.
      await as(m.token)
        .post(`/opportunities/${opp.id}/track`, { status: 'COMPLETED', outcome: 'AWARDED' })
        .expect(200);
      const listed = await as(other.token).get('/opportunities', { q: opp.title }).expect(200);
      expect(listed.body.meta.total).toBe(0);
    });
  });

  describe('jobs', () => {
    it('sends 7-day and 1-day reminders once, to members who saved it, respecting preferences', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const prov = await provider(admin);
      const week = await listing(admin, prov.id, {
        title: `Week ${uniq()}`,
        deadlineAt: inDays(7).toISOString(),
      });
      const tomorrow = await listing(admin, prov.id, {
        title: `Tomorrow ${uniq()}`,
        deadlineAt: inDays(1).toISOString(),
      });
      const mid = await listing(admin, prov.id, {
        title: `Mid ${uniq()}`,
        deadlineAt: inDays(4).toISOString(),
      });

      const saver = await member();
      const optedOut = await member();
      const applier = await member();
      for (const m of [saver, optedOut, applier]) {
        for (const o of [week, tomorrow, mid])
          await as(m.token).put(`/opportunities/${o.id}/save`).expect(200);
      }
      await as(applier.token)
        .post(`/opportunities/${week.id}/track`, { status: 'APPLIED' })
        .expect(200);
      await prisma.notificationPreference.create({
        data: {
          userId: optedOut.id,
          category: 'OPPORTUNITIES',
          pushEnabled: false,
          emailEnabled: false,
        },
      });

      const first = await jobs.sendDeadlineReminders();
      expect(first.sent).toBeGreaterThanOrEqual(3);
      const notes = (userId: string) =>
        prisma.notification.findMany({
          where: { userId, category: 'OPPORTUNITIES' },
          orderBy: { title: 'asc' },
        });

      const saverNotes = await notes(saver.id);
      expect(saverNotes.map((n) => n.title).sort()).toEqual(['Closes tomorrow', 'One week left']);
      expect(saverNotes.find((n) => n.title === 'One week left')!.deepLink).toBe(
        `/opportunities/${week.id}`,
      );
      // Nothing for the 4-day listing, nothing for the member who opted out, and nothing for a listing already applied to.
      expect(saverNotes.some((n) => n.deepLink === `/opportunities/${mid.id}`)).toBe(false);
      expect(await notes(optedOut.id)).toHaveLength(0);
      expect((await notes(applier.id)).map((n) => n.title)).toEqual(['Closes tomorrow']);

      // Running again (or on a second worker) sends nothing new.
      const second = await jobs.sendDeadlineReminders();
      expect(second.sent).toBe(0);
      expect(await notes(saver.id)).toHaveLength(2);
    });

    it('link health flags a broken link for admins and never changes the listing', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const prov = await provider(admin);
      const good = await listing(admin, prov.id, {
        applicationUrl: 'https://good.example.org/apply',
      });
      const bad = await listing(admin, prov.id, {
        applicationUrl: 'https://gone.example.org/apply',
      });
      const blocked = await listing(admin, prov.id, {
        applicationUrl: 'https://picky.example.org/apply',
      });

      const fetcher = app.get(SafeFetcher);
      const real = fetcher.probe.bind(fetcher);
      fetcher.probe = jest.fn(async (url: string) => {
        if (url.includes('gone.')) return { status: 404, url };
        if (url.includes('picky.')) return { status: 403, url };
        if (url.includes('good.')) return { status: 200, url };
        return real(url);
      });
      try {
        const out = await jobs.checkLinks();
        expect(out.checked).toBeGreaterThanOrEqual(3);
      } finally {
        fetcher.probe = real;
      }

      const row = (id: string) => prisma.opportunity.findUniqueOrThrow({ where: { id } });
      expect((await row(good.id)).linkStatus).toBe('OK');
      // 403 means the site refuses robots, not that the link is dead.
      expect((await row(blocked.id)).linkStatus).toBe('OK');
      const flagged = await row(bad.id);
      expect(flagged.linkStatus).toBe('BROKEN');
      expect(flagged.status).toBe('PUBLISHED');
      expect(flagged.applicationUrl).toBe('https://gone.example.org/apply');

      const report = await as(admin.token).get('/admin/opportunities/link-health').expect(200);
      const item = report.body.data.find(
        (i: { opportunityId: string }) => i.opportunityId === bad.id,
      );
      expect(item).toMatchObject({ httpStatus: 404, linkStatus: 'BROKEN' });
      expect(
        report.body.data.some((i: { opportunityId: string }) => i.opportunityId === good.id),
      ).toBe(false);

      // Checked this week: a second run leaves it alone.
      const again = await jobs.checkLinks();
      expect(again.checked).toBe(0);
    });

    it('refuses private addresses instead of fetching them', async () => {
      await expect(app.get(SafeFetcher).probe('http://127.0.0.1/')).rejects.toThrow(/Private/);
      await expect(app.get(SafeFetcher).probe('http://localhost/')).rejects.toThrow(/Internal/);
    });

    it('keeps provider counts right', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const prov = await provider(admin);
      const a = await listing(admin, prov.id);
      await listing(admin, prov.id);
      await listing(admin, prov.id, {}, false);
      expect(
        (await as(admin.token).get(`/admin/opportunity-providers/${prov.id}`).expect(200)).body.data
          .opportunitiesCount,
      ).toBe(2);
      await as(admin.token).post(`/admin/opportunities/${a.id}/close`).expect(200);
      expect(
        (await as(admin.token).get(`/admin/opportunity-providers/${prov.id}`).expect(200)).body.data
          .opportunitiesCount,
      ).toBe(1);
      await prisma.opportunityProvider.update({
        where: { id: prov.id },
        data: { opportunitiesCount: 99 },
      });
      await jobs.refreshCounts();
      expect(
        (await prisma.opportunityProvider.findUniqueOrThrow({ where: { id: prov.id } }))
          .opportunitiesCount,
      ).toBe(1);
    });
  });

  describe('trust, review and permissions', () => {
    it('a provider cannot set trust or publish; submissions land in PENDING_REVIEW with the lowest trust', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const owner = await staff('OPPORTUNITY_PROVIDER');
      const prov = await provider(admin, `Own ${uniq()}`, { ownerUserId: owner.id });
      const stranger = await provider(admin);

      // The request body has no `trust` field: sending one is refused outright.
      await as(owner.token)
        .post('/provider/opportunities', fields(prov.id, { trust: 'VERIFIED' }))
        .expect(400);
      // Nor for someone else's organisation.
      await as(owner.token).post('/provider/opportunities', fields(stranger.id)).expect(403);

      const sub = (
        await as(owner.token).post('/provider/opportunities', fields(prov.id)).expect(201)
      ).body.data;
      created.opportunities.push(sub.id);
      expect(sub).toMatchObject({ status: 'PENDING_REVIEW', trust: 'EXTERNAL_SOURCE' });
      await as(owner.token)
        .patch(`/provider/opportunities/${sub.id}`, { trust: 'VERIFIED' })
        .expect(400);

      // None of the staff routes work for a provider.
      for (const path of ['publish', 'verify', 'set-trust', 'feature']) {
        await as(owner.token)
          .post(`/admin/opportunities/${sub.id}/${path}`, { trust: 'VERIFIED' })
          .expect(403);
      }
      await as(owner.token).get('/admin/opportunities').expect(403);

      // Members do not see it until staff publish.
      const m = await member();
      await as(m.token).get(`/opportunities/${sub.id}`).expect(404);
      const own = await as(owner.token).get('/provider/opportunities').expect(200);
      expect(own.body.data.map((o: { id: string }) => o.id)).toContain(sub.id);
      const orgs = await as(owner.token).get('/provider/organisations').expect(200);
      expect(orgs.body.data.map((p: { id: string }) => p.id)).toEqual([prov.id]);
      // A provider sees only their own listings.
      const foreign = await listing(admin, stranger.id);
      await as(owner.token).get(`/provider/opportunities/${foreign.id}`).expect(404);
      await as(owner.token)
        .patch(`/provider/opportunities/${foreign.id}`, { title: 'Hijack' })
        .expect(404);

      // Staff publish: the provider is told, and the listing is still not "verified".
      await as(admin.token).post(`/admin/opportunities/${sub.id}/publish`).expect(200);
      const live = (await as(m.token).get(`/opportunities/${sub.id}`).expect(200)).body.data;
      expect(live.trust).toBe('EXTERNAL_SOURCE');
      const told = await prisma.notification.findMany({
        where: { userId: owner.id, category: 'OPPORTUNITIES' },
      });
      expect(told.map((n) => n.title)).toContain('Your opportunity is live');
      // Once published, only staff can edit it.
      await as(owner.token)
        .patch(`/provider/opportunities/${sub.id}`, { title: 'Sneaky edit' })
        .expect(409);
    });

    it('sending a submission back tells the provider why and returns it to draft', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const owner = await staff('OPPORTUNITY_PROVIDER');
      const prov = await provider(admin, `Own ${uniq()}`, { ownerUserId: owner.id });
      const sub = (
        await as(owner.token).post('/provider/opportunities', fields(prov.id)).expect(201)
      ).body.data;
      created.opportunities.push(sub.id);
      await as(admin.token)
        .post(`/admin/opportunities/${sub.id}/reject`, { reason: 'Add the eligibility rules.' })
        .expect(200);
      expect((await prisma.opportunity.findUniqueOrThrow({ where: { id: sub.id } })).status).toBe(
        'DRAFT',
      );
      const told = await prisma.notification.findMany({ where: { userId: owner.id } });
      expect(told.some((n) => n.body.includes('Add the eligibility rules.'))).toBe(true);
      // Only a pending submission can be sent back.
      await as(admin.token)
        .post(`/admin/opportunities/${sub.id}/reject`, { reason: 'Again please' })
        .expect(409);
    });

    it('only opportunity.verify can set VERIFIED, and it is audited', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const content = await staff('CONTENT_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const opp = await listing(admin, prov.id);

      // Content admins do not manage opportunities at all.
      await as(content.token).get('/admin/opportunities').expect(403);
      await as(content.token)
        .post(`/admin/opportunities/${opp.id}/set-trust`, { trust: 'SOURCE_CONFIRMED' })
        .expect(403);
      // Even with opportunity.manage, the lower-level endpoint cannot hand out VERIFIED.
      await as(admin.token)
        .post(`/admin/opportunities/${opp.id}/set-trust`, { trust: 'VERIFIED' })
        .expect(403);

      const mid = await as(admin.token)
        .post(`/admin/opportunities/${opp.id}/set-trust`, {
          trust: 'SOURCE_CONFIRMED',
          reason: 'Checked with the organiser',
        })
        .expect(200);
      expect(mid.body.data.trust).toBe('SOURCE_CONFIRMED');
      expect((await as(m.token).get(`/opportunities/${opp.id}`).expect(200)).body.data.trust).toBe(
        'SOURCE_CONFIRMED',
      );

      const verified = await as(admin.token)
        .post(`/admin/opportunities/${opp.id}/verify`, {
          reason: 'Registered NGO, confirmed by phone',
        })
        .expect(200);
      expect(verified.body.data.trust).toBe('VERIFIED');
      expect((await as(m.token).get(`/opportunities/${opp.id}`).expect(200)).body.data.trust).toBe(
        'VERIFIED',
      );
      const trail = await prisma.auditLog.findMany({
        where: {
          entityType: 'opportunity',
          entityId: opp.id,
          action: { in: ['opportunity.verify', 'opportunity.trust.set'] },
        },
        orderBy: { createdAt: 'asc' },
      });
      expect(trail.map((t) => t.action)).toEqual(['opportunity.trust.set', 'opportunity.verify']);
      expect(trail[1]).toMatchObject({ actorId: admin.id, actorType: 'ADMIN' });
      expect(trail[1]!.after).toMatchObject({
        trust: 'VERIFIED',
        reason: 'Registered NGO, confirmed by phone',
      });
      expect(trail[1]!.before).toMatchObject({ trust: 'SOURCE_CONFIRMED' });
    });

    it('verifying a provider shows the tick on its cards', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const opp = await listing(admin, prov.id);
      expect(
        (await as(m.token).get(`/opportunities/${opp.id}`).expect(200)).body.data.provider.verified,
      ).toBe(false);
      await as(admin.token)
        .post(`/admin/opportunity-providers/${prov.id}/verify`, { status: 'VERIFIED' })
        .expect(200);
      expect(
        (await as(m.token).get(`/opportunities/${opp.id}`).expect(200)).body.data.provider.verified,
      ).toBe(true);
      await as(admin.token)
        .patch(`/admin/opportunity-providers/${prov.id}`, { website: 'https://org.example.org' })
        .expect(200);
      const lookup = await as(admin.token)
        .get('/admin/opportunity-providers', { q: prov.name })
        .expect(200);
      expect(lookup.body.data[0]).toMatchObject({
        id: prov.id,
        verificationStatus: 'VERIFIED',
        website: 'https://org.example.org/',
      });
    });

    it('publishing needs a way to apply and a future deadline; lifecycle moves are checked and audited', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const prov = await provider(admin);
      const noLink = (
        await as(admin.token)
          .post('/admin/opportunities', {
            providerId: prov.id,
            title: `No link ${uniq()}`,
            type: 'JOB',
            summary: 'A role with no way to apply yet.',
          })
          .expect(201)
      ).body.data;
      created.opportunities.push(noLink.id);
      const refused = await as(admin.token)
        .post(`/admin/opportunities/${noLink.id}/publish`)
        .expect(400);
      expect(refused.body.error.details.field).toBe('applicationUrl');
      await as(admin.token)
        .patch(`/admin/opportunities/${noLink.id}`, {
          applicationUrl: 'http://insecure.example.org',
        })
        .expect(400);
      await as(admin.token)
        .patch(`/admin/opportunities/${noLink.id}`, {
          applicationUrl: 'https://apply.example.org/x',
          deadlineAt: inDays(-1).toISOString(),
        })
        .expect(200);
      await as(admin.token).post(`/admin/opportunities/${noLink.id}/publish`).expect(400);
      await as(admin.token)
        .patch(`/admin/opportunities/${noLink.id}`, { deadlineAt: inDays(10).toISOString() })
        .expect(200);
      const live = (
        await as(admin.token).post(`/admin/opportunities/${noLink.id}/publish`).expect(200)
      ).body.data;
      expect(live).toMatchObject({ status: 'PUBLISHED', applicationDomain: 'apply.example.org' });
      expect(live.publishedAt).not.toBeNull();

      // Cannot publish twice, or close a draft; archive then publish is refused.
      await as(admin.token).post(`/admin/opportunities/${noLink.id}/publish`).expect(409);
      await as(admin.token).post(`/admin/opportunities/${noLink.id}/archive`).expect(200);
      await as(admin.token).post(`/admin/opportunities/${noLink.id}/publish`).expect(409);
      // Only published listings can be featured.
      await as(admin.token)
        .post(`/admin/opportunities/${noLink.id}/feature`, { until: inDays(3).toISOString() })
        .expect(409);
      const actions = (
        await prisma.auditLog.findMany({
          where: { entityType: 'opportunity', entityId: noLink.id },
          orderBy: { createdAt: 'asc' },
        })
      ).map((a) => a.action);
      expect(actions).toEqual(
        expect.arrayContaining([
          'opportunity.create',
          'opportunity.update',
          'opportunity.publish',
          'opportunity.archive',
        ]),
      );
    });
  });

  describe('CSV import', () => {
    const HEADER =
      'title,provider,type,summary,application_url,deadline,county,work_mode,value_min,value_max,currency,disciplines,requirements,benefits';

    it('validates, previews and commits valid rows as drafts only, skipping duplicates', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const tag = `Imp${uniq()}`.replace(/[^a-z0-9]/gi, '');
      const known = await provider(admin, `Known ${tag}`);
      const deadline = inDays(40).toISOString().slice(0, 10);
      const csv = [
        HEADER,
        `${tag} Fund,Known ${tag},GRANT,A fund for new work by Kenyan filmmakers.,https://fund.example.org/apply,${deadline},Nairobi,ONSITE,100000,500000,KES,Film / Video,"Kenyan resident|Short film",Mentorship`,
        `${tag} Residency,Brand New ${tag},RESIDENCY,Three months in Kilifi for visual artists.,https://res.example.org/apply,${deadline},Kilifi,ONSITE,,,,Visual Art,,`,
        `${tag} Bad,,NOPE,short,http://insecure.example.org,2001-01-01,Atlantis,SIDEWAYS,,,,Basket Weaving,,`,
      ].join('\n');

      const preview = (
        await as(admin.token).post('/admin/opportunities/import/preview', { csv }).expect(200)
      ).body.data;
      expect(preview).toMatchObject({ totalCount: 3, validCount: 2 });
      expect(preview.issues.every((i: { line: number }) => i.line === 4)).toBe(true);
      expect(
        preview.preview.find((p: { provider: string }) => p.provider === `Known ${tag}`)
          .providerExists,
      ).toBe(true);
      expect(
        preview.preview.find((p: { provider: string }) => p.provider === `Brand New ${tag}`)
          .providerExists,
      ).toBe(false);
      // Previewing writes nothing.
      expect(await prisma.opportunity.count({ where: { title: { startsWith: tag } } })).toBe(0);

      const done = (await as(admin.token).post('/admin/opportunities/import', { csv }).expect(200))
        .body.data;
      expect(done).toMatchObject({ created: 2, skipped: 0, status: 'DRAFT' });
      const rows = await prisma.opportunity.findMany({
        where: { title: { startsWith: tag } },
        include: { provider: true },
      });
      for (const r of rows) created.opportunities.push(r.id);
      for (const p of new Set(rows.map((r) => r.providerId))) created.providers.push(p);
      expect(rows).toHaveLength(2);
      // Never published and never trusted automatically; the new provider is unverified.
      expect(
        rows.every(
          (r) => r.status === 'DRAFT' && r.trust === 'EXTERNAL_SOURCE' && r.importedAt !== null,
        ),
      ).toBe(true);
      expect(
        rows.find((r) => r.provider.name === `Brand New ${tag}`)!.provider.verificationStatus,
      ).toBe('NOT_SUBMITTED');
      const fund = rows.find((r) => r.title === `${tag} Fund`)!;
      expect(fund.providerId).toBe(known.id);
      expect(fund.valueMaxMinor).toBe(50_000_000n);
      expect(fund.requirements).toEqual(['Kenyan resident', 'Short film']);
      await as(m.token).get(`/opportunities/${fund.id}`).expect(404);

      // Importing the same file again creates nothing.
      const again = (await as(admin.token).post('/admin/opportunities/import', { csv }).expect(200))
        .body.data;
      expect(again).toMatchObject({ created: 0, skipped: 2, status: 'DRAFT' });
      expect(await prisma.opportunity.count({ where: { title: { startsWith: tag } } })).toBe(2);
    });
  });

  describe('database rules', () => {
    it('refuses an inverted value range and an outcome on an unfinished application', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const prov = await provider(admin);
      const opp = await listing(admin, prov.id);
      await expect(
        prisma.opportunity.update({
          where: { id: opp.id },
          data: { valueMinMinor: 500n, valueMaxMinor: 100n, valueCurrency: 'KES' },
        }),
      ).rejects.toThrow();
      await expect(
        prisma.opportunityTracking.create({
          data: { userId: m.id, opportunityId: opp.id, status: 'APPLIED', outcome: 'AWARDED' },
        }),
      ).rejects.toThrow();
    });

    it('client roles can read none of the tables (RLS deny-all)', async () => {
      const rows = await prisma.$queryRaw<Array<{ relname: string; relrowsecurity: boolean }>>`
        SELECT relname, relrowsecurity FROM pg_class
        WHERE relname IN ('opportunity_providers','opportunities','opportunity_disciplines','opportunity_requirement_rules','opportunity_trackings','external_link_checks')`;
      expect(rows).toHaveLength(6);
      expect(rows.every((r) => r.relrowsecurity)).toBe(true);
      const grants = await prisma.$queryRaw<Array<{ n: bigint }>>`
        SELECT count(*) AS n FROM information_schema.role_table_grants
        WHERE table_name IN ('opportunity_providers','opportunities','opportunity_disciplines','opportunity_requirement_rules','opportunity_trackings','external_link_checks')
          AND grantee IN ('anon','authenticated')`;
      expect(Number(grants[0]!.n)).toBe(0);
    });
  });
});
