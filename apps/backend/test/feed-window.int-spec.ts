import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { RANK_BOOST_MINUTES } from '../src/community/feed-cursor';
import { PrismaService } from '../src/prisma/prisma.service';
import { bearer, createTestApp, deleteUsers, loginMember, makeUser, uniq } from './helpers';

/**
 * P1-M12 hardening: the feed ranks a window of recent posts instead of every visible post (FeedService). This proves the
 * windowed query returns exactly what ranking everything would: the same posts in the same order, page after page,
 * including the boosts that reorder posts, and across the cursor boundary.
 */
jest.setTimeout(180_000);

const MIN = 60_000;

describe('Feed: windowed ranking equals full ranking (integration)', () => {
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

  async function member(o: { county: string; discipline: string }) {
    const { user, email } = await makeUser(app, { fullName: `Feed ${uniq()}` });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const [county, discipline] = await Promise.all([
      prisma.county.findFirstOrThrow({ where: { code: o.county } }),
      prisma.discipline.findFirstOrThrow({ where: { name: o.discipline } }),
    ]);
    await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle: `f_${uniq()}`.replace(/-/g, '_'),
        displayName: 'Feeder',
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        primaryDisciplineId: discipline.id,
        countyId: county.id,
        countryId: county.countryId,
      },
    });
    return { id: user.id, token, countyId: county.id, disciplineId: discipline.id };
  }

  const pages = async (token: string, limit: number, query: object = {}) => {
    const ids: string[] = [];
    let cursor: string | undefined;
    for (let i = 0; i < 60; i += 1) {
      const res = await http()
        .get('/api/v1/community/feed')
        .query({ limit, ...query, ...(cursor ? { cursor } : {}) })
        .set(...bearer(token))
        .expect(200);
      ids.push(...res.body.data.map((p: { id: string }) => p.id));
      cursor = res.body.meta.nextCursor ?? undefined;
      if (!cursor) break;
    }
    return ids;
  };

  it('returns the same posts in the same order as ranking every visible post, for several page sizes', async () => {
    const viewer = await member({ county: 'NBI', discipline: 'Music' });
    const sameCounty = await member({ county: 'NBI', discipline: 'Fashion' });
    const sameDiscipline = await member({ county: 'MSA', discipline: 'Music' });
    const stranger = await member({ county: 'MSA', discipline: 'Fashion' });
    const connected = await member({ county: 'MSA', discipline: 'Fashion' });
    const group = await prisma.group.create({
      data: {
        slug: `fw-${uniq()}`,
        type: 'INTEREST',
        name: 'Feed window',
        visibility: 'OPEN',
        createdById: viewer.id,
      },
    });
    await prisma.groupMembership.create({
      data: { groupId: group.id, userId: viewer.id, role: 'MEMBER' },
    });
    await prisma.connection.create({
      data: { requesterId: viewer.id, addresseeId: connected.id, status: 'ACCEPTED' },
    });

    // Sixty posts over three days, mixed audiences and authors, so boosts of up to six hours reorder neighbours.
    const authors = [sameCounty, sameDiscipline, stranger, connected, viewer];
    const now = Date.now();
    const created: Array<{
      id: string;
      authorId: string;
      createdAt: Date;
      audience: string;
      groupId: string | null;
      announcement: boolean;
    }> = [];
    for (let i = 0; i < 60; i += 1) {
      const author = authors[i % authors.length]!;
      const audience = (['MEMBERS', 'PUBLIC', 'CONNECTIONS', 'GROUP', 'MEMBERS'] as const)[i % 5]!;
      const inGroup = audience === 'GROUP';
      const row = await prisma.post.create({
        data: {
          authorId: author.id,
          type: 'UPDATE',
          body: `Window post ${i}`,
          audience,
          groupId: inGroup ? group.id : null,
          isStaffAnnouncement: i % 17 === 0,
          // Roughly every 70 minutes, so the 6 hour boosts reorder about five posts each way.
          createdAt: new Date(now - i * 70 * MIN - (i % 3) * MIN),
        },
      });
      created.push({
        id: row.id,
        authorId: author.id,
        createdAt: row.createdAt,
        audience,
        groupId: row.groupId,
        announcement: row.isStaffAnnouncement,
      });
    }

    // The reference: rank everything the viewer may see, exactly as the Master Prompt defines it.
    const visible = created.filter(
      (p) =>
        p.authorId === viewer.id ||
        p.audience === 'MEMBERS' ||
        p.audience === 'PUBLIC' ||
        (p.audience === 'CONNECTIONS' && p.authorId === connected.id) ||
        (p.audience === 'GROUP' && p.groupId === group.id),
    );
    const boost = (p: (typeof created)[number]) =>
      (p.groupId === group.id ? RANK_BOOST_MINUTES.group : 0) +
      (p.authorId === connected.id ? RANK_BOOST_MINUTES.connection : 0) +
      (p.authorId === sameDiscipline.id || p.authorId === viewer.id
        ? RANK_BOOST_MINUTES.discipline
        : 0) +
      (p.authorId === sameCounty.id || p.authorId === viewer.id ? RANK_BOOST_MINUTES.county : 0) +
      (p.announcement ? RANK_BOOST_MINUTES.announcement : 0);
    const expected = [...visible]
      .sort((a, b) => {
        const ra = a.createdAt.getTime() + boost(a) * MIN;
        const rb = b.createdAt.getTime() + boost(b) * MIN;
        return rb - ra || (a.id < b.id ? 1 : -1);
      })
      .map((p) => p.id);
    const mine = new Set(created.map((p) => p.id));
    expect(expected.length).toBeGreaterThan(30);

    for (const limit of [1, 3, 7, 50]) {
      const got = (await pages(viewer.token, limit)).filter((id) => mine.has(id));
      expect(got).toEqual(expected);
    }

    // The group page ranks nothing (newest first) and must agree with the plain ordering too.
    const groupPosts = created
      .filter((p) => p.groupId === group.id)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime() || (a.id < b.id ? 1 : -1))
      .map((p) => p.id);
    const groupPage = await http()
      .get(`/api/v1/groups/${group.slug}/posts`)
      .query({ limit: 5 })
      .set(...bearer(viewer.token))
      .expect(200);
    expect(groupPage.body.data.map((p: { id: string }) => p.id)).toEqual(groupPosts.slice(0, 5));
  });

  it('a feed with fewer posts than a page, and one with none, still answer', async () => {
    const quiet = await member({ county: 'KSM', discipline: 'Writing' });
    const empty = await http()
      .get('/api/v1/community/feed')
      .query({ limit: 20 })
      .set(...bearer(quiet.token))
      .expect(200);
    expect(
      empty.body.meta.nextCursor === null || typeof empty.body.meta.nextCursor === 'string',
    ).toBe(true);
    await prisma.post.create({
      data: { authorId: quiet.id, type: 'UPDATE', body: 'Only post', audience: 'MEMBERS' },
    });
    const one = await pages(quiet.token, 20);
    expect(one.length).toBeGreaterThanOrEqual(1);
  });
});
