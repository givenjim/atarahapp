import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import { StorageService } from '../src/storage/storage.service';
import { bearer, createTestApp, emailFor, loginMember, makeUser, uniq } from './helpers';

describe('Onboarding and creative profile (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const http = () => request(app.getHttpServer());
  const createdUsers: string[] = [];

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
    // These suites stub object storage; the avatar view only needs a signed URL to exist.
    Object.assign(app.get(StorageService), {
      signedDownloadUrl: async (_b: string, key: string) => `https://signed.test/${key}`,
      remove: async () => undefined,
    });
  });
  afterAll(async () => {
    // Deleting the user cascades to the profile, its selections, Passport and suggestions.
    await prisma.user.deleteMany({ where: { id: { in: createdUsers } } });
    await app.close();
  });

  async function member(fullName = 'Nia Wairimu') {
    const { user, email } = await makeUser(app, { fullName });
    createdUsers.push(user.id);
    const { accessToken } = await loginMember(app, email);
    return { id: user.id, token: accessToken, email };
  }
  const get = (token: string, path: string) =>
    http()
      .get(`/api/v1${path}`)
      .set(...bearer(token));
  const patch = (token: string, body: Record<string, unknown>) =>
    http()
      .patch('/api/v1/me/onboarding')
      .set(...bearer(token))
      .send(body);

  async function discipline(name: string) {
    return prisma.discipline.findFirstOrThrow({
      where: { name },
      include: { specialisations: { orderBy: { sortOrder: 'asc' } } },
    });
  }
  const county = (code: string) => prisma.county.findFirstOrThrow({ where: { code } });

  describe('taxonomy and locations', () => {
    it('requires sign-in', async () => {
      await http().get('/api/v1/taxonomy/disciplines').expect(401);
      await http().get('/api/v1/locations/counties').expect(401);
    });

    it('serves the 12 seeded disciplines with their specialisations in prototype order', async () => {
      const { token } = await member();
      const res = await get(token, '/taxonomy/disciplines').expect(200);
      expect(res.body.data.map((d: any) => d.name)).toEqual([
        'Music',
        'Acting',
        'Dance',
        'Writing',
        'Fashion',
        'Visual Art',
        'Photography',
        'Film / Video',
        'Design',
        'Animation',
        'Production',
        'Entrepreneur',
      ]);
      const animation = res.body.data.find((d: any) => d.name === 'Animation');
      expect(animation.icon).toBe('aperture');
      expect(animation.specialisations.map((s: any) => s.name)).toEqual([
        '2D animation',
        '3D animation',
        'Motion graphics',
        'Character design',
        'Storyboarding',
      ]);
    });

    it('serves skills (general, or a discipline by slug or id), interests and areas to develop', async () => {
      const { token } = await member();
      const skills = await get(token, '/taxonomy/skills').expect(200);
      expect(skills.body.data.map((s: any) => s.name)).toContain('After Effects');
      const animation = await discipline('Animation');
      const bySlug = await get(token, '/taxonomy/skills?discipline=animation').expect(200);
      const byId = await get(token, `/taxonomy/skills?discipline=${animation.id}`).expect(200);
      expect(bySlug.body.data).toEqual(byId.body.data);
      await get(token, '/taxonomy/skills?discipline=nope').expect(404);
      expect((await get(token, '/taxonomy/interests').expect(200)).body.data).toHaveLength(6);
      expect((await get(token, '/taxonomy/development-areas').expect(200)).body.data).toHaveLength(
        5,
      );
    });

    it('lists Kenya and its 47 counties, and matches a phone’s place name to a county', async () => {
      const { token } = await member();
      const countries = await get(token, '/locations/countries').expect(200);
      expect(countries.body.data[0]).toMatchObject({
        isoCode: 'KE',
        name: 'Kenya',
        callingCode: '+254',
      });
      const counties = await get(token, '/locations/counties?country=KE').expect(200);
      expect(counties.body.data).toHaveLength(47);
      expect(counties.body.data.find((c: any) => c.code === 'NBI').name).toBe('Nairobi');
      await get(token, '/locations/counties?country=ZZ').expect(404);

      const nairobi = await get(
        token,
        '/locations/counties/match?q=Nairobi%20City%20County',
      ).expect(200);
      expect(nairobi.body.data.county).toMatchObject({ code: 'NBI', name: 'Nairobi' });
      const muranga = await get(token, '/locations/counties/match?q=Murang%27a').expect(200);
      expect(muranga.body.data.county.code).toBe('MRG');
      const none = await get(token, '/locations/counties/match?q=Atlantis').expect(200);
      expect(none.body.data.county).toBeNull();
    });
  });

  describe('onboarding', () => {
    it('starts at the intro with an empty profile named after the account', async () => {
      const { token } = await member('Wanjiru Mwangi');
      const res = await get(token, '/me/onboarding').expect(200);
      expect(res.body.data).toMatchObject({
        step: 'INTRO',
        completed: false,
        passportNumber: null,
        profile: {
          displayName: 'Wanjiru Mwangi',
          handle: null,
          discipline: null,
          locationVisibility: 'MEMBERS',
        },
      });
      expect(res.body.data.completion.percent).toBe(5); // contact verified only
    });

    it('saves every step, resumes after a restart, and the data persists', async () => {
      const { token, email } = await member();
      const animation = await discipline('Animation');
      const [two, , , character] = animation.specialisations;
      const skills = await prisma.skill.findMany({
        where: { name: { in: ['After Effects', 'Procreate', 'Storyboarding'] } },
      });
      const interests = await prisma.interest.findMany({
        where: { name: { in: ['Music videos', 'Comics'] } },
      });
      const areas = await prisma.developmentArea.findMany({
        where: { name: { in: ['Pricing my work'] } },
      });
      const nbi = await county('NBI');

      await patch(token, { step: 'INTRO' }).expect(200);
      let res = await patch(token, { step: 'DISCIPLINE', disciplineId: animation.id }).expect(200);
      expect(res.body.data).toMatchObject({
        step: 'SPECIALISATION',
        profile: { discipline: { name: 'Animation', icon: 'aperture' } },
      });

      res = await patch(token, {
        step: 'SPECIALISATION',
        specialisationIds: [two!.id, character!.id],
      }).expect(200);
      expect(res.body.data.profile.specialisations.map((s: any) => s.name)).toEqual([
        '2D animation',
        'Character design',
      ]);

      res = await patch(token, {
        step: 'SKILLS',
        skillIds: skills.map((s) => s.id),
        interestIds: interests.map((s) => s.id),
        developmentAreaIds: areas.map((s) => s.id),
      }).expect(200);
      expect(res.body.data.profile.skills).toHaveLength(3);
      expect(res.body.data.profile.interests).toHaveLength(2);

      res = await patch(token, {
        step: 'LOCATION',
        countyId: nbi.id,
        town: '  Kilimani ',
        locationVisibility: 'PUBLIC',
      }).expect(200);
      expect(res.body.data.profile).toMatchObject({
        countyName: 'Nairobi',
        countryName: 'Kenya',
        town: 'Kilimani',
        locationVisibility: 'PUBLIC',
      });

      // "App killed": a fresh sign-in sees exactly where the member got to.
      const again = await loginMember(app, email);
      const resumed = await get(again.accessToken, '/me/onboarding').expect(200);
      expect(resumed.body.data.step).toBe('BASICS');
      expect(resumed.body.data.profile.skills).toHaveLength(3);
      expect(resumed.body.data.profile.specialisations).toHaveLength(2);
      expect(resumed.body.data.profile.countyName).toBe('Nairobi');
    });

    it('never moves the resume point back when an earlier step is saved again', async () => {
      const { token } = await member();
      const music = await discipline('Music');
      await patch(token, { step: 'DISCIPLINE', disciplineId: music.id }).expect(200);
      await patch(token, { step: 'SPECIALISATION', skipped: true }).expect(200);
      await patch(token, { step: 'SKILLS', skipped: true }).expect(200);
      const res = await patch(token, { step: 'DISCIPLINE', disciplineId: music.id }).expect(200);
      expect(res.body.data.step).toBe('LOCATION');
    });

    it('skip saves nothing, moves on, and the completion percentage shows the gap', async () => {
      const { token } = await member();
      const before = (await get(token, '/me/onboarding')).body.data.completion.percent;
      const res = await patch(token, {
        step: 'DISCIPLINE',
        skipped: true,
        disciplineId: (await discipline('Music')).id,
      }).expect(200);
      expect(res.body.data.step).toBe('SPECIALISATION');
      expect(res.body.data.profile.discipline).toBeNull(); // nothing was stored although a value was sent
      expect(res.body.data.completion.percent).toBe(before);
    });

    it('changing the discipline clears specialisations', async () => {
      const { token } = await member();
      const animation = await discipline('Animation');
      const music = await discipline('Music');
      await patch(token, { step: 'DISCIPLINE', disciplineId: animation.id }).expect(200);
      await patch(token, {
        step: 'SPECIALISATION',
        specialisationIds: [animation.specialisations[0]!.id],
      }).expect(200);
      const res = await patch(token, { step: 'DISCIPLINE', disciplineId: music.id }).expect(200);
      expect(res.body.data.profile.discipline.name).toBe('Music');
      expect(res.body.data.profile.specialisations).toEqual([]);
      // Picking the same discipline again keeps what was chosen.
      await patch(token, {
        step: 'SPECIALISATION',
        specialisationIds: [music.specialisations[0]!.id],
      }).expect(200);
      const same = await patch(token, { step: 'DISCIPLINE', disciplineId: music.id }).expect(200);
      expect(same.body.data.profile.specialisations).toHaveLength(1);
    });

    it('refuses what does not belong: wrong discipline, unknown ids, missing prerequisites', async () => {
      const { token } = await member();
      const animation = await discipline('Animation');
      const music = await discipline('Music');
      await patch(token, {
        step: 'SPECIALISATION',
        specialisationIds: [music.specialisations[0]!.id],
      }).expect(409);
      await patch(token, { step: 'DISCIPLINE' }).expect(400);
      await patch(token, {
        step: 'DISCIPLINE',
        disciplineId: '00000000-0000-4000-8000-000000000000',
      }).expect(400);
      await patch(token, { step: 'DISCIPLINE', disciplineId: animation.id }).expect(200);
      const wrong = await patch(token, {
        step: 'SPECIALISATION',
        specialisationIds: [music.specialisations[0]!.id],
      }).expect(400);
      expect(wrong.body.error.details.field).toBe('specialisationIds');
      await patch(token, {
        step: 'SKILLS',
        skillIds: ['00000000-0000-4000-8000-000000000000'],
      }).expect(400);
      await patch(token, { step: 'NOPE' }).expect(400);
      await patch(token, { step: 'LOCATION', countyId: 'not-a-uuid' }).expect(400);
    });

    it('rejects a county that is not in the chosen country, and caps list sizes', async () => {
      const { token } = await member();
      const nbi = await county('NBI');
      const other = await prisma.country.create({
        data: { isoCode: 'ZZ', name: `Zedland ${uniq()}`, callingCode: '+999' },
      });
      try {
        await patch(token, { step: 'LOCATION', countryId: other.id, countyId: nbi.id }).expect(400);
        await patch(token, { step: 'LOCATION', countryId: other.id }).expect(200);
      } finally {
        await prisma.creativeProfile.updateMany({
          where: { countryId: other.id },
          data: { countryId: null },
        });
        await prisma.country.delete({ where: { id: other.id } });
      }
      const ids = Array.from(
        { length: 21 },
        (_, i) => `00000000-0000-4000-8000-${String(i).padStart(12, '0')}`,
      );
      await patch(token, { step: 'SKILLS', skillIds: ids }).expect(400);
    });

    it('validates the basics: name, bio length, handle format and reserved words', async () => {
      const { token } = await member();
      await patch(token, { step: 'BASICS', displayName: ' ' }).expect(400);
      await patch(token, { step: 'BASICS', bio: 'x'.repeat(161) }).expect(400);
      const bad = await patch(token, { step: 'BASICS', handle: 'no spaces' }).expect(400);
      expect(bad.body.error.details.reason).toBe('INVALID');
      const reserved = await patch(token, { step: 'BASICS', handle: 'Admin' }).expect(400);
      expect(reserved.body.error.details.reason).toBe('RESERVED');
      const ok = await patch(token, {
        step: 'BASICS',
        displayName: 'Nia  W.',
        handle: '@Nia_W',
        bio: ' Short bio. ',
      }).expect(200);
      expect(ok.body.data.profile).toMatchObject({
        displayName: 'Nia W.',
        handle: 'nia_w',
        bio: 'Short bio.',
      });
    });
  });

  describe('profile link', () => {
    it('reports availability, treating your own handle as available, with suggestions when taken', async () => {
      const a = await member();
      const b = await member();
      const handle = `taken_${uniq().replace(/-/g, '_')}`;
      await patch(a.token, { step: 'BASICS', handle }).expect(200);

      const mine = await get(a.token, `/handles/${handle.toUpperCase()}/availability`).expect(200);
      expect(mine.body.data).toMatchObject({ handle, available: true, reason: null });

      const theirs = await get(b.token, `/handles/${handle}/availability`).expect(200);
      expect(theirs.body.data).toMatchObject({ available: false, reason: 'TAKEN' });
      expect(theirs.body.data.suggestions).toHaveLength(3);
      for (const s of theirs.body.data.suggestions) {
        expect((await get(b.token, `/handles/${s}/availability`)).body.data.available).toBe(true);
      }

      const free = await get(
        b.token,
        `/handles/free_${uniq().replace(/-/g, '_')}/availability`,
      ).expect(200);
      expect(free.body.data.available).toBe(true);
      expect((await get(b.token, '/handles/ab/availability')).body.data).toMatchObject({
        available: false,
        reason: 'INVALID',
      });
      expect((await get(b.token, '/handles/support/availability')).body.data).toMatchObject({
        available: false,
        reason: 'RESERVED',
      });
    });

    it('lets exactly one of two simultaneous claims win; the other gets a conflict with suggestions', async () => {
      const a = await member();
      const b = await member();
      const handle = `race_${uniq().replace(/-/g, '_')}`;
      const [ra, rb] = await Promise.all([
        patch(a.token, { step: 'BASICS', handle }),
        patch(b.token, { step: 'BASICS', handle }),
      ]);
      expect([ra.status, rb.status].sort()).toEqual([200, 409]);
      const loser = ra.status === 409 ? ra : rb;
      expect(loser.body.error.code).toBe('CONFLICT');
      expect(loser.body.error.details).toMatchObject({ field: 'handle', reason: 'TAKEN' });
      expect(loser.body.error.details.suggestions.length).toBeGreaterThan(0);
      expect(await prisma.creativeProfile.count({ where: { handle } })).toBe(1);
    });
  });

  describe('photo', () => {
    const asset = (ownerId: string, over: Record<string, unknown> = {}) =>
      prisma.mediaAsset.create({
        data: {
          ownerId,
          kind: 'IMAGE',
          bucket: 'PUBLIC',
          objectKey: `media/${uniq()}/original.jpg`,
          mimeType: 'image/jpeg',
          sizeBytes: BigInt(1000),
          status: 'READY',
          width: 800,
          height: 800,
          variants: { '200': 'k/w200.webp', '600': 'k/w600.webp' },
          ...over,
        } as any,
      });

    it('attaches a ready image, raises completion by 15 points, and removes it again', async () => {
      const { id, token } = await member();
      const before = (await get(token, '/me/onboarding')).body.data.completion.percent;
      const a = await asset(id);
      const res = await http()
        .post('/api/v1/me/avatar')
        .set(...bearer(token))
        .send({ mediaId: a.id })
        .expect(200);
      expect(res.body.data.profile.avatarUrl).toBe('https://signed.test/k/w600.webp');
      expect(res.body.data.completion.percent).toBe(before + 15);

      const gone = await http()
        .delete('/api/v1/me/avatar')
        .set(...bearer(token))
        .expect(200);
      expect(gone.body.data.profile.avatarUrl).toBeNull();
      expect(gone.body.data.completion.percent).toBe(before);
    });

    it('replaces the old photo, and refuses other people’s, unfinished, private and non-image files', async () => {
      const { id, token } = await member();
      const other = await member();
      const first = await asset(id);
      const second = await asset(id);
      await http()
        .post('/api/v1/me/avatar')
        .set(...bearer(token))
        .send({ mediaId: first.id })
        .expect(200);
      await http()
        .post('/api/v1/me/avatar')
        .set(...bearer(token))
        .send({ mediaId: second.id })
        .expect(200);
      expect((await prisma.mediaAsset.findUniqueOrThrow({ where: { id: first.id } })).status).toBe(
        'DELETED',
      );

      const post = (mediaId: string) =>
        http()
          .post('/api/v1/me/avatar')
          .set(...bearer(token))
          .send({ mediaId });
      await post((await asset(other.id)).id).expect(404);
      await post((await asset(id, { status: 'PROCESSING' })).id).expect(409);
      await post((await asset(id, { bucket: 'PRIVATE' })).id).expect(400);
      await post((await asset(id, { kind: 'DOCUMENT', mimeType: 'application/pdf' })).id).expect(
        400,
      );
      await post('00000000-0000-4000-8000-000000000000').expect(404);
      await post('nope').expect(400);
    });
  });

  describe('finishing and the Creative Passport', () => {
    it('issues ATR-{COUNTY}-{sequence} once, keeps it, and makes the profile real', async () => {
      const { token } = await member('Amina Hassan');
      const msa = await county('MSA');
      await prisma.passportCounter.deleteMany({ where: { countyCode: 'MSA' } });
      await patch(token, {
        step: 'DISCIPLINE',
        disciplineId: (await discipline('Photography')).id,
      }).expect(200);
      await patch(token, { step: 'LOCATION', countyId: msa.id }).expect(200);
      await patch(token, {
        step: 'BASICS',
        handle: `amina_${uniq().replace(/-/g, '_')}`,
        bio: 'Documentary photographer on the coast.',
      }).expect(200);

      const done = await http()
        .post('/api/v1/me/onboarding/complete')
        .set(...bearer(token))
        .expect(200);
      expect(done.body.data.passport.passportNumber).toBe('ATR-MSA-0001');
      expect(done.body.data.state).toMatchObject({
        completed: true,
        step: 'DONE',
        passportNumber: 'ATR-MSA-0001',
      });
      // discipline 10 + bio 10 + location 10 + contact 5
      expect(done.body.data.state.completion.percent).toBe(35);

      // Tapping Finish again, or reopening, returns the same Passport and uses no new number.
      const again = await http()
        .post('/api/v1/me/onboarding/complete')
        .set(...bearer(token))
        .expect(200);
      expect(again.body.data.passport.passportNumber).toBe('ATR-MSA-0001');
      expect(
        (await prisma.passportCounter.findUniqueOrThrow({ where: { countyCode: 'MSA' } }))
          .lastValue,
      ).toBe(1);

      // Setup is closed; the profile is edited elsewhere from now on.
      await patch(token, { step: 'BASICS', bio: 'Changed' }).expect(409);
    });

    it('numbers concurrent completions in one county without gaps or duplicates', async () => {
      const kisumu = await county('KSM');
      await prisma.passportCounter.deleteMany({ where: { countyCode: 'KSM' } });
      const members = await Promise.all(Array.from({ length: 6 }, () => member()));
      for (const m of members)
        await patch(m.token, { step: 'LOCATION', countyId: kisumu.id }).expect(200);
      const results = await Promise.all(
        members.map((m) =>
          http()
            .post('/api/v1/me/onboarding/complete')
            .set(...bearer(m.token)),
        ),
      );
      expect(results.map((r) => r.status)).toEqual(Array(6).fill(200));
      const numbers = results.map((r) => r.body.data.passport.passportNumber as string).sort();
      expect(numbers).toEqual(
        [1, 2, 3, 4, 5, 6].map((n) => `ATR-KSM-${String(n).padStart(4, '0')}`),
      );
    });

    it('double Finish at the same moment still yields one Passport and no wasted number', async () => {
      const nakuru = await county('NKR');
      await prisma.passportCounter.deleteMany({ where: { countyCode: 'NKR' } });
      const m = await member();
      await patch(m.token, { step: 'LOCATION', countyId: nakuru.id }).expect(200);
      const [a, b] = await Promise.all([
        http()
          .post('/api/v1/me/onboarding/complete')
          .set(...bearer(m.token)),
        http()
          .post('/api/v1/me/onboarding/complete')
          .set(...bearer(m.token)),
      ]);
      expect([a.status, b.status]).toEqual([200, 200]);
      expect(a.body.data.passport.passportNumber).toBe(b.body.data.passport.passportNumber);
      expect(
        (await prisma.passportCounter.findUniqueOrThrow({ where: { countyCode: 'NKR' } }))
          .lastValue,
      ).toBe(1);
    });

    it('lets a member who skipped everything finish: a handle is made from their name, the code is GEN', async () => {
      const { token, id } = await member('Zoë Kamau');
      await prisma.passportCounter.deleteMany({ where: { countyCode: 'GEN' } });
      const done = await http()
        .post('/api/v1/me/onboarding/complete')
        .set(...bearer(token))
        .expect(200);
      expect(done.body.data.passport.passportNumber).toBe('ATR-GEN-0001');
      expect(done.body.data.state.profile.handle).toMatch(/^zoekamau\d*$/);
      expect(done.body.data.state.completion.percent).toBe(5);
      const profile = await prisma.creativeProfile.findUniqueOrThrow({
        where: { userId: id },
        include: { passport: true },
      });
      expect(profile.completionPercent).toBe(5);
      expect(profile.passport!.countyCode).toBe('GEN');
    });

    it('does not let members touch one another’s profile or Passport', async () => {
      const a = await member();
      const b = await member();
      await patch(a.token, { step: 'BASICS', bio: 'Only mine, thanks.' }).expect(200);
      expect((await get(b.token, '/me/onboarding')).body.data.profile.bio).toBeNull();
    });

    it('requires authentication on every onboarding route', async () => {
      await http().get('/api/v1/me/onboarding').expect(401);
      await http().patch('/api/v1/me/onboarding').send({ step: 'INTRO' }).expect(401);
      await http().post('/api/v1/me/onboarding/complete').expect(401);
      await http().post('/api/v1/me/avatar').send({}).expect(401);
      await http().get('/api/v1/handles/abc/availability').expect(401);
    });
  });

  describe('specialisation suggestions (member side)', () => {
    it('queues a suggestion, returns the open one when repeated, and refuses duplicates of the list', async () => {
      const { token, id } = await member();
      const design = await discipline('Design');
      const name = `Zine making ${uniq()}`;
      const post = (body: Record<string, unknown>) =>
        http()
          .post('/api/v1/taxonomy/specialisations/suggestions')
          .set(...bearer(token))
          .send(body);

      const first = await post({ disciplineId: design.id, name }).expect(201);
      expect(first.body.data).toMatchObject({ name, status: 'PENDING' });
      const repeat = await post({ disciplineId: design.id, name: name.toUpperCase() }).expect(201);
      expect(repeat.body.data.id).toBe(first.body.data.id);
      expect(await prisma.specialisationSuggestion.count({ where: { userId: id } })).toBe(1);

      const dup = await post({ disciplineId: design.id, name: 'ui / ux' }).expect(409);
      expect(dup.body.error.message).toMatch(/already in the Design list/);
      await post({ disciplineId: design.id, name: 'x' }).expect(400);
      await post({ disciplineId: 'bad', name }).expect(400);
    });

    it('stops one member filling the queue', async () => {
      const { token } = await member();
      const design = await discipline('Design');
      for (let i = 0; i < 5; i++) {
        await http()
          .post('/api/v1/taxonomy/specialisations/suggestions')
          .set(...bearer(token))
          .send({ disciplineId: design.id, name: `Idea ${i} ${uniq()}` })
          .expect(201);
      }
      await http()
        .post('/api/v1/taxonomy/specialisations/suggestions')
        .set(...bearer(token))
        .send({ disciplineId: design.id, name: `One more ${uniq()}` })
        .expect(429);
    });
  });

  it('emailFor stays unique across members (guards the helper this suite relies on)', () => {
    expect(emailFor()).not.toBe(emailFor());
  });
});
