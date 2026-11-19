import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { MentorshipHooks } from '../src/mentorship/busy-slots';
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
}

const EVERY_DAY = [1, 2, 3, 4, 5, 6, 7].map((weekday) => ({
  weekday,
  startMinute: 8 * 60,
  endMinute: 18 * 60,
}));

describe('Mentorship discovery and onboarding (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let hooks: MentorshipHooks;
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
    app = await createTestApp();
    prisma = app.get(PrismaService);
    hooks = app.get(MentorshipHooks);
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  async function member(o: { pro?: boolean; profile?: boolean } = {}): Promise<Member> {
    const { user, email } = await makeUser(app, {
      fullName: `Mia ${uniq()}`,
      ...(o.pro ? { membership: { status: 'ACTIVE', periodEndInDays: 20 } } : {}),
    });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    if (o.profile !== false) {
      const discipline = await prisma.discipline.findFirstOrThrow({
        where: { name: 'Film / Video' },
      });
      await prisma.creativeProfile.create({
        data: {
          userId: user.id,
          handle: `m_${uniq()}`.replace(/-/g, '_'),
          displayName: `Mia ${uniq()}`,
          headline: 'Documentary editor',
          bio: 'I edit documentaries.',
          onboardingStep: 'DONE',
          onboardingCompletedAt: new Date(),
          primaryDisciplineId: discipline.id,
          disciplines: { create: [{ disciplineId: discipline.id, isPrimary: true }] },
        },
      });
    }
    return { id: user.id, token };
  }

  async function admin(): Promise<Member> {
    const { user, email } = await makeUser(app, {
      roles: ['PLATFORM_ADMIN'],
      fullName: `Ops ${uniq()}`,
    });
    users.push(user.id);
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  const applicationBody = (over: object = {}) => ({
    headline: 'Senior documentary editor',
    yearsExperience: 9,
    expertiseTags: ['Editing', 'Storytelling'],
    disciplineIds: [] as string[],
    credentials: [{ title: 'Editor, Kenya Film Commission reel', issuer: 'KFC', year: 2022 }],
    timeZone: 'Africa/Nairobi',
    statement:
      'I have edited documentaries for ten years and want to help new editors find their voice.',
    evidenceLinks: ['https://example.com/reel'],
    proposedSessionTypes: [
      { name: 'Portfolio review', durationMinutes: 45, priceMinor: 150_000 },
      {
        name: 'Career chat',
        description: 'A relaxed chat.',
        durationMinutes: 30,
        priceMinor: 80_000,
      },
    ],
    acceptTerms: true,
    ...over,
  });

  /** Applies as `m` and has `ops` approve it. Returns the mentor profile id. */
  async function makeMentor(ops: Member, o: { availability?: boolean } = {}) {
    const m = await member();
    const applied = await as(m.token).post('/me/mentor-application', applicationBody());
    expect(applied.status).toBe(201);
    const approved = await as(ops.token).post(
      `/admin/mentor-applications/${applied.body.data.id}/approve`,
      {},
    );
    expect(approved.status).toBe(200);
    if (o.availability !== false) {
      const set = await as(m.token).put('/me/mentor/availability', { weekly: EVERY_DAY });
      expect(set.status).toBe(200);
    }
    const mine = await as(m.token).get('/me/mentor');
    return { ...m, mentorId: mine.body.data.id as string };
  }

  it('applies, an admin approves, the role is granted exactly once and the mentor is listed with real availability and prices', async () => {
    const ops = await admin();
    const applicant = await member();
    const pre = await as(applicant.token).get('/me/mentor-application/prefill');
    expect(pre.status).toBe(200);
    expect(pre.body.data.headline).toBe('Documentary editor');
    expect(pre.body.data.profileReady).toBe(true);

    // Not a mentor yet: mentor tools are refused by the backend.
    expect((await as(applicant.token).get('/me/mentor')).status).toBe(403);

    const applied = await as(applicant.token).post('/me/mentor-application', applicationBody());
    expect(applied.status).toBe(201);
    const id = applied.body.data.id as string;
    expect(
      (await as(applicant.token).post('/me/mentor-application', applicationBody())).status,
    ).toBe(409);

    // A member cannot reach the admin queue.
    expect((await as(applicant.token).get('/admin/mentor-applications')).status).toBe(403);

    const queue = await as(ops.token).get('/admin/mentor-applications', { status: 'PENDING' });
    expect(queue.status).toBe(200);
    expect(queue.body.data.some((a: { id: string }) => a.id === id)).toBe(true);

    // Two approvals race: one wins, the role is granted once.
    const [a, b] = await Promise.all([
      as(ops.token).post(`/admin/mentor-applications/${id}/approve`, {}),
      as(ops.token).post(`/admin/mentor-applications/${id}/approve`, {}),
    ]);
    expect([a.status, b.status].sort()).toEqual([200, 409]);
    const role = await prisma.role.findUniqueOrThrow({ where: { key: 'MENTOR' } });
    expect(
      await prisma.userRole.count({
        where: { userId: applicant.id, roleId: role.id, revokedAt: null },
      }),
    ).toBe(1);
    expect((await as(ops.token).post(`/admin/mentor-applications/${id}/approve`, {})).status).toBe(
      409,
    );
    expect(
      await prisma.auditLog.count({
        where: { action: 'mentor.application.approve', entityId: id },
      }),
    ).toBe(1);

    // Session types were created from the proposal; with no availability the mentor has no next slot.
    const me = await as(applicant.token).get('/me/mentor');
    expect(me.status).toBe(200);
    expect(me.body.data.sessionTypes).toHaveLength(2);
    expect(me.body.data.availability.nextAvailableAt).toBeNull();

    const set = await as(applicant.token).put('/me/mentor/availability', { weekly: EVERY_DAY });
    expect(set.status).toBe(200);
    expect(set.body.data.nextAvailableAt).not.toBeNull();

    const viewer = await member();
    const list = await as(viewer.token).get('/mentors', { limit: 100 });
    expect(list.status).toBe(200);
    const card = list.body.data.find((c: { id: string }) => c.id === me.body.data.id);
    expect(card).toBeDefined();
    expect(card.fromPriceMinor).toBe(80_000);
    expect(card.nextAvailableAt).toBe(set.body.data.nextAvailableAt);
    expect(card.videoCall).toBe(true);
    const week = await as(viewer.token).get('/mentors', { availableThisWeek: true, limit: 100 });
    expect(week.body.data.some((c: { id: string }) => c.id === me.body.data.id)).toBe(true);
    const cheap = await as(viewer.token).get('/mentors', { maxPriceMinor: 10_000, limit: 100 });
    expect(cheap.body.data.some((c: { id: string }) => c.id === me.body.data.id)).toBe(false);
  });

  it('gates booking slots by the MENTORSHIP_BOOKING entitlement on the server', async () => {
    const ops = await admin();
    const mentor = await makeMentor(ops);
    const free = await member();
    const pro = await member({ pro: true });

    const detailFree = await as(free.token).get(`/mentors/${mentor.mentorId}`);
    expect(detailFree.status).toBe(200);
    expect(detailFree.body.data.booking).toEqual({
      allowed: false,
      requiresPro: true,
      isSelf: false,
    });
    const typeId = detailFree.body.data.sessionTypes[0].id as string;

    const blocked = await as(free.token).get(`/mentors/${mentor.mentorId}/slots`, {
      sessionTypeId: typeId,
    });
    expect(blocked.status).toBe(403);
    expect(blocked.body.error.code).toBe('PREMIUM_REQUIRED');

    const detailPro = await as(pro.token).get(`/mentors/${mentor.mentorId}`);
    expect(detailPro.body.data.booking).toEqual({
      allowed: true,
      requiresPro: false,
      isSelf: false,
    });
    const slots = await as(pro.token).get(`/mentors/${mentor.mentorId}/slots`, {
      sessionTypeId: typeId,
      timeZone: 'Africa/Nairobi',
    });
    expect(slots.status).toBe(200);
    expect(slots.body.data.slots.length).toBeGreaterThan(0);

    // A Pro mentor cannot book themselves.
    await prisma.membership.create({
      data: {
        userId: mentor.id,
        planId: (await prisma.membershipPlan.findUniqueOrThrow({ where: { key: 'PRO' } })).id,
        source: 'ADMIN_GRANT',
        status: 'ACTIVE',
        currentPeriodEnd: new Date(Date.now() + 5 * 86_400_000),
      },
    });
    expect(
      (await as(mentor.token).get(`/mentors/${mentor.mentorId}/slots`, { sessionTypeId: typeId }))
        .status,
    ).toBe(403);
  });

  it('subtracts bookings supplied through the busy-slot provider', async () => {
    const ops = await admin();
    const mentor = await makeMentor(ops);
    const pro = await member({ pro: true });
    const detail = await as(pro.token).get(`/mentors/${mentor.mentorId}`);
    const typeId = detail.body.data.sessionTypes[0].id as string;
    const before = await as(pro.token).get(`/mentors/${mentor.mentorId}/slots`, {
      sessionTypeId: typeId,
    });
    const first = before.body.data.slots[0] as { startsAt: string; endsAt: string };

    hooks.registerBusySlots({
      busySlots: async (id) =>
        id === mentor.mentorId
          ? [{ start: new Date(first.startsAt), end: new Date(first.endsAt) }]
          : [],
    });
    const after = await as(pro.token).get(`/mentors/${mentor.mentorId}/slots`, {
      sessionTypeId: typeId,
    });
    const starts = after.body.data.slots.map((s: { startsAt: string }) => s.startsAt);
    expect(starts).not.toContain(first.startsAt);
    expect(starts.length).toBeLessThan(before.body.data.slots.length);
  });

  it('validates availability, exceptions and session types in the mentor tools', async () => {
    const ops = await admin();
    const mentor = await makeMentor(ops);
    const t = as(mentor.token);

    const overlap = await t.put('/me/mentor/availability', {
      weekly: [
        { weekday: 2, startMinute: 600, endMinute: 720 },
        { weekday: 2, startMinute: 700, endMinute: 800 },
      ],
    });
    expect(overlap.status).toBe(400);
    expect(
      (await t.put('/me/mentor/availability', { timeZone: 'Mars/Base', weekly: [] })).status,
    ).toBe(400);

    const date = new Date(Date.now() + 3 * 86_400_000).toISOString().slice(0, 10);
    const ex = await t.post('/me/mentor/availability/exceptions', { date, reason: 'Travel' });
    expect(ex.status).toBe(201);
    expect((await t.post('/me/mentor/availability/exceptions', { date })).status).toBe(409);
    const av = await t.get('/me/mentor/availability');
    expect(av.body.data.exceptions.map((e: { date: string }) => e.date)).toContain(date);
    expect((await t.del(`/me/mentor/availability/exceptions/${ex.body.data.id}`)).status).toBe(204);

    const created = await t.post('/me/mentor/session-types', {
      name: 'Deep dive',
      durationMinutes: 90,
      priceMinor: 400_000,
    });
    expect(created.status).toBe(201);
    const upd = await t.patch(`/me/mentor/session-types/${created.body.data.id}`, {
      priceMinor: 450_000,
    });
    expect(upd.body.data.priceMinor).toBe(450_000);
    expect((await t.del(`/me/mentor/session-types/${created.body.data.id}`)).status).toBe(204);
    const me = await t.get('/me/mentor');
    expect(
      me.body.data.sessionTypes.find((s: { id: string }) => s.id === created.body.data.id).active,
    ).toBe(false);

    const prof = await t.patch('/me/mentor/profile', {
      headline: 'Editor and teacher',
      videoCallLink: 'https://meet.example.com/abc',
    });
    expect(prof.status).toBe(200);
    expect(prof.body.data.videoCallLink).toBe('https://meet.example.com/abc');
    expect(
      (await t.patch('/me/mentor/profile', { videoCallLink: 'http://insecure.example.com' }))
        .status,
    ).toBe(400);

    // Booking requests list is a real empty state until P2-M5.
    const requests = await t.get('/me/mentor/booking-requests');
    expect(requests.status).toBe(200);
    expect(requests.body.data).toEqual([]);

    // Another member cannot touch this mentor's session types.
    const other = await makeMentor(ops, { availability: false });
    expect(
      (
        await as(other.token).patch(`/me/mentor/session-types/${created.body.data.id}`, {
          priceMinor: 1,
        })
      ).status,
    ).toBe(404);
  });

  it('rejects with a reason, blocks self-review, and lets staff pause, remove and oversee session types', async () => {
    const ops = await admin();
    const applicant = await member();
    const applied = await as(applicant.token).post('/me/mentor-application', applicationBody());
    const id = applied.body.data.id as string;

    expect((await as(ops.token).post(`/admin/mentor-applications/${id}/reject`, {})).status).toBe(
      400,
    );
    const rej = await as(ops.token).post(`/admin/mentor-applications/${id}/reject`, {
      reason: 'Add a longer reel.',
    });
    expect(rej.status).toBe(200);
    const mine = await as(applicant.token).get('/me/mentor-application');
    expect(mine.body.data.latest.status).toBe('REJECTED');
    expect(mine.body.data.latest.reviewerNotes).toBe('Add a longer reel.');
    expect(mine.body.data.canApply).toBe(false); // cooldown (DEC-130)

    // An admin who applies cannot approve their own application.
    const self = await makeUser(app, { roles: ['PLATFORM_ADMIN'] });
    users.push(self.user.id);
    const selfAdmin = await adminSignIn(app, self.email);
    const discipline = await prisma.discipline.findFirstOrThrow({
      where: { name: 'Film / Video' },
    });
    await prisma.creativeProfile.create({
      data: {
        userId: self.user.id,
        displayName: 'Self',
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        primaryDisciplineId: discipline.id,
      },
    });
    const selfToken = selfAdmin.session.accessToken;
    const selfApp = await as(selfToken).post('/me/mentor-application', applicationBody());
    expect(selfApp.status).toBe(201);
    expect(
      (await as(selfToken).post(`/admin/mentor-applications/${selfApp.body.data.id}/approve`, {}))
        .status,
    ).toBe(403);

    // Staff controls on a live mentor.
    const mentor = await makeMentor(ops);
    const viewer = await member();
    const listed = async () =>
      (await as(viewer.token).get('/mentors', { limit: 100 })).body.data.some(
        (c: { id: string }) => c.id === mentor.mentorId,
      );
    expect(await listed()).toBe(true);

    const feat = await as(ops.token).patch(`/admin/mentors/${mentor.mentorId}/featured`, {
      featured: true,
    });
    expect(feat.body.data.featured).toBe(true);
    const home = await as(viewer.token).get('/mentorship/home');
    expect(home.body.data.topMentors[0].id).toBe(mentor.mentorId);

    const types = await as(ops.token).get('/admin/mentor-session-types', {
      mentorId: mentor.mentorId,
    });
    expect(types.body.data).toHaveLength(2);
    const off = await as(ops.token).patch(`/admin/mentor-session-types/${types.body.data[0].id}`, {
      disabled: true,
      note: 'Price looks wrong',
    });
    expect(off.body.data.disabledByStaff).toBe(true);
    // The mentor cannot switch it back on.
    expect(
      (
        await as(mentor.token).patch(`/me/mentor/session-types/${types.body.data[0].id}`, {
          active: true,
        })
      ).status,
    ).toBe(403);
    const detail = await as(viewer.token).get(`/mentors/${mentor.mentorId}`);
    expect(detail.body.data.sessionTypes).toHaveLength(1);

    const paused = await as(ops.token).post(`/admin/mentors/${mentor.mentorId}/pause`, {
      reason: 'Under review',
    });
    expect(paused.body.data.status).toBe('PAUSED');
    expect(await listed()).toBe(false);
    expect((await as(viewer.token).get(`/mentors/${mentor.mentorId}`)).status).toBe(404);
    // A staff pause cannot be lifted by the mentor.
    expect((await as(mentor.token).put('/me/mentor/paused', { paused: false })).status).toBe(403);
    const resumed = await as(ops.token).post(`/admin/mentors/${mentor.mentorId}/resume`, {
      reason: 'Cleared',
    });
    expect(resumed.body.data.status).toBe('APPROVED');
    expect(await listed()).toBe(true);

    // The mentor may pause and resume their own profile.
    expect(
      (await as(mentor.token).put('/me/mentor/paused', { paused: true })).body.data.status,
    ).toBe('PAUSED');
    expect(await listed()).toBe(false);
    expect(
      (await as(mentor.token).put('/me/mentor/paused', { paused: false })).body.data.status,
    ).toBe('APPROVED');

    const removed = await as(ops.token).post(`/admin/mentors/${mentor.mentorId}/remove`, {
      reason: 'Terms breach',
    });
    expect(removed.body.data.status).toBe('REMOVED');
    expect(await listed()).toBe(false);
    const role = await prisma.role.findUniqueOrThrow({ where: { key: 'MENTOR' } });
    expect(
      await prisma.userRole.count({
        where: { userId: mentor.id, roleId: role.id, revokedAt: null },
      }),
    ).toBe(0);
    expect((await as(mentor.token).get('/me/mentor')).status).toBe(403);
  });
});
