import { Controller, Get, HttpCode, type INestApplication, Module, Post } from '@nestjs/common';
import { type MembershipStatus } from '@prisma/client';
import type { Redis } from 'ioredis';
import request from 'supertest';
import {
  RequiresEntitlement,
  RequiresPermission,
  RequiresRecentAuth,
} from '../src/access/decorators';
import { PrismaService } from '../src/prisma/prisma.service';
import { REDIS } from '../src/redis/redis.module';
import {
  adminSignIn,
  bearer,
  createTestApp,
  loginMember,
  makeUser,
  outbox,
  nextTotpCode,
  PASSWORD,
} from './helpers';

/** The Supabase session id inside an access token (for tests that poke session state). */
function sessionIdOf(token: string): string {
  return JSON.parse(Buffer.from(token.split('.')[1]!, 'base64url').toString()).session_id as string;
}

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

describe('Authorisation matrix (real Supabase + Redis)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let redis: Redis;
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    app = await createTestApp([AccessProbeModule]);
    prisma = app.get(PrismaService);
    redis = app.get(REDIS);
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

  describe('administrator access (Supabase MFA: AAL2)', () => {
    it('a staff member signed in with a password only (AAL1) is refused on admin routes', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const s = await loginMember(app, email);
      const res = await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(s.accessToken))
        .expect(403);
      expect(res.body.error.details.reason).toBe('MFA_REQUIRED');
    });

    it('enrolling and verifying an authenticator code gives an AAL2 session that reaches admin routes', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      expect(sessionIdOf(session.accessToken)).toMatch(/[0-9a-f-]{36}/);
      await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(session.accessToken))
        .expect(200);
    });

    it('a wrong authenticator code does not raise the session to AAL2', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const s = await loginMember(app, email);
      const enrol = await s.client.auth.mfa.enroll({ factorType: 'totp' });
      const verified = await s.client.auth.mfa.challengeAndVerify({
        factorId: enrol.data!.id,
        code: '000000',
      });
      expect(verified.error).not.toBeNull();
      const res = await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(s.accessToken))
        .expect(403);
      expect(res.body.error.details.reason).toBe('MFA_REQUIRED');
    });

    it('a member without a staff role is refused even at AAL2', async () => {
      const { email } = await makeUser(app);
      const { session } = await adminSignIn(app, email);
      const res = await http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(session.accessToken))
        .expect(403);
      expect(res.body.error.details.reason).toBe('ADMIN_ONLY');
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

    it('one AAL2 session works on both admin and member routes; the password-only session works on member routes only', async () => {
      const { email } = await makeUser(app, { roles: ['PLATFORM_ADMIN'] });
      const member = await loginMember(app, email); // staff are also members
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(member.accessToken))
        .expect(200);
      const memberOnAdmin = await adminGet(member.accessToken, 'whoami');
      expect(memberOnAdmin.status).toBe(403);
      expect(memberOnAdmin.body.error.details.reason).toBe('MFA_REQUIRED');

      const { session } = await adminSignIn(app, email);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(session.accessToken))
        .expect(200);
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
    const whoami = (token: string) =>
      http()
        .get('/api/v1/admin/probe/whoami')
        .set(...bearer(token));

    it('signs the admin out after 30 minutes of inactivity and ends the Supabase session', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      await whoami(session.accessToken).expect(200);
      await redis.set(
        `auth:admin-activity:${sessionIdOf(session.accessToken)}`,
        String(Date.now() - 31 * 60_000),
      );
      const res = await whoami(session.accessToken).expect(401);
      expect(res.body.error.details.reason).toBe('SESSION_IDLE');
      // The session itself is gone, so even a fresh request fails.
      await whoami(session.accessToken).expect(401);
    });

    it('activity keeps an admin session alive', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
      await whoami(session.accessToken).expect(200);
      await redis.set(
        `auth:admin-activity:${sessionIdOf(session.accessToken)}`,
        String(Date.now() - 20 * 60_000),
      );
      await whoami(session.accessToken).expect(200);
      await whoami(session.accessToken).expect(200);
    });

    it('signing out ends the session immediately, before the access token expires', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session, client } = await adminSignIn(app, email);
      await whoami(session.accessToken).expect(200);
      await client.auth.signOut();
      await whoami(session.accessToken).expect(401);
    });
  });

  describe('re-authentication for sensitive actions', () => {
    const sensitive = (token: string) =>
      http()
        .post('/api/v1/admin/probe/sensitive')
        .set(...bearer(token));

    it('accepts a fresh authenticator verification, and asks again once it is older than 5 minutes', async () => {
      const { email } = await makeUser(app, { roles: ['PLATFORM_ADMIN'] });
      const { session, secret, factorId, client } = await adminSignIn(app, email);
      await sensitive(session.accessToken).expect(200);

      const realNow = Date.now;
      jest.spyOn(Date, 'now').mockImplementation(() => realNow() + 6 * 60_000);
      const blocked = await sensitive(session.accessToken).expect(401);
      expect(blocked.body.error.details).toMatchObject({ reason: 'REAUTH_REQUIRED' });
      jest.restoreAllMocks();

      // Verifying the factor again (a new TOTP window) refreshes the session's proof.
      const challenge = await client.auth.mfa.challenge({ factorId });
      const refreshed = await client.auth.mfa.verify({
        factorId,
        challengeId: challenge.data!.id,
        code: await nextTotpCode(secret),
      });
      expect(refreshed.error).toBeNull();
      await sensitive(refreshed.data!.access_token).expect(200);
    });

    it('does not help a caller without the permission', async () => {
      const { email } = await makeUser(app, { roles: ['MODERATOR'] });
      const { session } = await adminSignIn(app, email);
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
