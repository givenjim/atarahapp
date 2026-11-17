import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import { bearer, createTestApp, deleteUsers, loginMember, makeUser } from './helpers';

jest.setTimeout(60_000);

describe('Member preferences (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  async function member() {
    const { user, email } = await makeUser(app);
    users.push(user.id);
    const session = await loginMember(app, email);
    return { id: user.id, email, token: session.accessToken, client: session.client };
  }

  it('GET /users/me works for a user with no row (LIGHT) and does not write', async () => {
    const m = await member();
    await prisma.memberPreference.deleteMany({ where: { userId: m.id } });
    const res = await http()
      .get('/api/v1/users/me')
      .set(...bearer(m.token))
      .expect(200);
    expect(res.body.data).toMatchObject({
      appearance: 'LIGHT',
      locale: 'en',
      timeZone: 'Africa/Nairobi',
      marketingOptIn: false,
    });
    expect(await prisma.memberPreference.count({ where: { userId: m.id } })).toBe(0);
  });

  it('GET /me/preferences returns the defaults and creates the row lazily', async () => {
    const m = await member();
    await prisma.memberPreference.deleteMany({ where: { userId: m.id } });
    const res = await http()
      .get('/api/v1/me/preferences')
      .set(...bearer(m.token))
      .expect(200);
    expect(res.body.data).toEqual({
      appearance: 'LIGHT',
      locale: 'en',
      timeZone: 'Africa/Nairobi',
      marketingOptIn: false,
    });
    expect(await prisma.memberPreference.count({ where: { userId: m.id } })).toBe(1);
  });

  it('PATCH persists, is partial, shows in /users/me, and never touches another member', async () => {
    const a = await member();
    const b = await member();
    await prisma.memberPreference.deleteMany({ where: { userId: a.id } }); // first write creates the row
    const patched = await http()
      .patch('/api/v1/me/preferences')
      .set(...bearer(a.token))
      .send({ appearance: 'DARK' })
      .expect(200);
    expect(patched.body.data.appearance).toBe('DARK');
    expect(patched.body.data.timeZone).toBe('Africa/Nairobi');

    await http()
      .patch('/api/v1/me/preferences')
      .set(...bearer(a.token))
      .send({ locale: 'sw', timeZone: 'Africa/Kampala', marketingOptIn: true })
      .expect(200);
    const again = await http()
      .get('/api/v1/me/preferences')
      .set(...bearer(a.token))
      .expect(200);
    expect(again.body.data).toEqual({
      appearance: 'DARK',
      locale: 'sw',
      timeZone: 'Africa/Kampala',
      marketingOptIn: true,
    });
    const me = await http()
      .get('/api/v1/users/me')
      .set(...bearer(a.token))
      .expect(200);
    expect(me.body.data).toMatchObject({ appearance: 'DARK', locale: 'sw', marketingOptIn: true });

    const other = await http()
      .get('/api/v1/me/preferences')
      .set(...bearer(b.token))
      .expect(200);
    expect(other.body.data.appearance).toBe('LIGHT');
  });

  it('rejects invalid values with VALIDATION_ERROR', async () => {
    const m = await member();
    for (const body of [
      { appearance: 'SEPIA' },
      { timeZone: 'Mars/Olympus' },
      { locale: 'English!' },
      { marketingOptIn: 'yes' },
      { userId: '00000000-0000-4000-8000-000000000001' },
    ]) {
      const res = await http()
        .patch('/api/v1/me/preferences')
        .set(...bearer(m.token))
        .send(body)
        .expect(400);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
    }
  });

  it('requires authentication', async () => {
    await http().get('/api/v1/me/preferences').expect(401);
    await http().patch('/api/v1/me/preferences').send({ appearance: 'DARK' }).expect(401);
  });

  it('is not readable or writable through the Supabase API (RLS, no grants)', async () => {
    const m = await member();
    await http()
      .get('/api/v1/me/preferences')
      .set(...bearer(m.token))
      .expect(200);
    const read = await m.client.from('member_preferences').select('*').limit(1);
    expect(read.error?.code).toBe('42501');
    const write = await m.client
      .from('member_preferences')
      .update({ appearance: 'DARK' })
      .eq('userId', m.id);
    expect(write.error).not.toBeNull();
  });
});
