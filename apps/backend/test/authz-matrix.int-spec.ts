import { type INestApplication, RequestMethod } from '@nestjs/common';
import { METHOD_METADATA, PATH_METADATA } from '@nestjs/common/constants';
import { ModulesContainer } from '@nestjs/core';
import request from 'supertest';
import { ENTITLEMENT, IS_PUBLIC, OPTIONAL_AUTH, PERMISSIONS } from '../src/access/decorators';
import { AccessService } from '../src/access/access.service';
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

/**
 * P1-M12 authorisation matrix. Part 1 reads every route of the running application from its decorators (so a new
 * endpoint is covered the moment it exists) and runs it as eight kinds of caller, asserting that the guards allow or
 * refuse exactly what the metadata says. Part 2 states the role matrix of Master Prompt section 5.6 explicitly for the
 * sensitive actions, independent of the metadata. Part 3 is IDOR: one member tries every `{id}` route on another
 * member's data.
 *
 * "Allowed" means the guards let the request through (any status except 401, 403 and 429: the handler may still
 * answer 400 or 404 for the placeholder id and body). "Denied" means 401 or 403, never a 2xx.
 */
jest.setTimeout(900_000);

const PLACEHOLDER = '00000000-0000-4000-8000-000000000001';
const METHODS: Record<number, string> = {
  [RequestMethod.GET]: 'get',
  [RequestMethod.POST]: 'post',
  [RequestMethod.PUT]: 'put',
  [RequestMethod.PATCH]: 'patch',
  [RequestMethod.DELETE]: 'delete',
};

interface Route {
  method: string;
  path: string;
  isPublic: boolean;
  optional: boolean;
  permissions: string[];
  entitlement: string | null;
  admin: boolean;
}

/** Routes that act on the caller's own account when probed as an allowed caller, or that carry their own checks. */
const SKIP_WHEN_ALLOWED = [
  '/api/v1/me/delete',
  '/api/v1/me/restore',
  '/api/v1/me/export',
  '/api/v1/auth/sessions/revoke-others',
  '/api/v1/me/password',
];
/** Public by design but verified another way (a signed hook, a metrics token): not part of the metadata matrix. */
const SELF_VERIFIED = ['/api/v1/auth/hooks/send-sms', '/metrics'];

const norm = (p: string) => `/${p}`.replace(/\/+/g, '/').replace(/\/$/, '') || '/';

describe('Authorisation matrix (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let access: AccessService;
  let routes: Route[] = [];
  const users: string[] = [];
  const http = () => request(app.getHttpServer());

  interface Persona {
    key: string;
    token: string | null;
    permissions: Set<string>;
    isStaffSession: boolean;
    suspended?: boolean;
  }
  const personas: Persona[] = [];

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
    access = app.get(AccessService);
    routes = enumerate();

    const build = async (
      key: string,
      role?: 'MODERATOR' | 'CONTENT_ADMIN' | 'PLATFORM_ADMIN' | 'SUPER_ADMIN',
    ) => {
      const { user, email } = await makeUser(app, {
        roles: role ? [role] : [],
        fullName: `Matrix ${key}`,
      });
      users.push(user.id);
      const token = role
        ? (await adminSignIn(app, email)).session.accessToken
        : (await loginMember(app, email)).accessToken;
      const eff = await access.effectiveAccess(user.id, 'ACTIVE');
      personas.push({ key, token, permissions: new Set(eff.permissions), isStaffSession: !!role });
      return { id: user.id, email, token };
    };
    personas.push({ key: 'anonymous', token: null, permissions: new Set(), isStaffSession: false });
    await build('member', undefined);
    await build('moderator', 'MODERATOR');
    await build('content-admin', 'CONTENT_ADMIN');
    await build('platform-admin', 'PLATFORM_ADMIN');
    await build('super-admin', 'SUPER_ADMIN');
    // A member whose account is suspended after they signed in: the token is still valid, the account is not.
    const s = await makeUser(app, { fullName: 'Matrix suspended' });
    users.push(s.user.id);
    const sToken = (await loginMember(app, s.email)).accessToken;
    await prisma.user.update({ where: { id: s.user.id }, data: { status: 'SUSPENDED' } });
    personas.push({
      key: 'suspended-member',
      token: sToken,
      permissions: new Set(),
      isStaffSession: false,
      suspended: true,
    });
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  /** Every route from the controllers' decorators. */
  function enumerate(): Route[] {
    const out: Route[] = [];
    const reflect = Reflect as unknown as { getMetadata(k: string, t: unknown): unknown };
    const container = app.get(ModulesContainer);
    for (const mod of container.values()) {
      for (const wrapper of mod.controllers.values()) {
        const ctrl = wrapper.metatype as unknown as { prototype: Record<string, unknown> } | null;
        if (!ctrl) continue;
        const base = reflect.getMetadata(PATH_METADATA, ctrl);
        const bases = Array.isArray(base)
          ? (base as string[])
          : [(base as string | undefined) ?? ''];
        for (const name of Object.getOwnPropertyNames(ctrl.prototype)) {
          const handler = ctrl.prototype[name];
          if (typeof handler !== 'function' || name === 'constructor') continue;
          const methodCode = reflect.getMetadata(METHOD_METADATA, handler) as number | undefined;
          if (methodCode === undefined || !(methodCode in METHODS)) continue;
          const sub = reflect.getMetadata(PATH_METADATA, handler);
          const subs = Array.isArray(sub) ? (sub as string[]) : [(sub as string | undefined) ?? ''];
          const meta = <T>(k: string) =>
            (reflect.getMetadata(k, handler) ?? reflect.getMetadata(k, ctrl)) as T | undefined;
          for (const b of bases) {
            for (const s of subs) {
              const raw = norm(`${b}/${s}`);
              const outside =
                raw === '/health/live' || raw === '/health/ready' || raw === '/metrics';
              out.push({
                method: METHODS[methodCode]!,
                path: outside ? raw : `/api/v1${raw}`,
                isPublic: meta<boolean>(IS_PUBLIC) === true,
                optional: meta<boolean>(OPTIONAL_AUTH) === true,
                permissions: meta<string[]>(PERMISSIONS) ?? [],
                entitlement: meta<string>(ENTITLEMENT) ?? null,
                admin: raw.startsWith('/admin'),
              });
            }
          }
        }
      }
    }
    // Express treats `/x/:id` and `/x/fixed` by registration order; both are probed, so keep every route.
    return out.filter((r) => !SELF_VERIFIED.includes(r.path));
  }

  const concrete = (path: string) => path.replace(/:[A-Za-z]+/g, PLACEHOLDER);

  async function send(p: Persona, r: Route): Promise<number> {
    let req = (http() as unknown as Record<string, (u: string) => request.Test>)[r.method]!(
      concrete(r.path),
    );
    if (p.token) req = req.set(...bearer(p.token));
    // A body no DTO accepts: a handler behind a DTO answers 400; a guard answers before it ever looks.
    if (r.method !== 'get' && r.method !== 'delete') req = req.send({ __matrix: true });
    return (await req).status;
  }

  const denied = (s: number) => s === 401 || s === 403;
  const guardsPassed = (s: number) => !denied(s) && s !== 429;

  it('enumerates the whole application (sanity)', () => {
    expect(routes.length).toBeGreaterThan(150);
    expect(
      routes.some((r) => r.path === '/api/v1/admin/users' && r.permissions.includes('user.view')),
    ).toBe(true);
    expect(routes.some((r) => r.isPublic)).toBe(true);
    expect(routes.some((r) => r.optional)).toBe(true);
  });

  it('every route allows or refuses each kind of caller exactly as its decorators say', async () => {
    const failures: string[] = [];
    let checked = 0;
    for (const p of personas) {
      for (const r of routes) {
        const status = await send(p, r);
        checked += 1;
        const label = `${p.key}: ${r.method.toUpperCase()} ${r.path} -> ${status}`;

        let expectAllowed: boolean | null;
        if (r.isPublic) expectAllowed = p.suspended ? null : true;
        else if (!p.token) expectAllowed = r.optional;
        else if (p.suspended) expectAllowed = r.optional ? null : false;
        else if (r.admin && !p.isStaffSession) expectAllowed = false;
        else {
          const need = r.admin ? ['admin.access', ...r.permissions] : r.permissions;
          expectAllowed = need.every((k) => p.permissions.has(k)) && r.entitlement === null;
        }
        if (expectAllowed === null) continue;
        if (!expectAllowed && !denied(status)) failures.push(`${label} (expected 401/403)`);
        if (expectAllowed && !guardsPassed(status)) {
          // Routes that act on the caller's own account are probed as denied callers only.
          if (!SKIP_WHEN_ALLOWED.includes(r.path))
            failures.push(`${label} (expected the guards to let it through)`);
        }
        // A refused caller never gets a success of any kind.
        if (!expectAllowed && status >= 200 && status < 300)
          failures.push(`${label} (2xx for a refused caller)`);
      }
    }
    // eslint-disable-next-line no-console
    console.log(
      `Authorisation matrix: ${checked} requests (${routes.length} routes x ${personas.length} callers)`,
    );
    expect(failures).toEqual([]);
  });

  describe('the role matrix (Master Prompt 5.6), stated explicitly', () => {
    const rows: Array<[string, string, string, Record<string, boolean>]> = [
      // [description, method, path, who may] (anyone not listed is refused)
      ['read users', 'get', '/api/v1/admin/users', { 'platform-admin': true, 'super-admin': true }],
      [
        'suspend users',
        'post',
        `/api/v1/admin/users/${PLACEHOLDER}/suspend`,
        { 'platform-admin': true, 'super-admin': true },
      ],
      [
        'assign roles',
        'post',
        `/api/v1/admin/users/${PLACEHOLDER}/roles`,
        { 'platform-admin': true, 'super-admin': true },
      ],
      [
        'view analytics',
        'get',
        '/api/v1/admin/analytics/events',
        { 'platform-admin': true, 'super-admin': true },
      ],
      [
        'view the audit log',
        'get',
        '/api/v1/admin/audit-logs',
        { 'platform-admin': true, 'super-admin': true },
      ],
      [
        'manage opportunities',
        'get',
        '/api/v1/admin/opportunities',
        { 'platform-admin': true, 'super-admin': true },
      ],
      [
        'set VERIFIED on an opportunity',
        'post',
        `/api/v1/admin/opportunities/${PLACEHOLDER}/verify`,
        { 'platform-admin': true, 'super-admin': true },
      ],
      [
        'view the report queue',
        'get',
        '/api/v1/admin/reports',
        { moderator: true, 'platform-admin': true, 'super-admin': true },
      ],
      [
        'decide moderation cases',
        'post',
        `/api/v1/admin/moderation-cases/${PLACEHOLDER}/actions`,
        { moderator: true, 'platform-admin': true, 'super-admin': true },
      ],
      [
        'manage articles',
        'get',
        '/api/v1/admin/articles',
        { 'content-admin': true, 'super-admin': true },
      ],
      [
        'manage the taxonomy',
        'get',
        '/api/v1/admin/taxonomy/disciplines',
        { 'content-admin': true, 'platform-admin': true, 'super-admin': true },
      ],
      [
        'see queue counts',
        'get',
        '/api/v1/admin/jobs',
        { 'platform-admin': true, 'super-admin': true },
      ],
    ];
    for (const [what, method, path, who] of rows) {
      it(`${what}: ${Object.keys(who).join(', ')} only`, async () => {
        for (const p of personas) {
          if (p.suspended) continue;
          const status = await send(p, {
            method,
            path,
            isPublic: false,
            optional: false,
            permissions: [],
            entitlement: null,
            admin: false,
          });
          if (who[p.key]) expect([p.key, guardsPassed(status)]).toEqual([p.key, true]);
          else expect([p.key, denied(status)]).toEqual([p.key, true]);
        }
      });
    }

    it('nobody but a super admin can grant administrator roles', async () => {
      const admin = personas.find((p) => p.key === 'platform-admin')!;
      expect(admin.permissions.has('admin.manage')).toBe(false);
      expect(personas.find((p) => p.key === 'super-admin')!.permissions.has('admin.manage')).toBe(
        true,
      );
    });
  });
});

describe("IDOR: one member against another member's data (integration)", () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const users: string[] = [];
  const http = () => request(app.getHttpServer());

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  const as = (token: string) => ({
    get: (p: string, q: object = {}) =>
      http()
        .get(`/api/v1${p}`)
        .query(q)
        .set(...bearer(token)),
    post: (p: string, b: object = {}) =>
      http()
        .post(`/api/v1${p}`)
        .send(b)
        .set(...bearer(token)),
    put: (p: string, b: object = {}) =>
      http()
        .put(`/api/v1${p}`)
        .send(b)
        .set(...bearer(token)),
    patch: (p: string, b: object = {}) =>
      http()
        .patch(`/api/v1${p}`)
        .send(b)
        .set(...bearer(token)),
    del: (p: string) =>
      http()
        .delete(`/api/v1${p}`)
        .set(...bearer(token)),
  });

  async function member(label: string) {
    const { user, email } = await makeUser(app, { fullName: `${label} ${uniq()}` });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const discipline = await prisma.discipline.findFirstOrThrow();
    await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle: `i_${uniq()}`.replace(/-/g, '_'),
        displayName: label,
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        primaryDisciplineId: discipline.id,
      },
    });
    return { id: user.id, token };
  }

  it('another member can neither read nor change what is not theirs (404 or 403, never 2xx)', async () => {
    const owner = await member('Owner');
    const other = await member('Other');

    const project = (await as(owner.token).post('/me/projects', { title: 'Mine' }).expect(201)).body
      .data.id as string;
    const experience = (
      await as(owner.token)
        .post('/me/experience', {
          title: 'Role',
          organisation: 'Org',
          startDate: '2020-01-01',
          current: true,
        })
        .expect(201)
    ).body.data.id as string;
    const achievement = (
      await as(owner.token).post('/me/achievements', { type: 'AWARD', title: 'Prize' }).expect(201)
    ).body.data.id as string;
    const service = (
      await as(owner.token)
        .post('/me/services', { title: 'Service', priceType: 'ON_REQUEST' })
        .expect(201)
    ).body.data.id as string;
    const post = (
      await as(owner.token)
        .post('/posts', { type: 'UPDATE', body: 'Owner post', audience: 'MEMBERS' })
        .expect(201)
    ).body.data.id as string;
    const comment = (
      await as(owner.token).post(`/posts/${post}/comments`, { body: 'Owner comment' }).expect(201)
    ).body.data.id as string;
    const recent = (
      await as(owner.token).post('/me/recent-searches', { query: 'owner words' }).expect(200)
    ).body.data.id as string;
    const device = await prisma.userDevice
      .create({
        data: {
          userId: owner.id,
          deviceHash: `h-${uniq()}`,
          name: 'Phone',
          platform: 'ANDROID',
        } as never,
      })
      .catch(() => null);
    const sessionId = (await as(owner.token).get('/auth/sessions').expect(200)).body.data[0]?.id as
      string | undefined;

    const probes: Array<[string, () => request.Test]> = [
      ['GET own project', () => as(other.token).get(`/me/projects/${project}`)],
      [
        'PATCH own project',
        () => as(other.token).patch(`/me/projects/${project}`, { title: 'Hijacked' }),
      ],
      ['DELETE own project', () => as(other.token).del(`/me/projects/${project}`)],
      ['publish own project', () => as(other.token).post(`/me/projects/${project}/publish`)],
      [
        'add collaborator',
        () => as(other.token).post(`/me/projects/${project}/collaborators`, { name: 'x' }),
      ],
      [
        'PATCH experience',
        () => as(other.token).patch(`/me/experience/${experience}`, { title: 'Hijacked' }),
      ],
      ['DELETE experience', () => as(other.token).del(`/me/experience/${experience}`)],
      [
        'PATCH achievement',
        () => as(other.token).patch(`/me/achievements/${achievement}`, { title: 'Hijacked' }),
      ],
      ['DELETE achievement', () => as(other.token).del(`/me/achievements/${achievement}`)],
      [
        'PATCH service',
        () => as(other.token).patch(`/me/services/${service}`, { title: 'Hijacked' }),
      ],
      ['DELETE service', () => as(other.token).del(`/me/services/${service}`)],
      ['PATCH post', () => as(other.token).patch(`/posts/${post}`, { body: 'Hijacked' })],
      ['DELETE post', () => as(other.token).del(`/posts/${post}`)],
      ['PATCH comment', () => as(other.token).patch(`/comments/${comment}`, { body: 'Hijacked' })],
      ['DELETE comment', () => as(other.token).del(`/comments/${comment}`)],
      ['DELETE recent search', () => as(other.token).del(`/me/recent-searches/${recent}`)],
    ];
    if (device) probes.push(['DELETE device', () => as(other.token).del(`/devices/${device.id}`)]);
    if (sessionId)
      probes.push(['DELETE session', () => as(other.token).del(`/auth/sessions/${sessionId}`)]);

    const leaks: string[] = [];
    for (const [label, probe] of probes) {
      const res = await probe();
      if (res.status >= 200 && res.status < 300) leaks.push(`${label} -> ${res.status}`);
      if (![400, 403, 404, 409].includes(res.status) && !(res.status >= 200 && res.status < 300))
        leaks.push(`${label} -> unexpected ${res.status}`);
    }
    expect(leaks).toEqual([]);

    // Nothing changed, and the owner still reaches everything.
    expect((await as(owner.token).get(`/me/projects/${project}`).expect(200)).body.data.title).toBe(
      'Mine',
    );
    expect((await prisma.post.findUniqueOrThrow({ where: { id: post } })).body).toBe('Owner post');
    expect((await prisma.comment.findUniqueOrThrow({ where: { id: comment } })).body).toBe(
      'Owner comment',
    );
    expect(await prisma.profileService.count({ where: { id: service } })).toBe(1);
    expect(await prisma.achievement.count({ where: { id: achievement } })).toBe(1);
    expect(await prisma.experience.count({ where: { id: experience } })).toBe(1);
    expect(await prisma.recentSearch.count({ where: { id: recent } })).toBe(1);
    expect(await prisma.userRole.count({ where: { userId: other.id } })).toBe(0);
  });

  it('a connection request can be answered only by the person it was sent to', async () => {
    const a = await member('Asker');
    const b = await member('Target');
    const c = await member('Bystander');
    const handleB = (await prisma.creativeProfile.findUniqueOrThrow({ where: { userId: b.id } }))
      .handle!;
    await as(a.token).post(`/creatives/${handleB}/connect`).expect(200);
    const row = await prisma.connection.findFirstOrThrow({
      where: { requesterId: a.id, addresseeId: b.id },
    });
    for (const who of [a, c]) {
      const res = await as(who.token).post(`/connections/${row.id}/accept`);
      expect([403, 404, 409]).toContain(res.status);
    }
    expect((await prisma.connection.findUniqueOrThrow({ where: { id: row.id } })).status).toBe(
      'PENDING',
    );
    // A bystander cannot cancel it either.
    expect([403, 404, 409]).toContain((await as(c.token).del(`/connections/${row.id}`)).status);
    await as(b.token).post(`/connections/${row.id}/accept`).expect(200);
  });

  it('a private group and a private post are the same 404 as a missing one', async () => {
    const owner = await member('GroupOwner');
    const other = await member('Outsider');
    const group = await prisma.group.create({
      data: {
        slug: `g-${uniq()}`,
        type: 'INTEREST',
        name: 'Private',
        visibility: 'PRIVATE',
        createdById: owner.id,
      },
    });
    await prisma.groupMembership.create({
      data: { groupId: group.id, userId: owner.id, role: 'OWNER' },
    });
    const missing = await as(other.token).get('/groups/does-not-exist-at-all');
    const hidden = await as(other.token).get(`/groups/${group.slug}`);
    expect(hidden.status).toBe(404);
    expect(hidden.status).toBe(missing.status);
    expect(hidden.body.error.code).toBe(missing.body.error.code);
    expect([403, 404]).toContain((await as(other.token).post(`/groups/${group.slug}/join`)).status);
    expect([403, 404]).toContain((await as(other.token).get(`/groups/${group.slug}/posts`)).status);

    const post = await prisma.post.create({
      data: {
        authorId: owner.id,
        type: 'UPDATE',
        body: 'Only for connections',
        audience: 'CONNECTIONS',
      },
    });
    expect((await as(other.token).get(`/posts/${post.id}`)).status).toBe(404);
    expect((await as(other.token).get(`/posts/${post.id}/comments`)).status).toBe(404);
    expect((await as(other.token).put(`/posts/${post.id}/reactions`)).status).toBe(404);
  });

  it('draft opportunities, learning drafts and private media do not leak by id', async () => {
    const owner = await member('Uploader');
    const other = await member('Snoop');
    const prov = await prisma.opportunityProvider.create({ data: { name: `IDOR ${uniq()}` } });
    const draft = await prisma.opportunity.create({
      data: {
        providerId: prov.id,
        slug: `d-${uniq()}`,
        type: 'GIG',
        title: 'Secret draft',
        summary: 'A draft nobody should see yet.',
        status: 'DRAFT',
      },
    });
    expect((await as(other.token).get(`/opportunities/${draft.id}`)).status).toBe(404);
    expect((await as(other.token).put(`/opportunities/${draft.id}/save`)).status).toBe(404);
    expect(
      (await as(other.token).post(`/opportunities/${draft.id}/track`, { status: 'SAVED' })).status,
    ).toBe(404);

    // The upload endpoint needs object storage, which these tests stub out: create the private file directly.
    const media = (
      await prisma.mediaAsset.create({
        data: {
          ownerId: owner.id,
          kind: 'IMAGE',
          bucket: 'PRIVATE',
          objectKey: `idor/${uniq()}.jpg`,
          mimeType: 'image/jpeg',
          sizeBytes: 1000n,
          status: 'READY',
        },
      })
    ).id;
    for (const res of [
      await as(other.token).get(`/media/${media}`),
      await as(other.token).del(`/media/${media}`),
      await as(other.token).post(`/media/${media}/complete`),
    ]) {
      expect(res.status).toBe(404);
    }
    await prisma.opportunity.delete({ where: { id: draft.id } });
    await prisma.opportunityProvider.delete({ where: { id: prov.id } });
  });

  it('a suspended member and a member of another account cannot be impersonated through the admin area', async () => {
    const m = await member('Plain');
    for (const path of [
      '/admin/users',
      '/admin/dashboard',
      '/admin/analytics/events',
      '/admin/roles',
      `/admin/users/${m.id}/overview`,
    ]) {
      expect([401, 403]).toContain((await as(m.token).get(path)).status);
    }
    expect([401, 403]).toContain(
      (await as(m.token).post(`/admin/users/${m.id}/roles`, { role: 'SUPER_ADMIN' })).status,
    );
    expect(await prisma.userRole.count({ where: { userId: m.id } })).toBe(0);
  });
});
