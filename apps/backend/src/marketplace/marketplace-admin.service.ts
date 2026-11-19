import { Injectable } from '@nestjs/common';
import { type ListingStatus, Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type AdminMarketplaceCategoryDto,
  type AdminListingDto,
  type AdminListingReportDto,
  type AdminListingsQueryDto,
  type AdminListingReportsQueryDto,
  type AdminReviewDto,
  type AdminReviewsQueryDto,
  type AdminSellerDto,
  type AdminSellersQueryDto,
  type MarketplaceCategoryFieldsDto,
  type ResolveReportDto,
  type UpdateMarketplaceCategoryDto,
} from './marketplace.dto';
import { assertTransition } from './marketplace-logic';
import { MarketplaceSupportService } from './marketplace-support.service';
import { LISTING_CARD_INCLUDE, MarketplaceViewsService } from './marketplace-views.service';

export interface Actor {
  userId: string;
  ip?: string | undefined;
  requestId?: string | undefined;
}

const SELLER_ADMIN_INCLUDE = {
  user: {
    select: {
      email: true,
      fullName: true,
      creativeProfile: {
        select: { displayName: true, handle: true, headline: true, avatarMediaId: true },
      },
    },
  },
} satisfies Prisma.SellerProfileInclude;

const REPORT_INCLUDE = {
  listing: {
    select: {
      title: true,
      status: true,
      seller: { select: { user: { select: { fullName: true } } } },
    },
  },
  reporter: { select: { fullName: true } },
} satisfies Prisma.ListingReportInclude;

const reportDto = (
  r: Prisma.ListingReportGetPayload<{ include: typeof REPORT_INCLUDE }>,
): AdminListingReportDto => ({
  id: r.id,
  listingId: r.listingId,
  listingTitle: r.listing.title,
  listingStatus: r.listing.status,
  sellerName: r.listing.seller.user.fullName,
  reporterName: r.reporter.fullName,
  reason: r.reason,
  note: r.note,
  status: r.status,
  resolution: r.resolution,
  createdAt: r.createdAt,
});

const REVIEW_INCLUDE = {
  listing: { select: { title: true } },
  reviewer: { select: { fullName: true } },
} satisfies Prisma.ListingReviewInclude;

const reviewDto = (
  r: Prisma.ListingReviewGetPayload<{ include: typeof REVIEW_INCLUDE }>,
): AdminReviewDto => ({
  id: r.id,
  listingId: r.listingId,
  listingTitle: r.listing.title,
  reviewerName: r.reviewer.fullName,
  rating: r.rating,
  body: r.body,
  status: r.status,
  hiddenReason: r.hiddenReason,
  createdAt: r.createdAt,
});

const SELLER_SUSPENSION_PREFIX = 'Seller suspended: ';

const slugify = (name: string): string =>
  name
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 50) || 'category';

/** Staff operations on the marketplace. Each action is audited with the actor and the reason. */
@Injectable()
export class MarketplaceAdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly views: MarketplaceViewsService,
    private readonly media: MediaService,
    private readonly support: MarketplaceSupportService,
  ) {}

  private record(
    actor: Actor,
    action: string,
    entityType: string,
    entityId: string,
    before: unknown,
    after: unknown,
    tx?: Prisma.TransactionClient,
  ) {
    return this.audit.record(
      {
        actorType: 'ADMIN',
        actorId: actor.userId,
        action,
        entityType,
        entityId,
        before,
        after,
        ip: actor.ip ?? null,
        requestId: actor.requestId ?? null,
      },
      tx,
    );
  }

  // ---- sellers ------------------------------------------------------------------------------------------------

  private async sellerDto(
    r: Prisma.SellerProfileGetPayload<{ include: typeof SELLER_ADMIN_INCLUDE }>,
  ): Promise<AdminSellerDto> {
    const [live, review, reports] = await Promise.all([
      this.prisma.listing.count({ where: { sellerId: r.id, status: 'PUBLISHED' } }),
      this.prisma.listing.count({ where: { sellerId: r.id, status: 'UNDER_REVIEW' } }),
      this.prisma.listingReport.count({ where: { listing: { sellerId: r.id }, status: 'OPEN' } }),
    ]);
    const card = await this.views.sellerCard(r, live);
    return {
      ...card,
      userId: r.userId,
      email: r.user.email ?? '',
      status: r.status,
      verificationStatus: r.verificationStatus,
      canPublishDirectly: r.canPublishDirectly,
      termsVersion: r.termsVersion,
      termsAcceptedAt: r.termsAcceptedAt,
      suspendedReason: r.suspendedReason,
      liveListings: live,
      underReviewListings: review,
      openReports: reports,
    };
  }

  async sellers(q: AdminSellersQueryDto) {
    const and: Prisma.SellerProfileWhereInput[] = [];
    const term = q.q?.trim();
    if (term) {
      and.push({
        user: {
          OR: [
            { fullName: { contains: term, mode: 'insensitive' } },
            { email: { contains: term, mode: 'insensitive' } },
            { creativeProfile: { displayName: { contains: term, mode: 'insensitive' } } },
            { creativeProfile: { handle: { contains: term, mode: 'insensitive' } } },
          ],
        },
      });
    }
    if (q.status) and.push({ status: q.status });
    const where: Prisma.SellerProfileWhereInput = { AND: and };
    const [rows, total] = await Promise.all([
      this.prisma.sellerProfile.findMany({
        where,
        include: SELLER_ADMIN_INCLUDE,
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.sellerProfile.count({ where }),
    ]);
    return {
      items: await Promise.all(rows.map((r) => this.sellerDto(r))),
      meta: pageMeta(q, total),
    };
  }

  private async sellerRow(id: string) {
    const r = await this.prisma.sellerProfile.findUnique({
      where: { id },
      include: SELLER_ADMIN_INCLUDE,
    });
    if (!r) throw ApiException.notFound('We could not find that seller.');
    return r;
  }

  async seller(id: string) {
    return this.sellerDto(await this.sellerRow(id));
  }

  /** Suspends the seller: they cannot create, submit or reply, and their live listings are suspended with them. */
  async suspendSeller(actor: Actor, id: string, reason: string) {
    const r = await this.sellerRow(id);
    if (r.status === 'SUSPENDED')
      throw ApiException.invalidState('This seller is already suspended.');
    await this.prisma.transaction(async (tx) => {
      await tx.sellerProfile.update({
        where: { id },
        data: { status: 'SUSPENDED', suspendedReason: reason, suspendedAt: new Date() },
      });
      await tx.listing.updateMany({
        where: { sellerId: id, status: 'PUBLISHED' },
        data: { status: 'SUSPENDED', suspendedReason: `${SELLER_SUSPENSION_PREFIX}${reason}` },
      });
      await this.record(
        actor,
        'seller.suspend',
        'seller_profile',
        id,
        { status: r.status },
        { status: 'SUSPENDED', reason },
        tx,
      );
    });
    await this.support.tell(r.userId, {
      type: 'marketplace.seller.suspended',
      title: 'Your seller account is suspended',
      body: 'Your listings are hidden for now. Contact support to find out more.',
    });
    return this.seller(id);
  }

  async reinstateSeller(actor: Actor, id: string, reason: string) {
    const r = await this.sellerRow(id);
    if (r.status !== 'SUSPENDED') throw ApiException.invalidState('This seller is not suspended.');
    await this.prisma.transaction(async (tx) => {
      await tx.sellerProfile.update({
        where: { id },
        data: { status: 'ACTIVE', suspendedReason: null, suspendedAt: null },
      });
      // Only the listings that were suspended together with the seller come back.
      await tx.listing.updateMany({
        where: {
          sellerId: id,
          status: 'SUSPENDED',
          suspendedReason: { startsWith: SELLER_SUSPENSION_PREFIX },
        },
        data: { status: 'PUBLISHED', suspendedReason: null },
      });
      await this.record(
        actor,
        'seller.reinstate',
        'seller_profile',
        id,
        { status: r.status },
        { status: 'ACTIVE', reason },
        tx,
      );
    });
    await this.support.tell(r.userId, {
      type: 'marketplace.seller.reinstated',
      title: 'Your seller account is active again',
      body: 'Your listings are back on the marketplace.',
    });
    return this.seller(id);
  }

  async setDirectPublish(actor: Actor, id: string, canPublishDirectly: boolean) {
    const r = await this.sellerRow(id);
    await this.prisma.transaction(async (tx) => {
      await tx.sellerProfile.update({ where: { id }, data: { canPublishDirectly } });
      await this.record(
        actor,
        'seller.direct_publish',
        'seller_profile',
        id,
        { canPublishDirectly: r.canPublishDirectly },
        { canPublishDirectly },
        tx,
      );
    });
    return this.seller(id);
  }

  // ---- listings -----------------------------------------------------------------------------------------------

  private async listingDtos(
    rows: Array<Prisma.ListingGetPayload<{ include: typeof LISTING_CARD_INCLUDE }>>,
    viewerId: string,
  ) {
    const cards = await this.views.cards(rows, viewerId);
    const ids = rows.map((r) => r.id);
    const [reports, approved, mediaRows] = await Promise.all([
      this.prisma.listingReport.groupBy({
        by: ['listingId'],
        where: { listingId: { in: ids }, status: 'OPEN' },
        _count: { _all: true },
      }),
      this.prisma.listing.groupBy({
        by: ['sellerId'],
        where: { sellerId: { in: rows.map((r) => r.sellerId) }, publishedAt: { not: null } },
        _count: { _all: true },
      }),
      this.prisma.listingMedia.findMany({
        where: { listingId: { in: ids } },
        orderBy: { sortOrder: 'asc' },
        select: { listingId: true, mediaId: true },
      }),
    ]);
    const mediaViews = await this.media.viewMany(mediaRows.map((m) => m.mediaId));
    const reportBy = new Map(reports.map((r) => [r.listingId, r._count._all]));
    const approvedBy = new Map(approved.map((r) => [r.sellerId, r._count._all]));
    return cards.map((card, i): AdminListingDto => {
      const r = rows[i]!;
      return {
        ...card,
        description: r.description,
        includedItems: (r.includedItems as string[]) ?? [],
        media: mediaRows
          .filter((m) => m.listingId === r.id)
          .flatMap((m) => {
            const v = mediaViews.get(m.mediaId);
            return v ? [{ id: m.mediaId, kind: v.kind, url: v.variants?.['1200'] ?? v.url }] : [];
          }),
        rejectionReason: r.rejectionReason,
        suspendedReason: r.suspendedReason,
        featuredUntil: r.featuredUntil,
        publishedAt: r.publishedAt,
        createdAt: r.createdAt,
        openReports: reportBy.get(r.id) ?? 0,
        sellerStatus: r.seller.status,
        sellerApprovedBefore: approvedBy.get(r.sellerId) ?? 0,
      };
    });
  }

  async listings(viewerId: string, q: AdminListingsQueryDto) {
    const and: Prisma.ListingWhereInput[] = [];
    if (q.status) and.push({ status: q.status });
    if (q.reported) and.push({ reports: { some: { status: 'OPEN' } } });
    const term = q.q?.trim();
    if (term) {
      and.push({
        OR: [
          { title: { contains: term, mode: 'insensitive' } },
          { seller: { user: { fullName: { contains: term, mode: 'insensitive' } } } },
          { seller: { user: { email: { contains: term, mode: 'insensitive' } } } },
        ],
      });
    }
    const where: Prisma.ListingWhereInput = { AND: and };
    const [rows, total] = await Promise.all([
      this.prisma.listing.findMany({
        where,
        include: LISTING_CARD_INCLUDE,
        // The review queue works oldest first; everything else newest first.
        orderBy:
          q.status === 'UNDER_REVIEW'
            ? [{ updatedAt: 'asc' }, { id: 'asc' }]
            : [{ updatedAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.listing.count({ where }),
    ]);
    return { items: await this.listingDtos(rows, viewerId), meta: pageMeta(q, total) };
  }

  async listing(viewerId: string, id: string) {
    const row = await this.prisma.listing.findUnique({
      where: { id },
      include: LISTING_CARD_INCLUDE,
    });
    if (!row) throw ApiException.notFound('We could not find that listing.');
    return (await this.listingDtos([row], viewerId))[0]!;
  }

  private async move(
    actor: Actor,
    id: string,
    to: ListingStatus,
    data: Prisma.ListingUpdateInput,
    action: string,
    reason?: string,
  ) {
    const row = await this.prisma.listing.findUnique({
      where: { id },
      include: { seller: { select: { userId: true } } },
    });
    if (!row) throw ApiException.notFound('We could not find that listing.');
    assertTransition(row.status, to);
    await this.prisma.transaction(async (tx) => {
      await tx.listing.update({ where: { id }, data: { status: to, ...data } });
      await this.record(
        actor,
        action,
        'listing',
        id,
        { status: row.status },
        { status: to, ...(reason ? { reason } : {}) },
        tx,
      );
    });
    return row;
  }

  async approve(actor: Actor, viewerId: string, id: string) {
    // Only a listing waiting for review is approved. (A seller who publishes directly never needs this.)
    const current = await this.prisma.listing.findUnique({
      where: { id },
      select: { status: true },
    });
    if (current && current.status !== 'UNDER_REVIEW') {
      throw ApiException.invalidState('Only a listing that is under review can be approved.', {
        status: current.status,
      });
    }
    const row = await this.move(
      actor,
      id,
      'PUBLISHED',
      { rejectionReason: null, suspendedReason: null, publishedAt: new Date() },
      'listing.approve',
    );
    {
      await this.support.tell(row.seller.userId, {
        type: 'marketplace.listing.approved',
        title: 'Your listing is live',
        body: `${row.title} is now on the marketplace.`,
        deepLink: `/marketplace/listings/${id}`,
      });
    }
    return this.listing(viewerId, id);
  }

  async reject(actor: Actor, viewerId: string, id: string, reason: string) {
    const row = await this.move(
      actor,
      id,
      'REJECTED',
      { rejectionReason: reason },
      'listing.reject',
      reason,
    );
    await this.support.tell(row.seller.userId, {
      type: 'marketplace.listing.rejected',
      title: 'Changes needed on your listing',
      body: `${row.title} was not published yet: ${reason}`,
      deepLink: `/marketplace/mine/${id}`,
    });
    return this.listing(viewerId, id);
  }

  async suspend(actor: Actor, viewerId: string, id: string, reason: string) {
    const row = await this.move(
      actor,
      id,
      'SUSPENDED',
      { suspendedReason: reason },
      'listing.suspend',
      reason,
    );
    await this.support.tell(row.seller.userId, {
      type: 'marketplace.listing.suspended',
      title: 'Your listing was taken down',
      body: `${row.title} is hidden: ${reason}`,
      deepLink: `/marketplace/mine/${id}`,
    });
    return this.listing(viewerId, id);
  }

  async reinstate(actor: Actor, viewerId: string, id: string, reason: string) {
    const row = await this.move(
      actor,
      id,
      'PUBLISHED',
      { suspendedReason: null },
      'listing.reinstate',
      reason,
    );
    await this.support.tell(row.seller.userId, {
      type: 'marketplace.listing.approved',
      title: 'Your listing is live again',
      body: `${row.title} is back on the marketplace.`,
      deepLink: `/marketplace/listings/${id}`,
    });
    return this.listing(viewerId, id);
  }

  async feature(actor: Actor, viewerId: string, id: string, until: Date | null) {
    const row = await this.prisma.listing.findUnique({ where: { id } });
    if (!row) throw ApiException.notFound('We could not find that listing.');
    if (until && row.status !== 'PUBLISHED') {
      throw ApiException.invalidState('Only a live listing can be featured.');
    }
    if (until && until <= new Date()) {
      throw ApiException.validation('Pick a date in the future.', { field: 'until' });
    }
    await this.prisma.transaction(async (tx) => {
      await tx.listing.update({ where: { id }, data: { featuredUntil: until } });
      await this.record(
        actor,
        until ? 'listing.feature' : 'listing.unfeature',
        'listing',
        id,
        { featuredUntil: row.featuredUntil },
        { featuredUntil: until },
        tx,
      );
    });
    return this.listing(viewerId, id);
  }

  // ---- reports ------------------------------------------------------------------------------------------------

  async reports(q: AdminListingReportsQueryDto) {
    const where: Prisma.ListingReportWhereInput = { status: q.status ?? 'OPEN' };
    const [rows, total] = await Promise.all([
      this.prisma.listingReport.findMany({
        where,
        orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
        include: REPORT_INCLUDE,
        ...toSkipTake(q),
      }),
      this.prisma.listingReport.count({ where }),
    ]);
    return { items: rows.map(reportDto), meta: pageMeta(q, total) };
  }

  async report(id: string): Promise<AdminListingReportDto> {
    const r = await this.prisma.listingReport.findUnique({
      where: { id },
      include: REPORT_INCLUDE,
    });
    if (!r) throw ApiException.notFound('We could not find that report.');
    return reportDto(r);
  }

  async resolveReport(actor: Actor, id: string, dto: ResolveReportDto) {
    const r = await this.prisma.listingReport.findUnique({
      where: { id },
      include: {
        listing: {
          select: { id: true, status: true, title: true, seller: { select: { userId: true } } },
        },
      },
    });
    if (!r) throw ApiException.notFound('We could not find that report.');
    if (r.status !== 'OPEN') throw ApiException.invalidState('This report is already resolved.');
    const suspend = dto.action === 'SUSPEND_LISTING';
    if (suspend && r.listing.status !== 'SUSPENDED')
      assertTransition(r.listing.status, 'SUSPENDED');
    await this.prisma.transaction(async (tx) => {
      const now = new Date();
      if (suspend) {
        if (r.listing.status !== 'SUSPENDED') {
          await tx.listing.update({
            where: { id: r.listingId },
            data: { status: 'SUSPENDED', suspendedReason: dto.note },
          });
        }
        // Every open report on that listing is answered by the same decision.
        await tx.listingReport.updateMany({
          where: { listingId: r.listingId, status: 'OPEN' },
          data: {
            status: 'RESOLVED',
            resolution: dto.note,
            resolvedById: actor.userId,
            resolvedAt: now,
          },
        });
      } else {
        await tx.listingReport.update({
          where: { id },
          data: {
            status: 'DISMISSED',
            resolution: dto.note,
            resolvedById: actor.userId,
            resolvedAt: now,
          },
        });
      }
      await this.record(
        actor,
        `listing.report.${suspend ? 'suspend' : 'dismiss'}`,
        'listing_report',
        id,
        { status: 'OPEN' },
        { action: dto.action, note: dto.note },
        tx,
      );
    });
    if (suspend) {
      await this.support.tell(r.listing.seller.userId, {
        type: 'marketplace.listing.suspended',
        title: 'Your listing was taken down',
        body: `${r.listing.title} is hidden: ${dto.note}`,
        deepLink: `/marketplace/mine/${r.listingId}`,
      });
    }
    return this.report(id);
  }

  // ---- categories ---------------------------------------------------------------------------------------------

  async categories(): Promise<AdminMarketplaceCategoryDto[]> {
    const [cats, counts] = await Promise.all([
      this.prisma.marketplaceCategory.findMany({
        orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      }),
      this.prisma.listing.groupBy({
        by: ['categoryId'],
        where: { status: 'PUBLISHED' },
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
      sortOrder: c.sortOrder,
      isActive: c.isActive,
    }));
  }

  async createCategory(actor: Actor, dto: MarketplaceCategoryFieldsDto): Promise<AdminMarketplaceCategoryDto> {
    const base = slugify(dto.name);
    let slug = base;
    for (let i = 2; await this.prisma.marketplaceCategory.count({ where: { slug } }); i++) {
      slug = `${base}-${i}`;
    }
    const max = await this.prisma.marketplaceCategory.aggregate({ _max: { sortOrder: true } });
    const row = await this.prisma.transaction(async (tx) => {
      const c = await tx.marketplaceCategory.create({
        data: {
          slug,
          name: dto.name.trim(),
          icon: dto.icon.trim(),
          tone: dto.tone,
          sortOrder: dto.sortOrder ?? (max._max.sortOrder ?? 0) + 1,
          isActive: dto.isActive ?? true,
        },
      });
      await this.record(
        actor,
        'marketplace_category.create',
        'marketplace_category',
        c.id,
        null,
        { name: c.name },
        tx,
      );
      return c;
    });
    return {
      id: row.id,
      slug: row.slug,
      name: row.name,
      icon: row.icon,
      tone: row.tone,
      count: 0,
      sortOrder: row.sortOrder,
      isActive: row.isActive,
    };
  }

  async updateCategory(
    actor: Actor,
    id: string,
    dto: UpdateMarketplaceCategoryDto,
  ): Promise<AdminMarketplaceCategoryDto> {
    const before = await this.prisma.marketplaceCategory.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('We could not find that category.');
    if (dto.isActive === false) {
      const live = await this.prisma.listing.count({
        where: { categoryId: id, status: { in: ['PUBLISHED', 'UNDER_REVIEW'] } },
      });
      if (live > 0) {
        throw ApiException.invalidState(
          'Move or archive the live listings in this category before hiding it.',
          { liveListings: live },
        );
      }
    }
    await this.prisma.transaction(async (tx) => {
      await tx.marketplaceCategory.update({
        where: { id },
        data: {
          ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
          ...(dto.icon !== undefined ? { icon: dto.icon.trim() } : {}),
          ...(dto.tone !== undefined ? { tone: dto.tone } : {}),
          ...(dto.sortOrder !== undefined ? { sortOrder: dto.sortOrder } : {}),
          ...(dto.isActive !== undefined ? { isActive: dto.isActive } : {}),
        },
      });
      await this.record(
        actor,
        'marketplace_category.update',
        'marketplace_category',
        id,
        before,
        dto,
        tx,
      );
    });
    return (await this.categories()).find((c) => c.id === id)!;
  }

  // ---- reviews ------------------------------------------------------------------------------------------------

  async reviews(q: AdminReviewsQueryDto) {
    const where: Prisma.ListingReviewWhereInput = q.status ? { status: q.status } : {};
    const [rows, total] = await Promise.all([
      this.prisma.listingReview.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        include: REVIEW_INCLUDE,
        ...toSkipTake(q),
      }),
      this.prisma.listingReview.count({ where }),
    ]);
    return { items: rows.map(reviewDto), meta: pageMeta(q, total) };
  }

  private async setReviewStatus(
    actor: Actor,
    id: string,
    status: 'VISIBLE' | 'HIDDEN',
    reason: string,
  ) {
    const r = await this.prisma.listingReview.findUnique({
      where: { id },
      include: { listing: { select: { sellerId: true } } },
    });
    if (!r) throw ApiException.notFound('We could not find that review.');
    if (r.status === status)
      throw ApiException.invalidState(`This review is already ${status.toLowerCase()}.`);
    await this.prisma.transaction(async (tx) => {
      await tx.listingReview.update({
        where: { id },
        data:
          status === 'HIDDEN'
            ? { status, hiddenReason: reason, hiddenById: actor.userId }
            : { status, hiddenReason: null, hiddenById: null },
      });
      await this.record(
        actor,
        status === 'HIDDEN' ? 'listing_review.hide' : 'listing_review.restore',
        'listing_review',
        id,
        { status: r.status },
        { status, reason },
        tx,
      );
    });
    await this.support.refreshSellerStats(r.listing.sellerId);
    const fresh = await this.prisma.listingReview.findUniqueOrThrow({
      where: { id },
      include: REVIEW_INCLUDE,
    });
    return reviewDto(fresh);
  }

  hideReview(actor: Actor, id: string, reason: string) {
    return this.setReviewStatus(actor, id, 'HIDDEN', reason);
  }

  restoreReview(actor: Actor, id: string, reason: string) {
    return this.setReviewStatus(actor, id, 'VISIBLE', reason);
  }
}
