import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import { StorageService } from '../src/storage/storage.service';
import { bearer, createTestApp, loginMember, makeUser, uniq } from './helpers';

// Each test signs up and sets up several members (password hashing, onboarding), so allow more than 5 s.
jest.setTimeout(90_000);

describe('My profile, Passport, public profile and connections (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];

  beforeAll(async () => {
    app = await createTestApp();
    prisma = app.get(PrismaService);
    Object.assign(app.get(StorageService), {
      signedDownloadUrl: async (_b: string, key: string) => `https://signed.test/${key}`,
      remove: async () => undefined,
    });
  });
  afterAll(async () => {
    await prisma.notification.deleteMany({ where: { userId: { in: users } } });
    await prisma.user.deleteMany({ where: { id: { in: users } } });
    await app.close();
  });

  interface Member {
    id: string;
    token: string;
    handle: string;
    email: string;
  }

  /** A member who finished setup: handle, discipline, skills, county, bio, phone. */
  async function member(name = 'Nia Wairimu', opts: { finished?: boolean } = {}): Promise<Member> {
    const { user, email } = await makeUser(app, {
      fullName: name,
      phone: `+2547${Math.floor(10000000 + Math.random() * 89999999)}`,
    });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const handle = `m_${uniq().replace(/-/g, '_')}`;
    if (opts.finished !== false) {
      const patch = (b: object) =>
        http()
          .patch('/api/v1/me/onboarding')
          .set(...bearer(token))
          .send(b)
          .expect(200);
      const animation = await prisma.discipline.findFirstOrThrow({ where: { name: 'Animation' } });
      const nbi = await prisma.county.findFirstOrThrow({ where: { code: 'NBI' } });
      const skills = await prisma.skill.findMany({ take: 3 });
      await patch({ step: 'DISCIPLINE', disciplineId: animation.id });
      await patch({ step: 'SKILLS', skillIds: skills.map((s) => s.id) });
      await patch({ step: 'LOCATION', countyId: nbi.id, town: 'Kilimani' });
      await patch({ step: 'BASICS', handle, bio: 'Illustrator and 2D animator in Nairobi.' });
      await http()
        .post('/api/v1/me/onboarding/complete')
        .set(...bearer(token))
        .expect(200);
    }
    return { id: user.id, token, handle, email };
  }
  const as = (t?: string) => ({
    get: (p: string) => {
      const r = http().get(`/api/v1${p}`);
      return t ? r.set(...bearer(t)) : r;
    },
    post: (p: string, b: object = {}) => {
      const r = http().post(`/api/v1${p}`).send(b);
      return t ? r.set(...bearer(t)) : r;
    },
    patch: (p: string, b: object) => {
      const r = http().patch(`/api/v1${p}`).send(b);
      return t ? r.set(...bearer(t)) : r;
    },
    del: (p: string) => {
      const r = http().delete(`/api/v1${p}`);
      return t ? r.set(...bearer(t)) : r;
    },
  });
  const connect = async (a: Member, b: Member) => {
    const sent = (await as(a.token).post(`/creatives/${b.handle}/connect`).expect(200)).body.data;
    await as(b.token).post(`/connections/${sent.id}/accept`).expect(200);
  };

  describe('my profile', () => {
    it('returns everything the profile screen needs, with real counts and the next best action', async () => {
      const m = await member();
      const res = await as(m.token).get('/me/profile').expect(200);
      const p = res.body.data;
      expect(p).toMatchObject({
        handle: m.handle,
        displayName: 'Nia Wairimu',
        onboardingCompleted: true,
        openToCommissions: false,
        acceptConnections: true,
        discipline: { name: 'Animation' },
        location: { countyName: 'Nairobi', countryName: 'Kenya', town: 'Kilimani' },
        counts: { skills: 3, connections: 0, pendingRequests: 0 },
        links: [],
      });
      expect(p.passport.passportNumber).toMatch(/^ATR-NBI-\d{4}$/);
      expect(p.shareUrl).toBe(`https://atarah.app/${m.handle}`);
      expect(p.contact).toMatchObject({ showEmail: true, showPhone: false, forConnections: false });
      // Photo and first project weigh the same (15); the photo comes first.
      expect(p.completion.next.map((i: any) => i.key).slice(0, 2)).toEqual(['avatar', 'project']);
      // Defaults from the Master Prompt, with location from onboarding.
      const vis = Object.fromEntries(p.sections.map((s: any) => [s.section, s.visibility]));
      expect(vis).toEqual({
        BIO: 'PUBLIC',
        LOCATION: 'MEMBERS',
        PORTFOLIO: 'PUBLIC',
        SKILLS: 'PUBLIC',
        EXPERIENCE: 'MEMBERS',
        SERVICES: 'PUBLIC',
        LINKS: 'PUBLIC',
        CONTACT: 'PRIVATE',
      });
    });

    it('requires sign-in', async () => {
      await as().get('/me/profile').expect(401);
      await as().patch('/me/profile', {}).expect(401);
      await as().get('/me/passport').expect(401);
      await as().get('/me/growth').expect(401);
    });

    it('edits name, headline, bio, links and contact preferences; completion follows', async () => {
      const m = await member();
      const before = (await as(m.token).get('/me/profile')).body.data.completion.percent;
      const res = await as(m.token)
        .patch('/me/profile', {
          displayName: '  Nia   W.  ',
          headline: ' Character animator ',
          bio: 'New bio, long enough to count.',
          openToCommissions: true,
          contactShowPhone: true,
          contactForConnections: true,
          links: [
            { label: 'Instagram', url: 'https://instagram.com/nia' },
            { label: 'Same again', url: 'https://INSTAGRAM.com/nia' },
            { label: 'Site', url: 'https://nia.example.com' },
          ],
        })
        .expect(200);
      const p = res.body.data;
      expect(p).toMatchObject({
        displayName: 'Nia W.',
        headline: 'Character animator',
        openToCommissions: true,
      });
      expect(p.contact).toMatchObject({ showPhone: true, forConnections: true });
      expect(p.links.map((l: any) => l.label)).toEqual(['Instagram', 'Site']); // duplicate address dropped
      expect(p.completion.percent).toBe(before + 5); // headline
      // Clearing works.
      const cleared = await as(m.token)
        .patch('/me/profile', { headline: '', links: [] })
        .expect(200);
      expect(cleared.body.data).toMatchObject({ headline: null, links: [] });
    });

    it('validates on the server: names, lengths, link count and https only', async () => {
      const m = await member();
      const patch = (b: object) => as(m.token).patch('/me/profile', b);
      await patch({ displayName: ' ' }).expect(400);
      await patch({ headline: 'x'.repeat(81) }).expect(400);
      await patch({ bio: 'x'.repeat(161) }).expect(400);
      await patch({ links: [{ label: 'Bad', url: 'http://insecure.example.com' }] }).expect(400);
      await patch({ links: [{ label: 'Bad', url: 'javascript:alert(1)' }] }).expect(400);
      await patch({ links: [{ label: '', url: 'https://ok.example.com' }] }).expect(400);
      const nine = Array.from({ length: 9 }, (_, i) => ({
        label: `L${i}`,
        url: `https://x${i}.example.com`,
      }));
      await patch({ links: nine }).expect(400);
      await patch({ openToCommissions: 'yes' }).expect(400);
      // The handle cannot be changed from here.
      const res = await patch({ handle: 'sneaky' });
      expect([200, 400]).toContain(res.status);
      expect((await as(m.token).get('/me/profile')).body.data.handle).toBe(m.handle);
    });

    it('edits only the caller’s own profile', async () => {
      const a = await member();
      const b = await member();
      await as(a.token).patch('/me/profile', { headline: 'Mine only' }).expect(200);
      expect((await as(b.token).get('/me/profile')).body.data.headline).toBeNull();
    });
  });

  describe('Creative Passport and growth', () => {
    it('returns the card, honest growth bars, sections and the share link', async () => {
      const m = await member();
      const res = await as(m.token).get('/me/passport').expect(200);
      const p = res.body.data;
      expect(p).toMatchObject({
        displayName: 'Nia Wairimu',
        handle: m.handle,
        discipline: 'Animation',
        location: { countyName: 'Nairobi' },
        trust: [],
        shareUrl: `https://atarah.app/${m.handle}`,
      });
      expect(p.passportNumber).toMatch(/^ATR-NBI-\d{4}$/);
      expect(p.sections).toHaveLength(8);
      const bars = Object.fromEntries(p.growth.bars.map((b: any) => [b.key, b.percent]));
      // identity: discipline 10 + location 10 + bio 10 + contact 5 = 35 of 65
      expect(bars).toEqual({
        identity: 54,
        portfolio: 0,
        skills: 38,
        learning: 0,
        connections: 0,
        professionalisation: 0,
      });
      expect(p.growth.strength).toBe('EARLY');
      expect(
        await as(m.token)
          .get('/me/growth')
          .then((r) => r.body.data),
      ).toEqual(p.growth);
    });

    it('connections feed the connections bar', async () => {
      const a = await member();
      const b = await member();
      await connect(a, b);
      const bars = (await as(a.token).get('/me/growth')).body.data.bars;
      expect(bars.find((x: any) => x.key === 'connections').percent).toBe(10);
    });

    it('refuses a Passport before setup is finished', async () => {
      const m = await member('Early Bird', { finished: false });
      await as(m.token).get('/me/passport').expect(409);
    });

    it('changes a section’s visibility inline, including location', async () => {
      const m = await member();
      let res = await as(m.token)
        .patch('/me/passport/visibility', { section: 'EXPERIENCE', visibility: 'PRIVATE' })
        .expect(200);
      expect(res.body.data.find((s: any) => s.section === 'EXPERIENCE').visibility).toBe('PRIVATE');
      res = await as(m.token)
        .patch('/me/passport/visibility', { section: 'LOCATION', visibility: 'PUBLIC' })
        .expect(200);
      expect(res.body.data.find((s: any) => s.section === 'LOCATION').visibility).toBe('PUBLIC');
      const profile = await prisma.creativeProfile.findUniqueOrThrow({ where: { userId: m.id } });
      expect(profile.locationVisibility).toBe('PUBLIC');
      await as(m.token)
        .patch('/me/passport/visibility', { section: 'NOPE', visibility: 'PUBLIC' })
        .expect(400);
      await as(m.token)
        .patch('/me/passport/visibility', { section: 'BIO', visibility: 'EVERYONE' })
        .expect(400);
    });
  });

  describe('visibility matrix: owner, connection, member, anonymous x each section', () => {
    type Who = 'OWNER' | 'CONNECTION' | 'MEMBER' | 'ANONYMOUS';
    const SECTIONS = [
      'BIO',
      'LOCATION',
      'PORTFOLIO',
      'SKILLS',
      'EXPERIENCE',
      'SERVICES',
      'LINKS',
      'CONTACT',
    ] as const;

    async function setup() {
      const owner = await member('Owner Person');
      const friend = await member('Friend Person');
      const stranger = await member('Stranger Person');
      await connect(friend, owner);
      await as(owner.token)
        .patch('/me/profile', {
          links: [{ label: 'Site', url: 'https://owner.example.com' }],
          contactShowEmail: true,
          contactShowPhone: true,
        })
        .expect(200);
      const tokens: Record<Who, string | undefined> = {
        OWNER: owner.token,
        CONNECTION: friend.token,
        MEMBER: stranger.token,
        ANONYMOUS: undefined,
      };
      const view = async (who: Who) =>
        (await as(tokens[who]).get(`/creatives/${owner.handle}`).expect(200)).body.data;
      const setVis = (section: string, visibility: string) =>
        as(owner.token).patch('/me/passport/visibility', { section, visibility }).expect(200);
      return { owner, view, setVis };
    }

    const contentOf = (p: any, s: (typeof SECTIONS)[number]) =>
      (
        ({
          BIO: p.bio,
          LOCATION: p.location,
          SKILLS: p.skills,
          LINKS: p.links,
          CONTACT: p.contact,
        }) as Record<string, unknown>
      )[s];

    const expected: Record<string, Record<Who, boolean>> = {
      PUBLIC: { OWNER: true, CONNECTION: true, MEMBER: true, ANONYMOUS: true },
      MEMBERS: { OWNER: true, CONNECTION: true, MEMBER: true, ANONYMOUS: false },
      PRIVATE: { OWNER: true, CONNECTION: false, MEMBER: false, ANONYMOUS: false },
    };

    it('every section at every level is shown or withheld exactly as the matrix says', async () => {
      const { view, setVis } = await setup();
      for (const level of ['PUBLIC', 'MEMBERS', 'PRIVATE']) {
        for (const section of SECTIONS) {
          await setVis(section, level);
          for (const who of ['OWNER', 'CONNECTION', 'MEMBER', 'ANONYMOUS'] as Who[]) {
            const p = await view(who);
            const allowed = expected[level]![who];
            expect(p.visibleSections.includes(section)).toBe(allowed);
            expect(p.lockedSections.includes(section)).toBe(!allowed);
            if (['BIO', 'LOCATION', 'SKILLS', 'LINKS', 'CONTACT'].includes(section)) {
              expect(contentOf(p, section) !== null).toBe(allowed);
            }
            expect(p.relation).toBe(who);
          }
          await setVis(section, section === 'LOCATION' ? 'MEMBERS' : 'PUBLIC');
        }
      }
    });

    it('contact: a connection sees it when the owner allows it, even while private; members never do', async () => {
      const { owner, view } = await setup();
      // CONTACT is PRIVATE by default.
      expect((await view('CONNECTION')).contact).toBeNull();
      await as(owner.token).patch('/me/profile', { contactForConnections: true }).expect(200);
      const c = (await view('CONNECTION')).contact;
      expect(c.email).toBe(owner.email);
      expect(c.phone).toMatch(/^\+2547/);
      expect((await view('MEMBER')).contact).toBeNull();
      expect((await view('ANONYMOUS')).contact).toBeNull();
      // Hide the phone: it disappears from what connections see.
      await as(owner.token).patch('/me/profile', { contactShowPhone: false }).expect(200);
      expect((await view('CONNECTION')).contact).toEqual({ email: owner.email, phone: null });
    });

    it('identity is always shown; anonymous callers get no connection state or counts', async () => {
      const { owner, view } = await setup();
      const p = await view('ANONYMOUS');
      expect(p).toMatchObject({
        handle: owner.handle,
        displayName: 'Owner Person',
        discipline: { name: 'Animation' },
        connection: null,
        connectionCount: null,
      });
      expect((await view('MEMBER')).connectionCount).toBe(1);
      expect(Object.keys(p)).not.toContain('email');
    });

    it('the owner can preview the profile as the public or as members, and nobody else can', async () => {
      const { owner, setVis } = await setup();
      await setVis('LOCATION', 'MEMBERS');
      const get = (token: string | undefined, q: string) =>
        as(token).get(`/creatives/${owner.handle}?${q}`);
      const pub = (await get(owner.token, 'previewAs=PUBLIC').expect(200)).body.data;
      expect(pub).toMatchObject({ relation: 'ANONYMOUS', location: null, connection: null });
      const mem = (await get(owner.token, 'previewAs=MEMBERS').expect(200)).body.data;
      expect(mem).toMatchObject({ relation: 'MEMBER' });
      expect(mem.location.countyName).toBe('Nairobi');
      const other = await member();
      await get(other.token, 'previewAs=PUBLIC').expect(403);
      await get(undefined, 'previewAs=PUBLIC').expect(403);
      await get(owner.token, 'previewAs=EVERYONE').expect(400);
    });

    it('hides profiles that should not be seen: unknown handle, unfinished setup, suspended account', async () => {
      const viewer = await member();
      await as(viewer.token).get('/creatives/nobody_here_xyz').expect(404);
      const early = await member('Not Finished', { finished: false });
      await as(early.token)
        .patch('/me/onboarding', { step: 'BASICS', handle: `early_${uniq().replace(/-/g, '_')}` })
        .expect(200);
      const h = (await prisma.creativeProfile.findUniqueOrThrow({ where: { userId: early.id } }))
        .handle!;
      await as(viewer.token).get(`/creatives/${h}`).expect(404);
      await as(undefined).get(`/creatives/${h}`).expect(404);
      await as(early.token).get(`/creatives/${h}`).expect(200); // the owner still can

      const gone = await member();
      await prisma.user.update({ where: { id: gone.id }, data: { status: 'SUSPENDED' } });
      await as(viewer.token).get(`/creatives/${gone.handle}`).expect(404);
    });

    it('handles are case-insensitive in the URL', async () => {
      const { owner } = await setup();
      const res = await as(undefined).get(`/creatives/${owner.handle.toUpperCase()}`).expect(200);
      expect(res.body.data.handle).toBe(owner.handle);
    });

    it('a stale or bad token on the public route is a 401, not silently anonymous', async () => {
      const owner = await member();
      await http()
        .get(`/api/v1/creatives/${owner.handle}`)
        .set('Authorization', 'Bearer not.a.token')
        .expect(401);
    });
  });

  describe('connections', () => {
    it('request, accept, both sides see CONNECTED, then remove', async () => {
      const a = await member('Ada Request');
      const b = await member('Bea Receive');
      const sent = (await as(a.token).post(`/creatives/${b.handle}/connect`).expect(200)).body.data;
      expect(sent).toMatchObject({ state: 'PENDING_SENT', canConnect: false });
      // The receiver sees it pending, with a notification.
      const theirView = (await as(b.token).get(`/creatives/${a.handle}`)).body.data.connection;
      expect(theirView).toMatchObject({ state: 'PENDING_RECEIVED', id: sent.id });
      expect(
        await prisma.notification.count({ where: { userId: b.id, category: 'COMMUNITY' } }),
      ).toBe(1);
      expect((await as(b.token).get('/me/profile')).body.data.counts.pendingRequests).toBe(1);

      const incoming = (
        await as(b.token).get('/me/connections?listState=PENDING_RECEIVED').expect(200)
      ).body;
      expect(incoming.data).toHaveLength(1);
      expect(incoming.data[0].person).toMatchObject({
        handle: a.handle,
        displayName: 'Ada Request',
      });
      expect(incoming.meta.total).toBe(1);
      expect(
        (await as(a.token).get('/me/connections?listState=PENDING_SENT')).body.data,
      ).toHaveLength(1);

      const accepted = (await as(b.token).post(`/connections/${sent.id}/accept`).expect(200)).body
        .data;
      expect(accepted.state).toBe('CONNECTED');
      expect(
        await prisma.notification.count({ where: { userId: a.id, category: 'COMMUNITY' } }),
      ).toBe(1);
      expect((await as(a.token).get(`/creatives/${b.handle}`)).body.data.connection.state).toBe(
        'CONNECTED',
      );
      expect(
        (await as(a.token).get('/me/connections')).body.data.map((c: any) => c.person.handle),
      ).toEqual([b.handle]);
      expect((await as(b.token).get('/me/profile')).body.data.counts).toMatchObject({
        connections: 1,
        pendingRequests: 0,
      });

      // Either side can end it; the profile then shows NONE and Connect is allowed again.
      const removed = (await as(a.token).del(`/connections/${sent.id}`).expect(200)).body.data;
      expect(removed.state).toBe('NONE');
      expect((await as(a.token).get('/me/connections')).body.data).toEqual([]);
      expect((await as(b.token).get(`/creatives/${a.handle}`)).body.data.connection).toMatchObject({
        state: 'NONE',
        canConnect: true,
      });
    });

    it('is idempotent, and asking someone who already asked you connects you', async () => {
      const a = await member();
      const b = await member();
      const first = (await as(a.token).post(`/creatives/${b.handle}/connect`)).body.data;
      const again = (await as(a.token).post(`/creatives/${b.handle}/connect`).expect(200)).body
        .data;
      expect(again.id).toBe(first.id);
      expect(
        await prisma.connection.count({
          where: { OR: [{ requesterId: a.id }, { addresseeId: a.id }] },
        }),
      ).toBe(1);
      const back = (await as(b.token).post(`/creatives/${a.handle}/connect`).expect(200)).body.data;
      expect(back.state).toBe('CONNECTED');
    });

    it('two people pressing Connect at the same moment end up connected with one row', async () => {
      const a = await member();
      const b = await member();
      const [ra, rb] = await Promise.all([
        as(a.token).post(`/creatives/${b.handle}/connect`),
        as(b.token).post(`/creatives/${a.handle}/connect`),
      ]);
      expect([ra.status, rb.status]).toEqual([200, 200]);
      const rows = await prisma.connection.findMany({
        where: { OR: [{ requesterId: a.id }, { addresseeId: a.id }] },
      });
      expect(rows).toHaveLength(1);
      expect(rows[0]!.status).toBe('ACCEPTED');
    });

    it('decline: the requester waits 30 days, the decliner can still ask', async () => {
      const a = await member();
      const b = await member();
      const sent = (await as(a.token).post(`/creatives/${b.handle}/connect`)).body.data;
      const declined = (await as(b.token).post(`/connections/${sent.id}/decline`).expect(200)).body
        .data;
      expect(declined.state).toBe('NONE');
      const seen = (await as(a.token).get(`/creatives/${b.handle}`)).body.data.connection;
      expect(seen).toMatchObject({ state: 'NONE', canConnect: false, reason: 'COOLDOWN' });
      const again = await as(a.token).post(`/creatives/${b.handle}/connect`).expect(409);
      expect(again.body.error.details.reason).toBe('COOLDOWN');
      // After the cooldown the requester may ask again.
      await prisma.connection.update({
        where: { id: sent.id },
        data: { respondedAt: new Date(Date.now() - 31 * 86_400_000) },
      });
      expect(
        (await as(a.token).post(`/creatives/${b.handle}/connect`).expect(200)).body.data.state,
      ).toBe('PENDING_SENT');
    });

    it('refuses: yourself, members who do not accept requests, unfinished setups, unknown people', async () => {
      const a = await member();
      const closed = await member();
      await as(closed.token).patch('/me/profile', { acceptConnections: false }).expect(200);
      await as(a.token).post(`/creatives/${a.handle}/connect`).expect(409);
      const r = await as(a.token).post(`/creatives/${closed.handle}/connect`).expect(409);
      expect(r.body.error.details.reason).toBe('NOT_ACCEPTING');
      expect(
        (await as(a.token).get(`/creatives/${closed.handle}`)).body.data.connection,
      ).toMatchObject({ canConnect: false, reason: 'NOT_ACCEPTING' });
      await as(a.token).post('/creatives/nobody_here_xyz/connect').expect(404);
      const early = await member('Early', { finished: false });
      await as(early.token).post(`/creatives/${a.handle}/connect`).expect(409);
      await as().post(`/creatives/${a.handle}/connect`).expect(401);
    });

    it('only the right person can answer or end a request', async () => {
      const a = await member();
      const b = await member();
      const c = await member();
      const sent = (await as(a.token).post(`/creatives/${b.handle}/connect`)).body.data;
      await as(a.token).post(`/connections/${sent.id}/accept`).expect(404); // the requester cannot accept their own
      await as(c.token).post(`/connections/${sent.id}/accept`).expect(404);
      await as(c.token).del(`/connections/${sent.id}`).expect(404);
      await as(b.token).del(`/connections/${sent.id}`).expect(409); // the receiver declines instead
      await as(a.token).del(`/connections/${sent.id}`).expect(200); // the sender can cancel
      await as(b.token).post(`/connections/${sent.id}/accept`).expect(409); // no longer pending
      await as(a.token).post('/connections/nope/accept').expect(400);
    });

    it('lists are paged and only show active, finished members', async () => {
      const me = await member();
      const friends = await Promise.all([member(), member(), member()]);
      for (const f of friends) await connect(f, me);
      const page = await as(me.token).get('/me/connections?limit=2').expect(200);
      expect(page.body.data).toHaveLength(2);
      expect(page.body.meta).toMatchObject({ page: 1, limit: 2, total: 3 });
      await prisma.user.update({ where: { id: friends[0]!.id }, data: { status: 'SUSPENDED' } });
      expect((await as(me.token).get('/me/connections')).body.meta.total).toBe(2);
      expect((await as(me.token).get('/me/profile')).body.data.counts.connections).toBe(2);
      await as(me.token).get('/me/connections?listState=EVERYONE').expect(400);
    });
  });
});
