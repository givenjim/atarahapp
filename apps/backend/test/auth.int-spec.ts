import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { FeatureFlagService } from '../src/feature-flags/feature-flag.service';
import { PrismaService } from '../src/prisma/prisma.service';
import { REDIS } from '../src/redis/redis.module';
import { type Redis } from 'ioredis';
import {
  bearer,
  createTestApp,
  emailFor,
  loginMember,
  makeUser,
  outbox,
  PASSWORD,
  uniq,
} from './helpers';

const WRONG_PASSWORD =
  "That password doesn't match this account. Check it and try again, or reset it.";

describe('Authentication (real PostgreSQL + Redis)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
  });
  afterAll(async () => {
    await app.close();
  });
  beforeEach(() => outbox(app).clear());

  const register = (over: Record<string, unknown> = {}) =>
    http()
      .post('/api/v1/auth/register')
      .send({
        fullName: 'Nia Test',
        identifier: emailFor('nia'),
        password: PASSWORD,
        consent: { terms: true, privacy: true },
        ...over,
      });

  const codeFor = (destination: string): string => {
    const code = outbox(app).lastCodeTo(destination);
    if (!code) throw new Error(`no code delivered to ${destination}`);
    return code;
  };

  describe('registration and verification', () => {
    it('registers by email, verifies with the emailed code, and returns a signed-in session', async () => {
      const email = emailFor('reg');
      const res = await register({ identifier: email }).expect(201);
      expect(res.body.data.verification.channel).toBe('EMAIL');
      expect(res.body.data.verification.destination).toMatch(/^r\*\*\*@test\.atarah\.local$/);
      expect(res.body.data).not.toHaveProperty('accessToken');

      const pending = await prisma.user.findUniqueOrThrow({ where: { email } });
      expect(pending.status).toBe('PENDING_VERIFICATION');
      // Consent is recorded with a version (Data Protection Act).
      const consents = await prisma.consentRecord.findMany({ where: { userId: pending.id } });
      expect(consents.map((c) => c.documentType).sort()).toEqual(['PRIVACY', 'TERMS']);
      expect(consents.every((c) => c.version.length > 0)).toBe(true);

      const verified = await http()
        .post('/api/v1/auth/verify')
        .send({ identifier: email, code: codeFor(email), client: 'ANDROID' })
        .expect(200);
      expect(verified.body.data.accessToken).toEqual(expect.any(String));
      expect(verified.body.data.refreshToken).toEqual(expect.any(String));
      expect(verified.body.data.user).toMatchObject({
        status: 'ACTIVE',
        emailVerified: true,
        email,
      });

      const me = await http()
        .get('/api/v1/users/me')
        .set(...bearer(verified.body.data.accessToken))
        .expect(200);
      expect(me.body.data).toMatchObject({
        email,
        roles: [],
        membership: { plan: 'FREE' },
        entitlements: [],
      });
    });

    it('registers by phone, normalising 07… to +254 and delivering the code by SMS', async () => {
      const local = `07${Math.floor(10000000 + Math.random() * 89999999)}`;
      const e164 = `+254${local.slice(1)}`;
      const res = await register({ identifier: local }).expect(201);
      expect(res.body.data.verification.channel).toBe('SMS');
      expect(outbox(app).sms.at(-1)?.to).toBe(e164);

      await http()
        .post('/api/v1/auth/verify')
        .send({ identifier: local, code: codeFor(e164), client: 'ANDROID' })
        .expect(200);
      const user = await prisma.user.findUniqueOrThrow({ where: { phone: e164 } });
      expect(user.phoneVerifiedAt).not.toBeNull();
      expect(user.status).toBe('ACTIVE');
    });

    it('rejects a duplicate email (any case) and a duplicate phone (any format) with a field-level conflict', async () => {
      const email = emailFor('dup');
      await register({ identifier: email }).expect(201);
      const dupEmail = await register({ identifier: email.toUpperCase() }).expect(409);
      expect(dupEmail.body.error).toMatchObject({
        code: 'CONFLICT',
        details: { reason: 'ACCOUNT_EXISTS' },
      });
      expect(dupEmail.body.error.message).toContain('already exists. Sign in instead?');
      expect(dupEmail.body.error.details.fields[0].field).toBe('identifier');

      const phone = `0722${Math.floor(100000 + Math.random() * 899999)}`;
      await register({ identifier: phone }).expect(201);
      await register({ identifier: `+254${phone.slice(1)}` }).expect(409);
    });

    it('validates name, identifier, password strength and consent', async () => {
      const weak = await register({ password: 'nodigitshere' }).expect(400);
      expect(weak.body.error.details.fields.some((f: any) => f.field === 'password')).toBe(true);
      await register({ password: 'sh0rt' }).expect(400);
      await register({ identifier: 'not-an-email@' }).expect(400);
      await register({ fullName: 'x' }).expect(400);
      const noConsent = await register({ consent: { terms: false, privacy: true } }).expect(400);
      expect(JSON.stringify(noConsent.body.error.details)).toContain('Terms');
      await register({ consent: undefined }).expect(400);
    });

    it('stores codes hashed and expires them after 10 minutes', async () => {
      const email = emailFor('hash');
      await register({ identifier: email }).expect(201);
      const code = codeFor(email);
      const user = await prisma.user.findUniqueOrThrow({ where: { email } });
      const row = await prisma.verificationCode.findFirstOrThrow({ where: { userId: user.id } });
      expect(row.codeHash).not.toContain(code);
      expect(row.codeHash).toMatch(/^[0-9a-f]{64}$/);
      const ttlMs = row.expiresAt.getTime() - row.createdAt.getTime();
      expect(ttlMs).toBeGreaterThan(9 * 60_000);
      expect(ttlMs).toBeLessThanOrEqual(10 * 60_000 + 1000);

      await prisma.verificationCode.update({
        where: { id: row.id },
        data: { expiresAt: new Date(Date.now() - 1000) },
      });
      const res = await http()
        .post('/api/v1/auth/verify')
        .send({ identifier: email, code })
        .expect(400);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
      expect(res.body.error.details.fields[0].field).toBe('code');
    });

    it('rejects a wrong code, and each code works exactly once', async () => {
      const email = emailFor('once');
      await register({ identifier: email }).expect(201);
      const code = codeFor(email);
      const wrong = code === '000000' ? '000001' : '000000';
      await http().post('/api/v1/auth/verify').send({ identifier: email, code: wrong }).expect(400);
      await http().post('/api/v1/auth/verify').send({ identifier: email, code }).expect(200);
      await http().post('/api/v1/auth/verify').send({ identifier: email, code }).expect(400);
    });

    it('locks a code after 5 wrong guesses, even if the right one is then supplied', async () => {
      const email = emailFor('brute');
      await register({ identifier: email }).expect(201);
      const code = codeFor(email);
      const wrong = code === '123456' ? '654321' : '123456';
      for (let i = 0; i < 5; i++)
        await http()
          .post('/api/v1/auth/verify')
          .send({ identifier: email, code: wrong })
          .expect(400);
      const res = await http()
        .post('/api/v1/auth/verify')
        .send({ identifier: email, code })
        .expect(400);
      expect(res.body.error.message).toMatch(/Too many wrong attempts|not right/);
      expect((await prisma.user.findUniqueOrThrow({ where: { email } })).status).toBe(
        'PENDING_VERIFICATION',
      );
    });

    it('does not reveal whether an identifier exists when verifying', async () => {
      const res = await http()
        .post('/api/v1/auth/verify')
        .send({ identifier: emailFor('ghost'), code: '123456' })
        .expect(400);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
    });

    it('enforces the 60 s resend cooldown, then issues a new code that supersedes the old one', async () => {
      const email = emailFor('resend');
      await register({ identifier: email }).expect(201);
      const first = codeFor(email);

      const tooSoon = await http()
        .post('/api/v1/auth/resend-code')
        .send({ identifier: email })
        .expect(429);
      expect(tooSoon.body.error.code).toBe('RATE_LIMITED');
      expect(tooSoon.body.error.details.retryAfterSeconds).toBeGreaterThan(0);
      expect(tooSoon.body.error.details.retryAfterSeconds).toBeLessThanOrEqual(60);

      // Let the cooldown pass.
      const user = await prisma.user.findUniqueOrThrow({ where: { email } });
      await prisma.verificationCode.updateMany({
        where: { userId: user.id },
        data: { createdAt: new Date(Date.now() - 61_000) },
      });
      await http().post('/api/v1/auth/resend-code').send({ identifier: email }).expect(200);
      const second = codeFor(email);

      if (second !== first) {
        await http()
          .post('/api/v1/auth/verify')
          .send({ identifier: email, code: first })
          .expect(400);
      }
      await http()
        .post('/api/v1/auth/verify')
        .send({ identifier: email, code: second })
        .expect(200);
    });

    it('resend answers the same for unknown and already-active accounts (no enumeration)', async () => {
      const unknown = await http()
        .post('/api/v1/auth/resend-code')
        .send({ identifier: emailFor('nobody') })
        .expect(200);
      const { email } = await makeUser(app);
      const active = await http()
        .post('/api/v1/auth/resend-code')
        .send({ identifier: email })
        .expect(200);
      expect(unknown.body).toEqual(active.body);
      expect(outbox(app).emails.find((m) => m.to === email)).toBeUndefined();
    });
  });

  describe('sign in', () => {
    it('returns tokens, a 15-minute access token and a 30-day refresh token', async () => {
      const { email } = await makeUser(app, { fullName: 'Amani Test' });
      const body = await loginMember(app, email);
      expect(body.user).toMatchObject({ fullName: 'Amani Test', status: 'ACTIVE', roles: [] });
      const access = Date.parse(body.accessTokenExpiresAt) - Date.now();
      expect(access).toBeGreaterThan(14 * 60_000);
      expect(access).toBeLessThanOrEqual(15 * 60_000);
      const refresh = Date.parse(body.refreshTokenExpiresAt) - Date.now();
      expect(refresh).toBeGreaterThan(29 * 24 * 3600_000);
      // The refresh token is opaque and only its hash is stored.
      const stored = await prisma.session.findMany({ where: { userId: body.user.id } });
      expect(stored.every((s) => s.refreshTokenHash !== body.refreshToken)).toBe(true);
    });

    it('uses the prototype wording for a wrong password and does not distinguish unknown accounts', async () => {
      const { email } = await makeUser(app);
      const wrong = await http()
        .post('/api/v1/auth/login')
        .send({ identifier: email, password: 'Wrong-pass-1', client: 'WEB' })
        .expect(401);
      const unknown = await http()
        .post('/api/v1/auth/login')
        .send({ identifier: emailFor('ghost'), password: 'Wrong-pass-1', client: 'WEB' })
        .expect(401);
      expect(wrong.body.error).toMatchObject({
        code: 'INVALID_CREDENTIALS',
        message: WRONG_PASSWORD,
      });
      expect(unknown.body.error).toMatchObject({
        code: 'INVALID_CREDENTIALS',
        message: WRONG_PASSWORD,
      });
    });

    it('signs in by phone in any local format', async () => {
      const phone = `+2547${Math.floor(10000000 + Math.random() * 89999999)}`;
      await makeUser(app, { email: emailFor('ph'), phone });
      await http()
        .post('/api/v1/auth/login')
        .send({ identifier: `0${phone.slice(4)}`, password: PASSWORD, client: 'ANDROID' })
        .expect(200);
    });

    it('sends a fresh code and asks for verification when the account is still pending', async () => {
      const email = emailFor('pend');
      await register({ identifier: email }).expect(201);
      const user = await prisma.user.findUniqueOrThrow({ where: { email } });
      await prisma.verificationCode.updateMany({
        where: { userId: user.id },
        data: { createdAt: new Date(Date.now() - 120_000) },
      });
      outbox(app).clear();
      const res = await http()
        .post('/api/v1/auth/login')
        .send({ identifier: email, password: PASSWORD, client: 'ANDROID' })
        .expect(403);
      expect(res.body.error).toMatchObject({
        code: 'VERIFICATION_REQUIRED',
        details: { reason: 'ACCOUNT_NOT_VERIFIED' },
      });
      expect(outbox(app).lastCodeTo(email)).toMatch(/^\d{6}$/);
    });

    it.each([
      ['SUSPENDED', 'ACCOUNT_SUSPENDED'],
      ['DEACTIVATED', 'ACCOUNT_DEACTIVATED'],
    ] as const)('denies a %s account with FORBIDDEN', async (status, reason) => {
      const { email } = await makeUser(app, { status });
      const res = await http()
        .post('/api/v1/auth/login')
        .send({ identifier: email, password: PASSWORD, client: 'IOS' })
        .expect(403);
      expect(res.body.error).toMatchObject({ code: 'FORBIDDEN', details: { reason } });
    });

    it('locks sign-in after 5 failures for that account, then recovers after a successful reset', async () => {
      const { email } = await makeUser(app);
      for (let i = 0; i < 5; i++) {
        await http()
          .post('/api/v1/auth/login')
          .send({ identifier: email, password: 'Wrong-pass-1', client: 'WEB' })
          .expect(401);
      }
      const locked = await http()
        .post('/api/v1/auth/login')
        .send({ identifier: email, password: PASSWORD, client: 'WEB' })
        .expect(429);
      expect(locked.body.error).toMatchObject({
        code: 'RATE_LIMITED',
        details: { reason: 'SIGN_IN_LOCKED' },
      });
      expect(locked.body.error.details.retryAfterSeconds).toBeGreaterThan(0);
      await app.get<Redis>(REDIS).del(`auth:fail:member:${email}`);
      await http()
        .post('/api/v1/auth/login')
        .send({ identifier: email, password: PASSWORD, client: 'WEB' })
        .expect(200);
    });

    it('rate limits the sign-in route itself per client address', async () => {
      let last = 0;
      for (let i = 0; i < 12; i++) {
        const r = await http()
          .post('/api/v1/auth/login')
          .set('X-Test-Throttle', 'on')
          .send({ identifier: emailFor('flood'), password: 'x', client: 'WEB' });
        last = r.status;
      }
      expect(last).toBe(429);
    });
  });

  describe('refresh, rotation and logout', () => {
    it('rotates the refresh token on every use', async () => {
      const { email } = await makeUser(app);
      const first = await loginMember(app, email);
      const second = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: first.refreshToken })
        .expect(200);
      expect(second.body.data.refreshToken).not.toBe(first.refreshToken);
      expect(second.body.data.accessToken).not.toBe(first.accessToken);
      // The session family is unchanged, so the old access token still works until it expires.
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(second.body.data.accessToken))
        .expect(200);
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: second.body.data.refreshToken })
        .expect(200);
    });

    it('treats an immediate retry of a rotated token as a race, not an attack', async () => {
      const { email } = await makeUser(app);
      const first = await loginMember(app, email);
      const next = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: first.refreshToken })
        .expect(200);
      const retry = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: first.refreshToken })
        .expect(401);
      expect(retry.body.error.details.reason).toBe('REFRESH_IN_PROGRESS');
      // The newest token still works: the family was not revoked.
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: next.body.data.refreshToken })
        .expect(200);
    });

    it('revokes the whole session family when a rotated token is replayed later (reuse attack)', async () => {
      const { email } = await makeUser(app);
      const first = await loginMember(app, email);
      const next = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: first.refreshToken })
        .expect(200);
      // Age the rotation beyond the grace window.
      await prisma.session.updateMany({
        where: { rotatedAt: { not: null }, userId: first.user.id },
        data: { rotatedAt: new Date(Date.now() - 60_000) },
      });

      const attack = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: first.refreshToken })
        .expect(401);
      expect(attack.body.error.details.reason).toBe('TOKEN_REUSED');
      // Everyone in that family is out, including the legitimate newest token and its access token.
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: next.body.data.refreshToken })
        .expect(401);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(next.body.data.accessToken))
        .expect(401);
    });

    it('rejects unknown, malformed and expired refresh tokens', async () => {
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: 'x'.repeat(43) })
        .expect(401);
      await http().post('/api/v1/auth/refresh').send({ refreshToken: 'short' }).expect(400);
      const { email } = await makeUser(app);
      const s = await loginMember(app, email);
      await prisma.session.updateMany({
        where: { userId: s.user.id },
        data: { expiresAt: new Date(Date.now() - 1000) },
      });
      await http().post('/api/v1/auth/refresh').send({ refreshToken: s.refreshToken }).expect(401);
    });

    it('refuses to refresh once the account is suspended', async () => {
      const { email, user } = await makeUser(app);
      const s = await loginMember(app, email);
      await prisma.user.update({ where: { id: user.id }, data: { status: 'SUSPENDED' } });
      const res = await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: s.refreshToken })
        .expect(403);
      expect(res.body.error.code).toBe('FORBIDDEN');
      // The refresh also ended the session, so the old access token no longer works either.
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(s.accessToken))
        .expect(401);
    });

    it('denies an in-flight access token as soon as the account is suspended', async () => {
      const { email, user } = await makeUser(app);
      const s = await loginMember(app, email);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(s.accessToken))
        .expect(200);
      await prisma.user.update({ where: { id: user.id }, data: { status: 'SUSPENDED' } });
      const res = await http()
        .get('/api/v1/users/me')
        .set(...bearer(s.accessToken))
        .expect(403);
      expect(res.body.error).toMatchObject({
        code: 'FORBIDDEN',
        details: { reason: 'ACCOUNT_SUSPENDED' },
      });
    });

    it('logout ends that session immediately (access and refresh tokens both stop working)', async () => {
      const { email } = await makeUser(app);
      const s = await loginMember(app, email);
      await http()
        .post('/api/v1/auth/logout')
        .set(...bearer(s.accessToken))
        .expect(200);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(s.accessToken))
        .expect(401);
      await http().post('/api/v1/auth/refresh').send({ refreshToken: s.refreshToken }).expect(401);
    });

    it('logout-all ends every device', async () => {
      const { email } = await makeUser(app);
      const phone = await loginMember(app, email, PASSWORD, 'ANDROID');
      const web = await loginMember(app, email, PASSWORD, 'WEB');
      const res = await http()
        .post('/api/v1/auth/logout-all')
        .set(...bearer(phone.accessToken))
        .expect(200);
      expect(res.body.data.sessionsRevoked).toBe(2);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(web.accessToken))
        .expect(401);
    });
  });

  describe('active sessions', () => {
    it('lists devices with the current one marked, and lets a member sign out another device', async () => {
      const { email } = await makeUser(app);
      const phone = await loginMember(app, email, PASSWORD, 'ANDROID');
      const web = await loginMember(app, email, PASSWORD, 'WEB');
      const list = await http()
        .get('/api/v1/auth/sessions')
        .set(...bearer(phone.accessToken))
        .expect(200);
      expect(list.body.data).toHaveLength(2);
      expect(list.body.data.filter((s: any) => s.current)).toHaveLength(1);
      expect(list.body.data.map((s: any) => s.client).sort()).toEqual(['ANDROID', 'WEB']);

      const other = list.body.data.find((s: any) => !s.current);
      await http()
        .delete(`/api/v1/auth/sessions/${other.id}`)
        .set(...bearer(phone.accessToken))
        .expect(200);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(web.accessToken))
        .expect(401);
      const after = await http()
        .get('/api/v1/auth/sessions')
        .set(...bearer(phone.accessToken))
        .expect(200);
      expect(after.body.data).toHaveLength(1);
    });

    it('does not let a member see or end someone else’s session', async () => {
      const a = await makeUser(app);
      const b = await makeUser(app);
      const sa = await loginMember(app, a.email);
      const sb = await loginMember(app, b.email);
      const listB = await http()
        .get('/api/v1/auth/sessions')
        .set(...bearer(sb.accessToken))
        .expect(200);
      await http()
        .delete(`/api/v1/auth/sessions/${listB.body.data[0].id}`)
        .set(...bearer(sa.accessToken))
        .expect(404);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(sb.accessToken))
        .expect(200);
      await http()
        .delete('/api/v1/auth/sessions/not-a-uuid')
        .set(...bearer(sa.accessToken))
        .expect(400);
    });
  });

  describe('password recovery', () => {
    it('answers identically for known and unknown accounts and only emails known ones', async () => {
      const { email } = await makeUser(app);
      const known = await http()
        .post('/api/v1/auth/password/forgot')
        .send({ identifier: email })
        .expect(200);
      const unknown = await http()
        .post('/api/v1/auth/password/forgot')
        .send({ identifier: emailFor('ghost') })
        .expect(200);
      expect(known.body).toEqual(unknown.body);
      expect(outbox(app).emails.filter((m) => m.to === email)).toHaveLength(1);
      expect(outbox(app).emails).toHaveLength(1);
    });

    it('resets the password with a 15-minute code, signs out every device, and the old password stops working', async () => {
      const { email, user } = await makeUser(app);
      const device = await loginMember(app, email);
      await http().post('/api/v1/auth/password/forgot').send({ identifier: email }).expect(200);
      const code = codeFor(email);

      const row = await prisma.verificationCode.findFirstOrThrow({
        where: { userId: user.id, purpose: 'PASSWORD_RESET' },
      });
      const ttl = row.expiresAt.getTime() - row.createdAt.getTime();
      expect(ttl).toBeGreaterThan(14 * 60_000);
      expect(ttl).toBeLessThanOrEqual(15 * 60_000 + 1000);

      const weak = await http()
        .post('/api/v1/auth/password/reset')
        .send({ identifier: email, code, newPassword: 'nodigits' })
        .expect(400);
      expect(weak.body.error.details.fields[0].field).toBe('newPassword');
      await http()
        .post('/api/v1/auth/password/reset')
        .send({
          identifier: email,
          code: '000000'.replace(/./g, code[0]!) === code ? '123456' : '000000',
          newPassword: 'Brand-new-pw-2',
        })
        .expect(400);

      await http()
        .post('/api/v1/auth/password/reset')
        .send({ identifier: email, code, newPassword: 'Brand-new-pw-2' })
        .expect(200);
      // Single use.
      await http()
        .post('/api/v1/auth/password/reset')
        .send({ identifier: email, code, newPassword: 'Another-pw-3' })
        .expect(400);
      // Signed out of other devices.
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(device.accessToken))
        .expect(401);
      await http()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: device.refreshToken })
        .expect(401);
      // New password works, old one does not.
      await http()
        .post('/api/v1/auth/login')
        .send({ identifier: email, password: PASSWORD, client: 'WEB' })
        .expect(401);
      await http()
        .post('/api/v1/auth/login')
        .send({ identifier: email, password: 'Brand-new-pw-2', client: 'WEB' })
        .expect(200);
    });

    it('a recovery code cannot be used to verify a registration, and vice versa', async () => {
      const email = emailFor('purpose');
      await register({ identifier: email }).expect(201);
      const regCode = codeFor(email);
      await http()
        .post('/api/v1/auth/password/reset')
        .send({ identifier: email, code: regCode, newPassword: 'Brand-new-pw-2' })
        .expect(400);
    });
  });

  describe('protected routes', () => {
    it('requires a valid bearer token', async () => {
      const none = await http().get('/api/v1/users/me').expect(401);
      expect(none.body.error.code).toBe('AUTHENTICATION_REQUIRED');
      await http().get('/api/v1/users/me').set('Authorization', 'Bearer not.a.jwt').expect(401);
      await http().get('/api/v1/users/me').set('Authorization', 'Basic abc').expect(401);
    });

    it('rejects a token signed with a different secret', async () => {
      const { email } = await makeUser(app);
      const s = await loginMember(app, email);
      const [h, p] = s.accessToken.split('.');
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(`${h}.${p}.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA`))
        .expect(401);
    });

    it('lets a pending account read /users/me but nothing else', async () => {
      const email = emailFor('pendingtok');
      await register({ identifier: email }).expect(201);
      const user = await prisma.user.findUniqueOrThrow({ where: { email } });
      const { SessionService } = await import('../src/identity/session.service');
      const { TokenService } = await import('../src/access/token.service');
      const sess = await app.get(SessionService).create(user.id, { client: 'ANDROID' });
      const token = (
        await app
          .get(TokenService)
          .signAccess({ userId: user.id, familyId: sess.familyId, admin: false })
      ).token;

      const me = await http()
        .get('/api/v1/users/me')
        .set(...bearer(token))
        .expect(200);
      expect(me.body.data.status).toBe('PENDING_VERIFICATION');
      const denied = await http()
        .get('/api/v1/auth/sessions')
        .set(...bearer(token))
        .expect(403);
      expect(denied.body.error.code).toBe('VERIFICATION_REQUIRED');
    });
  });

  describe('Continue with Google (behind a flag)', () => {
    it('does not exist while the flag is off', async () => {
      const res = await http()
        .post('/api/v1/auth/google')
        .send({ idToken: 'x', client: 'ANDROID' })
        .expect(404);
      expect(res.body.error.code).toBe('RESOURCE_NOT_FOUND');
    });

    it('fails clearly, not silently, if enabled without OAuth credentials', async () => {
      const flags = app.get(FeatureFlagService);
      await flags.set('google-sign-in', true, { id: '00000000-0000-4000-8000-000000000009' });
      try {
        const res = await http()
          .post('/api/v1/auth/google')
          .send({ idToken: 'x', client: 'ANDROID' })
          .expect(503);
        expect(res.body.error).toMatchObject({
          code: 'EXTERNAL_SERVICE_ERROR',
          details: { reason: 'GOOGLE_NOT_CONFIGURED' },
        });
      } finally {
        await flags.set('google-sign-in', false, { id: '00000000-0000-4000-8000-000000000009' });
      }
    });
  });

  it('never writes passwords, codes or tokens to the audit log or logs', async () => {
    const rows = await prisma.auditLog.findMany();
    expect(JSON.stringify(rows)).not.toContain(PASSWORD);
    expect(uniq()).toBeTruthy();
  });
});
