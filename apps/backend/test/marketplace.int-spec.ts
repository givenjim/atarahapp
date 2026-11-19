import { type INestApplication } from '@nestjs/common';
import request from 'supertest';
import { PrismaService } from '../src/prisma/prisma.service';
import { StorageService } from '../src/storage/storage.service';
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
jest.setTimeout(240_000);

interface Member {
  id: string;
  token: string;
  email: string;
}

describe('Marketplace foundation (integration)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const http = () => request(app.getHttpServer());
  const users: string[] = [];
  let categoryId: string;

  const as = (token?: string) => {
    const wrap = (r: request.Test) => (token ? r.set(...bearer(token)) : r);
    return {
      get: (p: string, query: object = {}) => wrap(http().get(`/api/v1${p}`).query(query)),
      post: (p: string, b: object = {}) => wrap(http().post(`/api/v1${p}`).send(b)),
      put: (p: string, b: object = {}) => wrap(http().put(`/api/v1${p}`).send(b)),
      patch: (p: string, b: object = {}) => wrap(http().patch(`/api/v1${p}`).send(b)),
      del: (p: string) => wrap(http().del(`/api/v1${p}`)),
    };
  };

  beforeAll(async () => {
    app = await createTestApp();
    // The suite stubs object storage; give it the one call that renders a picture address.
    Object.assign(app.get(StorageService), {
      signedDownloadUrl: async (_bucket: string, key: string) => `https://files.test/${key}`,
    });
    prisma = app.get(PrismaService);
    categoryId = (await prisma.marketplaceCategory.findFirstOrThrow({ where: { isActive: true } }))
      .id;
  });
  afterAll(async () => {
    await deleteUsers(app, users);
    await app.close();
  });

  async function member(name = 'Mia'): Promise<Member> {
    const { user, email } = await makeUser(app, { fullName: `${name} ${uniq()}` });
    users.push(user.id);
    const token = (await loginMember(app, email)).accessToken;
    await prisma.creativeProfile.create({
      data: {
        userId: user.id,
        handle: `c_${uniq()}`.replace(/-/g, '_'),
        displayName: name,
        onboardingStep: 'DONE',
        onboardingCompletedAt: new Date(),
      },
    });
    return { id: user.id, token, email };
  }

  async function staff(role: 'PLATFORM_ADMIN' | 'CONTENT_ADMIN' | 'MODERATOR' = 'PLATFORM_ADMIN') {
    const { user, email } = await makeUser(app, { roles: [role], fullName: `Staff ${uniq()}` });
    users.push(user.id);
    const { session } = await adminSignIn(app, email);
    return { id: user.id, token: session.accessToken };
  }

  async function image(ownerId: string) {
    return prisma.mediaAsset.create({
      data: {
        ownerId,
        kind: 'IMAGE',
        bucket: 'PUBLIC',
        objectKey: `test/${uniq()}.jpg`,
        mimeType: 'image/jpeg',
        sizeBytes: 1000,
        status: 'READY',
      },
    });
  }

  /** A complete listing, ready to submit. Becomes a seller on first use. */
  async function draft(m: Member, o: { title?: string; first?: boolean } = {}) {
    const media = await image(m.id);
    const res = await as(m.token)
      .post('/me/listings', {
        title: o.title ?? `Wedding photography ${uniq()}`,
        categoryId,
        description: 'A full day of coverage with an edited gallery delivered in two weeks.',
        pricingType: 'FIXED',
        priceMin: 25000,
        mediaIds: [media.id],
        includedItems: ['Edited gallery', 'Print rights'],
        deliveryDays: 14,
        acceptTerms: o.first === false ? undefined : true,
      })
      .expect(201);
    return res.body.data as { id: string; status: string; title: string };
  }

  async function publish(seller: Member, admin: { token: string }, o: { title?: string } = {}) {
    const l = await draft(seller, o);
    const sub = await as(seller.token).post(`/me/listings/${l.id}/submit`).expect(200);
    if (!sub.body.data.published) {
      await as(admin.token).post(`/admin/marketplace/listings/${l.id}/approve`).expect(200);
    }
    return l;
  }

  describe('becoming a seller', () => {
    it('needs the terms accepted, then grants the SELLER role exactly once', async () => {
      const m = await member();
      const refused = await as(m.token)
        .post('/me/listings', { title: 'My first listing', categoryId })
        .expect(400);
      expect(refused.body.error.details.code).toBe('SELLER_TERMS_REQUIRED');
      expect(await prisma.sellerProfile.count({ where: { userId: m.id } })).toBe(0);

      const first = await draft(m);
      const roles = () =>
        prisma.userRole.count({
          where: { userId: m.id, revokedAt: null, role: { key: 'SELLER' } },
        });
      expect(await roles()).toBe(1);
      const profile = await prisma.sellerProfile.findUniqueOrThrow({ where: { userId: m.id } });
      expect(profile.termsVersion).toBe('draft-1');
      expect(first.status).toBe('DRAFT');

      await draft(m, { first: false });
      await draft(m);
      expect(await roles()).toBe(1);
      expect(await prisma.sellerProfile.count({ where: { userId: m.id } })).toBe(1);
      const audit = await prisma.auditLog.count({
        where: { action: 'seller.become', actorId: m.id },
      });
      expect(audit).toBe(1);
    });

    it('a seller whose profile is suspended cannot create or submit', async () => {
      const admin = await staff();
      const m = await member();
      const l = await draft(m);
      const profile = await prisma.sellerProfile.findUniqueOrThrow({ where: { userId: m.id } });
      await as(admin.token)
        .post(`/admin/marketplace/sellers/${profile.id}/suspend`, { reason: 'Test suspension' })
        .expect(200);
      await as(m.token).post('/me/listings', { title: 'Another', categoryId }).expect(403);
      await as(m.token).post(`/me/listings/${l.id}/submit`).expect(403);
      await as(admin.token)
        .post(`/admin/marketplace/sellers/${profile.id}/reinstate`, { reason: 'Fine now' })
        .expect(200);
      await as(m.token).post(`/me/listings/${l.id}/submit`).expect(200);
    });
  });

  describe('listing state machine', () => {
    it('submit validates, first listings are reviewed, staff decide, owners pause and restore', async () => {
      const admin = await staff();
      const seller = await member();
      const buyer = await member('Ben');
      const bare = await as(seller.token)
        .post('/me/listings', { title: 'Bare listing', categoryId, acceptTerms: true })
        .expect(201);
      const bareId = bare.body.data.id as string;
      const missing = await as(seller.token).post(`/me/listings/${bareId}/submit`).expect(400);
      expect(missing.body.error.details.missing.length).toBeGreaterThanOrEqual(2);
      await as(seller.token).del(`/me/listings/${bareId}`).expect(204);

      const l = await draft(seller);
      // A draft is invisible to everyone else.
      await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(404);

      const sub = await as(seller.token).post(`/me/listings/${l.id}/submit`).expect(200);
      expect(sub.body.data.published).toBe(false);
      expect(sub.body.data.listing.status).toBe('UNDER_REVIEW');
      await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(404);
      const browse = await as(buyer.token)
        .get('/marketplace/listings', { q: 'Wedding' })
        .expect(200);
      expect(browse.body.data.map((x: { id: string }) => x.id)).not.toContain(l.id);

      // Only staff with the permission decide.
      await as(buyer.token).post(`/admin/marketplace/listings/${l.id}/approve`).expect(403);
      const moderator = await staff('MODERATOR');
      await as(moderator.token).post(`/admin/marketplace/listings/${l.id}/approve`).expect(403);
      // The wrong transition is refused.
      const other = await draft(seller, { first: false });
      await as(admin.token).post(`/admin/marketplace/listings/${other.id}/approve`).expect(409);
      // A rejection needs a reason and tells the seller.
      await as(admin.token).post(`/admin/marketplace/listings/${l.id}/reject`, {}).expect(400);
      await as(admin.token)
        .post(`/admin/marketplace/listings/${l.id}/reject`, {
          reason: 'Add a clearer cover picture.',
        })
        .expect(200);
      const rejected = await as(seller.token).get(`/me/listings/${l.id}`).expect(200);
      expect(rejected.body.data.status).toBe('REJECTED');
      expect(rejected.body.data.rejectionReason).toBe('Add a clearer cover picture.');
      expect(
        await prisma.notification.count({
          where: { userId: seller.id, type: 'marketplace.listing.rejected' },
        }),
      ).toBe(1);

      await as(seller.token).post(`/me/listings/${l.id}/submit`).expect(200);
      await as(admin.token).post(`/admin/marketplace/listings/${l.id}/approve`).expect(200);
      expect(
        await prisma.notification.count({
          where: { userId: seller.id, type: 'marketplace.listing.approved' },
        }),
      ).toBe(1);

      const live = await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(200);
      expect(live.body.data.priceLabel).toBe('KES 25,000');
      expect(live.body.data.requestNote).toBe(
        "You'll agree details and payment directly with the seller.",
      );
      expect(live.body.data.media).toHaveLength(1);
      expect(live.body.data.seller.verified).toBe(false);

      // A live listing cannot be deleted; pausing hides it and restoring makes it a draft.
      await as(seller.token).del(`/me/listings/${l.id}`).expect(409);
      await as(seller.token).post(`/me/listings/${l.id}/archive`).expect(200);
      await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(404);
      await as(seller.token).post(`/me/listings/${l.id}/archive`).expect(409);
      const restored = await as(seller.token).post(`/me/listings/${l.id}/restore`).expect(200);
      expect(restored.body.data.status).toBe('DRAFT');

      // Another member cannot touch it: the answer matches a missing listing.
      await as(buyer.token).patch(`/me/listings/${l.id}`, { title: 'Hijack' }).expect(403);
      await as(buyer.token).post(`/me/listings/${l.id}/submit`).expect(403);
    });

    it('a seller marked for direct publishing goes live at once; editing a live one re-reviews others', async () => {
      const admin = await staff();
      const seller = await member();
      const first = await draft(seller);
      const profile = await prisma.sellerProfile.findUniqueOrThrow({
        where: { userId: seller.id },
      });
      await as(admin.token)
        .patch(`/admin/marketplace/sellers/${profile.id}/direct-publish`, {
          canPublishDirectly: true,
        })
        .expect(200);
      const sub = await as(seller.token).post(`/me/listings/${first.id}/submit`).expect(200);
      expect(sub.body.data.published).toBe(true);
      // Direct publishers keep a live listing live when they edit it.
      const edited = await as(seller.token)
        .patch(`/me/listings/${first.id}`, { title: 'Wedding films' })
        .expect(200);
      expect(edited.body.data.status).toBe('PUBLISHED');

      const reviewed = await member();
      const live = await publish(reviewed, admin);
      const edit = await as(reviewed.token)
        .patch(`/me/listings/${live.id}`, {
          description: 'Completely new description for the review.',
        })
        .expect(200);
      expect(edit.body.data.status).toBe('UNDER_REVIEW');
    });
  });

  describe('discovery, search, saving and reporting', () => {
    it('a published listing is found by browse, search and the seller page; saving and reporting work', async () => {
      const admin = await staff();
      const seller = await member('Sade');
      const buyer = await member('Ben');
      const word = `Zanzibarlens${uniq().replace(/[^a-z0-9]/gi, '')}`;
      const l = await publish(seller, admin, { title: `${word} portraits` });

      const list = await as(buyer.token)
        .get('/marketplace/listings', { q: word, type: 'SERVICE', categoryId })
        .expect(200);
      expect(list.body.data.map((x: { id: string }) => x.id)).toEqual([l.id]);
      expect(
        (
          await as(buyer.token)
            .get('/marketplace/listings', { q: word, type: 'PRODUCT' })
            .expect(200)
        ).body.data,
      ).toHaveLength(0);
      for (const sort of ['recommended', 'price_low', 'price_high', 'rating', 'newest']) {
        await as(buyer.token).get('/marketplace/listings', { sort, q: word }).expect(200);
      }
      await as(buyer.token).get('/marketplace/listings', { sort: 'nonsense' }).expect(400);

      const home = await as(buyer.token).get('/marketplace/home').expect(200);
      expect(home.body.data.isSeller).toBe(false);
      expect(home.body.data.categories.length).toBeGreaterThan(0);
      const sellerHome = await as(seller.token).get('/marketplace/home').expect(200);
      expect(sellerHome.body.data.isSeller).toBe(true);

      // Search integration: a marketplace group, and nothing for drafts or paused listings.
      const search = await as(buyer.token).get('/search', { q: word }).expect(200);
      const group = search.body.data.groups.find((g: { type: string }) => g.type === 'marketplace');
      expect(group.items.map((i: { id: string }) => i.id)).toEqual([l.id]);
      expect(group.items[0].path).toBe(`/marketplace/listings/${l.id}`);
      const typed = await as(buyer.token)
        .get('/search', { q: word, type: 'marketplace' })
        .expect(200);
      expect(typed.body.data.groups[0].count).toBe(1);

      const sellerPage = await as(buyer.token)
        .get(
          `/marketplace/sellers/${(await prisma.sellerProfile.findUniqueOrThrow({ where: { userId: seller.id } })).id}`,
        )
        .expect(200);
      expect(sellerPage.body.data.listings.map((x: { id: string }) => x.id)).toEqual([l.id]);
      // Trust lines only when real: nothing is verified, so none is shown.
      expect(sellerPage.body.data.trustLines).toEqual([]);
      const sellers = await as(buyer.token).get('/marketplace/sellers').expect(200);
      expect(sellers.body.data.length).toBeGreaterThan(0);

      // Saved.
      await as(buyer.token).put(`/me/saved/LISTING/${l.id}`).expect(204);
      const card = await as(buyer.token).get('/marketplace/listings', { q: word }).expect(200);
      expect(card.body.data[0].saved).toBe(true);
      const saved = await as(buyer.token).get('/me/saved', { type: 'LISTING' }).expect(200);
      expect(saved.body.data.map((s: { targetId: string }) => s.targetId)).toEqual([l.id]);
      await as(buyer.token).del(`/me/saved/LISTING/${l.id}`).expect(204);
      await as(seller.token).put(`/me/saved/LISTING/${l.id}`).expect(404);

      // Reports: not your own, once per member, queue for staff, staff can take it down.
      await as(seller.token)
        .post(`/marketplace/listings/${l.id}/report`, { reason: 'SCAM' })
        .expect(409);
      await as(buyer.token)
        .post(`/marketplace/listings/${l.id}/report`, { reason: 'SCAM', note: 'Looks fake' })
        .expect(204);
      await as(buyer.token)
        .post(`/marketplace/listings/${l.id}/report`, { reason: 'SCAM' })
        .expect(204);
      expect(await prisma.listingReport.count({ where: { listingId: l.id } })).toBe(1);
      const queue = await as(admin.token).get('/admin/marketplace/reports').expect(200);
      const report = queue.body.data.find((r: { listingId: string }) => r.listingId === l.id);
      expect(report.reporterName).toBeTruthy();
      await as(buyer.token).get('/admin/marketplace/reports').expect(403);
      await as(admin.token)
        .post(`/admin/marketplace/reports/${report.id}/resolve`, {
          action: 'SUSPEND_LISTING',
          note: 'Confirmed spam.',
        })
        .expect(200);
      await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(404);
      expect(
        (await as(buyer.token).get('/search', { q: word, type: 'marketplace' }).expect(200)).body
          .data.groups[0].count,
      ).toBe(0);
      await as(admin.token)
        .post(`/admin/marketplace/listings/${l.id}/reinstate`, { reason: 'Appeal accepted' })
        .expect(200);
      await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(200);
    });

    it('a blocked member cannot see the seller listings', async () => {
      const admin = await staff();
      const seller = await member();
      const buyer = await member();
      const l = await publish(seller, admin);
      await prisma.block.create({ data: { blockerId: buyer.id, blockedId: seller.id } });
      await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(404);
      await as(buyer.token)
        .post(`/marketplace/listings/${l.id}/enquiries`, { message: 'Hello there, are you free?' })
        .expect(404);
    });
  });

  describe('requests, the thread and reviews', () => {
    it('only the two parties see the thread; reviews need a closed request', async () => {
      const admin = await staff();
      const seller = await member('Sade');
      const buyer = await member('Ben');
      const outsider = await member('Olu');
      const l = await publish(seller, admin);

      // Buyer sends a request; the note under the CTA is only informational (no payment is created).
      await as(buyer.token)
        .post(`/marketplace/listings/${l.id}/enquiries`, { message: 'x' })
        .expect(400);
      await as(seller.token)
        .post(`/marketplace/listings/${l.id}/enquiries`, { message: 'Talking to myself here' })
        .expect(409);
      const sent = await as(buyer.token)
        .post(`/marketplace/listings/${l.id}/enquiries`, {
          message: 'I need photos for a wedding in March.',
          budget: 20000,
          preferredTiming: 'March',
        })
        .expect(201);
      const eid = sent.body.data.id as string;
      expect(sent.body.data.status).toBe('NEW');
      expect(sent.body.data.role).toBe('BUYER');
      expect(sent.body.data.messages).toHaveLength(1);
      const dup = await as(buyer.token)
        .post(`/marketplace/listings/${l.id}/enquiries`, { message: 'Sending it again please' })
        .expect(409);
      expect(dup.body.error.details.enquiryId).toBe(eid);

      // The seller was told.
      expect(
        await prisma.notification.count({
          where: { userId: seller.id, type: 'marketplace.enquiry.new' },
        }),
      ).toBe(1);
      const detail = await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(200);
      expect(detail.body.data.openEnquiryId).toBe(eid);

      // Only the two parties.
      await as(outsider.token).get(`/marketplace/enquiries/${eid}`).expect(404);
      await as(outsider.token)
        .post(`/marketplace/enquiries/${eid}/messages`, { body: 'Let me in' })
        .expect(404);
      await as(outsider.token).post(`/marketplace/enquiries/${eid}/close`).expect(404);
      await as(outsider.token)
        .post(`/marketplace/enquiries/${eid}/review`, { rating: 5 })
        .expect(404);
      expect(
        (await as(outsider.token).get('/marketplace/enquiries').expect(200)).body.data,
      ).toHaveLength(0);
      const sellerInbox = await as(seller.token)
        .get('/marketplace/enquiries', { as: 'seller' })
        .expect(200);
      expect(sellerInbox.body.data.map((e: { id: string }) => e.id)).toEqual([eid]);
      expect(sellerInbox.body.data[0].unread).toBe(true);
      expect(
        (await as(buyer.token).get('/marketplace/enquiries', { as: 'seller' }).expect(200)).body
          .data,
      ).toHaveLength(0);

      const mine = await as(seller.token).get('/me/listings').expect(200);
      expect(mine.body.data.stats.newInterest).toBe(1);
      expect(mine.body.data.stats.live).toBe(1);

      // Cannot close or review before the seller has replied, and the seller can never review.
      await as(buyer.token).post(`/marketplace/enquiries/${eid}/close`).expect(409);
      await as(buyer.token).post(`/marketplace/enquiries/${eid}/review`, { rating: 5 }).expect(409);

      // The seller reads it (marks read) and replies.
      const read = await as(seller.token).get(`/marketplace/enquiries/${eid}`).expect(200);
      expect(read.body.data.role).toBe('SELLER');
      expect(read.body.data.counterpart.displayName).toBe('Ben');
      expect(
        (await as(seller.token).get('/marketplace/enquiries', { as: 'seller' }).expect(200)).body
          .data[0].unread,
      ).toBe(false);
      const replied = await as(seller.token)
        .post(`/marketplace/enquiries/${eid}/messages`, { body: 'Happy to help. March is open.' })
        .expect(201);
      expect(replied.body.data.status).toBe('REPLIED');
      expect(replied.body.data.messages).toHaveLength(2);
      expect(
        await prisma.notification.count({
          where: { userId: buyer.id, type: 'marketplace.enquiry.reply' },
        }),
      ).toBe(1);
      const refreshed = await prisma.sellerProfile.findUniqueOrThrow({
        where: { userId: seller.id },
      });
      expect(refreshed.medianReplyMinutes).not.toBeNull();

      await as(buyer.token)
        .post(`/marketplace/enquiries/${eid}/messages`, { body: 'Great, thank you.' })
        .expect(201);
      // Open request: no review yet.
      await as(buyer.token).post(`/marketplace/enquiries/${eid}/review`, { rating: 5 }).expect(409);

      const closed = await as(seller.token).post(`/marketplace/enquiries/${eid}/close`).expect(200);
      expect(closed.body.data.status).toBe('CLOSED');
      await as(buyer.token)
        .post(`/marketplace/enquiries/${eid}/messages`, { body: 'One more thing' })
        .expect(409);

      // Reviews: out-of-range rating refused, the seller cannot review their own work, the buyer once.
      await as(buyer.token).post(`/marketplace/enquiries/${eid}/review`, { rating: 6 }).expect(400);
      await as(seller.token)
        .post(`/marketplace/enquiries/${eid}/review`, { rating: 5 })
        .expect(403);
      await as(buyer.token)
        .post(`/marketplace/enquiries/${eid}/review`, {
          rating: 4,
          body: 'Lovely photos, quick replies.',
        })
        .expect(201);
      await as(buyer.token).post(`/marketplace/enquiries/${eid}/review`, { rating: 1 }).expect(409);

      const reviews = await as(outsider.token)
        .get(`/marketplace/listings/${l.id}/reviews`)
        .expect(200);
      expect(reviews.body.data).toHaveLength(1);
      expect(reviews.body.data[0].rating).toBe(4);
      const stats = await prisma.sellerProfile.findUniqueOrThrow({ where: { userId: seller.id } });
      expect(stats.ratingCount).toBe(1);
      expect(stats.ratingAverage).toBe(4);
      expect(stats.completedCount).toBe(1);

      // A review needs a closed request with that seller: a member who never sent one cannot review.
      await as(outsider.token)
        .post(`/marketplace/enquiries/${eid}/review`, { rating: 5 })
        .expect(404);
      expect(await prisma.listingReview.count({ where: { listingId: l.id } })).toBe(1);

      // After closing, the buyer can send a fresh request.
      await as(buyer.token)
        .post(`/marketplace/listings/${l.id}/enquiries`, {
          message: 'Another event in June, are you free?',
        })
        .expect(201);

      // Staff can hide the review; the rating drops out of the stats.
      const adminReviews = await as(admin.token).get('/admin/marketplace/reviews').expect(200);
      const rid = adminReviews.body.data.find((r: { listingId: string }) => r.listingId === l.id)
        .id as string;
      await as(admin.token)
        .post(`/admin/marketplace/reviews/${rid}/hide`, { reason: 'Contains a phone number' })
        .expect(200);
      expect(
        (await as(outsider.token).get(`/marketplace/listings/${l.id}/reviews`).expect(200)).body
          .data,
      ).toHaveLength(0);
      expect(
        (await prisma.sellerProfile.findUniqueOrThrow({ where: { userId: seller.id } }))
          .ratingCount,
      ).toBe(0);
      await as(admin.token)
        .post(`/admin/marketplace/reviews/${rid}/restore`, { reason: 'Mistake' })
        .expect(200);
      expect(
        (await prisma.sellerProfile.findUniqueOrThrow({ where: { userId: seller.id } }))
          .ratingCount,
      ).toBe(1);
    });
  });

  describe('profile services and admin', () => {
    it('Publish turns a profile service into a draft listing and flips the pill', async () => {
      const seller = await member();
      const svc = await as(seller.token)
        .post('/me/services', {
          title: 'Logo animation',
          priceType: 'FIXED',
          priceMin: 15000,
          description: 'Short animated logos',
        })
        .expect(201);
      const sid = svc.body.data.id as string;
      await as(seller.token).post(`/me/services/${sid}/listing`, { categoryId }).expect(400);
      const made = await as(seller.token)
        .post(`/me/services/${sid}/listing`, { categoryId, acceptTerms: true })
        .expect(201);
      expect(made.body.data.status).toBe('DRAFT');
      expect(made.body.data.title).toBe('Logo animation');
      expect(made.body.data.priceMin).toBe(15000);
      // Idempotent: the same listing comes back.
      const again = await as(seller.token)
        .post(`/me/services/${sid}/listing`, { categoryId })
        .expect(201);
      expect(again.body.data.id).toBe(made.body.data.id);
      const services = await as(seller.token).get('/me/services').expect(200);
      const s = services.body.data.find((x: { id: string }) => x.id === sid);
      expect(s.status).toBe('ON_MARKETPLACE');
      expect(s.listingId).toBe(made.body.data.id);
      expect(s.listingStatus).toBe('DRAFT');
      // Deleting the draft puts the service back on the profile only.
      await as(seller.token).del(`/me/listings/${made.body.data.id}`).expect(204);
      const after = (await as(seller.token).get('/me/services').expect(200)).body.data.find(
        (x: { id: string }) => x.id === sid,
      );
      expect(after.status).toBe('PROFILE_ONLY');
      expect(after.listingId).toBeNull();
    });

    it('categories, featured listings and seller management', async () => {
      const admin = await staff();
      const content = await staff('CONTENT_ADMIN');
      const seller = await member();
      const buyer = await member();
      const l = await publish(seller, admin);

      // Categories need category.manage (content admins), not marketplace.manage.
      await as(admin.token).get('/admin/marketplace/categories').expect(403);
      const name = `Test category ${uniq()}`;
      const created = await as(content.token)
        .post('/admin/marketplace/categories', { name, icon: 'palette', tone: 'violet' })
        .expect(201);
      expect(created.body.data.slug).toMatch(/^test-category/);
      const cid = created.body.data.id as string;
      await as(content.token)
        .patch(`/admin/marketplace/categories/${cid}`, { name: `${name} renamed`, isActive: false })
        .expect(200);
      const cats = await as(buyer.token).get('/marketplace/categories').expect(200);
      expect(cats.body.data.find((c: { id: string }) => c.id === cid)).toBeUndefined();
      // The one with a live listing cannot be hidden.
      await as(content.token)
        .patch(`/admin/marketplace/categories/${categoryId}`, { isActive: false })
        .expect(409);

      // Featured.
      const until = new Date(Date.now() + 7 * 86_400_000).toISOString();
      await as(buyer.token)
        .post(`/admin/marketplace/listings/${l.id}/feature`, { until })
        .expect(403);
      await as(admin.token)
        .post(`/admin/marketplace/listings/${l.id}/feature`, { until })
        .expect(200);
      const home = await as(buyer.token).get('/marketplace/home').expect(200);
      expect(home.body.data.featured.map((x: { id: string }) => x.id)).toContain(l.id);
      await as(admin.token)
        .post(`/admin/marketplace/listings/${l.id}/feature`, { until: null })
        .expect(200);
      expect(
        (await as(buyer.token).get('/marketplace/home').expect(200)).body.data.featured.map(
          (x: { id: string }) => x.id,
        ),
      ).not.toContain(l.id);

      // Sellers: list, view, suspend hides live listings, reinstate brings them back.
      const profile = await prisma.sellerProfile.findUniqueOrThrow({
        where: { userId: seller.id },
      });
      const sellers = await as(admin.token)
        .get('/admin/marketplace/sellers', { q: 'Mia' })
        .expect(200);
      expect(sellers.body.data.some((s: { id: string }) => s.id === profile.id)).toBe(true);
      await as(buyer.token).get('/admin/marketplace/sellers').expect(403);
      await as(admin.token)
        .post(`/admin/marketplace/sellers/${profile.id}/suspend`, { reason: 'Policy breach' })
        .expect(200);
      await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(404);
      await as(buyer.token).get(`/marketplace/sellers/${profile.id}`).expect(404);
      await as(admin.token)
        .post(`/admin/marketplace/sellers/${profile.id}/reinstate`, { reason: 'Resolved' })
        .expect(200);
      await as(buyer.token).get(`/marketplace/listings/${l.id}`).expect(200);
      expect(
        await prisma.auditLog.count({
          where: { entityId: profile.id, action: { in: ['seller.suspend', 'seller.reinstate'] } },
        }),
      ).toBe(2);
    });

    it('requires sign-in and the member permission', async () => {
      await as().get('/marketplace/home').expect(401);
      await as().get('/me/listings').expect(401);
      await as().get('/admin/marketplace/listings').expect(401);
      const m = await member();
      await as(m.token).get('/me/listings/00000000-0000-4000-8000-000000000000').expect(403);
      const mine = await as(m.token).get('/me/listings').expect(200);
      expect(mine.body.data.isSeller).toBe(false);
      const terms = await as(m.token).get('/marketplace/seller-terms').expect(200);
      expect(terms.body.data.isDraft).toBe(true);
    });
  });
});
