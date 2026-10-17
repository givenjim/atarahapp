import { type INestApplication } from '@nestjs/common';
import { generateSync } from 'otplib';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import {
  adminSignIn,
  bearer,
  createTestApp,
  emailFor,
  loginMember,
  makeUser,
  PASSWORD,
  rewindTotpReplay,
} from './helpers';

describe('Admin users and audit log (integration)', () => {
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

  async function adminWithReauth(roles: Array<'PLATFORM_ADMIN' | 'SUPER_ADMIN' | 'MODERATOR'>) {
    const { email, user } = await makeUser(app, { roles });
    const { session, secret } = await adminSignIn(app, email);
    await rewindTotpReplay(app, user.id);
    await http()
      .post('/api/v1/admin/auth/reauth')
      .set(...bearer(session.accessToken))
      .send({ password: PASSWORD, code: generateSync({ secret: secret! }) })
      .expect(200);
    return { token: session.accessToken, user };
  }

  it('lists users with search, status filter and pagination meta', async () => {
    const { token } = await adminWithReauth(['PLATFORM_ADMIN']);
    const needle = `Findable${Date.now().toString(36)}`;
    await makeUser(app, { fullName: `${needle} One` });
    await makeUser(app, { fullName: `${needle} Two`, status: 'SUSPENDED' });

    const all = await http()
      .get('/api/v1/admin/users')
      .query({ q: needle, limit: 1 })
      .set(...bearer(token))
      .expect(200);
    expect(all.body.data).toHaveLength(1);
    expect(all.body.meta).toMatchObject({ page: 1, limit: 1, total: 2 });
    expect(all.body.data[0]).not.toHaveProperty('passwordHash');

    const suspended = await http()
      .get('/api/v1/admin/users')
      .query({ q: needle, status: 'SUSPENDED' })
      .set(...bearer(token))
      .expect(200);
    expect(suspended.body.meta.total).toBe(1);
  });

  it('suspends a member: audit entry written, sessions revoked, member locked out', async () => {
    const { token, user: admin } = await adminWithReauth(['PLATFORM_ADMIN']);
    const { email, user: member } = await makeUser(app);
    const memberSession = await loginMember(app, email);
    await http()
      .get('/api/v1/users/me')
      .set(...bearer(memberSession.accessToken))
      .expect(200);

    const res = await http()
      .post(`/api/v1/admin/users/${member.id}/suspend`)
      .set(...bearer(token))
      .send({ reason: 'Repeated harassment reports' })
      .expect(200);
    expect(res.body.data).toMatchObject({ id: member.id, status: 'SUSPENDED' });

    // Takes effect immediately, before the access token would expire.
    await http()
      .get('/api/v1/users/me')
      .set(...bearer(memberSession.accessToken))
      .expect(401);
    await http()
      .post('/api/v1/auth/login')
      .send({ identifier: email, password: PASSWORD, client: 'ANDROID' })
      .expect((r) => expect(r.status).toBeGreaterThanOrEqual(400));

    const entry = await prisma.auditLog.findFirstOrThrow({
      where: { action: 'user.suspend', entityId: member.id },
    });
    expect(entry).toMatchObject({ actorType: 'ADMIN', actorId: admin.id });
    expect(entry.after).toMatchObject({ status: 'SUSPENDED' });

    // The audit log endpoint shows it, with the actor's name.
    const log = await http()
      .get('/api/v1/admin/audit-logs')
      .query({ action: 'user.suspend', entityId: member.id })
      .set(...bearer(token))
      .expect(200);
    expect(log.body.data[0]).toMatchObject({ action: 'user.suspend', actorId: admin.id });
    expect(log.body.data[0].actorName).toBeTruthy();
  });

  it('reactivates a suspended account and refuses invalid transitions', async () => {
    const { token } = await adminWithReauth(['PLATFORM_ADMIN']);
    const { user: member } = await makeUser(app, { status: 'SUSPENDED' });
    await http()
      .post(`/api/v1/admin/users/${member.id}/suspend`)
      .set(...bearer(token))
      .send({ reason: 'Already suspended' })
      .expect(409);
    const res = await http()
      .post(`/api/v1/admin/users/${member.id}/reactivate`)
      .set(...bearer(token))
      .send({})
      .expect(200);
    expect(res.body.data.status).toBe('ACTIVE');
    await http()
      .post(`/api/v1/admin/users/${member.id}/reactivate`)
      .set(...bearer(token))
      .send({})
      .expect(409);
  });

  it('refuses self-suspension and lets only a super admin act on administrators', async () => {
    const { token, user: admin } = await adminWithReauth(['PLATFORM_ADMIN']);
    await http()
      .post(`/api/v1/admin/users/${admin.id}/suspend`)
      .set(...bearer(token))
      .send({ reason: 'Trying to lock myself out' })
      .expect(403);

    const { user: peer } = await makeUser(app, { roles: ['PLATFORM_ADMIN'] });
    await http()
      .post(`/api/v1/admin/users/${peer.id}/suspend`)
      .set(...bearer(token))
      .send({ reason: 'Peer admin lockout attempt' })
      .expect(403);

    const { token: superToken } = await adminWithReauth(['SUPER_ADMIN']);
    await http()
      .post(`/api/v1/admin/users/${peer.id}/suspend`)
      .set(...bearer(superToken))
      .send({ reason: 'Compromised credentials' })
      .expect(200);
  });

  it('requires recent re-authentication and the right permissions', async () => {
    const { email, user } = await makeUser(app, { roles: ['PLATFORM_ADMIN'] });
    const { session } = await adminSignIn(app, email);
    const { user: member } = await makeUser(app);
    const res = await http()
      .post(`/api/v1/admin/users/${member.id}/suspend`)
      .set(...bearer(session.accessToken))
      .send({ reason: 'No recent re-authentication' })
      .expect(401);
    expect(res.body.error.details).toMatchObject({ reason: 'REAUTH_REQUIRED' });
    expect(user.id).toBeDefined();

    // A moderator has neither user.view nor audit.view.
    const { token: modToken } = await adminWithReauth(['MODERATOR']);
    await http()
      .get('/api/v1/admin/users')
      .set(...bearer(modToken))
      .expect(403);
    await http()
      .get('/api/v1/admin/audit-logs')
      .set(...bearer(modToken))
      .expect(403);

    // A member token never reaches admin routes.
    const memberEmail = emailFor();
    await makeUser(app, { email: memberEmail });
    const memberSession = await loginMember(app, memberEmail);
    await http()
      .get('/api/v1/admin/users')
      .set(...bearer(memberSession.accessToken))
      .expect(403);
    await http().get('/api/v1/admin/users').expect(401);
  });

  it('validates input', async () => {
    const { token } = await adminWithReauth(['PLATFORM_ADMIN']);
    const { user: member } = await makeUser(app);
    await http()
      .post(`/api/v1/admin/users/${member.id}/suspend`)
      .set(...bearer(token))
      .send({ reason: 'no' })
      .expect(400);
    await http()
      .get('/api/v1/admin/users/not-a-uuid')
      .set(...bearer(token))
      .expect(400);
    await http()
      .get('/api/v1/admin/users')
      .query({ status: 'WHATEVER' })
      .set(...bearer(token))
      .expect(400);
  });
});
