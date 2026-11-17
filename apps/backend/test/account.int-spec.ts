import { inflateRawSync } from 'node:zlib';
import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AccountJobsModule } from '../src/account/jobs/account-jobs.module';
import { AccountJobsService } from '../src/account/jobs/account-jobs.service';
import { PrismaService } from '../src/prisma/prisma.service';
import { StorageService } from '../src/storage/storage.service';
import { SupabaseAdminService } from '../src/supabase/supabase-admin.service';
import {
  adminSignIn,
  anonClient,
  bearer,
  createTestApp,
  deleteUsers,
  loginMember,
  makeUser,
  nextTotpCode,
  PASSWORD,
  uniq,
} from './helpers';

// Each test sets up several real Supabase Auth members, so allow more than 5 s.
jest.setTimeout(240_000);

const DAY = 86_400_000;

interface Member {
  id: string;
  token: string;
  email: string;
  handle: string;
  profileId: string;
}

/** Reads the central directory of a ZIP: name -> content. */
function unzip(buf: Buffer): Record<string, Buffer> {
  const end = buf.lastIndexOf(Buffer.from([0x50, 0x4b, 0x05, 0x06]));
  const count = buf.readUInt16LE(end + 10);
  let p = buf.readUInt32LE(end + 16);
  const out: Record<string, Buffer> = {};
  for (let i = 0; i < count; i += 1) {
    const method = buf.readUInt16LE(p + 10);
    const size = buf.readUInt32LE(p + 20);
    const nameLen = buf.readUInt16LE(p + 28);
    const local = buf.readUInt32LE(p + 42);
    const name = buf.subarray(p + 46, p + 46 + nameLen).toString('utf8');
    const start = local + 30 + buf.readUInt16LE(local + 26) + buf.readUInt16LE(local + 28);
    const body = buf.subarray(start, start + size);
    out[name] = method === 8 ? inflateRawSync(body) : body;
    p += 46 + nameLen;
  }
  return out;
}

describe('Account, privacy, security, export and deletion (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let jobs: AccountJobsService;
  let storage: StorageService;
  let admin: SupabaseAdminService;
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
    app = await createTestApp([AccountJobsModule], { realStorage: true });
    prisma = app.get(PrismaService);
    jobs = app.get(AccountJobsService);
    storage = app.get(StorageService);
    admin = app.get(SupabaseAdminService);
  });
  afterAll(async () => {
    const placeholder = await prisma.platformSetting.findUnique({
      where: { key: 'system.deleted_member_user_id' },
    });
    if (placeholder) users.push(placeholder.value as string);
    await deleteUsers(app, users);
    await app.close();
  });

  async function member(o: { name?: string; countyCode?: string } = {}): Promise<Member> {
    const { user, email } = await makeUser(app, { fullName: o.name ?? `Tess ${uniq()}` });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const discipline = await prisma.discipline.findFirstOrThrow({
      where: { name: 'Film / Video' },
    });
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

  async function staff(role: 'PLATFORM_ADMIN') {
    const { user, email } = await makeUser(app, { roles: [role], fullName: `Staff ${uniq()}` });
    users.push(user.id);
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  // ---------------------------------------------------------------------------------------------------------------

  describe('account', () => {
    it('changes the name and the username, with the same rules as sign-up', async () => {
      const me = await member({ name: 'Old Name' });
      const other = await member();
      const before = (await as(me.token).get('/me/account').expect(200)).body.data;
      expect(before).toMatchObject({
        fullName: 'Old Name',
        handle: me.handle,
        emailVerified: true,
        pendingEmail: null,
        pendingPhone: null,
      });

      const reserved = await as(me.token).patch('/me/account', { handle: 'admin' }).expect(400);
      expect(reserved.body.error.details).toMatchObject({ field: 'handle', reason: 'RESERVED' });
      await as(me.token).patch('/me/account', { handle: 'Not Valid!' }).expect(400);
      await as(me.token).patch('/me/account', { handle: 'ab' }).expect(400);
      const taken = await as(me.token).patch('/me/account', { handle: other.handle }).expect(409);
      expect(taken.body.error.details.reason).toBe('TAKEN');
      await as(me.token).patch('/me/account', { fullName: ' ' }).expect(400);

      const fresh = `renamed_${uniq()}`.replace(/-/g, '_').slice(0, 28);
      const after = (
        await as(me.token)
          .patch('/me/account', { fullName: 'New  Name', handle: `@${fresh.toUpperCase()}` })
          .expect(200)
      ).body.data;
      expect(after).toMatchObject({ fullName: 'New Name', handle: fresh });
      // The profile follows: new address works, old one is gone, and the name on the profile matches.
      const profile = (await as(other.token).get(`/creatives/${fresh}`).expect(200)).body.data;
      expect(profile.displayName).toBe('New Name');
      await as(other.token).get(`/creatives/${me.handle}`).expect(404);
      const audit = await prisma.auditLog.findFirst({
        where: { action: 'account.update', entityId: me.id },
      });
      expect(audit?.after).toMatchObject({ fullName: 'New Name', handle: fresh });
    });

    it('needs the current password to change it, ends other devices and notifies', async () => {
      const me = await member();
      const first = await loginMember(app, me.email);
      const second = await loginMember(app, me.email);

      await as(first.accessToken)
        .post('/me/password', {
          currentPassword: 'wrong-password',
          newPassword: 'Brand-new-pass-9',
        })
        .expect(400);
      const weak = await as(first.accessToken)
        .post('/me/password', { currentPassword: PASSWORD, newPassword: '12345678' })
        .expect(400);
      expect(weak.body.error.details.field).toBe('newPassword');
      await as(first.accessToken)
        .post('/me/password', { currentPassword: PASSWORD, newPassword: 'short' })
        .expect(400);

      const done = (
        await as(first.accessToken)
          .post('/me/password', { currentPassword: PASSWORD, newPassword: 'Brand-new-pass-9' })
          .expect(200)
      ).body.data;
      expect(done.sessionsRevoked).toBeGreaterThanOrEqual(1);
      // The device that changed it stays signed in; the other one is signed out at once.
      await as(first.accessToken).get('/me/account').expect(200);
      await as(second.accessToken).get('/me/account').expect(401);
      await expect(loginMember(app, me.email, PASSWORD)).rejects.toThrow();
      await loginMember(app, me.email, 'Brand-new-pass-9');
      const note = await prisma.notification.findFirstOrThrow({
        where: { userId: me.id, type: 'account.password_changed' },
      });
      expect(note.category).toBe('SYSTEM');
      expect(
        await prisma.auditLog.count({
          where: { action: 'account.password_change', actorId: me.id },
        }),
      ).toBe(1);
    });

    it('limits password tries to five an hour', async () => {
      const me = await member();
      for (let i = 0; i < 5; i += 1) {
        await as(me.token)
          .post('/me/password', {
            currentPassword: 'nope-nope-nope',
            newPassword: 'Brand-new-pass-9',
          })
          .expect(400);
      }
      await as(me.token)
        .post('/me/password', { currentPassword: PASSWORD, newPassword: 'Brand-new-pass-9' })
        .expect(429);
    });

    it('starts an email change, tells the old address, and finishes (signing others out) once the new one is confirmed', async () => {
      const me = await member();
      const other = await loginMember(app, me.email);
      const next = `changed.${uniq()}@test.atarah.local`;

      await as(me.token).post('/me/email/change', { email: 'not-an-email' }).expect(400);
      await as(me.token).post('/me/email/change', { email: me.email }).expect(400);
      const started = (await as(me.token).post('/me/email/change', { email: next }).expect(200))
        .body.data;
      expect(started).toMatchObject({
        kind: 'EMAIL',
        sentTo: expect.stringContaining('***@test.atarah.local'),
      });
      expect(
        await prisma.notification.count({
          where: { userId: me.id, type: 'account.email_change_requested' },
        }),
      ).toBe(1);
      expect((await as(me.token).get('/me/account').expect(200)).body.data).toMatchObject({
        email: me.email,
        pendingEmail: next,
      });
      // Nothing is signed out until the change is confirmed.
      await as(other.accessToken).get('/me/account').expect(200);

      // The member clicks the confirmation links: Supabase updates the account and the sync trigger mirrors it.
      const confirmed = await admin.auth.updateUserById(me.id, {
        email: next,
        email_confirm: true,
      });
      expect(confirmed.error).toBeNull();
      const account = (await as(me.token).get('/me/account').expect(200)).body.data;
      expect(account).toMatchObject({ email: next, pendingEmail: null });
      await as(other.accessToken).get('/me/account').expect(401);
      expect(
        await prisma.notification.count({
          where: { userId: me.id, type: 'account.contact_changed' },
        }),
      ).toBe(1);
      expect(
        (await prisma.contactChangeRequest.findFirstOrThrow({ where: { userId: me.id } }))
          .completedAt,
      ).not.toBeNull();
    });

    it('validates phone numbers and refuses a wrong code', async () => {
      const me = await member();
      await as(me.token).post('/me/phone/change', { phone: '0712345678' }).expect(400);
      await as(me.token).post('/me/phone/change', { phone: '+1' }).expect(400);
      await as(me.token)
        .post('/me/phone/verify', { phone: '+254712345678', code: '000000' })
        .expect(400);
    });
  });

  describe('privacy and visibility', () => {
    it('defaults match the Master Prompt and changes apply at once to the public profile, search and the portfolio', async () => {
      const me = await member({ countyCode: 'MSA' });
      const viewer = await member();
      await prisma.project.create({
        data: {
          profileId: me.profileId,
          title: 'A public piece',
          status: 'PUBLISHED',
          publishedAt: new Date(),
          visibility: 'PUBLIC',
        },
      });

      const start = (await as(me.token).get('/me/privacy').expect(200)).body.data.fields;
      expect(start.map((f: { field: string }) => f.field)).toEqual([
        'CONTACT',
        'LOCATION',
        'PORTFOLIO',
        'EXPERIENCE',
        'ACTIVITY',
      ]);
      const at = (field: string, fields = start) =>
        fields.find((f: { field: string }) => f.field === field).visibility;
      expect([
        at('CONTACT'),
        at('LOCATION'),
        at('PORTFOLIO'),
        at('EXPERIENCE'),
        at('ACTIVITY'),
      ]).toEqual(['PRIVATE', 'MEMBERS', 'PUBLIC', 'MEMBERS', 'PRIVATE']);

      const seen = async () =>
        (await as(viewer.token).get(`/creatives/${me.handle}`).expect(200)).body.data;
      const msa = await prisma.county.findFirstOrThrow({ where: { code: 'MSA' } });
      const searchHas = async () =>
        (await as(viewer.token).get('/creatives', { countyId: msa.id }).expect(200)).body.data.some(
          (c: { handle: string }) => c.handle === me.handle,
        );

      // Members can see the county and the portfolio count at first.
      expect((await seen()).location).not.toBeNull();
      expect((await seen()).portfolioCount).toBe(1);
      expect(await searchHas()).toBe(true);

      const afterLocation = (
        await as(me.token)
          .patch('/me/privacy', { field: 'LOCATION', visibility: 'PRIVATE' })
          .expect(200)
      ).body.data.fields;
      expect(at('LOCATION', afterLocation)).toBe('PRIVATE');
      expect((await seen()).location).toBeNull();
      expect(await searchHas()).toBe(false);

      await as(me.token)
        .patch('/me/privacy', { field: 'PORTFOLIO', visibility: 'PRIVATE' })
        .expect(200);
      expect((await seen()).portfolioCount).toBeNull();
      await as(viewer.token).get(`/creatives/${me.handle}/projects`).expect(404);

      await as(me.token)
        .patch('/me/privacy', { field: 'CONTACT', visibility: 'MEMBERS' })
        .expect(200);
      expect((await seen()).contact).not.toBeNull();
      await as(me.token)
        .patch('/me/privacy', { field: 'CONTACT', visibility: 'PRIVATE' })
        .expect(200);
      expect((await seen()).contact).toBeNull();

      await as(me.token)
        .patch('/me/privacy', { field: 'LOCATION', visibility: 'PUBLIC' })
        .expect(200);
      expect((await seen()).location).not.toBeNull();
      expect(await searchHas()).toBe(true);

      // Activity has no profile section: stored on its own and read back.
      const withActivity = (
        await as(me.token)
          .patch('/me/privacy', { field: 'ACTIVITY', visibility: 'MEMBERS' })
          .expect(200)
      ).body.data.fields;
      expect(at('ACTIVITY', withActivity)).toBe('MEMBERS');
      expect(
        at('ACTIVITY', (await as(me.token).get('/me/privacy').expect(200)).body.data.fields),
      ).toBe('MEMBERS');

      await as(me.token)
        .patch('/me/privacy', { field: 'SECRETS', visibility: 'PUBLIC' })
        .expect(400);
      await as(me.token)
        .patch('/me/privacy', { field: 'LOCATION', visibility: 'EVERYONE' })
        .expect(400);
      // Only the owner's own settings: another member's change never touches this profile.
      await as(viewer.token)
        .patch('/me/privacy', { field: 'LOCATION', visibility: 'PRIVATE' })
        .expect(200);
      expect((await seen()).location).not.toBeNull();
    });

    it('asks a member without a profile to finish setting up first', async () => {
      const { user, email } = await makeUser(app);
      users.push(user.id);
      const token = (await loginMember(app, email)).accessToken;
      await as(token).get('/me/privacy').expect(409);
    });
  });

  describe('two-step sign-in on a new device', () => {
    it('needs a verified second factor to switch on, then challenges new devices until the second step is passed', async () => {
      const me = await member();
      const hashA = `device-a-${uniq()}-aaaaaaaa`;
      const hashB = `device-b-${uniq()}-bbbbbbbb`;
      const device = (deviceHash: string, name: string) => ({
        deviceHash,
        name,
        platform: 'ANDROID',
      });

      // 1. Cannot switch it on without a second factor.
      const aal1 = await loginMember(app, me.email);
      const refused = await as(aal1.accessToken).put('/me/two-step', { enabled: true }).expect(409);
      expect(refused.body.error.details.reason).toBe('FACTOR_REQUIRED');
      expect((await as(aal1.accessToken).get('/me/security').expect(200)).body.data).toMatchObject({
        twoStepEnabled: false,
        hasVerifiedFactor: false,
      });

      // 2. Enrol an authenticator (the same factor type the app's second step uses for the AAL2 challenge).
      const enrol = await aal1.client.auth.mfa.enroll({
        factorType: 'totp',
        friendlyName: 'phone',
      });
      const secret = enrol.data!.totp.secret;
      const { generateSync } = await import('otplib');
      const verified = await aal1.client.auth.mfa.challengeAndVerify({
        factorId: enrol.data!.id,
        code: generateSync({ secret }),
      });
      const aal2Token = verified.data!.access_token;
      expect((await as(aal2Token).get('/me/security').expect(200)).body.data).toMatchObject({
        hasVerifiedFactor: true,
        twoStepEnabled: false,
      });

      // 3. Device A is registered on the verified session, then two-step is turned on: existing devices stay trusted.
      expect(
        (await as(aal2Token).put('/me/device', device(hashA, 'Pixel 6')).expect(200)).body.data,
      ).toMatchObject({ newDevice: true, verified: true });
      expect(
        (await as(aal2Token).put('/me/two-step', { enabled: true }).expect(200)).body.data,
      ).toEqual({ enabled: true, hasVerifiedFactor: true });
      expect((await as(aal2Token).get('/me/security').expect(200)).body.data.twoStepEnabled).toBe(
        true,
      );

      // 4. A known device signing in again (password only) is let straight through.
      const again = await loginMember(app, me.email);
      expect(
        (await as(again.accessToken).put('/me/device', device(hashA, 'Pixel 6')).expect(200)).body
          .data,
      ).toMatchObject({ newDevice: false, verified: true });
      await as(again.accessToken).get('/me/account').expect(200);

      // 5. A new device is refused everything except what the challenge needs.
      const fresh = await loginMember(app, me.email);
      expect(
        (await as(fresh.accessToken).put('/me/device', device(hashB, 'Tecno Spark')).expect(200))
          .body.data,
      ).toMatchObject({ newDevice: true, verified: false });
      const blocked = await as(fresh.accessToken).get('/me/account').expect(403);
      expect(blocked.body.error.details.reason).toBe('TWO_STEP_REQUIRED');
      await as(fresh.accessToken).get('/me/profile').expect(403);
      await as(fresh.accessToken).get('/opportunities/home').expect(403);
      await as(fresh.accessToken).get('/users/me').expect(200);
      await as(fresh.accessToken).get('/me/security').expect(200);
      await as(fresh.accessToken).get('/auth/sessions').expect(200);

      // 6. Passing the second step opens the door and the device becomes trusted.
      const factorId = enrol.data!.id;
      const passed = await fresh.client.auth.mfa.challengeAndVerify({
        factorId,
        code: await nextTotpCode(secret),
      });
      expect(passed.error).toBeNull();
      const passedToken = passed.data!.access_token;
      await as(passedToken).get('/me/account').expect(200);
      const deviceB = await prisma.userDevice.findFirstOrThrow({
        where: { userId: me.id, deviceHash: hashB },
      });
      expect(deviceB.verifiedAt).not.toBeNull();
      // ...so the next password-only sign-in on that device is fine too.
      const later = await loginMember(app, me.email);
      expect(
        (await as(later.accessToken).put('/me/device', device(hashB, 'Tecno Spark')).expect(200))
          .body.data.verified,
      ).toBe(true);
      await as(later.accessToken).get('/me/account').expect(200);

      // 7. Switching it off needs the second step; after that nothing is challenged.
      const nope = await as(later.accessToken).put('/me/two-step', { enabled: false }).expect(403);
      expect(nope.body.error.details.reason).toBe('MFA_REQUIRED');
      expect(
        (await as(passedToken).put('/me/two-step', { enabled: false }).expect(200)).body.data
          .enabled,
      ).toBe(false);
      const free = await loginMember(app, me.email);
      await as(free.accessToken)
        .put('/me/device', device(`device-c-${uniq()}-cccccccc`, 'Another'))
        .expect(200);
      await as(free.accessToken).get('/me/account').expect(200);
    });
  });

  describe('download my data', () => {
    it('builds a ZIP of everything personal, links it for 7 days, allows one a day, and expires it', async () => {
      const me = await member({ name: 'Export Person' });
      await prisma.project.create({
        data: {
          profileId: me.profileId,
          title: 'Exported project',
          status: 'PUBLISHED',
          publishedAt: new Date(),
        },
      });
      // A picture of the member's own, which belongs in the archive.
      const pngKey = `test-export/${uniq()}.png`;
      const pixel = Buffer.from(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        'base64',
      );
      await storage.write('public', pngKey, pixel, 'image/png');
      const asset = await prisma.mediaAsset.create({
        data: {
          ownerId: me.id,
          kind: 'IMAGE',
          bucket: 'PUBLIC',
          objectKey: pngKey,
          mimeType: 'image/png',
          sizeBytes: BigInt(pixel.length),
          status: 'READY',
        },
      });

      expect((await as(me.token).get('/me/export').expect(200)).body.data.status).toBe('NONE');
      const queued = (await as(me.token).post('/me/export').expect(202)).body.data;
      expect(queued).toMatchObject({ status: 'QUEUED', downloadUrl: null });
      const limited = await as(me.token).post('/me/export').expect(429);
      expect(limited.body.error.details.nextAllowedAt).toBeTruthy();

      const built = await jobs.buildExport(queued.id);
      expect(built).toMatchObject({ status: 'READY', files: 1 });
      expect((await jobs.buildExport(queued.id)).status).toBe('READY'); // safe to run twice

      const state = (await as(me.token).get('/me/export').expect(200)).body.data;
      expect(state.status).toBe('READY');
      const days = (new Date(state.expiresAt).getTime() - Date.now()) / DAY;
      expect(days).toBeGreaterThan(6.9);
      expect(days).toBeLessThanOrEqual(7.01);
      const res = await fetch(state.downloadUrl);
      expect(res.ok).toBe(true);
      const files = unzip(Buffer.from(await res.arrayBuffer()));
      expect(Object.keys(files)).toEqual(
        expect.arrayContaining([
          'account.json',
          'profile.json',
          'portfolio.json',
          'community.json',
          'saved.json',
          'learning.json',
          'notifications.json',
          'README.json',
          `media/${asset.id}.png`,
        ]),
      );
      const account = JSON.parse(files['account.json']!.toString());
      expect(account.user).toMatchObject({ id: me.id, email: me.email, fullName: 'Export Person' });
      expect(JSON.stringify(account)).not.toMatch(/password|token/i);
      expect(JSON.parse(files['profile.json']!.toString()).profile.handle).toBe(me.handle);
      expect(
        JSON.parse(files['portfolio.json']!.toString()).projects.map(
          (p: { title: string }) => p.title,
        ),
      ).toEqual(['Exported project']);
      expect(files[`media/${asset.id}.png`]!.equals(pixel)).toBe(true);
      // The member is told, with the link.
      const note = await prisma.notification.findFirstOrThrow({
        where: { userId: me.id, type: 'account.export_ready' },
      });
      expect(note.body).toContain('http');
      // Another member never sees it.
      const other = await member();
      expect((await as(other.token).get('/me/export').expect(200)).body.data.status).toBe('NONE');

      // Eight days later the link is dead, the file is gone and a new export is allowed.
      const sweep = await jobs.exportSweep(new Date(Date.now() + 8 * DAY));
      expect(sweep.expired).toBeGreaterThanOrEqual(1);
      expect(
        (await prisma.dataExportRequest.findUniqueOrThrow({ where: { id: queued.id } })).status,
      ).toBe('EXPIRED');
      expect((await fetch(state.downloadUrl)).ok).toBe(false);
      await prisma.dataExportRequest.update({
        where: { id: queued.id },
        data: { requestedAt: new Date(Date.now() - 2 * DAY) },
      });
      expect((await as(me.token).post('/me/export').expect(202)).body.data.status).toBe('QUEUED');
      await storage.remove('public', pngKey).catch(() => undefined);
    });

    it('re-queues an export nobody picked up', async () => {
      const me = await member();
      const stuck = await prisma.dataExportRequest.create({
        data: { userId: me.id, requestedAt: new Date(Date.now() - 30 * 60_000) },
      });
      const out = await jobs.exportSweep();
      expect(out.requeued).toBeGreaterThanOrEqual(1);
      expect(await jobs.buildExport(stuck.id)).toMatchObject({ status: 'READY' });
    });
  });

  describe('delete my account', () => {
    it('asks for DELETE and a recent sign-in, hides everything at once, restores in the grace period', async () => {
      const me = await member({ name: 'Leaving Soon' });
      const viewer = await member();
      const second = await loginMember(app, me.email);

      await as(me.token).post('/me/delete', {}).expect(400);
      await as(me.token).post('/me/delete', { confirm: 'delete' }).expect(400);
      // Signed in a while ago: the password is needed.
      await prisma.user.update({
        where: { id: me.id },
        data: { lastLoginAt: new Date(Date.now() - 2 * 3_600_000) },
      });
      const reauth = await as(me.token).post('/me/delete', { confirm: 'DELETE' }).expect(403);
      expect(reauth.body.error.details.reason).toBe('REAUTH_REQUIRED');
      await as(me.token)
        .post('/me/delete', { confirm: 'DELETE', password: 'not-my-password' })
        .expect(400);
      expect((await prisma.user.findUniqueOrThrow({ where: { id: me.id } })).status).toBe('ACTIVE');

      const asked = (
        await as(me.token).post('/me/delete', { confirm: 'DELETE', password: PASSWORD }).expect(200)
      ).body.data;
      const grace = (new Date(asked.purgeAfter).getTime() - Date.now()) / DAY;
      expect(grace).toBeGreaterThan(29.9);
      expect(grace).toBeLessThanOrEqual(30.01);
      expect(asked.sessionsRevoked).toBeGreaterThanOrEqual(1);

      // Signed out everywhere, and the profile is gone for everyone else.
      await as(me.token).get('/users/me').expect(401);
      await as(second.accessToken).get('/users/me').expect(401);
      await as(viewer.token).get(`/creatives/${me.handle}`).expect(404);
      expect((await prisma.user.findUniqueOrThrow({ where: { id: me.id } })).status).toBe(
        'DEACTIVATED',
      );
      expect(
        await prisma.accountDeletionRequest.count({ where: { userId: me.id, status: 'PENDING' } }),
      ).toBe(1);

      // Signing in again during the grace period reaches only "who am I" and "restore".
      const back = await loginMember(app, me.email);
      const who = (await as(back.accessToken).get('/users/me').expect(200)).body.data;
      expect(who.status).toBe('DEACTIVATED');
      expect(new Date(who.deletionScheduledFor).getTime()).toBe(
        new Date(asked.purgeAfter).getTime(),
      );
      await as(back.accessToken).get('/me/account').expect(403);
      await as(back.accessToken).get('/opportunities/home').expect(403);

      expect((await as(back.accessToken).post('/me/restore').expect(200)).body.data.restored).toBe(
        true,
      );
      await as(back.accessToken).get('/me/account').expect(200);
      expect(
        (await as(viewer.token).get(`/creatives/${me.handle}`).expect(200)).body.data.displayName,
      ).toBe('Leaving Soon');
      expect(
        (await prisma.accountDeletionRequest.findFirstOrThrow({ where: { userId: me.id } })).status,
      ).toBe('CANCELLED');
      // Nothing to restore any more.
      await as(back.accessToken).post('/me/restore').expect(409);
      // A member who never asked cannot use the restore route either.
      const never = await member();
      await prisma.user.update({ where: { id: never.id }, data: { status: 'DEACTIVATED' } });
      const neverBack = await loginMember(app, never.email);
      await as(neverBack.accessToken).post('/me/restore').expect(403);
    });

    it('purges after 30 days: personal data and files go, posts stay as "Deleted member", the log keeps only the id', async () => {
      const me = await member({ name: 'Goodbye Person' });
      const friend = await member();
      const adminUser = await staff('PLATFORM_ADMIN');

      const post = (
        await as(me.token)
          .post('/posts', { type: 'UPDATE', body: 'A thought worth keeping in the thread.' })
          .expect(201)
      ).body.data;
      const reply = (
        await as(friend.token)
          .post(`/posts/${post.id}/comments`, { body: 'I agree with this.' })
          .expect(201)
      ).body.data;
      const mine = (
        await as(me.token)
          .post(`/posts/${post.id}/comments`, { body: 'Thanks for the reply.' })
          .expect(201)
      ).body.data;
      await prisma.project.create({
        data: {
          profileId: me.profileId,
          title: 'Gone with me',
          status: 'PUBLISHED',
          publishedAt: new Date(),
        },
      });
      await prisma.savedItem.create({ data: { userId: me.id, type: 'POST', targetId: post.id } });
      const key = `test-purge/${uniq()}.png`;
      await storage.write('public', key, Buffer.from('fake-image-bytes'), 'image/png');
      await prisma.mediaAsset.create({
        data: {
          ownerId: me.id,
          kind: 'IMAGE',
          bucket: 'PUBLIC',
          objectKey: key,
          mimeType: 'image/png',
          sizeBytes: 16n,
          status: 'READY',
        },
      });

      await as(me.token).post('/me/delete', { confirm: 'DELETE' }).expect(200);
      const request = await prisma.accountDeletionRequest.findFirstOrThrow({
        where: { userId: me.id },
      });

      // Day 29: nothing happens. Day 31: purged.
      expect((await jobs.purgeAccounts(new Date(Date.now() + 29 * DAY))).purged).toBe(0);
      expect(await prisma.user.count({ where: { id: me.id } })).toBe(1);
      const out = await jobs.purgeAccounts(new Date(Date.now() + 31 * DAY));
      expect(out.purged).toBeGreaterThanOrEqual(1);
      expect(out.failed).toBe(0);

      expect(await prisma.user.count({ where: { id: me.id } })).toBe(0);
      expect(await prisma.creativeProfile.count({ where: { userId: me.id } })).toBe(0);
      expect(await prisma.project.count({ where: { profileId: me.profileId } })).toBe(0);
      expect(await prisma.savedItem.count({ where: { userId: me.id } })).toBe(0);
      expect(await prisma.mediaAsset.count({ where: { ownerId: me.id } })).toBe(0);
      expect(await storage.head('public', key)).toBeNull();
      const gone = await admin.auth.getUserById(me.id);
      expect(gone.data.user).toBeNull();
      await expect(loginMember(app, me.email)).rejects.toThrow();
      await as(friend.token).get(`/creatives/${me.handle}`).expect(404);

      // What they wrote stays, credited to one shared "Deleted member".
      const kept = (await as(friend.token).get(`/posts/${post.id}`).expect(200)).body.data;
      expect(kept.body).toBe('A thought worth keeping in the thread.');
      expect(kept.author.displayName).toBe('Deleted member');
      expect(kept.author.handle).toBeNull();
      const placeholder = (
        await prisma.platformSetting.findUniqueOrThrow({
          where: { key: 'system.deleted_member_user_id' },
        })
      ).value as string;
      expect((await prisma.post.findUniqueOrThrow({ where: { id: post.id } })).authorId).toBe(
        placeholder,
      );
      expect((await prisma.comment.findUniqueOrThrow({ where: { id: mine.id } })).authorId).toBe(
        placeholder,
      );
      expect((await prisma.comment.findUniqueOrThrow({ where: { id: reply.id } })).authorId).toBe(
        friend.id,
      );
      const ghost = await prisma.user.findUniqueOrThrow({ where: { id: placeholder } });
      expect(ghost).toMatchObject({
        fullName: 'Deleted member',
        status: 'ACTIVE',
        statusReason: 'SYSTEM_PLACEHOLDER',
      });

      // The log keeps the request without the person, and the audit trail only the id.
      const done = await prisma.accountDeletionRequest.findUniqueOrThrow({
        where: { id: request.id },
      });
      expect(done).toMatchObject({ status: 'PURGED', userId: me.id });
      expect(done.purgedAt).not.toBeNull();
      const log = (
        await as(adminUser.token).get('/admin/privacy-requests', { kind: 'DELETION' }).expect(200)
      ).body.data;
      const row = log.find((r: { id: string }) => r.id === request.id);
      expect(row).toMatchObject({
        kind: 'DELETION',
        status: 'PURGED',
        userId: me.id,
        memberName: null,
      });
      const trail = await prisma.auditLog.findMany({
        where: { entityId: me.id, action: 'account.purge' },
      });
      expect(trail).toHaveLength(1);
      expect(JSON.stringify(trail[0])).not.toContain('Goodbye');

      // A second purge reuses the same placeholder and running the job again is harmless.
      expect((await jobs.purgeAccounts(new Date(Date.now() + 31 * DAY))).purged).toBe(0);
    });

    it('shows exports and deletions to staff only', async () => {
      const adminUser = await staff('PLATFORM_ADMIN');
      const me = await member();
      await prisma.dataExportRequest.create({ data: { userId: me.id } });
      const all = (await as(adminUser.token).get('/admin/privacy-requests').expect(200)).body;
      expect(
        all.data.some(
          (r: { kind: string; userId: string }) => r.kind === 'EXPORT' && r.userId === me.id,
        ),
      ).toBe(true);
      expect(
        (
          await as(adminUser.token)
            .get('/admin/privacy-requests', { kind: 'EXPORT', status: 'QUEUED' })
            .expect(200)
        ).body.data.every((r: { status: string }) => r.status === 'QUEUED'),
      ).toBe(true);
      await as(me.token).get('/admin/privacy-requests').expect(403);
      void anonClient;
    });
  });
});
