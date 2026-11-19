import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { notBlockedWhere } from '../community-core/blocks';
import { AppConfigService } from '../config/app-config.service';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type CategoryDto,
  type ListingCardDto,
  type ListingDto,
  type ListingReviewDto,
  type ListingsQueryDto,
  type MarketplaceHomeDto,
  type ReportListingDto,
  type SellerProfileDto,
  type SellersQueryDto,
} from './marketplace.dto';
import { fromMinor, REQUEST_NOTE, toMinor } from './marketplace-logic';
import {
  LISTING_CARD_INCLUDE,
  listingVisibleWhere,
  MarketplaceViewsService,
  SELLER_INCLUDE,
  type ListingCardRow,
} from './marketplace-views.service';

const HOME_FEATURED = 6;
const HOME_SELLERS = 8;
const HOME_RECENT = 8;
const DETAIL_REVIEWS = 5;
/** "Recommended" scores a bounded candidate set, then pages through it. */
const RECOMMENDED_CANDIDATES = 300;
const DAY_MS = 86_400_000;

const SELLER_RATING_WEIGHT = 2;

export const DETAIL_INCLUDE = {
  ...LISTING_CARD_INCLUDE,
  media: { orderBy: { sortOrder: 'asc' }, select: { mediaId: true } },
  portfolio: {
    orderBy: { sortOrder: 'asc' },
    include: {
      project: {
        select: {
          id: true,
          title: true,
          status: true,
          visibility: true,
          hiddenAt: true,
          deletedAt: true,
          category: true,
          media: { orderBy: { sortOrder: 'asc' }, take: 1, select: { mediaId: true } },
        },
      },
    },
  },
} satisfies Prisma.ListingInclude;
export type DetailRow = Prisma.ListingGetPayload<{ include: typeof DETAIL_INCLUDE }>;

const words = (q: string): string[] =>
  q
    .trim()
    .split(/\s+/)
    .filter((w) => w.length > 0)
    .slice(0, 5);

export const replyLabel = (minutes: number | null): string | null => {
  if (minutes === null) return null;
  if (minutes < 60) return 'Replies within an hour';
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `Replies within ${hours} ${hours === 1 ? 'hour' : 'hours'}`;
  const days = Math.max(1, Math.round(hours / 24));
  return `Replies within ${days} ${days === 1 ? 'day' : 'days'}`;
};

@Injectable()
export class MarketplaceService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly views: MarketplaceViewsService,
    private readonly media: MediaService,
    private readonly config: AppConfigService,
  ) {}

  shareUrl(id: string): string {
    return `${this.config.appLinkBaseUrl.replace(/\/$/, '')}/marketplace/listings/${id}`;
  }

  /** An active seller who still holds the SELLER role. Drives the "My listings" pill. */
  async isSeller(userId: string): Promise<boolean> {
    const [profile, role] = await Promise.all([
      this.prisma.sellerProfile.findUnique({ where: { userId }, select: { status: true } }),
      this.prisma.userRole.findFirst({
        where: { userId, revokedAt: null, role: { key: 'SELLER' } },
        select: { id: true },
      }),
    ]);
    return profile?.status === 'ACTIVE' && !!role;
  }

  // ---- categories and home ------------------------------------------------------------------------------------

  async categories(): Promise<CategoryDto[]> {
    const [cats, counts] = await Promise.all([
      this.prisma.marketplaceCategory.findMany({
        where: { isActive: true },
        orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      }),
      this.prisma.listing.groupBy({
        by: ['categoryId'],
        where: { status: 'PUBLISHED', seller: { status: 'ACTIVE' } },
        _count: { _all: true },
      }),
    ]);
    const by = new Map(counts.map((c) => [c.categoryId, c._count._all]));
    return cats.map((c) => ({
      id: c.id,
      slug: c.slug,
      name: c.name,
      icon: c.icon,
      tone: c.tone,
      count: by.get(c.id) ?? 0,
    }));
  }

  async home(userId: string, isSeller: boolean, now = new Date()): Promise<MarketplaceHomeDto> {
    const visible = listingVisibleWhere(userId);
    const [categories, featured, recent, sellers] = await Promise.all([
      this.categories(),
      this.prisma.listing.findMany({
        where: { ...visible, featuredUntil: { gt: now } },
        include: LISTING_CARD_INCLUDE,
        orderBy: [{ featuredUntil: 'desc' }, { id: 'asc' }],
        take: HOME_FEATURED,
      }),
      this.prisma.listing.findMany({
        where: visible,
        include: LISTING_CARD_INCLUDE,
        orderBy: [{ publishedAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }],
        take: HOME_RECENT,
      }),
      this.prisma.sellerProfile.findMany({
        where: {
          status: 'ACTIVE',
          listings: { some: { status: 'PUBLISHED' } },
          user: { status: 'ACTIVE', deletedAt: null, ...notBlockedWhere(userId) },
        },
        include: SELLER_INCLUDE,
        orderBy: [
          { ratingCount: 'desc' },
          { completedCount: 'desc' },
          { createdAt: 'asc' },
          { id: 'asc' },
        ],
        take: HOME_SELLERS,
      }),
    ]);
    return {
      isSeller,
      categories,
      featured: await this.views.cards(featured, userId, now),
      recent: await this.views.cards(recent, userId, now),
      popularSellers: await this.views.sellerCards(sellers),
    };
  }

  // ---- browse -------------------------------------------------------------------------------------------------

  private browseWhere(userId: string, q: ListingsQueryDto): Prisma.ListingWhereInput {
    const and: Prisma.ListingWhereInput[] = [];
    if (q.type) and.push({ type: q.type });
    if (q.categoryId) and.push({ categoryId: q.categoryId });
    if (q.sellerId) and.push({ sellerId: q.sellerId });
    if (q.remote) and.push({ workMode: 'REMOTE' });
    if (q.priced) and.push({ pricingType: { not: 'ON_REQUEST' } });
    if (q.minPrice !== undefined) and.push({ priceMinMinor: { gte: toMinor(q.minPrice)! } });
    if (q.maxPrice !== undefined) {
      and.push({ priceMinMinor: { lte: toMinor(q.maxPrice)! } });
    }
    for (const w of q.q ? words(q.q) : []) {
      and.push({
        OR: [
          { title: { contains: w, mode: 'insensitive' } },
          { description: { contains: w, mode: 'insensitive' } },
          { category: { name: { contains: w, mode: 'insensitive' } } },
          {
            seller: {
              user: {
                OR: [
                  { fullName: { contains: w, mode: 'insensitive' } },
                  { creativeProfile: { displayName: { contains: w, mode: 'insensitive' } } },
                ],
              },
            },
          },
        ],
      });
    }
    return { AND: [listingVisibleWhere(userId), ...and] };
  }

  async list(userId: string, q: ListingsQueryDto, now = new Date()) {
    const where = this.browseWhere(userId, q);
    const sort = q.sort ?? 'recommended';
    if (sort === 'recommended') return this.recommended(userId, q, where, now);
    const orderBy: Prisma.ListingOrderByWithRelationInput[] =
      sort === 'price_low'
        ? [{ priceMinMinor: { sort: 'asc', nulls: 'last' } }, { id: 'asc' }]
        : sort === 'price_high'
          ? [{ priceMinMinor: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }]
          : sort === 'rating'
            ? [
                { seller: { ratingAverage: { sort: 'desc', nulls: 'last' } } },
                { seller: { ratingCount: 'desc' } },
                { publishedAt: 'desc' },
                { id: 'asc' },
              ]
            : [{ publishedAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }];
    const [rows, total] = await Promise.all([
      this.prisma.listing.findMany({
        where,
        include: LISTING_CARD_INCLUDE,
        orderBy,
        ...toSkipTake(q),
      }),
      this.prisma.listing.count({ where }),
    ]);
    return { items: await this.views.cards(rows, userId, now), meta: pageMeta(q, total) };
  }

  /** Featured first, then sellers with better ratings, then the newest. */
  private async recommended(
    userId: string,
    q: ListingsQueryDto,
    where: Prisma.ListingWhereInput,
    now: Date,
  ) {
    const rows = await this.prisma.listing.findMany({
      where,
      include: LISTING_CARD_INCLUDE,
      orderBy: [{ publishedAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }],
      take: RECOMMENDED_CANDIDATES,
    });
    const score = (r: ListingCardRow) => {
      const featured = r.featuredUntil !== null && r.featuredUntil > now ? 1000 : 0;
      const rating =
        (r.seller.ratingAverage ?? 0) * SELLER_RATING_WEIGHT +
        Math.min(r.seller.ratingCount, 20) / 10;
      const ageDays = r.publishedAt ? (now.getTime() - r.publishedAt.getTime()) / DAY_MS : 365;
      return featured + rating * 10 - Math.min(ageDays, 365) / 10;
    };
    rows.sort((a, b) => score(b) - score(a) || a.id.localeCompare(b.id));
    const { skip, take } = toSkipTake(q);
    const total =
      rows.length >= RECOMMENDED_CANDIDATES
        ? await this.prisma.listing.count({ where })
        : rows.length;
    return {
      items: await this.views.cards(rows.slice(skip, skip + take), userId, now),
      meta: pageMeta(q, total),
    };
  }

  // ---- detail -------------------------------------------------------------------------------------------------

  /**
   * A listing as the viewer may see it: live listings to everyone (subject to blocks), any status to the owner.
   * Anything else answers "not found", the same as a listing that does not exist.
   */
  async detail(viewerId: string, id: string, now = new Date()): Promise<ListingDto> {
    const row = await this.prisma.listing.findFirst({
      where: { id, OR: [listingVisibleWhere(viewerId), { seller: { userId: viewerId } }] },
      include: DETAIL_INCLUDE,
    });
    if (!row) throw ApiException.notFound('We could not find that listing.');
    return this.toDetail(row, viewerId, now);
  }

  async toDetail(row: DetailRow, viewerId: string, now: Date): Promise<ListingDto> {
    const [card] = await this.views.cards([row], viewerId, now);
    const isOwner = row.seller.userId === viewerId;
    const mediaIds = row.media.map((m) => m.mediaId);
    const mediaViews = await this.media.viewMany(mediaIds);
    const reviews = await this.reviewList(row.id, 1, DETAIL_REVIEWS);
    const open = isOwner
      ? null
      : await this.prisma.enquiry.findFirst({
          where: { listingId: row.id, buyerId: viewerId, status: { not: 'CLOSED' } },
          select: { id: true },
        });
    const portfolio = [];
    for (const p of row.portfolio) {
      const pr = p.project;
      // Examples must be showable: a published, public project that is not hidden. The owner always sees their picks.
      const showable =
        pr.deletedAt === null &&
        pr.hiddenAt === null &&
        pr.status === 'PUBLISHED' &&
        pr.visibility === 'PUBLIC';
      if (!showable && !isOwner) continue;
      portfolio.push({
        id: pr.id,
        title: pr.title,
        coverUrl: await this.media.imageUrl(pr.media[0]?.mediaId ?? null, 600),
        category: pr.category.toString().toLowerCase().replace('_', ' '),
      });
    }
    const location =
      row.workMode === 'REMOTE'
        ? 'Remote'
        : row.workMode === 'HYBRID'
          ? `Hybrid${row.locationText ? ` · ${row.locationText}` : ''}`
          : (row.locationText ?? 'On site');
    return {
      ...card!,
      description: row.description,
      includedItems: (row.includedItems as string[]) ?? [],
      deliveryDays: row.deliveryDays,
      workMode: row.workMode,
      locationText: row.locationText,
      locationLabel: location,
      audienceText: row.audienceText,
      priceMin: fromMinor(row.priceMinMinor),
      priceMax: fromMinor(row.priceMaxMinor),
      categoryId: row.categoryId,
      media: mediaIds.flatMap((id) => {
        const v = mediaViews.get(id);
        return v ? [{ id, kind: v.kind, url: v.variants?.['1200'] ?? v.url }] : [];
      }),
      portfolio,
      reviews: reviews.items,
      rejectionReason: isOwner ? row.rejectionReason : null,
      isOwner,
      openEnquiryId: open?.id ?? null,
      requestNote: REQUEST_NOTE,
      shareUrl: this.shareUrl(row.id),
    };
  }

  /** One distinct viewer per listing per day; the owner's own views are not counted. */
  async recordView(viewerId: string, listingId: string): Promise<void> {
    const listing = await this.prisma.listing.findFirst({
      where: {
        AND: [
          { id: listingId },
          listingVisibleWhere(viewerId),
          { seller: { userId: { not: viewerId } } },
        ],
      },
      select: { id: true },
    });
    if (!listing) return;
    const today = new Date(new Date().toISOString().slice(0, 10) + 'T00:00:00.000Z');
    await this.prisma.listingView.createMany({
      data: [{ listingId, viewerId, viewedOn: today }],
      skipDuplicates: true,
    });
  }

  // ---- reviews ------------------------------------------------------------------------------------------------

  async reviewList(listingId: string, page: number, limit: number) {
    const where = { listingId, status: 'VISIBLE' as const };
    const [rows, total] = await Promise.all([
      this.prisma.listingReview.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        skip: (page - 1) * limit,
        take: limit,
        include: {
          reviewer: {
            select: {
              fullName: true,
              creativeProfile: { select: { displayName: true, avatarMediaId: true } },
            },
          },
        },
      }),
      this.prisma.listingReview.count({ where }),
    ]);
    const items: ListingReviewDto[] = await Promise.all(
      rows.map(async (r) => ({
        id: r.id,
        rating: r.rating,
        body: r.body,
        reviewerName: r.reviewer.creativeProfile?.displayName ?? r.reviewer.fullName,
        reviewerAvatarUrl: await this.media.imageUrl(
          r.reviewer.creativeProfile?.avatarMediaId ?? null,
          200,
        ),
        createdAt: r.createdAt,
      })),
    );
    return { items, total };
  }

  async reviews(viewerId: string, listingId: string, q: { page: number; limit: number }) {
    const ok = await this.prisma.listing.count({
      where: {
        id: listingId,
        OR: [listingVisibleWhere(viewerId), { seller: { userId: viewerId } }],
      },
    });
    if (!ok) throw ApiException.notFound('We could not find that listing.');
    const { items, total } = await this.reviewList(listingId, q.page, q.limit);
    return { items, meta: pageMeta(q, total) };
  }

  // ---- sellers ------------------------------------------------------------------------------------------------

  async sellers(userId: string, q: SellersQueryDto) {
    const and: Prisma.SellerProfileWhereInput[] = [];
    for (const w of q.q ? words(q.q) : []) {
      and.push({
        user: {
          OR: [
            { fullName: { contains: w, mode: 'insensitive' } },
            { creativeProfile: { displayName: { contains: w, mode: 'insensitive' } } },
            { creativeProfile: { headline: { contains: w, mode: 'insensitive' } } },
          ],
        },
      });
    }
    const where: Prisma.SellerProfileWhereInput = {
      status: 'ACTIVE',
      listings: { some: { status: 'PUBLISHED' } },
      user: { status: 'ACTIVE', deletedAt: null, ...notBlockedWhere(userId) },
      AND: and,
    };
    const orderBy: Prisma.SellerProfileOrderByWithRelationInput[] =
      q.sort === 'rating'
        ? [
            { ratingAverage: { sort: 'desc', nulls: 'last' } },
            { ratingCount: 'desc' },
            { id: 'asc' },
          ]
        : q.sort === 'newest'
          ? [{ createdAt: 'desc' }, { id: 'asc' }]
          : [
              { ratingCount: 'desc' },
              { completedCount: 'desc' },
              { createdAt: 'asc' },
              { id: 'asc' },
            ];
    const [rows, total] = await Promise.all([
      this.prisma.sellerProfile.findMany({
        where,
        include: SELLER_INCLUDE,
        orderBy,
        ...toSkipTake(q),
      }),
      this.prisma.sellerProfile.count({ where }),
    ]);
    return { items: await this.views.sellerCards(rows), meta: pageMeta(q, total) };
  }

  /**
   * A seller's public page. Trust lines are written only from real data: today that is `verificationStatus`
   * (set by P2-M6); nothing is shown otherwise (DEC-123).
   */
  async seller(viewerId: string, sellerId: string, now = new Date()): Promise<SellerProfileDto> {
    const row = await this.prisma.sellerProfile.findFirst({
      where: {
        id: sellerId,
        OR: [
          {
            status: 'ACTIVE',
            user: { status: 'ACTIVE', deletedAt: null, ...notBlockedWhere(viewerId) },
          },
          { userId: viewerId },
        ],
      },
      include: {
        user: {
          select: {
            fullName: true,
            createdAt: true,
            creativeProfile: {
              select: {
                displayName: true,
                handle: true,
                headline: true,
                bio: true,
                avatarMediaId: true,
                onboardingCompletedAt: true,
                county: { select: { name: true } },
                locationVisibility: true,
              },
            },
          },
        },
      },
    });
    if (!row) throw ApiException.notFound('We could not find that seller.');
    const listings = await this.prisma.listing.findMany({
      where: { sellerId, ...listingVisibleWhere(viewerId) },
      include: LISTING_CARD_INCLUDE,
      orderBy: [{ publishedAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }],
      take: 50,
    });
    const card = await this.views.sellerCard(row, listings.length);
    const cp = row.user.creativeProfile;
    const trustLines: string[] = [];
    if (row.verificationStatus === 'VERIFIED') trustLines.push('Identity verified by Atarah');
    return {
      ...card,
      userId: row.userId,
      medianReplyMinutes: row.medianReplyMinutes,
      replyLabel: replyLabel(row.medianReplyMinutes),
      trustLines,
      bio: cp?.bio ?? null,
      // The county is shown only where the member's own location visibility allows members to see it.
      location: cp?.county && cp.locationVisibility !== 'PRIVATE' ? cp.county.name : null,
      memberSince: row.createdAt,
      listings: await this.views.cards(listings, viewerId, now),
      hasProfile: !!cp?.handle && cp.onboardingCompletedAt !== null,
    };
  }

  // ---- reporting ----------------------------------------------------------------------------------------------

  async report(userId: string, listingId: string, dto: ReportListingDto): Promise<void> {
    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, ...listingVisibleWhere(userId) },
      select: { id: true, seller: { select: { userId: true } } },
    });
    if (!listing) throw ApiException.notFound('We could not find that listing.');
    if (listing.seller.userId === userId) {
      throw ApiException.invalidState('You cannot report your own listing.');
    }
    await this.prisma.listingReport.upsert({
      where: { listingId_reporterId: { listingId, reporterId: userId } },
      create: { listingId, reporterId: userId, reason: dto.reason, note: dto.note?.trim() || null },
      // Reporting again only refreshes the note; it never reopens a decision.
      update: { note: dto.note?.trim() || null },
    });
  }

  /** Cards for global search, in the order given, applying the same visibility. */
  async searchCards(viewerId: string, ids: string[]): Promise<ListingCardDto[]> {
    if (ids.length === 0) return [];
    const rows = await this.prisma.listing.findMany({
      where: { id: { in: ids }, ...listingVisibleWhere(viewerId) },
      include: LISTING_CARD_INCLUDE,
    });
    const order = new Map(ids.map((id, i) => [id, i]));
    rows.sort((a, b) => order.get(a.id)! - order.get(b.id)!);
    return this.views.cards(rows, viewerId);
  }
}
