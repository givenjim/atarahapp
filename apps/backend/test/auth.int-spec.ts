import { createHmac, randomUUID } from 'node:crypto';
import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import {
  anonClient,
  bearer,
  createTestApp,
  emailFor,
  loginMember,
  makeUser,
  outbox,
  PASSWORD,
} from './helpers';

const MAIL = 'http://127.0.0.1:55324/api/v1';

/** The newest message sent to `to` in the local mail catcher, and the 6-digit code inside it. */
async function codeSentTo(to: string, afterMs = 0): Promise<string> {
  for (let i = 0; i < 40; i++) {
    const list = (await (
      await fetch(`${MAIL}/search?query=${encodeURIComponent(`to:${to}`)}`)
    ).json()) as {
      messages: Array<{ ID: string; Created: string }>;
    };
    const msg = list.messages.find((m) => new Date(m.Created).getTime() >= afterMs);
    if (msg) {
      const full = (await (await fetch(`${MAIL}/message/${msg.ID}`)).json()) as {
        Text: string;
        HTML: string;
      };
      const match = /\b(\d{6})\b/.exec(full.Text || full.HTML);
      if (match) return match[1]!;
    }
    await new Promise((r) => setTimeout(r, 250));
  }
  throw new Error(`No code email arrived for ${to}`);
}

const signHook = (body: string, id = 'msg_test', ts = String(Math.floor(Date.now() / 1000))) => {
  const secret = Buffer.from(
    process.env.ATARAH_SEND_SMS_HOOK_SECRET!.replace(/^v1,whsec_/, ''),
    'base64',
  );
  const mac = createHmac('sha256', secret).update(`${id}.${ts}.${body}`).digest('base64');
  return { 'webhook-id': id, 'webhook-timestamp': ts, 'webhook-signature': `v1,${mac}` };
};

describe('Authentication on Supabase Auth (real local stack)', () => {
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

  describe('sign-up and email verification (6-digit code)', () => {
    it('creates a pending account with consent, then a correct code activates it', async () => {
      const email = emailFor('signup');
      const client = anonClient();
      const started = Date.now() - 1000;
      const { data, error } = await client.auth.signUp({
        email,
        password: PASSWORD,
        options: {
          data: { full_name: 'Nia Signup', terms_version: '2026-10', privacy_version: '2026-10' },
        },
      });
      expect(error).toBeNull();
      const id = data.user!.id;

      const pending = await prisma.user.findUniqueOrThrow({ where: { id } });
      expect(pending.status).toBe('PENDING_VERIFICATION');
      expect(pending.fullName).toBe('Nia Signup');
      expect(pending.emailVerifiedAt).toBeNull();
      const consents = await prisma.consentRecord.findMany({ where: { userId: id } });
      expect(consents.map((c) => c.documentType).sort()).toEqual(['PRIVACY', 'TERMS']);
      expect(consents.every((c) => c.version === '2026-10')).toBe(true);

      const code = await codeSentTo(email, started);
      expect(code).toMatch(/^\d{6}$/);

      const wrong = await client.auth.verifyOtp({
        email,
        token: code === '000000' ? '111111' : '000000',
        type: 'signup',
      });
      expect(wrong.error).not.toBeNull();

      const ok = await client.auth.verifyOtp({ email, token: code, type: 'signup' });
      expect(ok.error).toBeNull();
      expect(ok.data.session?.access_token).toBeTruthy();

      const active = await prisma.user.findUniqueOrThrow({ where: { id } });
      expect(active.status).toBe('ACTIVE');
      expect(active.emailVerifiedAt).not.toBeNull();

      const me = await http()
        .get('/api/v1/users/me')
        .set(...bearer(ok.data.session!.access_token))
        .expect(200);
      expect(me.body.data).toMatchObject({ id, email, status: 'ACTIVE', emailVerified: true });
    });

    it('a pending account can read /users/me but nothing else until verified', async () => {
      const { email, user } = await makeUser(app);
      const s = await loginMember(app, email);
      // Supabase issues no session before confirmation, so put the confirmed account back to pending afterwards.
      await prisma.user.update({
        where: { id: user.id },
        data: { status: 'PENDING_VERIFICATION' },
      });
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(s.accessToken))
        .expect(200);
      const blocked = await http()
        .get('/api/v1/me/growth')
        .set(...bearer(s.accessToken))
        .expect(403);
      expect(blocked.body.error.code).toBe('VERIFICATION_REQUIRED');
    });

    it('refuses a duplicate email and a weak password at Supabase', async () => {
      const { email } = await makeUser(app);
      const dup = await anonClient().auth.signUp({ email, password: PASSWORD });
      // Supabase hides whether an address exists: it answers with an obfuscated user and no session.
      expect(dup.data.session).toBeNull();
      const weak = await anonClient().auth.signUp({ email: emailFor(), password: 'abcdefgh' });
      expect(weak.error).not.toBeNull();
      const short = await anonClient().auth.signUp({ email: emailFor(), password: 'a1' });
      expect(short.error).not.toBeNull();
    });

    it('enforces the 60-second resend cooldown', async () => {
      const email = emailFor('cooldown');
      const client = anonClient();
      await client.auth.signUp({ email, password: PASSWORD });
      const again = await client.auth.resend({ type: 'signup', email });
      expect(again.error).not.toBeNull();
    });
  });

  describe('sign-in, refresh and sign-out', () => {
    it('rejects a wrong password and accepts the right one', async () => {
      const { email } = await makeUser(app);
      const bad = await anonClient().auth.signInWithPassword({ email, password: 'Wrong-pass-1' });
      expect(bad.error).not.toBeNull();
      const good = await loginMember(app, email);
      expect(good.accessToken).toBeTruthy();
    });

    it('refreshing gives a working new token and rotates the refresh token', async () => {
      const { email } = await makeUser(app);
      const s = await loginMember(app, email);
      const refreshed = await s.client.auth.refreshSession();
      expect(refreshed.error).toBeNull();
      expect(refreshed.data.session!.refresh_token).not.toBe(s.refreshToken);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(refreshed.data.session!.access_token))
        .expect(200);
    });

    it('a token from a signed-out session stops working at once', async () => {
      const { email } = await makeUser(app);
      const s = await loginMember(app, email);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(s.accessToken))
        .expect(200);
      await s.client.auth.signOut();
      const res = await http()
        .get('/api/v1/users/me')
        .set(...bearer(s.accessToken))
        .expect(401);
      expect(res.body.error.code).toBe('AUTHENTICATION_REQUIRED');
    });

    it('requires a token, and refuses garbage, an expired-style token and a token signed by someone else', async () => {
      await http().get('/api/v1/users/me').expect(401);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer('not-a-jwt'))
        .expect(401);
      const forged = [
        Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url'),
        Buffer.from(
          JSON.stringify({
            sub: randomUUID(),
            session_id: randomUUID(),
            role: 'authenticated',
            aud: 'authenticated',
          }),
        ).toString('base64url'),
        'x'.repeat(43),
      ].join('.');
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(forged))
        .expect(401);
    });
  });

  describe('password recovery by code', () => {
    it('sends a code, accepts it, sets a new password and signs the other devices out', async () => {
      const { email } = await makeUser(app);
      const other = await loginMember(app, email); // another device
      const phone = anonClient();
      const started = Date.now() - 1000;
      expect((await phone.auth.resetPasswordForEmail(email)).error).toBeNull();
      const code = await codeSentTo(email, started);

      const verified = await phone.auth.verifyOtp({ email, token: code, type: 'recovery' });
      expect(verified.error).toBeNull();
      const updated = await phone.auth.updateUser({ password: 'Brand-new-pass-7' });
      expect(updated.error).toBeNull();
      expect((await phone.auth.signOut({ scope: 'others' })).error).toBeNull();

      await http()
        .get('/api/v1/users/me')
        .set(...bearer(other.accessToken))
        .expect(401);
      const reused = await anonClient().auth.signInWithPassword({ email, password: PASSWORD });
      expect(reused.error).not.toBeNull();
      expect((await loginMember(app, email, 'Brand-new-pass-7')).accessToken).toBeTruthy();
    });
  });

  describe('account status is enforced by the guard', () => {
    it.each(['SUSPENDED', 'DEACTIVATED', 'DELETED'] as const)(
      '%s accounts are refused',
      async (status) => {
        const { email } = await makeUser(app, { status });
        const s = await loginMember(app, email);
        const res = await http()
          .get('/api/v1/users/me')
          .set(...bearer(s.accessToken))
          .expect(403);
        expect(res.body.error.details.reason).toBe(`ACCOUNT_${status}`);
      },
    );

    it('a deleted-at account is treated as unauthenticated', async () => {
      const { email, user } = await makeUser(app);
      const s = await loginMember(app, email);
      await prisma.user.update({ where: { id: user.id }, data: { deletedAt: new Date() } });
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(s.accessToken))
        .expect(401);
    });
  });

  describe('sessions and devices', () => {
    it('lists sessions with device names, revokes one, and keeps the current one on revoke-others', async () => {
      const { email } = await makeUser(app);
      const a = await loginMember(app, email);
      const b = await loginMember(app, email);
      const device = (n: string) => ({
        deviceHash: `hash-${n}-${randomUUID()}`,
        name: `Pixel ${n}`,
        platform: 'ANDROID',
      });

      const first = await http()
        .put('/api/v1/me/device')
        .set(...bearer(a.accessToken))
        .send(device('A'))
        .expect(200);
      expect(first.body.data.newDevice).toBe(true);
      const same = { deviceHash: `fixed-${randomUUID()}`, name: 'Pixel B', platform: 'ANDROID' };
      expect(
        (
          await http()
            .put('/api/v1/me/device')
            .set(...bearer(b.accessToken))
            .send(same)
            .expect(200)
        ).body.data.newDevice,
      ).toBe(true);
      expect(
        (
          await http()
            .put('/api/v1/me/device')
            .set(...bearer(b.accessToken))
            .send(same)
            .expect(200)
        ).body.data.newDevice,
      ).toBe(false);

      const list = await http()
        .get('/api/v1/auth/sessions')
        .set(...bearer(a.accessToken))
        .expect(200);
      expect(list.body.data).toHaveLength(2);
      expect(list.body.data.filter((s: { current: boolean }) => s.current)).toHaveLength(1);
      expect(list.body.data.map((s: { deviceName: string }) => s.deviceName).sort()).toEqual([
        'Pixel A',
        'Pixel B',
      ]);

      const other = list.body.data.find((s: { current: boolean }) => !s.current);
      await http()
        .delete(`/api/v1/auth/sessions/${other.id}`)
        .set(...bearer(a.accessToken))
        .expect(200);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(b.accessToken))
        .expect(401);
      await http()
        .delete(`/api/v1/auth/sessions/${other.id}`)
        .set(...bearer(a.accessToken))
        .expect(404);

      const c = await loginMember(app, email);
      const revoked = await http()
        .post('/api/v1/auth/sessions/revoke-others')
        .set(...bearer(c.accessToken))
        .expect(200);
      expect(revoked.body.data.sessionsRevoked).toBe(1);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(a.accessToken))
        .expect(401);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(c.accessToken))
        .expect(200);
    });

    it("cannot revoke or see another member's session (IDOR)", async () => {
      const a = await loginMember(app, (await makeUser(app)).email);
      const b = await loginMember(app, (await makeUser(app)).email);
      const bSessions = await http()
        .get('/api/v1/auth/sessions')
        .set(...bearer(b.accessToken))
        .expect(200);
      await http()
        .delete(`/api/v1/auth/sessions/${bSessions.body.data[0].id}`)
        .set(...bearer(a.accessToken))
        .expect(404);
      await http()
        .get('/api/v1/users/me')
        .set(...bearer(b.accessToken))
        .expect(200);
    });

    it('validates the device payload', async () => {
      const s = await loginMember(app, (await makeUser(app)).email);
      await http()
        .put('/api/v1/me/device')
        .set(...bearer(s.accessToken))
        .send({ deviceHash: 'short', name: '', platform: 'TOASTER' })
        .expect(400);
    });

    it('reports enrolled two-step factors', async () => {
      const { email } = await makeUser(app);
      const s = await loginMember(app, email);
      const before = await http()
        .get('/api/v1/me/security')
        .set(...bearer(s.accessToken))
        .expect(200);
      expect(before.body.data).toMatchObject({ twoStepEnabled: false, activeSessions: 1 });
      await s.client.auth.mfa.enroll({ factorType: 'totp' });
      const after = await http()
        .get('/api/v1/me/security')
        .set(...bearer(s.accessToken))
        .expect(200);
      expect(after.body.data.factors).toHaveLength(1);
      expect(after.body.data.twoStepEnabled).toBe(false); // unverified until a code is confirmed
    });
  });

  describe('Send SMS hook', () => {
    const body = JSON.stringify({ user: { phone: '254712345678' }, sms: { otp: '482913' } });
    const post = (headers: Record<string, string>, raw = body) =>
      http()
        .post('/api/v1/auth/hooks/send-sms')
        .set('Content-Type', 'application/json')
        .set(headers)
        .send(raw);

    it('verifies the signature and sends through the SMS adapter', async () => {
      outbox(app).sms.length = 0;
      await post(signHook(body)).expect(200);
      expect(outbox(app).sms).toHaveLength(1);
      expect(outbox(app).sms[0]).toMatchObject({ to: '+254712345678' });
      expect(outbox(app).sms[0]!.text).toContain('482913');
    });

    it.each([
      ['no signature', {}],
      [
        'a wrong signature',
        {
          'webhook-id': 'x',
          'webhook-timestamp': String(Math.floor(Date.now() / 1000)),
          'webhook-signature': 'v1,AAAA',
        },
      ],
      ['a stale timestamp', signHook(body, 'old', String(Math.floor(Date.now() / 1000) - 3600))],
    ])('rejects %s', async (_label, headers) => {
      outbox(app).sms.length = 0;
      await post(headers as Record<string, string>).expect(401);
      expect(outbox(app).sms).toHaveLength(0);
    });

    it('rejects a body that does not match its signature', async () => {
      await post(signHook(body), body.replace('482913', '000000')).expect(401);
    });

    it('delivers a real Supabase phone sign-up code through the hook', async () => {
      // Supabase (in Docker) calls the backend on the host, so the app must listen on the hook port.
      await app.listen(3000, '0.0.0.0');
      outbox(app).sms.length = 0;
      const phone = '+2547' + String(Math.floor(10000000 + Math.random() * 89999999));
      const { error } = await anonClient().auth.signUp({ phone, password: PASSWORD });
      expect(error).toBeNull();
      const sent = outbox(app).sms.find((m) => m.to === phone);
      expect(sent?.text).toMatch(/\b\d{6}\b/);
      const row = await prisma.user.findUnique({ where: { phone } });
      expect(row?.status).toBe('PENDING_VERIFICATION');
    });
  });
});
