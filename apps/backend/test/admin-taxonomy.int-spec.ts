import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import { adminSignIn, bearer, createTestApp, loginMember, makeUser, uniq } from './helpers';

describe('Admin taxonomy and suggestion queue (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let admin: string;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];
  const disciplines: string[] = [];

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
    const { email, user } = await makeUser(app, { roles: ['CONTENT_ADMIN'] });
    users.push(user.id);
    admin = (await adminSignIn(app, email)).session.accessToken;
  });
  afterAll(async () => {
    await prisma.specialisationSuggestion.deleteMany({ where: { userId: { in: users } } });
    await prisma.notification.deleteMany({ where: { userId: { in: users } } });
    await prisma.user.deleteMany({ where: { id: { in: users } } });
    await prisma.skill.deleteMany({ where: { slug: { startsWith: 'zz-test-' } } });
    await prisma.specialisation.deleteMany({ where: { disciplineId: { in: disciplines } } });
    await prisma.discipline.deleteMany({ where: { id: { in: disciplines } } });
    await prisma.interest.deleteMany({ where: { slug: { startsWith: 'zz-test-' } } });
    await app.close();
  });

  const as = (token: string) => ({
    get: (p: string) =>
      http()
        .get(`/api/v1${p}`)
        .set(...bearer(token)),
    post: (p: string, b: object = {}) =>
      http()
        .post(`/api/v1${p}`)
        .set(...bearer(token))
        .send(b),
    patch: (p: string, b: object) =>
      http()
        .patch(`/api/v1${p}`)
        .set(...bearer(token))
        .send(b),
  });
  const adm = () => as(admin);

  async function member() {
    const { email, user } = await makeUser(app);
    users.push(user.id);
    return { id: user.id, token: (await loginMember(app, email)).accessToken };
  }

  it('is closed to members and to staff without taxonomy.manage', async () => {
    const m = await member();
    await as(m.token).get('/admin/taxonomy/disciplines').expect(403);
    await as(m.token).post('/admin/taxonomy/interests', { name: 'Nope' }).expect(403);
    const mod = await makeUser(app, { roles: ['MODERATOR'] });
    users.push(mod.user.id);
    const modToken = (await adminSignIn(app, mod.email)).session.accessToken;
    await as(modToken).get('/admin/taxonomy/disciplines').expect(403);
    await http().get('/api/v1/admin/taxonomy/disciplines').expect(401);
  });

  it('creates, renames, archives and restores a discipline with its specialisations; audit entries are written', async () => {
    const name = `ZZ Test Craft ${uniq()}`;
    const created = await adm()
      .post('/admin/taxonomy/disciplines', { name, icon: 'hammer' })
      .expect(201);
    const d = created.body.data;
    disciplines.push(d.id);
    expect(d).toMatchObject({ name, icon: 'hammer', isActive: true, usage: 0 });
    expect(d.slug).toMatch(/^zz-test-craft-/);

    await adm().post('/admin/taxonomy/disciplines', { name }).expect(400); // icon required
    await adm().post('/admin/taxonomy/disciplines', { name, icon: 'hammer' }).expect(409); // duplicate slug

    const spec = (
      await adm()
        .post('/admin/taxonomy/specialisations', { name: 'Carving', disciplineId: d.id })
        .expect(201)
    ).body.data;
    expect(spec).toMatchObject({ disciplineName: name, sortOrder: 1 });
    await adm().post('/admin/taxonomy/specialisations', { name: 'Carving' }).expect(400); // discipline required
    await adm()
      .post('/admin/taxonomy/specialisations', { name: 'Carving', disciplineId: d.id })
      .expect(409);

    const renamed = await adm()
      .patch(`/admin/taxonomy/disciplines/${d.id}`, { name: `${name} Studio` })
      .expect(200);
    expect(renamed.body.data.name).toBe(`${name} Studio`);
    expect(renamed.body.data.slug).toBe(d.slug); // slug is stable

    // Archived: gone from what members see, still in the admin list.
    await adm().patch(`/admin/taxonomy/disciplines/${d.id}`, { isActive: false }).expect(200);
    const m = await member();
    const seen = (await as(m.token).get('/taxonomy/disciplines').expect(200)).body.data;
    expect(seen.find((x: any) => x.id === d.id)).toBeUndefined();
    const adminList = (await adm().get('/admin/taxonomy/disciplines').expect(200)).body.data;
    expect(adminList.find((x: any) => x.id === d.id).isActive).toBe(false);
    expect(
      (
        await adm().get('/admin/taxonomy/disciplines?includeArchived=false').expect(200)
      ).body.data.find((x: any) => x.id === d.id),
    ).toBeUndefined();
    await as(m.token)
      .patch('/me/onboarding', { step: 'DISCIPLINE', disciplineId: d.id })
      .expect(400);

    await adm().patch(`/admin/taxonomy/disciplines/${d.id}`, { isActive: true }).expect(200);
    expect(
      (await as(m.token).get('/taxonomy/disciplines')).body.data.find((x: any) => x.id === d.id)
        .specialisations,
    ).toHaveLength(1);

    const actions = (
      await prisma.auditLog.findMany({ where: { entityId: d.id }, orderBy: { createdAt: 'asc' } })
    ).map((a) => a.action);
    expect(actions).toEqual([
      'taxonomy.create',
      'taxonomy.update',
      'taxonomy.archive',
      'taxonomy.restore',
    ]);
  });

  it('reorders a list and rejects ids from different disciplines', async () => {
    const d = (
      await adm().post('/admin/taxonomy/disciplines', { name: `ZZ Order ${uniq()}`, icon: 'list' })
    ).body.data;
    disciplines.push(d.id);
    const ids: string[] = [];
    for (const n of ['One', 'Two', 'Three']) {
      ids.push(
        (
          await adm()
            .post('/admin/taxonomy/specialisations', { name: n, disciplineId: d.id })
            .expect(201)
        ).body.data.id,
      );
    }
    const res = await adm()
      .post('/admin/taxonomy/specialisations/reorder', { ids: [ids[2], ids[0], ids[1]] })
      .expect(200);
    expect(res.body.data.map((s: any) => s.name)).toEqual(['Three', 'One', 'Two']);
    // Members see the new order.
    const m = await member();
    const seen = (await as(m.token).get('/taxonomy/disciplines')).body.data.find(
      (x: any) => x.id === d.id,
    );
    expect(seen.specialisations.map((s: any) => s.name)).toEqual(['Three', 'One', 'Two']);

    const music = await prisma.specialisation.findFirstOrThrow({
      where: { discipline: { name: 'Music' } },
    });
    await adm()
      .post('/admin/taxonomy/specialisations/reorder', { ids: [ids[0], music.id] })
      .expect(400);
    await adm()
      .post('/admin/taxonomy/specialisations/reorder', {
        ids: ['00000000-0000-4000-8000-000000000000'],
      })
      .expect(400);
    await adm()
      .post('/admin/taxonomy/specialisations/reorder', { ids: [ids[0], ids[0]] })
      .expect(400);
  });

  it('manages skills (general or per discipline), interests and areas, and shows how many members use each', async () => {
    const skill = (
      await adm()
        .post('/admin/taxonomy/skills', { name: `ZZ Test Skill ${uniq()}` })
        .expect(201)
    ).body.data;
    expect(skill.disciplineId).toBeNull();
    const interest = (
      await adm()
        .post('/admin/taxonomy/interests', { name: `ZZ Test Interest ${uniq()}` })
        .expect(201)
    ).body.data;
    const area = (
      await adm()
        .post('/admin/taxonomy/development-areas', { name: `ZZ Test Area ${uniq()}` })
        .expect(201)
    ).body.data;
    try {
      const m = await member();
      await as(m.token)
        .patch('/me/onboarding', {
          step: 'SKILLS',
          skillIds: [skill.id],
          interestIds: [interest.id],
          developmentAreaIds: [area.id],
        })
        .expect(200);
      const list = (await adm().get('/admin/taxonomy/skills')).body.data;
      expect(list.find((s: any) => s.id === skill.id).usage).toBe(1);
      expect(
        (await adm().get('/admin/taxonomy/interests')).body.data.find(
          (s: any) => s.id === interest.id,
        ).usage,
      ).toBe(1);

      // Archiving keeps it on the profiles that already have it but stops new picks.
      await adm().patch(`/admin/taxonomy/skills/${skill.id}`, { isActive: false }).expect(200);
      expect((await as(m.token).get('/me/onboarding')).body.data.profile.skills).toHaveLength(1);
      expect(
        (await as(m.token).get('/taxonomy/skills')).body.data.find((s: any) => s.id === skill.id),
      ).toBeUndefined();
      const other = await member();
      await as(other.token)
        .patch('/me/onboarding', { step: 'SKILLS', skillIds: [skill.id] })
        .expect(400);
    } finally {
      await prisma.creativeProfile.deleteMany({ where: { userId: { in: users } } });
      await prisma.developmentArea.delete({ where: { id: area.id } });
      await prisma.interest.delete({ where: { id: interest.id } });
    }
    await adm()
      .patch('/admin/taxonomy/skills/00000000-0000-4000-8000-000000000000', { name: 'Ghost' })
      .expect(404);
    await adm().get('/admin/taxonomy/nonsense').expect(400);
  });

  describe('suggestion queue', () => {
    async function suggest(name: string, discipline = 'Design') {
      const m = await member();
      const d = await prisma.discipline.findFirstOrThrow({ where: { name: discipline } });
      await as(m.token)
        .patch('/me/onboarding', { step: 'DISCIPLINE', disciplineId: d.id })
        .expect(200);
      const s = (
        await as(m.token)
          .post('/taxonomy/specialisations/suggestions', { disciplineId: d.id, name })
          .expect(201)
      ).body.data;
      return { m, d, s };
    }

    it('lists pending suggestions oldest first with who asked', async () => {
      const { s, m } = await suggest(`Risograph ${uniq()}`);
      const list = await adm()
        .get('/admin/specialisation-suggestions?status=PENDING&limit=100')
        .expect(200);
      const found = list.body.data.find((x: any) => x.id === s.id);
      expect(found).toMatchObject({
        status: 'PENDING',
        disciplineName: 'Design',
        suggestedById: m.id,
      });
      expect(list.body.meta).toMatchObject({ page: 1 });
    });

    it('approves: creates the specialisation, adds it to the member’s profile, tells them, and audits', async () => {
      const { s, m, d } = await suggest(`Kitenge print ${uniq()}`);
      const res = await adm()
        .post(`/admin/specialisation-suggestions/${s.id}/approve`, {
          name: s.name.replace('print', 'prints'),
        })
        .expect(200);
      expect(res.body.data).toMatchObject({ status: 'APPROVED' });
      const created = await prisma.specialisation.findUniqueOrThrow({
        where: { id: res.body.data.specialisationId },
      });
      expect(created).toMatchObject({ disciplineId: d.id, isActive: true });
      expect(created.name).toContain('prints');
      expect(
        (await as(m.token).get('/me/onboarding')).body.data.profile.specialisations.map(
          (x: any) => x.id,
        ),
      ).toContain(created.id);
      expect(
        await prisma.notification.count({ where: { userId: m.id, category: 'PROFILE' } }),
      ).toBe(1);
      expect(
        await prisma.auditLog.count({
          where: { entityId: s.id, action: 'specialisation_suggestion.approve' },
        }),
      ).toBe(1);
      await adm().post(`/admin/specialisation-suggestions/${s.id}/approve`).expect(409); // already decided
      await prisma.creativeSpecialisation.deleteMany({ where: { specialisationId: created.id } });
      await prisma.specialisationSuggestion.update({
        where: { id: s.id },
        data: { specialisationId: null },
      });
      await prisma.specialisation.delete({ where: { id: created.id } });
    });

    it('merges into an existing specialisation of the same discipline only', async () => {
      const { s, m } = await suggest(`Brand marks ${uniq()}`);
      const brand = await prisma.specialisation.findFirstOrThrow({
        where: { name: 'Brand identity', discipline: { name: 'Design' } },
      });
      const music = await prisma.specialisation.findFirstOrThrow({
        where: { discipline: { name: 'Music' } },
      });
      await adm()
        .post(`/admin/specialisation-suggestions/${s.id}/merge`, { specialisationId: music.id })
        .expect(400);
      const res = await adm()
        .post(`/admin/specialisation-suggestions/${s.id}/merge`, { specialisationId: brand.id })
        .expect(200);
      expect(res.body.data).toMatchObject({ status: 'MERGED', specialisationId: brand.id });
      expect(
        (await as(m.token).get('/me/onboarding')).body.data.profile.specialisations.map(
          (x: any) => x.name,
        ),
      ).toContain('Brand identity');
    });

    it('rejects with a note, notifies the member, and leaves the list unchanged', async () => {
      const { s, m, d } = await suggest(`Spam ${uniq()}`);
      const before = await prisma.specialisation.count({ where: { disciplineId: d.id } });
      const res = await adm()
        .post(`/admin/specialisation-suggestions/${s.id}/reject`, { note: 'Too narrow' })
        .expect(200);
      expect(res.body.data).toMatchObject({ status: 'REJECTED', resolutionNote: 'Too narrow' });
      expect(await prisma.specialisation.count({ where: { disciplineId: d.id } })).toBe(before);
      expect(await prisma.notification.count({ where: { userId: m.id } })).toBe(1);
      await adm().post(`/admin/specialisation-suggestions/${s.id}/reject`).expect(409);
      await adm()
        .post('/admin/specialisation-suggestions/00000000-0000-4000-8000-000000000000/reject')
        .expect(404);
    });

    it('two admins deciding at the same moment: one wins, the other is told it is decided', async () => {
      const { s } = await suggest(`Collab ${uniq()}`);
      const [a, b] = await Promise.all([
        adm().post(`/admin/specialisation-suggestions/${s.id}/reject`),
        adm().post(`/admin/specialisation-suggestions/${s.id}/reject`),
      ]);
      expect([a.status, b.status].sort()).toEqual([200, 409]);
    });
  });
});
