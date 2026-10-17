import { Controller, Get, HttpCode, type INestApplication, Module, Post } from '@nestjs/common';
import { type MembershipStatus } from '@prisma/client';
import { generateSync } from 'otplib';
import request from 'supertest';
import {
  RequiresEntitlement,
  RequiresPermission,
  RequiresRecentAuth,
} from '../src/access/decorators';
import { PrismaService } from '../src/prisma/prisma.service';
import {
  adminSignIn,
  bearer,
  createTestApp,
  emailFor,
  loginMember,
  makeUser,
  outbox,
  PASSWORD,
  rewindTotpReplay,
} from './helpers';

// ---- probe routes: exist only in tests, to exercise the real guard chain ----

@Controller('access-probe')
class MemberProbeController {
  @Get('member') @RequiresPermission('profile.view') member() {
    return { ok: 'member' };
  }
  @Get('mentor') @RequiresPermission('mentor.profile.manage') mentor() {
    return { ok: 'mentor' };
  }
  @Get('seller') @RequiresPermission('listing.create') seller() {
    return { ok: 'seller' };
  }
  @Get('pro') @RequiresEntitlement('MENTORSHIP_BOOKING') pro() {
    return { ok: 'pro' };
  }
  @Get('verified-skill') @RequiresEntitlement('SKILL_VERIFICATION') skill() {
    return { ok: 'skill' };
  }
}

@Controller('admin/probe')
class AdminProbeController {
  @Get('whoami') whoami() {
    return { ok: 'admin' };
  }
  @Get('reports') @RequiresPermission('report.view') reports() {
    return { ok: 'reports' };
  }
  @Get('users') @RequiresPermission('user.suspend') users() {
    return { ok: 'users' };
  }
  @Get('articles') @RequiresPermission('article.manage') articles() {
    return { ok: 'articles' };
  }
  @Get('payments') @RequiresPermission('payment.manage') payments() {
    return { ok: 'payments' };
  }
  @Get('roles') @RequiresPermission('role.manage') roles() {
    return { ok: 'roles' };
  }
  @Post('sensitive')
  @HttpCode(200)
  @RequiresPermission('user.suspend')
  @RequiresRecentAuth()
  sensitive() {
    return { ok: 'done' };
  }
}

@Module({ controllers: [MemberProbeController, AdminProbeController] })
class AccessProbeModule {}

describe('Authorisation matrix (real PostgreSQL + Redis)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    app = await createTestApp([AccessProbeModule]);
    prisma = app.get(PrismaService);
  });
  afterAll(async () => {
    await app.close();
  });

  const memberGet = async (email: string, path: string) => {
    const s = await loginMember(app, email);
    return http()
      .get(`/api/v1/access-probe/${path}`)
      .set(...bearer(s.accessToken));
  };

  describe('members, roles and entitlements are independent', () => {
    it('a plain member has member capabilities only', async () => {
      const { email } = await makeUser(app);
      expect((await memberGet(email, 'member')).status).toBe(200);
      const mentor = await memberGet(email, 'mentor');
      expect(mentor.status).toBe(403);
      expect(mentor.body.error).toMatchObject({
        code: 'FORBIDDEN',
        details: { missing: ['mentor.profile.manage'] },
      });
      expect((await memberGet(email, 'seller')).status).toBe(403);
    });

    it('premium features answer PREMIUM_REQUIRED, not FORBIDDEN, for free members', async () => {
      const { email } = await makeUser(app);
      const res = await memberGet(email, 'pro');
      expect(res.status).toBe(403);
      expect(res.body.error).toMatchObject({
        code: 'PREMIUM_REQUIRED',
        details: { entitlement: 'MENTORSHIP_BOOKING' },
      });
    });

    it.each<[string, MembershipStatus, number | null, number]>([
      ['ACTIVE with a future period end', 'ACTIVE', 30, 200],
      ['ACTIVE with no end date (admin grant)', 'ACTIVE', null, 200],
      ['ACTIVE but the period already ended', 'ACTIVE', -1, 403],
      ['CANCELLED but still inside the paid period', 'CANCELLED', 5, 200],
      ['CANCELLED after the paid period', 'CANCELLED', -1, 403],
      ['PAST_DUE inside the 3-day grace period', 'PAST_DUE', -1, 200],
      ['PAST_DUE beyond the grace period', 'PAST_DUE', -5, 403],
      ['EXPIRED', 'EXPIRED', -30, 403],
    ])('Pro membership: %s -> %i', async (_label, status, endInDays, expected) => {
      const { email } = await makeUser(app, { membership: { status, periodEndInDays: endInDays } });
      expect((await memberGet(email, 'pro')).status).toBe(expected);
      expect((await memberGet(email, 'verified-skill')).status).toBe(expected);
    });

    it('Premium is not a role: Pro without MENTOR cannot reach mentor tools, MENTOR without Pro cannot book', async () => {
      const pro = await makeUser(app, { membership: { status: 'ACTIVE', periodEndInDays: 30 } });
      expect((await memberGet(pro.email, 'pro')).status).toBe(200);
      expect((await memberGet(pro.email, 'mentor')).status).toBe(403);

      const mentor = await makeUser(app, { roles: ['MENTOR'] });
      expect((await memberGet(mentor.email, 'mentor')).status).toBe(200);
      expect((await memberGet(mentor.email, 'pro')).body.error.code).toBe('PREMIUM_REQUIRED');
    });

    it('roles are additive and revocable', async () => {
      const both = await makeUser(app, { roles: ['MENTOR', 'SELLER'] });
      expect((await memberGet(both.email, 'mentor')).status).toBe(200);
      expect((await memberGet(both.email, 'seller')).status).toBe(200);
      expect((await memberGet(both.email, 'member')).status).toBe(200); // member defaults still apply

      const s = await loginMember(app, both.email);
      await prisma.userRole.updateMany({
        where: { userId: both.user.id, role: { key: 'MENTOR' } },
        data: { revokedAt: new Date() },
      });
      await http()
        .get('/api/v1/access-probe/mentor')
        .set(...bearer(s.accessToken))
        .expect(403);
      await http()
        .get('/api/v1/access-probe/seller')
        .set(...bearer(s.accessToken))
        .expect(200);
    });

    it('a role does not survive suspension of the account', async () => {
      const { email, user } = await makeUser(app, {
        roles: ['MENTOR'],
        membership: { status: 'ACTIVE', periodEndInDays: 30 },
      });
      const s = await loginMember(app, email);
      await prisma.user.update({ where: { id: user.id }, data: { status: 'SUSPENDED' } });
      for (const path of ['member', 'mentor', 'pro']) {
        await http()
          .get(`/api/v1/access-probe/${path}`)
          .set(...bearer(s.accessToken))
          .expect(403);
      }
    });

    it('/users/me reflects roles and entitlements so clients can show or hide controls', async () => {
      const { email } = await makeUser(app, {
        roles: ['SELLER'],
        membership: { status: 'ACTIVE', periodEndInDays: 30 },
      });
      const session = await loginMember(app, email);
      const me = (
        await http()
          .get('/api/v1/users/me')
          .set(...bearer(session.accessToken))
      ).body.data;
      expect(me.roles).toEqual(['SELLER']);
      expect(me.membership.plan).toBe('PRO');
      expect(me.entitlements.sort()).toEqual([
        'CREATIVE_VERIFICATION',
        'MENTORSHIP_BOOKING',
        'PREMIUM_CONTENT',
        'REDUCED_MARKETPLACE_FEES',
        'SKILL_VERIFICATION',
      ]);
    });
  });

  describe('administrator sign-in (password, then TOTP)', () => {
    it('only staff can start admin sign-in, and a non-staff member gets the same answer as a wrong password', async () => {
      const staff = await makeUser(app, { roles: ['MODERATOR'] });
      const member = await makeUser(app, { roles: ['MENTOR'] });
      const wrong = await http()
        .post('/api/v1/admin/auth/login')
        .send({ email: staff.email, password: 'Wrong-pass-1' })
        .expect(401);
      const notStaff = await http()
        .post('/api/v1/admin/auth/login')
        .send({ email: member.email, password: PASSWORD })
        .expect(401);
      const unknown = await http()
        .post('/api/v1/admin/auth/login')
        .send({ email: emailFor('ghost'), password: PASSWORD })
        .expect(401);
      expect(notStaff.body.error).toEqual({
        ...wrong.body.error,
        requestId: notStaff.body.error.requestId,
      });
      expect(unknown.body.error.message).toBe(wrong.body.error.message);
    });

    it('requires TOTP enrolment on first sign-in; the password step alone grants no API access', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const login = await http()
        .post('/api/v1/admin/auth/login')
        .send({ email, password: PASSWORD })
        .expect(200);
      expect(login.body.data.step).toBe('TOTP_ENROLMENT_REQUIRED');
      expect(login.body.data).not.toHaveProperty('accessToken');
      // The challenge token is not an access token.
      await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(login.body.data.challengeToken))
        .expect(401);
      await http()
        .get('/api/v1/admin/auth/me')
        .set(...bearer(login.body.data.challengeToken))
        .expect(401);
    });

    it('enrols TOTP, issues 8 one-time recovery codes, and stores the secret encrypted', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session, secret, userId } = await adminSignIn(app, email);
      expect(session.recoveryCodes).toHaveLength(8);
      expect(
        session.recoveryCodes.every((c: string) => /^[A-Z2-9]{4}(-[A-Z2-9]{4}){2}$/.test(c)),
      ).toBe(true);

      const row = await prisma.adminTotp.findUniqueOrThrow({ where: { userId } });
      expect(row.confirmedAt).not.toBeNull();
      expect(row.secretEncrypted).not.toContain(secret!);
      expect(row.recoveryCodeHashes).toHaveLength(8);
      expect(row.recoveryCodeHashes.join('')).not.toContain(session.recoveryCodes[0]!);

      const actions = (await prisma.auditLog.findMany({ where: { actorId: userId } })).map(
        (a) => a.action,
      );
      expect(actions).toContain('admin.totp_enrolled');
    });

    it('rejects a wrong authenticator code and leaves enrolment unconfirmed', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const login = await http()
        .post('/api/v1/admin/auth/login')
        .send({ email, password: PASSWORD })
        .expect(200);
      const { challengeToken } = login.body.data;
      const setup = await http()
        .post('/api/v1/admin/auth/totp/setup')
        .send({ challengeToken })
        .expect(200);
      expect(setup.body.data.otpauthUrl).toMatch(/^otpauth:\/\/totp\/Atarah%20Admin:/);
      const good = generateSync({ secret: setup.body.data.secret });
      const bad = good === '000000' ? '000001' : '000000';
      await http()
        .post('/api/v1/admin/auth/totp/verify')
        .send({ challengeToken, code: bad })
        .expect(401);
      const user = await prisma.user.findUniqueOrThrow({ where: { email } });
      expect(
        (await prisma.adminTotp.findUniqueOrThrow({ where: { userId: user.id } })).confirmedAt,
      ).toBeNull();
      await http().post('/api/v1/admin/auth/totp/verify').send({ challengeToken }).expect(400);
    });

    it('a returning admin signs in with a code; a code from the same time step cannot be replayed', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { secret, userId } = await adminSignIn(app, email);

      const login = await http()
        .post('/api/v1/admin/auth/login')
        .send({ email, password: PASSWORD })
        .expect(200);
      expect(login.body.data.step).toBe('TOTP_REQUIRED');
      const { challengeToken } = login.body.data;

      // Enrolment already consumed this time step.
      const replay = await http()
        .post('/api/v1/admin/auth/totp/verify')
        .send({ challengeToken, code: generateSync({ secret: secret! }) })
        .expect(401);
      expect(replay.body.error.message).toMatch(/already used|not right/);

      await rewindTotpReplay(app, userId);
      const ok = await http()
        .post('/api/v1/admin/auth/totp/verify')
        .send({ challengeToken, code: generateSync({ secret: secret! }) })
        .expect(200);
      expect(ok.body.data.accessToken).toEqual(expect.any(String));
      expect(ok.body.data).not.toHaveProperty('recoveryCodes');
      // The same code cannot be used twice (compare-and-set on the time step).
      const again = await http()
        .post('/api/v1/admin/auth/totp/verify')
        .send({ challengeToken, code: generateSync({ secret: secret! }) })
        .expect(401);
      expect(again.body.error.code).toBe('INVALID_CREDENTIALS');
    });

    it('accepts a recovery code once, then refuses it', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      const recovery = session.recoveryCodes[0]!;
      const signIn = async () => {
        const l = await http()
          .post('/api/v1/admin/auth/login')
          .send({ email, password: PASSWORD })
          .expect(200);
        return http()
          .post('/api/v1/admin/auth/totp/verify')
          .send({ challengeToken: l.body.data.challengeToken, recoveryCode: recovery });
      };
      expect((await signIn()).status).toBe(200);
      expect((await signIn()).status).toBe(401);
    });

    it('locks TOTP attempts after repeated wrong codes', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { userId } = await adminSignIn(app, email);
      const login = await http()
        .post('/api/v1/admin/auth/login')
        .send({ email, password: PASSWORD })
        .expect(200);
      const { challengeToken } = login.body.data;
      for (let i = 0; i < 5; i++)
        await http()
          .post('/api/v1/admin/auth/totp/verify')
          .send({ challengeToken, code: '000000' })
          .expect(401);
      const locked = await http()
        .post('/api/v1/admin/auth/totp/verify')
        .send({ challengeToken, code: '000000' })
        .expect(429);
      expect(locked.body.error.code).toBe('RATE_LIMITED');
      expect(userId).toBeTruthy();
    });

    it('refuses new enrolment once TOTP is confirmed (no downgrade by re-enrolling)', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      await adminSignIn(app, email);
      const login = await http()
        .post('/api/v1/admin/auth/login')
        .send({ email, password: PASSWORD })
        .expect(200);
      await http()
        .post('/api/v1/admin/auth/totp/setup')
        .send({ challengeToken: login.body.data.challengeToken })
        .expect(403);
    });
  });

  describe('admin routes and permission boundaries (Master Prompt §6.1)', () => {
    const adminGet = (token: string, path: string) =>
      http()
        .get(`/api/v1/admin/probe/${path}`)
        .set(...bearer(token));

    it.each([
      [
        'MODERATOR',
        { whoami: 200, reports: 200, users: 403, articles: 403, payments: 403, roles: 403 },
      ],
      [
        'CONTENT_ADMIN',
        { whoami: 200, reports: 403, users: 403, articles: 200, payments: 403, roles: 403 },
      ],
      [
        'PLATFORM_ADMIN',
        { whoami: 200, reports: 200, users: 200, articles: 403, payments: 403, roles: 403 },
      ],
      [
        'SUPER_ADMIN',
        { whoami: 200, reports: 200, users: 200, articles: 200, payments: 200, roles: 200 },
      ],
    ] as const)('%s', async (role, expected) => {
      const { email } = await makeUser(app, { roles: [role] });
      const { session } = await adminSignIn(app, email);
      for (const [path, status] of Object.entries(expected)) {
        const res = await adminGet(session.accessToken, path);
        expect([path, res.status]).toEqual([path, status]);
        if (status === 403) expect(res.body.error.code).toBe('FORBIDDEN');
      }
    });

    it('keeps member tokens off admin routes and admin tokens off member routes', async () => {
      const { email } = await makeUser(app, { roles: ['PLATFORM_ADMIN'] });
      const member = await loginMember(app, email); // staff are also members
      const memberOnAdmin = await adminGet(member.accessToken, 'whoami');
      expect(memberOnAdmin.status).toBe(403);
      expect(memberOnAdmin.body.error.details.reason).toBe('ADMIN_ONLY');

      const { session } = await adminSignIn(app, email);
      const adminOnMember = await http()
        .get('/api/v1/users/me')
        .set(...bearer(session.accessToken))
        .expect(403);
      expect(adminOnMember.body.error.details.reason).toBe('MEMBER_ONLY');
    });

    it('a plain member token is refused by admin routes even with every member permission', async () => {
      const { email } = await makeUser(app);
      const member = await loginMember(app, email);
      await adminGet(member.accessToken, 'whoami').expect(403);
    });

    it('drops admin access the moment the staff role is revoked', async () => {
      const { email, user } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      await adminGet(session.accessToken, 'whoami').expect(200);
      await prisma.userRole.updateMany({
        where: { userId: user.id },
        data: { revokedAt: new Date() },
      });
      const res = await adminGet(session.accessToken, 'whoami').expect(403);
      expect(res.body.error.details.reason).toBe('ADMIN_ONLY');
    });

    it('exposes the permission list for the console sidebar', async () => {
      const { email } = await makeUser(app, { roles: ['CONTENT_ADMIN'] });
      const { session } = await adminSignIn(app, email);
      const me = (
        await http()
          .get('/api/v1/admin/auth/me')
          .set(...bearer(session.accessToken))
          .expect(200)
      ).body.data;
      expect(me.permissions).toEqual(expect.arrayContaining(['admin.access', 'article.manage']));
      expect(me.permissions).not.toContain('opportunity.manage');
      expect(me.permissions).not.toContain('verification.decide');
    });
  });

  describe('admin sessions', () => {
    it('signs the admin out after 30 minutes of inactivity', async () => {
      const { email, user } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(session.accessToken))
        .expect(200);

      await prisma.session.updateMany({
        where: { userId: user.id },
        data: { lastActiveAt: new Date(Date.now() - 31 * 60_000) },
      });
      const res = await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(session.accessToken))
        .expect(401);
      expect(res.body.error.details.reason).toBe('SESSION_IDLE');
      // The session is gone for good, including its refresh token.
      await http()
        .post('/api/v1/admin/auth/refresh')
        .send({ refreshToken: session.refreshToken })
        .expect(401);
    });

    it('activity keeps an admin session alive', async () => {
      const { email, user } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      await prisma.session.updateMany({
        where: { userId: user.id },
        data: { lastActiveAt: new Date(Date.now() - 20 * 60_000) },
      });
      await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(session.accessToken))
        .expect(200);
      const head = await prisma.session.findFirstOrThrow({
        where: { userId: user.id, rotatedAt: null },
      });
      expect(Date.now() - head.lastActiveAt.getTime()).toBeLessThan(60_000);
    });

    it('rotates admin refresh tokens, and member and admin refresh tokens are not interchangeable', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      const member = await loginMember(app, email);

      const next = await http()
        .post('/api/v1/admin/auth/refresh')
        .send({ refreshToken: session.refreshToken })
        .expect(200);
      expect(next.body.data.refreshToken).not.toBe(session.refreshToken);
      await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(next.body.data.accessToken))
        .expect(200);

      await http()
        .post('/api/v1/admin/auth/refresh')
        .send({ refreshToken: member.refreshToken })
        .expect(401);
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: next.body.data.refreshToken })
        .expect(401);
    });

    it('admin logout ends the session', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      await http()
        .post('/api/v1/admin/auth/logout')
        .set(...bearer(session.accessToken))
        .expect(200);
      await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(session.accessToken))
        .expect(401);
    });
  });

  describe('re-authentication for sensitive actions', () => {
    const sensitive = (token: string) =>
      http()
        .post('/api/v1/admin/probe/sensitive')
        .set(...bearer(token));

    it('is required, accepted with password + code, and expires after 5 minutes', async () => {
      const { email, user } = await makeUser(app, { roles: ['PLATFORM_ADMIN'] });
      const { session, secret } = await adminSignIn(app, email);

      const blocked = await sensitive(session.accessToken).expect(401);
      expect(blocked.body.error.details).toMatchObject({ reason: 'REAUTH_REQUIRED' });

      await http()
        .post('/api/v1/admin/auth/reauth')
        .set(...bearer(session.accessToken))
        .send({ password: 'Wrong-pass-1', code: '123456' })
        .expect(401);

      await rewindTotpReplay(app, user.id);
      await http()
        .post('/api/v1/admin/auth/reauth')
        .set(...bearer(session.accessToken))
        .send({ password: PASSWORD, code: generateSync({ secret: secret! }) })
        .expect(200);
      await sensitive(session.accessToken).expect(200);

      await prisma.session.updateMany({
        where: { userId: user.id },
        data: { reauthAt: new Date(Date.now() - 6 * 60_000) },
      });
      await sensitive(session.accessToken).expect(401);

      const actions = (await prisma.auditLog.findMany({ where: { actorId: user.id } })).map(
        (a) => a.action,
      );
      expect(actions).toContain('admin.reauth');
    });

    it('does not help a caller without the permission', async () => {
      const { email, user } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session, secret } = await adminSignIn(app, email);
      await rewindTotpReplay(app, user.id);
      await http()
        .post('/api/v1/admin/auth/reauth')
        .set(...bearer(session.accessToken))
        .send({ password: PASSWORD, code: generateSync({ secret: secret! }) })
        .expect(200);
      const res = await sensitive(session.accessToken).expect(403);
      expect(res.body.error.code).toBe('FORBIDDEN');
    });
  });

  it('never leaks passwords, TOTP secrets, codes or tokens into the audit log', async () => {
    const dump = JSON.stringify(await prisma.auditLog.findMany());
    expect(dump).not.toContain(PASSWORD);
    expect(dump).not.toMatch(/otpauth|recovery/i);
    expect(outbox(app)).toBeDefined();
  });
});
