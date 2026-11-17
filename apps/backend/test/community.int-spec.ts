import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { CommunityJobsModule } from '../src/community/jobs/community-jobs.module';
import { CommunityJobsService } from '../src/community/jobs/community-jobs.service';
import { SafeFetcher } from '../src/community/jobs/safe-fetch';
import { REPORT_OUTCOME_COPY } from '../src/community/community-notifications.listener';
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

// Each test sets up several real Supabase Auth members, so allow more than 5 s.
jest.setTimeout(180_000);

interface Member {
  id: string;
  token: string;
  handle: string;
  name: string;
  email: string;
}

describe('Community: feed, posts, groups, connections and safety (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
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
    app = await createTestApp([CommunityJobsModule]);
    prisma = app.get(PrismaService);
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  /** A member with a finished profile (so they can connect and be found). Same discipline and county by default. */
  async function member(
    o: { name?: string; disciplineName?: string | null; countyCode?: string | null } = {},
  ): Promise<Member> {
    const name = o.name ?? `Tess ${uniq()}`;
    const { user, email } = await makeUser(app, { fullName: name });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    const handle = `c_${uniq()}`.replace(/-/g, '_');
    const discipline =
      o.disciplineName === null
        ? null
        : await prisma.discipline.findFirstOrThrow({
            where: { name: o.disciplineName ?? 'Animation' },
          });
    const county =
      o.countyCode === null
        ? null
        : await prisma.county.findFirstOrThrow({ where: { code: o.countyCode ?? 'NBI' } });
    await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle,
        displayName: name,
        headline: 'Creative in Kenya',
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
        primaryDisciplineId: discipline?.id ?? null,
        countyId: county?.id ?? null,
      },
    });
    return { id: user.id, token, handle, name, email };
  }

  /** A staff member at AAL2 with a fresh authenticator check. */
  async function staff(role: 'MODERATOR' | 'PLATFORM_ADMIN') {
    const { user, email } = await makeUser(app, { roles: [role], fullName: `Staff ${uniq()}` });
    users.push(user.id);
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  const post = async (m: Member, body: string, extra: object = {}) => {
    const res = await as(m.token)
      .post('/posts', { type: 'UPDATE', body, ...extra })
      .expect(201);
    return res.body.data as { id: string; body: string; reactionCount: number; replyCount: number };
  };

  const connect = async (a: Member, b: Member) => {
    await as(a.token).post(`/creatives/${b.handle}/connect`).expect(200);
    const row = await prisma.connection.findFirstOrThrow({
      where: { requesterId: a.id, addresseeId: b.id },
    });
    await as(b.token).post(`/connections/${row.id}/accept`).expect(200);
  };

  const feedIds = async (m: Member, query: object = {}) => {
    const out: string[] = [];
    let cursor: string | undefined;
    for (let i = 0; i < 30; i += 1) {
      const res = await as(m.token)
        .get('/community/feed', { limit: 50, ...query, ...(cursor ? { cursor } : {}) })
        .expect(200);
      out.push(...res.body.data.map((p: { id: string }) => p.id));
      cursor = res.body.meta.nextCursor ?? undefined;
      if (!cursor) break;
    }
    return out;
  };

  // ---------------------------------------------------------------------------------------------------------------

  describe('feed: pagination and audience', () => {
    it('pages by cursor without repeats or gaps, including posts with the same timestamp', async () => {
      const author = await member({ disciplineName: null, countyCode: null });
      const reader = await member({ disciplineName: null, countyCode: null });
      const base = Date.now() - 3_600_000;
      const ids: string[] = [];
      // Seven posts; pairs share a timestamp so the id tiebreak is exercised.
      for (let i = 0; i < 7; i += 1) {
        const p = await prisma.post.create({
          data: {
            authorId: author.id,
            type: 'UPDATE',
            body: `Paged post ${i}`,
            audience: 'MEMBERS',
            createdAt: new Date(base + Math.floor(i / 2) * 60_000),
          },
        });
        ids.push(p.id);
      }
      const seen: string[] = [];
      let cursor: string | undefined;
      let pages = 0;
      do {
        const res = await as(reader.token)
          .get('/community/feed', { limit: 3, ...(cursor ? { cursor } : {}) })
          .expect(200);
        pages += 1;
        const mine = res.body.data.filter(
          (p: { author: { id: string } }) => p.author.id === author.id,
        );
        seen.push(...mine.map((p: { id: string }) => p.id));
        expect(res.body.meta.limit).toBe(3);
        cursor = res.body.meta.nextCursor ?? undefined;
      } while (cursor && pages < 20);
      expect(new Set(seen).size).toBe(seen.length); // no repeats
      expect([...seen].sort()).toEqual([...ids].sort()); // no gaps
      // Newest first: the last two (same minute, highest index) come before the first.
      expect(seen.indexOf(ids[6]!)).toBeLessThan(seen.indexOf(ids[0]!));
    });

    it('rejects a tampered cursor and a page size outside 1-100', async () => {
      const m = await member();
      const bad = await as(m.token).get('/community/feed', { cursor: 'not-a-cursor' }).expect(400);
      expect(bad.body.error.code).toBe('VALIDATION_ERROR');
      await as(m.token).get('/community/feed', { limit: 500 }).expect(400);
    });

    it('applies audience, group membership, status and deletion in SQL', async () => {
      const a = await member();
      const friend = await member();
      const stranger = await member();
      await connect(a, friend);

      const open = await post(a, 'open to all members', { audience: 'PUBLIC' });
      const connectionsOnly = await post(a, 'connections only', { audience: 'CONNECTIONS' });

      const forFriend = await feedIds(friend);
      expect(forFriend).toEqual(expect.arrayContaining([open.id, connectionsOnly.id]));
      const forStranger = await feedIds(stranger);
      expect(forStranger).toContain(open.id);
      expect(forStranger).not.toContain(connectionsOnly.id);
      // The same rule holds for opening the post directly: it looks like it does not exist.
      await as(stranger.token).get(`/posts/${connectionsOnly.id}`).expect(404);
      await as(friend.token).get(`/posts/${connectionsOnly.id}`).expect(200);
      // The author always sees their own.
      expect(await feedIds(a)).toEqual(expect.arrayContaining([open.id, connectionsOnly.id]));

      // Hidden by a moderator, removed, or deleted by the author: gone from everyone's feed.
      const hidden = await post(a, 'will be hidden');
      const deleted = await post(a, 'will be deleted');
      await prisma.post.update({ where: { id: hidden.id }, data: { status: 'HIDDEN' } });
      await as(a.token).del(`/posts/${deleted.id}`).expect(204);
      const after = await feedIds(friend);
      expect(after).not.toContain(hidden.id);
      expect(after).not.toContain(deleted.id);
    });

    it('shows group posts only to group members, and filters by type', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const inside = await member();
      const outside = await member();
      const group = await as(admin.token)
        .post('/admin/groups', { name: `Feed group ${uniq()}`, type: 'INTEREST' })
        .expect(201);
      const gid = group.body.data.id as string;
      await as(inside.token).post(`/groups/${gid}/join`).expect(200);

      const gp = (
        await as(inside.token)
          .post(`/groups/${gid}/posts`, { type: 'DISCUSSION', body: 'group talk' })
          .expect(201)
      ).body.data;
      expect(gp.audience).toBe('GROUP');
      expect(gp.group.id).toBe(gid);
      expect(await feedIds(inside)).toContain(gp.id);
      expect(await feedIds(outside)).not.toContain(gp.id); // not in the feed of a non-member
      // Open groups are readable on the group page and by id, even before joining.
      await as(outside.token).get(`/posts/${gp.id}`).expect(200);
      const page = await as(outside.token).get(`/groups/${gid}/posts`).expect(200);
      expect(page.body.data.map((p: { id: string }) => p.id)).toContain(gp.id);

      const discussions = await feedIds(inside, { type: 'DISCUSSION' });
      expect(discussions).toContain(gp.id);
      const updates = await feedIds(inside, { type: 'UPDATE' });
      expect(updates).not.toContain(gp.id);
    });

    it('nudges relevance without breaking recency: a group post outranks a slightly newer ordinary post', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const reader = await member({ disciplineName: null, countyCode: null });
      const other = await member({ disciplineName: null, countyCode: null });
      const group = await as(admin.token)
        .post('/admin/groups', { name: `Rank group ${uniq()}`, type: 'INTEREST' })
        .expect(201);
      const gid = group.body.data.id as string;
      await as(reader.token).post(`/groups/${gid}/join`).expect(200);
      await as(other.token).post(`/groups/${gid}/join`).expect(200);
      const now = Date.now();
      const groupPost = await prisma.post.create({
        data: {
          authorId: other.id,
          type: 'UPDATE',
          body: 'older group post',
          audience: 'GROUP',
          groupId: gid,
          createdAt: new Date(now - 3 * 3_600_000),
        },
      });
      const plain = await prisma.post.create({
        data: {
          authorId: other.id,
          type: 'UPDATE',
          body: 'newer ordinary post',
          audience: 'MEMBERS',
          createdAt: new Date(now - 1 * 3_600_000),
        },
      });
      const ids = await feedIds(reader);
      expect(ids.indexOf(groupPost.id)).toBeGreaterThanOrEqual(0);
      expect(ids.indexOf(groupPost.id)).toBeLessThan(ids.indexOf(plain.id));
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  describe('posts, comments and reactions', () => {
    it('lets authors edit and delete only their own posts (IDOR)', async () => {
      const a = await member();
      const b = await member();
      const p = await post(a, 'original');
      // Another member gets the same 404 as for a post that does not exist.
      await as(b.token).patch(`/posts/${p.id}`, { body: 'hijacked' }).expect(404);
      await as(b.token).del(`/posts/${p.id}`).expect(404);
      const edited = await as(a.token).patch(`/posts/${p.id}`, { body: 'edited' }).expect(200);
      expect(edited.body.data.body).toBe('edited');
      expect(edited.body.data.editedAt).not.toBeNull();
      await as(a.token).del(`/posts/${p.id}`).expect(204);
      await as(a.token).get(`/posts/${p.id}`).expect(404);
      // Soft delete: the row is still there.
      expect(
        (await prisma.post.findUniqueOrThrow({ where: { id: p.id } })).deletedAt,
      ).not.toBeNull();
      await as(a.token).patch(`/posts/${p.id}`, { body: 'again' }).expect(404);
    });

    it('validates what can be posted', async () => {
      const a = await member();
      const empty = await as(a.token).post('/posts', { type: 'UPDATE' }).expect(400);
      expect(empty.body.error.code).toBe('VALIDATION_ERROR');
      await as(a.token)
        .post('/posts', { type: 'UPDATE', body: 'x'.repeat(5001) })
        .expect(400);
      await as(a.token).post('/posts', { type: 'NOPE', body: 'hi' }).expect(400);
      await as(a.token)
        .post('/posts', { type: 'UPDATE', body: 'hi', audience: 'GROUP' })
        .expect(400);
      await as(a.token)
        .post('/posts', {
          type: 'UPDATE',
          body: 'hi',
          mediaIds: Array.from({ length: 11 }, () => '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b'),
        })
        .expect(400);
      // Files that are not yours (or do not exist) cannot be attached.
      await as(a.token)
        .post('/posts', {
          type: 'UPDATE',
          body: 'hi',
          mediaIds: ['3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b'],
        })
        .expect(400);
      // Unsafe links are refused up front.
      await as(a.token)
        .post('/posts', { type: 'UPDATE', body: 'hi', linkUrl: 'http://localhost/admin' })
        .expect(400);
      await as(a.token)
        .post('/posts', { type: 'UPDATE', body: 'hi', linkUrl: 'javascript:alert(1)' })
        .expect(400);
    });

    it('attaches the member’s own uploads in order, up to ten', async () => {
      const a = await member();
      const b = await member();
      const mk = (ownerId: string, i: number) =>
        prisma.mediaAsset.create({
          data: {
            ownerId,
            kind: 'IMAGE',
            bucket: 'PUBLIC',
            objectKey: `community-test/${uniq()}-${i}.jpg`,
            mimeType: 'image/jpeg',
            sizeBytes: 1000,
            status: 'UPLOADED',
          },
        });
      const mine = await Promise.all(Array.from({ length: 10 }, (_, i) => mk(a.id, i)));
      const theirs = await mk(b.id, 99);
      const ok = await as(a.token)
        .post('/posts', { type: 'UPDATE', body: 'ten photos', mediaIds: mine.map((m) => m.id) })
        .expect(201);
      expect(ok.body.data.media.map((m: { id: string }) => m.id)).toEqual(mine.map((m) => m.id));
      await as(a.token)
        .post('/posts', { type: 'UPDATE', body: 'not mine', mediaIds: [theirs.id] })
        .expect(400);
      // The database refuses an eleventh position even if the API were bypassed.
      const p = await prisma.post.findFirstOrThrow({ where: { authorId: a.id } });
      await expect(
        prisma.postMedia.create({ data: { postId: p.id, mediaAssetId: theirs.id, sortOrder: 10 } }),
      ).rejects.toThrow();
    });

    it('threads comments one level deep and keeps counters in step', async () => {
      const a = await member();
      const b = await member();
      const p = await post(a, 'discuss this', { type: 'DISCUSSION' });
      const top = (await as(b.token).post(`/posts/${p.id}/comments`, { body: 'first' }).expect(201))
        .body.data;
      expect(top.parentCommentId).toBeNull();
      const reply = (
        await as(a.token)
          .post(`/posts/${p.id}/comments`, { body: 'a reply', parentCommentId: top.id })
          .expect(201)
      ).body.data;
      expect(reply.parentCommentId).toBe(top.id);
      // A reply to a reply is refused by the API ...
      await as(b.token)
        .post(`/posts/${p.id}/comments`, { body: 'deeper', parentCommentId: reply.id })
        .expect(400);
      // ... and by the database, were the API bypassed.
      await expect(
        prisma.comment.create({
          data: { postId: p.id, authorId: b.id, parentCommentId: reply.id, body: 'deeper' },
        }),
      ).rejects.toThrow(/top-level/);

      const listed = await as(a.token).get(`/posts/${p.id}/comments`).expect(200);
      expect(listed.body.data).toHaveLength(1);
      expect(listed.body.data[0].replies.map((r: { id: string }) => r.id)).toEqual([reply.id]);
      expect((await as(a.token).get(`/posts/${p.id}`).expect(200)).body.data.replyCount).toBe(2);

      // Only the author edits or deletes a comment.
      await as(a.token).patch(`/comments/${top.id}`, { body: 'hijack' }).expect(404);
      await as(a.token).del(`/comments/${top.id}`).expect(404);
      await as(b.token).patch(`/comments/${top.id}`, { body: 'first (edited)' }).expect(200);
      // Deleting the top-level comment takes its replies out of the count too.
      await as(b.token).del(`/comments/${top.id}`).expect(204);
      expect((await as(a.token).get(`/posts/${p.id}`).expect(200)).body.data.replyCount).toBe(0);
      expect((await as(a.token).get(`/posts/${p.id}/comments`).expect(200)).body.data).toHaveLength(
        0,
      );
    });

    it('pages top-level comments by cursor', async () => {
      const a = await member();
      const p = await post(a, 'busy thread');
      for (let i = 0; i < 5; i += 1) {
        await prisma.comment.create({
          data: {
            postId: p.id,
            authorId: a.id,
            body: `c${i}`,
            createdAt: new Date(Date.now() - (5 - i) * 1000),
          },
        });
      }
      const first = await as(a.token).get(`/posts/${p.id}/comments`, { limit: 2 }).expect(200);
      expect(first.body.data.map((c: { body: string }) => c.body)).toEqual(['c0', 'c1']);
      const second = await as(a.token)
        .get(`/posts/${p.id}/comments`, { limit: 2, cursor: first.body.meta.nextCursor })
        .expect(200);
      expect(second.body.data.map((c: { body: string }) => c.body)).toEqual(['c2', 'c3']);
    });

    it('reactions are idempotent and counters match the rows; the nightly job repairs drift', async () => {
      const a = await member();
      const b = await member();
      const p = await post(a, 'like me');
      const r1 = await as(b.token).put(`/posts/${p.id}/reactions`).expect(200);
      const r2 = await as(b.token).put(`/posts/${p.id}/reactions`).expect(200);
      expect(r1.body.data).toEqual({ reacted: true, reactionCount: 1 });
      expect(r2.body.data).toEqual({ reacted: true, reactionCount: 1 }); // idempotent
      expect(
        (await as(a.token).put(`/posts/${p.id}/reactions`).expect(200)).body.data.reactionCount,
      ).toBe(2);
      expect((await as(b.token).del(`/posts/${p.id}/reactions`).expect(200)).body.data).toEqual({
        reacted: false,
        reactionCount: 1,
      });
      await as(b.token).del(`/posts/${p.id}/reactions`).expect(200); // removing twice is fine
      const row = await prisma.post.findUniqueOrThrow({ where: { id: p.id } });
      expect(row.reactionCount).toBe(await prisma.reaction.count({ where: { postId: p.id } }));

      // Drift, then reconcile.
      await prisma.post.update({ where: { id: p.id }, data: { reactionCount: 41, replyCount: 9 } });
      const fixed = await app.get(CommunityJobsService).reconcileCounters();
      expect(fixed.reactionCounts).toBeGreaterThanOrEqual(1);
      expect(fixed.replyCounts).toBeGreaterThanOrEqual(1);
      const after = await prisma.post.findUniqueOrThrow({ where: { id: p.id } });
      expect(after).toMatchObject({ reactionCount: 1, replyCount: 0 });
    });

    it('saves posts through the saved-items table', async () => {
      const a = await member();
      const b = await member();
      const p = await post(a, 'worth keeping');
      expect((await as(b.token).put(`/posts/${p.id}/save`).expect(200)).body.data).toEqual({
        saved: true,
      });
      await as(b.token).put(`/posts/${p.id}/save`).expect(200); // idempotent
      expect(
        await prisma.savedItem.count({ where: { userId: b.id, type: 'POST', targetId: p.id } }),
      ).toBe(1);
      const saved = await as(b.token).get('/me/saved-posts').expect(200);
      expect(saved.body.data.map((x: { id: string }) => x.id)).toEqual([p.id]);
      expect(saved.body.data[0].viewer.saved).toBe(true);
      await as(b.token).del(`/posts/${p.id}/save`).expect(200);
      expect((await as(b.token).get('/me/saved-posts').expect(200)).body.data).toHaveLength(0);
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  describe('who may take part', () => {
    it('refuses accounts that are not active, or have no verified email or phone', async () => {
      const pending = await makeUser(app);
      users.push(pending.user.id);
      const pendingToken = (await loginMember(app, pending.email)).accessToken;
      // Signing in activates a verified account, so move it back after the token was issued.
      await prisma.user.update({
        where: { id: pending.user.id },
        data: { status: 'PENDING_VERIFICATION' },
      });
      const gated = await as(pendingToken)
        .post('/posts', { type: 'UPDATE', body: 'hello' })
        .expect(403);
      expect(gated.body.error.code).toBe('VERIFICATION_REQUIRED');

      const unverified = await member();
      await prisma.user.update({
        where: { id: unverified.id },
        data: { emailVerifiedAt: null, phoneVerifiedAt: null },
      });
      const target = await member();
      const p = await post(target, 'something to comment on');
      for (const attempt of [
        () => as(unverified.token).post('/posts', { type: 'UPDATE', body: 'hello' }),
        () => as(unverified.token).post(`/posts/${p.id}/comments`, { body: 'hi' }),
        () => as(unverified.token).post(`/creatives/${target.handle}/connect`),
      ]) {
        const res = await attempt().expect(403);
        expect(res.body.error.code).toBe('VERIFICATION_REQUIRED');
        expect(res.body.error.details.reason).toBe('CONTACT_NOT_VERIFIED');
      }
      // Reading is still fine.
      await as(unverified.token).get('/community/feed').expect(200);
    });

    it('limits posting to a sample of 10 per hour (rate limiting is real, not mocked)', async () => {
      const m = await member();
      const hit = () =>
        http()
          .post('/api/v1/posts')
          .set(...bearer(m.token))
          .set('X-Test-Throttle', 'on')
          .send({ type: 'UPDATE', body: 'rate limited post' });
      for (let i = 0; i < 10; i += 1) await hit().expect(201);
      const res = await hit().expect(429);
      expect(res.body.error.code).toBe('RATE_LIMITED');
      expect(res.headers['retry-after']).toBeDefined();
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  describe('groups', () => {
    it('lists, joins, leaves, pins and gates posting by membership', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const m = await member();
      const outsider = await member();
      const name = `Animators ${uniq()}`;
      const created = await as(admin.token)
        .post('/admin/groups', {
          name,
          type: 'DISCIPLINE',
          description: 'For animators',
          isOfficial: true,
        })
        .expect(201);
      const g = created.body.data;
      expect(g).toMatchObject({ name, type: 'DISCIPLINE', isOfficial: true, memberCount: 1 });
      expect(g.moderators[0].role).toBe('OWNER');
      await as(admin.token).post('/admin/groups', { name, type: 'DISCIPLINE' }).expect(409); // same web name

      // Discover lists it for non-members, filtered by type; "mine" does not.
      const discover = await as(m.token)
        .get('/groups', { scope: 'discover', type: 'DISCIPLINE', q: name })
        .expect(200);
      expect(discover.body.data.map((x: { id: string }) => x.id)).toEqual([g.id]);
      expect(discover.body.data[0]).toMatchObject({ joined: false, role: null });
      expect(
        (
          await as(m.token)
            .get('/groups', { scope: 'discover', type: 'LOCATION', q: name })
            .expect(200)
        ).body.data,
      ).toHaveLength(0);
      expect(
        (await as(m.token).get('/groups', { scope: 'mine' }).expect(200)).body.data.map(
          (x: { id: string }) => x.id,
        ),
      ).not.toContain(g.id);

      // Not a member: cannot post into it.
      const denied = await as(m.token)
        .post(`/groups/${g.id}/posts`, { type: 'DISCUSSION', body: 'let me in' })
        .expect(403);
      expect(denied.body.error.details.reason).toBe('NOT_A_MEMBER');
      await as(m.token)
        .post('/posts', { type: 'DISCUSSION', body: 'x', groupId: g.id })
        .expect(403);

      const joined = await as(m.token).post(`/groups/${g.id}/join`).expect(200);
      expect(joined.body.data).toEqual({ groupId: g.id, joined: true, memberCount: 2 });
      await as(m.token).post(`/groups/${g.slug}/join`).expect(200); // by slug, idempotent
      expect((await prisma.group.findUniqueOrThrow({ where: { id: g.id } })).memberCount).toBe(2);
      expect(
        (await as(m.token).get('/groups', { scope: 'mine' }).expect(200)).body.data.map(
          (x: { id: string }) => x.id,
        ),
      ).toContain(g.id);

      const gp = (
        await as(m.token)
          .post(`/groups/${g.id}/posts`, { type: 'DISCUSSION', body: 'first group post' })
          .expect(201)
      ).body.data;
      // Pin: only a post of that group.
      const stray = await post(m, 'not in the group');
      await as(admin.token).post(`/admin/groups/${g.id}/pins`, { postId: stray.id }).expect(404);
      const pinned = await as(admin.token)
        .post(`/admin/groups/${g.id}/pins`, { postId: gp.id })
        .expect(200);
      expect(pinned.body.data.pinnedPostIds).toEqual([gp.id]);

      const detail = await as(outsider.token).get(`/groups/${g.slug}`).expect(200);
      expect(detail.body.data.pinned.id).toBe(gp.id);
      expect(detail.body.data.viewer).toEqual({ joined: false, role: null, canPost: false });
      expect(detail.body.data.recentDiscussions).toEqual([]); // the only post is the pinned one
      const more = (
        await as(m.token)
          .post(`/groups/${g.id}/posts`, { type: 'QUESTION', body: 'second' })
          .expect(201)
      ).body.data;
      const detail2 = await as(m.token).get(`/groups/${g.id}`).expect(200);
      expect(detail2.body.data.recentDiscussions.map((p: { id: string }) => p.id)).toEqual([
        more.id,
      ]);
      expect(detail2.body.data.viewer.canPost).toBe(true);

      const left = await as(m.token).post(`/groups/${g.id}/leave`).expect(200);
      expect(left.body.data).toEqual({ groupId: g.id, joined: false, memberCount: 1 });
      await as(m.token)
        .post(`/groups/${g.id}/posts`, { type: 'DISCUSSION', body: 'after leaving' })
        .expect(403);

      // Moderators are assigned by admins only, and audited.
      const assigned = await as(admin.token)
        .post(`/admin/groups/${g.id}/moderators`, { userId: m.id })
        .expect(200);
      expect(assigned.body.data.moderators.map((x: { role: string }) => x.role).sort()).toEqual([
        'MODERATOR',
        'OWNER',
      ]);
      expect(
        await prisma.auditLog.count({
          where: { action: 'group.moderator.assign', entityId: g.id },
        }),
      ).toBe(1);
      await as(m.token).post(`/admin/groups/${g.id}/moderators`, { userId: m.id }).expect(403);
      await as(admin.token).del(`/admin/groups/${g.id}/moderators/${m.id}`).expect(200);

      // Archived groups disappear from members' lists but keep their history.
      await as(admin.token).del(`/admin/groups/${g.id}`).expect(204);
      await as(m.token).get(`/groups/${g.id}`).expect(404);
      expect(
        (await prisma.group.findUniqueOrThrow({ where: { id: g.id } })).archivedAt,
      ).not.toBeNull();
    });

    it('keeps private groups invisible and unjoinable for non-members', async () => {
      const admin = await staff('PLATFORM_ADMIN');
      const outsider = await member();
      const insider = await member();
      const g = (
        await as(admin.token)
          .post('/admin/groups', {
            name: `Secret ${uniq()}`,
            type: 'PROGRAMME',
            visibility: 'PRIVATE',
          })
          .expect(201)
      ).body.data;
      await as(admin.token)
        .post(`/admin/groups/${g.id}/moderators`, { userId: insider.id })
        .expect(200);

      await as(outsider.token).get(`/groups/${g.id}`).expect(404);
      await as(outsider.token).post(`/groups/${g.id}/join`).expect(404);
      await as(outsider.token).get(`/groups/${g.id}/posts`).expect(404);
      expect(
        (await as(outsider.token).get('/groups', { scope: 'all', q: g.name }).expect(200)).body
          .data,
      ).toHaveLength(0);
      const p = (
        await as(insider.token)
          .post(`/groups/${g.id}/posts`, { type: 'UPDATE', body: 'members only talk' })
          .expect(201)
      ).body.data;
      await as(outsider.token).get(`/posts/${p.id}`).expect(404);
      await as(insider.token).get(`/posts/${p.id}`).expect(200);
      expect(
        (await as(insider.token).get('/groups', { scope: 'mine' }).expect(200)).body.data.map(
          (x: { id: string }) => x.id,
        ),
      ).toContain(g.id);
    });

    it('needs the group-management permission for the admin groups API', async () => {
      const moderator = await staff('MODERATOR');
      const member1 = await member();
      await as(moderator.token).get('/admin/groups').expect(403);
      await as(moderator.token)
        .post('/admin/groups', { name: 'Nope', type: 'INTEREST' })
        .expect(403);
      await as(member1.token).get('/admin/groups').expect(403); // members are not staff at all
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  describe('announcements', () => {
    it('are limited to holders of community.announce, wherever they are posted from', async () => {
      const m = await member();
      const moderator = await staff('MODERATOR');
      const admin = await staff('PLATFORM_ADMIN');

      const refused = await as(m.token)
        .post('/posts', { type: 'ANNOUNCEMENT', body: 'official news' })
        .expect(403);
      expect(refused.body.error.details.missing).toEqual(['community.announce']);
      await as(moderator.token).post('/admin/announcements', { body: 'news' }).expect(403);
      await as(m.token).post('/admin/announcements', { body: 'news' }).expect(403);

      const made = await as(admin.token)
        .post('/admin/announcements', { body: 'Welcome to Atarah' })
        .expect(201);
      expect(made.body.data).toMatchObject({
        type: 'ANNOUNCEMENT',
        isStaffAnnouncement: true,
        audience: 'MEMBERS',
      });
      expect(await feedIds(m)).toContain(made.body.data.id);
      expect(
        await prisma.auditLog.count({
          where: { action: 'announcement.create', entityId: made.body.data.id },
        }),
      ).toBe(1);
      const listed = await as(admin.token).get('/admin/announcements').expect(200);
      expect(listed.body.data.map((p: { id: string }) => p.id)).toContain(made.body.data.id);

      // A group announcement does not need the admin to be a member and reaches that group only.
      const g = (
        await as(admin.token)
          .post('/admin/groups', { name: `Ann group ${uniq()}`, type: 'INTEREST' })
          .expect(201)
      ).body.data;
      await as(m.token).post(`/groups/${g.id}/join`).expect(200);
      const outsider = await member();
      const ga = (
        await as(admin.token)
          .post('/admin/announcements', { body: 'group notice', groupId: g.id })
          .expect(201)
      ).body.data;
      expect(ga.audience).toBe('GROUP');
      expect(await feedIds(m)).toContain(ga.id);
      expect(await feedIds(outsider)).not.toContain(ga.id);
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  describe('blocks and mutes', () => {
    it('hides content both ways and stops connection requests, comments and search hits', async () => {
      const a = await member({ name: `Alder ${uniq()}` });
      const b = await member({ name: `Birch ${uniq()}` });
      const word = `zyxword${uniq()}`;
      const aPost = await post(a, `Hello from A ${word}`);
      const bPost = await post(b, `Hello from B ${word}`);
      await as(b.token).post(`/posts/${aPost.id}/comments`, { body: 'nice, from B' }).expect(201);
      await as(a.token).post(`/posts/${bPost.id}/comments`, { body: 'nice, from A' }).expect(201);

      // Before the block they see each other everywhere.
      expect(await feedIds(b)).toContain(aPost.id);
      const before = await as(a.token).get('/search', { q: b.name }).expect(200);
      expect(
        before.body.data.groups.find((g: { type: string }) => g.type === 'creatives').count,
      ).toBe(1);

      await connect(a, b);
      const blocked = await as(b.token).post('/blocks', { userId: a.id }).expect(200);
      expect(blocked.body.data).toMatchObject({ userId: a.id, handle: a.handle });
      await as(b.token).post('/blocks', { handle: a.handle }).expect(200); // idempotent, by handle too
      await as(b.token).post('/blocks', { userId: b.id }).expect(409); // not yourself
      expect(await prisma.block.count({ where: { blockerId: b.id, blockedId: a.id } })).toBe(1);
      // The connection between them ended.
      expect(
        (
          await prisma.connection.findFirstOrThrow({
            where: { requesterId: a.id, addresseeId: b.id },
          })
        ).status,
      ).toBe('REMOVED');

      // Feed, direct links, comments: hidden in both directions.
      expect(await feedIds(b)).not.toContain(aPost.id);
      expect(await feedIds(a)).not.toContain(bPost.id);
      await as(b.token).get(`/posts/${aPost.id}`).expect(404);
      await as(a.token).get(`/posts/${bPost.id}`).expect(404);
      await as(a.token).post(`/posts/${bPost.id}/comments`, { body: 'still there?' }).expect(404);
      await as(b.token).post(`/posts/${aPost.id}/comments`, { body: 'still there?' }).expect(404);
      await as(a.token).put(`/posts/${bPost.id}/reactions`).expect(404);

      // A third member's post that both commented on: each sees only their own and others' comments, not the blocked one.
      const c = await member();
      const shared = await post(c, 'a shared thread');
      await as(a.token).post(`/posts/${shared.id}/comments`, { body: 'comment by A' }).expect(201);
      await as(b.token).post(`/posts/${shared.id}/comments`, { body: 'comment by B' }).expect(201);
      const seenByA = (
        await as(a.token).get(`/posts/${shared.id}/comments`).expect(200)
      ).body.data.map((x: { body: string }) => x.body);
      const seenByB = (
        await as(b.token).get(`/posts/${shared.id}/comments`).expect(200)
      ).body.data.map((x: { body: string }) => x.body);
      expect(seenByA).toEqual(['comment by A']);
      expect(seenByB).toEqual(['comment by B']);
      const seenByC = (await as(c.token).get(`/posts/${shared.id}/comments`).expect(200)).body.data
        .length;
      expect(seenByC).toBe(2);

      // Connection requests look like the member does not exist.
      await as(a.token).post(`/creatives/${b.handle}/connect`).expect(404);
      await as(b.token).post(`/creatives/${a.handle}/connect`).expect(404);

      // Search, both for people and for posts.
      for (const [viewer, otherName] of [
        [a, b.name],
        [b, a.name],
      ] as const) {
        const people = await as(viewer.token).get('/search', { q: otherName }).expect(200);
        expect(
          people.body.data.groups.find((g: { type: string }) => g.type === 'creatives').count,
        ).toBe(0);
      }
      const postsForA = await as(a.token).get('/search', { q: word, type: 'posts' }).expect(200);
      expect(postsForA.body.data.groups[0].items.map((i: { id: string }) => i.id)).toEqual([
        aPost.id,
      ]);
      const list = await as(a.token).get('/creatives', { q: b.name }).expect(200);
      expect(list.body.data).toHaveLength(0);

      // The blocked list, and unblocking restores everything.
      const mine = await as(b.token).get('/me/blocks').expect(200);
      expect(mine.body.data.map((x: { userId: string }) => x.userId)).toEqual([a.id]);
      await as(b.token).del(`/blocks/${a.id}`).expect(204);
      expect(await feedIds(b)).toContain(aPost.id);
      await as(a.token).post(`/creatives/${b.handle}/connect`).expect(200);
    });

    it('stops notifications between blocked members', async () => {
      const a = await member();
      const b = await member();
      const p = await post(a, 'notify me');
      await as(a.token).post('/blocks', { userId: b.id }).expect(200);
      // B cannot even reach the post, so no comment and no notification.
      await as(b.token).post(`/posts/${p.id}/comments`, { body: 'hi' }).expect(404);
      expect(
        await prisma.notification.count({
          where: { userId: a.id, title: { contains: 'comment' } },
        }),
      ).toBe(0);
    });

    it('mutes a member or a thread for the muter only', async () => {
      const a = await member();
      const b = await member();
      const p1 = await post(a, 'first from A');
      const p2 = await post(a, 'second from A');
      const other = await post(b, 'from B');

      // Mute one thread.
      const m1 = await as(b.token)
        .post('/mutes', { targetType: 'POST', targetId: p1.id })
        .expect(200);
      expect(m1.body.data).toEqual({ targetType: 'POST', targetId: p1.id, muted: true });
      await as(b.token).post('/mutes', { targetType: 'POST', targetId: p1.id }).expect(200); // idempotent
      let ids = await feedIds(b);
      expect(ids).not.toContain(p1.id);
      expect(ids).toContain(p2.id);
      // Still reachable directly, flagged as muted; the author and others are unaffected.
      expect((await as(b.token).get(`/posts/${p1.id}`).expect(200)).body.data.viewer.muted).toBe(
        true,
      );
      expect(await feedIds(a)).toContain(p1.id);

      // Mute the user (by handle): everything from them goes, nothing else.
      await as(b.token).post('/mutes', { targetType: 'USER', handle: a.handle }).expect(200);
      ids = await feedIds(b);
      expect(ids).not.toContain(p2.id);
      expect(ids).toContain(other.id);
      expect(await prisma.mute.count({ where: { userId: b.id } })).toBe(2);
      await as(b.token).post('/mutes', { targetType: 'USER', targetId: b.id }).expect(409);

      await as(b.token).del(`/mutes/USER/${a.id}`).expect(200);
      await as(b.token).del(`/mutes/POST/${p1.id}`).expect(200);
      ids = await feedIds(b);
      expect(ids).toEqual(expect.arrayContaining([p1.id, p2.id]));
      await as(b.token).del('/mutes/NOPE/3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b').expect(400);
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  /** Every page of People to meet (the shared test database holds many members). */
  async function suggestions(token: string, query: object) {
    const out: Array<{
      person: { handle: string; reason: string; discipline: { id: string } };
      connectionState: string;
      connectionId: string | null;
    }> = [];
    for (let page = 1; page < 50; page += 1) {
      const res = await as(token)
        .get('/creatives/suggestions', { ...query, page, limit: 100 })
        .expect(200);
      out.push(...res.body.data);
      if (res.body.data.length < 100) break;
    }
    return out;
  }

  describe('connections and People to meet', () => {
    it('notifies on request and on accept, both in-app', async () => {
      const a = await member();
      const b = await member();
      await as(a.token).post(`/creatives/${b.handle}/connect`).expect(200);
      const request1 = await prisma.notification.findFirstOrThrow({
        where: { userId: b.id, title: 'New connection request' },
      });
      expect(request1).toMatchObject({ category: 'COMMUNITY' });
      expect(request1.body).toContain(a.name);
      const incoming = await as(b.token)
        .get('/me/connections', { listState: 'PENDING_RECEIVED' })
        .expect(200);
      const id = incoming.body.data[0].id as string;
      await as(b.token).post(`/connections/${id}/accept`).expect(200);
      const accepted = await prisma.notification.findFirstOrThrow({
        where: { userId: a.id, title: 'Connection accepted' },
      });
      expect(accepted.body).toContain(b.name);
    });

    it('suggests people with a reason line and filters, and excludes people already connected or blocked', async () => {
      const anim = await prisma.discipline.findFirstOrThrow({ where: { name: 'Animation' } });
      const other = await prisma.discipline.findFirstOrThrow({ where: { id: { not: anim.id } } });
      const me = await member({ disciplineName: 'Animation', countyCode: 'NBI' });
      const msa = await prisma.county.findFirstOrThrow({ where: { code: 'MSA' } });
      const same = await member({ disciplineName: 'Animation', countyCode: 'MSA' });
      const diff = await member({ disciplineName: other.name, countyCode: 'NBI' });
      const friend = await member({ disciplineName: 'Animation', countyCode: 'NBI' });
      const foe = await member({ disciplineName: 'Animation', countyCode: 'NBI' });
      await connect(me, friend);
      await as(me.token).post('/blocks', { userId: foe.id }).expect(200);
      await prisma.creativeProfile.update({
        where: { userId: diff.id },
        data: { openToCommissions: true },
      });

      // The static path wins over /creatives/:handle.
      const all = await suggestions(me.token, {});
      const res = { body: { data: all } };
      const byHandle = new Map<
        string,
        { person: { handle: string; reason: string }; connectionState: string }
      >(
        res.body.data.map(
          (x: { person: { handle: string; reason: string }; connectionState: string }) => [
            x.person.handle,
            x,
          ],
        ),
      );
      expect(byHandle.get(same.handle)?.person.reason).toBe(`Also works in ${anim.name}`);
      expect(byHandle.has(diff.handle)).toBe(true);
      expect(byHandle.has(friend.handle)).toBe(false); // already connected
      expect(byHandle.has(foe.handle)).toBe(false); // blocked
      expect(byHandle.has(me.handle)).toBe(false);
      // Same discipline ranks above a different one.
      const order = res.body.data.map((x: { person: { handle: string } }) => x.person.handle);
      expect(order.indexOf(same.handle)).toBeLessThan(order.indexOf(diff.handle));

      const byDiscipline = await as(me.token)
        .get('/creatives/suggestions', { disciplineId: other.id })
        .expect(200);
      expect(
        byDiscipline.body.data.every(
          (x: { person: { discipline: { id: string } } }) => x.person.discipline.id === other.id,
        ),
      ).toBe(true);
      const available = await as(me.token)
        .get('/creatives/suggestions', { available: 'true' })
        .expect(200);
      expect(
        available.body.data.map((x: { person: { handle: string } }) => x.person.handle),
      ).toEqual([diff.handle]);
      const county = await as(me.token)
        .get('/creatives/suggestions', {
          countyId: (await prisma.county.findFirstOrThrow({ where: { code: 'MSA' } })).id,
        })
        .expect(200);
      expect(county.body.data.map((x: { person: { handle: string } }) => x.person.handle)).toEqual([
        same.handle,
      ]);
      const verified = await as(me.token)
        .get('/creatives/suggestions', { verified: 'true' })
        .expect(200);
      expect(verified.body.data).toHaveLength(0);

      // After asking, the person shows as Requested.
      await as(me.token).post(`/creatives/${same.handle}/connect`).expect(200);
      const again = { body: { data: await suggestions(me.token, { countyId: msa.id }) } };
      const requested = again.body.data.find(
        (x: { person: { handle: string } }) => x.person.handle === same.handle,
      );
      expect(requested).toMatchObject({ connectionState: 'PENDING_SENT' });
      expect(requested?.connectionId).not.toBeNull();
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  describe('reports, moderation and outcomes', () => {
    it('report -> case -> action -> reporters told, without internal details', async () => {
      const author = await member();
      const r1 = await member();
      const r2 = await member();
      const moderator = await staff('MODERATOR');
      const p = await post(author, 'something that breaks the rules');

      const rep1 = await as(r1.token)
        .post('/reports', {
          targetType: 'POST',
          targetId: p.id,
          reason: 'HARASSMENT',
          note: 'targets me',
        })
        .expect(201);
      expect(rep1.body.data).toMatchObject({
        targetType: 'POST',
        status: 'SUBMITTED',
        outcome: null,
      });
      const dup = await as(r1.token)
        .post('/reports', { targetType: 'POST', targetId: p.id, reason: 'SCAM' })
        .expect(201);
      expect(dup.body.data.id).toBe(rep1.body.data.id); // the same report, not a second one
      await as(author.token)
        .post('/reports', { targetType: 'POST', targetId: p.id, reason: 'OTHER' })
        .expect(409); // own content
      await as(r2.token)
        .post('/reports', { targetType: 'POST', targetId: p.id, reason: 'SCAM' })
        .expect(201);
      await as(r2.token)
        .post('/reports', {
          targetType: 'POST',
          targetId: '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b',
          reason: 'SCAM',
        })
        .expect(404);
      await as(r2.token).post('/reports', { targetType: 'POST', reason: 'SCAM' }).expect(400); // no target id

      // One case per target, with both reports behind it.
      const cases = await as(moderator.token)
        .get('/admin/moderation-cases', { open: 'true', targetType: 'POST' })
        .expect(200);
      const c = cases.body.data.find((x: { targetId: string }) => x.targetId === p.id);
      expect(c).toMatchObject({
        reportCount: 2,
        priority: 'HIGH',
        status: 'SUBMITTED',
        topReason: 'HARASSMENT',
      });
      expect(c.preview).toContain('breaks the rules');
      expect(c.author.id).toBe(author.id);
      const reports = await as(moderator.token)
        .get('/admin/reports', { targetType: 'POST', status: 'SUBMITTED' })
        .expect(200);
      expect(
        reports.body.data.filter((x: { targetId: string }) => x.targetId === p.id),
      ).toHaveLength(2);

      const detail = await as(moderator.token).get(`/admin/moderation-cases/${c.id}`).expect(200);
      expect(detail.body.data.reports).toHaveLength(2);
      expect(detail.body.data.content).toMatchObject({ exists: true, status: 'VISIBLE' });
      expect(detail.body.data.allowedActions).toContain('HIDE_CONTENT');

      // Assigning takes the case into review; a decision needs a reason and a permitted action.
      const assigned = await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/assign`, { assigneeId: moderator.id })
        .expect(200);
      expect(assigned.body.data).toMatchObject({
        status: 'IN_REVIEW',
        assignee: { id: moderator.id },
      });
      await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/assign`, { assigneeId: r1.id })
        .expect(400); // not staff
      await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, { action: 'HIDE_CONTENT' })
        .expect(400);
      // A moderator cannot suspend: that needs user.suspend.
      await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, {
          action: 'SUSPEND_ACCOUNT',
          reason: 'too much',
        })
        .expect(403);
      await as(r1.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, { action: 'NO_ACTION' })
        .expect(403); // members are not staff

      const decided = await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, {
          action: 'HIDE_CONTENT',
          reason: 'Harassment per guidelines',
        })
        .expect(200);
      expect(decided.body.data.status).toBe('RESOLVED');
      expect(decided.body.data.content.status).toBe('HIDDEN');
      expect(decided.body.data.history).toHaveLength(1);
      expect(decided.body.data.history[0]).toMatchObject({
        action: 'HIDE_CONTENT',
        actor: { id: moderator.id },
      });

      // The content is hidden for everyone but its author, who is told it is hidden and cannot edit it.
      await as(r1.token).get(`/posts/${p.id}`).expect(404);
      expect(await feedIds(r2)).not.toContain(p.id);
      expect((await as(author.token).get(`/posts/${p.id}`).expect(200)).body.data.status).toBe(
        'HIDDEN',
      );
      await as(author.token).patch(`/posts/${p.id}`, { body: 'edit it' }).expect(409);

      // Reporters: told once, with fixed wording that says nothing about who, how or why.
      for (const r of [r1, r2]) {
        const notes = await prisma.notification.findMany({
          where: { userId: r.id, title: 'Update on your report' },
        });
        expect(notes).toHaveLength(1);
        expect(notes[0]!.body).toBe(REPORT_OUTCOME_COPY.ACTION_TAKEN.body);
        const text = JSON.stringify(notes[0]).toLowerCase();
        for (const leak of [
          'moderator',
          'hidden',
          'hide',
          'harassment',
          author.name.toLowerCase(),
          'guidelines per',
        ]) {
          expect(text).not.toContain(leak);
        }
        const mine = await as(r.token).get('/me/reports').expect(200);
        expect(Object.keys(mine.body.data[0]).sort()).toEqual([
          'createdAt',
          'id',
          'outcome',
          'reason',
          'reviewedAt',
          'status',
          'targetType',
        ]);
        expect(mine.body.data[0]).toMatchObject({ status: 'REVIEWED', outcome: 'ACTION_TAKEN' });
      }
      // The author is told what happened to the content, not who reported it.
      const authorNote = await prisma.notification.findFirstOrThrow({
        where: { userId: author.id, title: 'A moderator reviewed your activity' },
      });
      expect(authorNote.body).toContain('hidden');
      expect(authorNote.body).not.toContain(r1.name);

      // The log is append-only, enforced by the database.
      await expect(
        prisma.$executeRaw`UPDATE moderation_actions SET reason = 'edited'`,
      ).rejects.toThrow(/append-only/);
      await expect(prisma.$executeRaw`DELETE FROM moderation_actions`).rejects.toThrow(
        /append-only/,
      );
      expect(
        await prisma.auditLog.count({
          where: { action: 'moderation.hide_content', entityId: c.id },
        }),
      ).toBe(1);

      // Restoring puts the post back; reporters are not messaged a second time.
      await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, {
          action: 'RESTORE_CONTENT',
          reason: 'Reviewed on appeal',
        })
        .expect(200);
      await as(r1.token).get(`/posts/${p.id}`).expect(200);
      expect(
        await prisma.notification.count({
          where: { userId: r1.id, title: 'Update on your report' },
        }),
      ).toBe(1);
      const history = await as(moderator.token).get(`/admin/moderation-cases/${c.id}`).expect(200);
      expect(history.body.data.history.map((h: { action: string }) => h.action)).toEqual([
        'HIDE_CONTENT',
        'RESTORE_CONTENT',
      ]);
    });

    it('dismisses with no action, tells the reporter so, and reopens on a new report', async () => {
      const author = await member();
      const r1 = await member();
      const r2 = await member();
      const moderator = await staff('MODERATOR');
      const p = await post(author, 'borderline but fine');
      await as(r1.token)
        .post('/reports', { targetType: 'POST', targetId: p.id, reason: 'MISLEADING' })
        .expect(201);
      const c = await prisma.moderationCase.findFirstOrThrow({ where: { targetId: p.id } });
      await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, { action: 'NO_ACTION' })
        .expect(200);
      expect((await prisma.moderationCase.findUniqueOrThrow({ where: { id: c.id } })).status).toBe(
        'DISMISSED',
      );
      const note = await prisma.notification.findFirstOrThrow({
        where: { userId: r1.id, title: 'Update on your report' },
      });
      expect(note.body).toBe(REPORT_OUTCOME_COPY.NO_ACTION.body);
      await as(r1.token).get(`/posts/${p.id}`).expect(200); // still visible
      expect((await as(author.token).get('/me/reports').expect(200)).body.data).toHaveLength(0);
      expect(
        await prisma.notification.count({
          where: { userId: author.id, title: 'A moderator reviewed your activity' },
        }),
      ).toBe(0);

      await as(r2.token)
        .post('/reports', { targetType: 'POST', targetId: p.id, reason: 'SCAM' })
        .expect(201);
      const reopened = await prisma.moderationCase.findUniqueOrThrow({ where: { id: c.id } });
      expect(reopened).toMatchObject({ status: 'SUBMITTED', reportCount: 2, resolvedAt: null });
    });

    it('reports comments, members and groups, and refuses targets the reporter cannot see', async () => {
      const author = await member();
      const reporter = await member();
      const other = await member();
      const p = await post(author, 'a thread');
      const cm = (
        await as(author.token).post(`/posts/${p.id}/comments`, { body: 'rude comment' }).expect(201)
      ).body.data;
      await as(reporter.token)
        .post('/reports', { targetType: 'COMMENT', targetId: cm.id, reason: 'INAPPROPRIATE' })
        .expect(201);
      await as(reporter.token)
        .post('/reports', { targetType: 'USER', handle: author.handle, reason: 'IMPERSONATION' })
        .expect(201);
      await as(reporter.token)
        .post('/reports', { targetType: 'USER', targetId: reporter.id, reason: 'OTHER' })
        .expect(409);
      // A connections-only post the reporter cannot see cannot be reported.
      const hiddenPost = await post(author, 'private words', { audience: 'CONNECTIONS' });
      await as(other.token)
        .post('/reports', { targetType: 'POST', targetId: hiddenPost.id, reason: 'SCAM' })
        .expect(404);
      expect(
        await prisma.moderationCase.count({ where: { targetId: { in: [cm.id, author.id] } } }),
      ).toBe(2);
    });

    it('restricts an account, which then cannot post, comment or connect, until the restriction is lifted', async () => {
      const bad = await member();
      const reporter = await member();
      const moderator = await staff('MODERATOR');
      const peer = await member();
      const p = await post(peer, 'a post to comment on');
      await as(reporter.token)
        .post('/reports', { targetType: 'USER', targetId: bad.id, reason: 'HARASSMENT' })
        .expect(201);
      const c = await prisma.moderationCase.findFirstOrThrow({
        where: { targetType: 'USER', targetId: bad.id },
      });
      const detail = await as(moderator.token).get(`/admin/moderation-cases/${c.id}`).expect(200);
      expect(detail.body.data.allowedActions).not.toContain('HIDE_CONTENT');
      await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, { action: 'HIDE_CONTENT', reason: 'x' })
        .expect(400);

      await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, {
          action: 'RESTRICT_ACCOUNT',
          reason: 'Repeated harassment',
          restrictDays: 7,
        })
        .expect(200);
      for (const attempt of [
        () => as(bad.token).post('/posts', { type: 'UPDATE', body: 'hello' }),
        () => as(bad.token).post(`/posts/${p.id}/comments`, { body: 'hello' }),
        () => as(bad.token).post(`/creatives/${peer.handle}/connect`),
      ]) {
        const res = await attempt().expect(403);
        expect(res.body.error.details.reason).toBe('ACCOUNT_RESTRICTED');
      }
      await as(bad.token).get('/community/feed').expect(200); // reading is not restricted
      const told = await prisma.notification.findFirstOrThrow({
        where: { userId: bad.id, title: 'A moderator reviewed your activity' },
      });
      expect(told.body).toContain('limited');

      await as(moderator.token)
        .post(`/admin/moderation-cases/${c.id}/actions`, {
          action: 'RESTORE_CONTENT',
          reason: 'Restriction lifted',
        })
        .expect(200);
      await as(bad.token).post('/posts', { type: 'UPDATE', body: 'back again' }).expect(201);
    });

    it('raises the 48-hour backlog alert once a day for each stale case', async () => {
      const author = await member();
      const reporter = await member();
      const moderator = await staff('MODERATOR');
      const p = await post(author, 'old report');
      await as(reporter.token)
        .post('/reports', { targetType: 'POST', targetId: p.id, reason: 'SCAM' })
        .expect(201);
      const c = await prisma.moderationCase.findFirstOrThrow({ where: { targetId: p.id } });
      const jobs = app.get(CommunityJobsService);

      const fresh = await jobs.alertModerationBacklog();
      expect(await prisma.moderationCase.findUniqueOrThrow({ where: { id: c.id } })).toMatchObject({
        alertedAt: null,
      }); // too young
      expect(fresh.cases).toBeGreaterThanOrEqual(0);

      await prisma.moderationCase.update({
        where: { id: c.id },
        data: { createdAt: new Date(Date.now() - 49 * 3_600_000) },
      });
      const first = await jobs.alertModerationBacklog();
      expect(first.cases).toBeGreaterThanOrEqual(1);
      expect(
        await prisma.notification.count({
          where: { userId: moderator.id, title: 'Moderation cases are waiting' },
        }),
      ).toBe(1);
      expect(
        (await prisma.moderationCase.findUniqueOrThrow({ where: { id: c.id } })).alertedAt,
      ).not.toBeNull();
      // Same day: not raised again.
      await jobs.alertModerationBacklog();
      expect(
        await prisma.notification.count({
          where: { userId: moderator.id, title: 'Moderation cases are waiting' },
        }),
      ).toBe(1);
      // The queue can be filtered to the backlog.
      const backlog = await as(moderator.token)
        .get('/admin/moderation-cases', { open: 'true', olderThanHours: 48 })
        .expect(200);
      expect(backlog.body.data.map((x: { id: string }) => x.id)).toContain(c.id);
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  describe('link previews (SSRF-safe job)', () => {
    it('stores a preview when the page is fetchable', async () => {
      const a = await member();
      const created = await post(a, 'read this', {
        linkUrl: 'https://news.example.com/story?id=1',
      });
      const row = await prisma.postLink.findUniqueOrThrow({ where: { postId: created.id } });
      expect(row).toMatchObject({ url: 'https://news.example.com/story?id=1', fetchedAt: null });
      const fetcher = app.get(SafeFetcher);
      const original = fetcher.fetchHtml.bind(fetcher);
      fetcher.fetchHtml = async (url: string) => ({
        url,
        status: 200,
        contentType: 'text/html',
        body: '<head><meta property="og:title" content="A good story"><meta property="og:image" content="https://cdn.example.com/a.jpg"></head>',
      });
      try {
        expect(await app.get(CommunityJobsService).fetchLinkPreview(created.id)).toEqual({
          status: 'stored',
        });
      } finally {
        fetcher.fetchHtml = original;
      }
      const view = (await as(a.token).get(`/posts/${created.id}`).expect(200)).body.data;
      expect(view.link).toMatchObject({
        title: 'A good story',
        image: 'https://cdn.example.com/a.jpg',
      });
    });

    it('refuses an address that resolves inside the network and records that it was tried', async () => {
      const a = await member();
      const created = await post(a, 'sneaky', { linkUrl: 'https://rebind.example.com/x' });
      const fetcher = app.get(SafeFetcher);
      const original = fetcher.resolve;
      fetcher.resolve = async () => ['169.254.169.254'];
      try {
        expect(await app.get(CommunityJobsService).fetchLinkPreview(created.id)).toEqual({
          status: 'refused',
        });
      } finally {
        fetcher.resolve = original;
      }
      const row = await prisma.postLink.findUniqueOrThrow({ where: { postId: created.id } });
      expect(row.fetchedAt).not.toBeNull();
      expect(row.title).toBeNull();
      // Run again: nothing more to do.
      expect(await app.get(CommunityJobsService).fetchLinkPreview(created.id)).toEqual({
        status: 'skipped',
      });
    });
  });

  // ---------------------------------------------------------------------------------------------------------------

  describe('database posture', () => {
    it('keeps the new tables out of reach of a signed-in member key', async () => {
      const m = await member();
      const session = await loginMember(app, m.email);
      for (const table of [
        'posts',
        'comments',
        'reactions',
        'groups',
        'group_memberships',
        'blocks',
        'mutes',
        'reports',
        'moderation_cases',
        'moderation_actions',
        'community_restrictions',
      ]) {
        const read = await session.client.from(table).select('*').limit(1);
        expect([table, read.error?.code]).toEqual([table, '42501']);
        const write = await session.client.from(table).insert({});
        expect([table, write.error === null]).toEqual([table, false]);
      }
    });

    it('enforces the pair, self and length rules in the database', async () => {
      const a = await member();
      await expect(
        prisma.block.create({ data: { blockerId: a.id, blockedId: a.id } }),
      ).rejects.toThrow();
      await expect(
        prisma.post.create({
          data: { authorId: a.id, type: 'UPDATE', body: 'x'.repeat(5001), audience: 'MEMBERS' },
        }),
      ).rejects.toThrow();
      await expect(
        prisma.post.create({
          data: { authorId: a.id, type: 'UPDATE', body: 'group without id', audience: 'GROUP' },
        }),
      ).rejects.toThrow();
    });
  });
});
