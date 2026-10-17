import { getQueueToken } from '@nestjs/bullmq';
import { type INestApplication, Module } from '@nestjs/common';
import { type NotificationCategory } from '@prisma/client';
import { type Queue } from 'bullmq';
import request from 'supertest';
import { NotificationsProcessor } from '../src/notifications/notifications.processor';
import { NotificationsService } from '../src/notifications/notifications.service';
import { PrismaService } from '../src/prisma/prisma.service';
import { bearer, createTestApp, emailFor, loginMember, makeUser, outbox, uniq } from './helpers';

// Runs the real delivery worker against the real queue (Redis); outbound messages land in the dev outbox.
@Module({ providers: [NotificationsProcessor] })
class NotificationsWorkerModule {}

describe('Notifications fan-out (real queue and worker)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let svc: NotificationsService;
  let queue: Queue;
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    app = await createTestApp([NotificationsWorkerModule]);
    prisma = app.get(PrismaService);
    svc = app.get(NotificationsService);
    queue = app.get<Queue>(getQueueToken('notifications'));
  });
  afterAll(async () => {
    await app.close();
  });
  beforeEach(() => outbox(app).clear());

  /** Wait until the worker has finished every queued delivery job. */
  async function drained() {
    for (let i = 0; i < 80; i++) {
      const c = await queue.getJobCounts('waiting', 'active', 'delayed', 'failed');
      if (c.failed) throw new Error('A notification job failed');
      if (!c.waiting && !c.active && !c.delayed) return;
      await new Promise((r) => setTimeout(r, 250));
    }
    throw new Error('Queue did not drain');
  }

  async function member(opts: { devices?: number; emailVerified?: boolean; phone?: string } = {}) {
    const { user, email } = await makeUser(app, {
      email: emailFor('n'),
      phone: opts.phone ?? null,
    });
    if (opts.emailVerified === false) {
      await prisma.user.update({ where: { id: user.id }, data: { emailVerifiedAt: null } });
    }
    if (opts.phone) {
      await prisma.user.update({ where: { id: user.id }, data: { phoneVerifiedAt: new Date() } });
    }
    const tokens: string[] = [];
    for (let i = 0; i < (opts.devices ?? 0); i++) {
      const token = `fcm-${uniq()}-${i}-aaaaaaaaaa`;
      tokens.push(token);
      await prisma.deviceToken.create({ data: { userId: user.id, token, platform: 'ANDROID' } });
    }
    return { id: user.id, email, tokens };
  }

  const setPref = (
    userId: string,
    category: NotificationCategory,
    pushEnabled: boolean,
    emailEnabled: boolean,
  ) =>
    prisma.notificationPreference.create({ data: { userId, category, pushEnabled, emailEnabled } });

  const base = (userId: string, category: NotificationCategory = 'OPPORTUNITIES') => ({
    userId,
    category,
    title: 'New opportunity for you',
    body: 'A paid animation brief matches your skills.',
    deepLink: '/opportunities/abc',
  });

  it('delivers on every channel by default and stores the in-app notification', async () => {
    const m = await member({ devices: 2 });
    const res = await svc.notify(base(m.id));
    expect(res.channels).toEqual(['in_app', 'push', 'email']);
    await drained();

    const stored = await prisma.notification.findUniqueOrThrow({
      where: { id: res.notificationId },
    });
    expect(stored).toMatchObject({
      userId: m.id,
      category: 'OPPORTUNITIES',
      deepLink: '/opportunities/abc',
      readAt: null,
    });

    const push = outbox(app).push;
    expect(push).toHaveLength(1);
    expect(push[0]!.tokens.sort()).toEqual([...m.tokens].sort());
    expect(push[0]!.data).toMatchObject({
      deepLink: '/opportunities/abc',
      category: 'OPPORTUNITIES',
    });

    const email = outbox(app).emails.find((e) => e.to === m.email)!;
    expect(email.subject).toBe('New opportunity for you');
    expect(email.text).toContain('https://atarah.app/opportunities/abc');
    expect(email.html).toContain('ATARA<span');
  });

  it("respects the member's per-category, per-channel preferences", async () => {
    const m = await member({ devices: 1 });
    await setPref(m.id, 'COMMUNITY', false, true); // push off, email on
    await setPref(m.id, 'LEARNING', true, false); // push on, email off
    await setPref(m.id, 'PROFILE', false, false); // everything off

    expect((await svc.notify(base(m.id, 'COMMUNITY'))).channels).toEqual(['in_app', 'email']);
    expect((await svc.notify(base(m.id, 'LEARNING'))).channels).toEqual(['in_app', 'push']);
    expect((await svc.notify(base(m.id, 'PROFILE'))).channels).toEqual(['in_app']);
    // A category with no stored preference defaults to on.
    expect((await svc.notify(base(m.id, 'MENTORSHIP'))).channels).toEqual([
      'in_app',
      'push',
      'email',
    ]);
    await drained();

    expect(
      outbox(app)
        .push.map((p) => p.data.category)
        .sort(),
    ).toEqual(['LEARNING', 'MENTORSHIP']);
    expect(outbox(app).emails.filter((e) => e.to === m.email)).toHaveLength(2);
    // The in-app record exists for all four, whatever the channel settings.
    expect(await prisma.notification.count({ where: { userId: m.id } })).toBe(4);
  });

  it('skips channels the member cannot receive on', async () => {
    const noDevice = await member({ devices: 0 });
    expect((await svc.notify(base(noDevice.id))).channels).toEqual(['in_app', 'email']);

    const unverified = await member({ devices: 1, emailVerified: false });
    expect((await svc.notify(base(unverified.id))).channels).toEqual(['in_app', 'push']);

    const revoked = await member({ devices: 1 });
    await prisma.deviceToken.updateMany({
      where: { userId: revoked.id },
      data: { revokedAt: new Date() },
    });
    expect((await svc.notify(base(revoked.id))).channels).toEqual(['in_app', 'email']);
    await drained();
    expect(outbox(app).push.flatMap((p) => p.tokens)).toEqual(unverified.tokens);
  });

  it('lets critical security notices through even when the member turned the category off', async () => {
    const m = await member({ devices: 1 });
    await setPref(m.id, 'SYSTEM', false, false);
    const quiet = await svc.notify(base(m.id, 'SYSTEM'));
    expect(quiet.channels).toEqual(['in_app']);
    const critical = await svc.notify({
      ...base(m.id, 'SYSTEM'),
      title: 'Your password was changed',
      critical: true,
    });
    expect(critical.channels).toEqual(['in_app', 'push', 'email']);
  });

  it('sends SMS only when asked, and only to a verified phone', async () => {
    const withPhone = await member({
      phone: `+2547${Math.floor(10000000 + Math.random() * 89999999)}`,
    });
    expect((await svc.notify(base(withPhone.id))).channels).not.toContain('sms');
    expect((await svc.notify({ ...base(withPhone.id, 'SYSTEM'), sms: true })).channels).toContain(
      'sms',
    );
    const noPhone = await member();
    expect((await svc.notify({ ...base(noPhone.id, 'SYSTEM'), sms: true })).channels).not.toContain(
      'sms',
    );
    await drained();
    expect(outbox(app).sms).toHaveLength(1);
    expect(outbox(app).sms[0]!.text.length).toBeLessThanOrEqual(160);
  });

  it('refuses deep links that leave the app', async () => {
    const m = await member();
    for (const bad of ['https://evil.example/x', '//evil.example', 'opportunities/1', '/a b']) {
      await expect(svc.notify({ ...base(m.id), deepLink: bad })).rejects.toThrow(/in-app path/);
    }
    expect(await prisma.notification.count({ where: { userId: m.id } })).toBe(0);
  });

  it('does not push to suspended members', async () => {
    const m = await member({ devices: 1 });
    await svc.notify(base(m.id));
    await prisma.user.update({ where: { id: m.id }, data: { status: 'SUSPENDED' } });
    await drained();
    // The jobs may already have run before the suspension; a second notification must be skipped at delivery.
    outbox(app).clear();
    const res = await svc.notify(base(m.id));
    expect(res.channels).toContain('push');
    await drained();
    expect(outbox(app).push).toHaveLength(0);
    expect(outbox(app).emails.filter((e) => e.to === m.email)).toHaveLength(0);
  });

  describe('HTTP: preferences and devices', () => {
    it('returns every category on by default and saves changes', async () => {
      const { email } = await makeUser(app, { email: emailFor('p') });
      const token = (await loginMember(app, email)).accessToken;

      const initial = await http()
        .get('/api/v1/notifications/preferences')
        .set(...bearer(token))
        .expect(200);
      expect(initial.body.data.preferences).toHaveLength(7);
      expect(
        initial.body.data.preferences.every(
          (p: { pushEnabled: boolean; emailEnabled: boolean }) => p.pushEnabled && p.emailEnabled,
        ),
      ).toBe(true);

      const saved = await http()
        .put('/api/v1/notifications/preferences')
        .set(...bearer(token))
        .send({ preferences: [{ category: 'COMMUNITY', pushEnabled: false, emailEnabled: true }] })
        .expect(200);
      expect(
        saved.body.data.preferences.find((p: { category: string }) => p.category === 'COMMUNITY'),
      ).toMatchObject({
        pushEnabled: false,
        emailEnabled: true,
      });
      await http()
        .put('/api/v1/notifications/preferences')
        .set(...bearer(token))
        .send({ preferences: [{ category: 'NOPE', pushEnabled: false, emailEnabled: true }] })
        .expect(400);
      await http()
        .put('/api/v1/notifications/preferences')
        .set(...bearer(token))
        .send({ preferences: [] })
        .expect(400);
      await http().get('/api/v1/notifications/preferences').expect(401);
    });

    it('registers, moves and removes device tokens', async () => {
      const a = await makeUser(app, { email: emailFor('da') });
      const b = await makeUser(app, { email: emailFor('db') });
      const ta = (await loginMember(app, a.email)).accessToken;
      const tb = (await loginMember(app, b.email)).accessToken;
      const token = `fcm-shared-${uniq()}-zzzzzzzz`;

      const reg = await http()
        .post('/api/v1/devices')
        .set(...bearer(ta))
        .send({ token, platform: 'ANDROID', appVersion: '1.0.0+1' })
        .expect(200);
      const id = reg.body.data.id as string;
      expect((await prisma.deviceToken.findUniqueOrThrow({ where: { token } })).userId).toBe(
        a.user.id,
      );

      // The phone is handed to another member who signs in: the token moves, it is never shared.
      await http()
        .post('/api/v1/devices')
        .set(...bearer(tb))
        .send({ token, platform: 'ANDROID' })
        .expect(200);
      expect((await prisma.deviceToken.findUniqueOrThrow({ where: { token } })).userId).toBe(
        b.user.id,
      );

      await http()
        .delete(`/api/v1/devices/${id}`)
        .set(...bearer(ta))
        .expect(404);
      await http()
        .delete(`/api/v1/devices/${id}`)
        .set(...bearer(tb))
        .expect(204);
      expect(
        (await prisma.deviceToken.findUniqueOrThrow({ where: { token } })).revokedAt,
      ).not.toBeNull();

      await http()
        .post('/api/v1/devices')
        .set(...bearer(ta))
        .send({ token: 'short', platform: 'ANDROID' })
        .expect(400);
      await http()
        .post('/api/v1/devices')
        .set(...bearer(ta))
        .send({ token, platform: 'PALM' })
        .expect(400);
      await http().post('/api/v1/devices').send({ token, platform: 'ANDROID' }).expect(401);
    });

    it('keeps only the ten newest active devices per member', async () => {
      const { email, user } = await makeUser(app, { email: emailFor('dm') });
      const t = (await loginMember(app, email)).accessToken;
      for (let i = 0; i < 12; i++) {
        await http()
          .post('/api/v1/devices')
          .set(...bearer(t))
          .send({ token: `fcm-many-${uniq()}-${i}-pppppp`, platform: 'ANDROID' })
          .expect(200);
        await new Promise((r) => setTimeout(r, 5));
      }
      expect(await prisma.deviceToken.count({ where: { userId: user.id, revokedAt: null } })).toBe(
        10,
      );
    });
  });
});
