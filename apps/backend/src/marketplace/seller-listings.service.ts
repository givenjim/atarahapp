import { Injectable } from '@nestjs/common';
import { type Listing, Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type CreateListingDto,
  type ListingFieldsDto,
  type MyListingDto,
  type MyListingsDto,
  type SubmitResultDto,
} from './marketplace.dto';
import {
  assertTransition,
  checkPricing,
  cleanList,
  cleanText,
  MAX_LISTING_MEDIA,
  MAX_LISTING_PROJECTS,
  MAX_LISTINGS_PER_SELLER,
  MIN_TITLE,
  missingForSubmit,
  OWNER_EDITABLE,
  SELLER_TERMS,
  submitTarget,
} from './marketplace-logic';
import { LISTING_CARD_INCLUDE, MarketplaceViewsService } from './marketplace-views.service';
import { DETAIL_INCLUDE, type DetailRow, MarketplaceService } from './marketplace.service';
import { MarketplaceSupportService } from './marketplace-support.service';

const DAY_MS = 86_400_000;
/** Fields whose change on a live listing sends it back for a second look (unless the seller publishes directly). */
const MATERIAL: ReadonlyArray<keyof ListingFieldsDto> = [
  'type',
  'title',
  'categoryId',
  'description',
  'mediaIds',
];

@Injectable()
export class SellerListingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly settings: PlatformSettingsService,
    private readonly market: MarketplaceService,
    private readonly views: MarketplaceViewsService,
    private readonly support: MarketplaceSupportService,
  ) {}

  // ---- becoming a seller --------------------------------------------------------------------------------------

  /**
   * The member's seller profile. A member who is not a seller yet becomes one here, in one transaction, when they
   * have accepted the seller terms: the profile is created and the SELLER role granted (audited). A suspended
   * seller, or one whose role staff revoked, is refused.
   */
  async ensureSeller(
    userId: string,
    terms: { acceptTerms?: boolean; termsVersion?: string },
  ): Promise<{ id: string; created: boolean }> {
    const existing = await this.prisma.sellerProfile.findUnique({ where: { userId } });
    const role = await this.prisma.userRole.findFirst({
      where: { userId, revokedAt: null, role: { key: 'SELLER' } },
      select: { id: true },
    });
    if (existing) {
      if (existing.status === 'SUSPENDED') {
        throw ApiException.forbidden(
          'Your seller account is suspended. Contact support if you think this is a mistake.',
        );
      }
      if (!role) {
        throw ApiException.forbidden('Your seller access was removed. Contact support for help.');
      }
      return { id: existing.id, created: false };
    }
    if (terms.acceptTerms !== true) {
      throw ApiException.validation('Accept the seller terms to start selling.', {
        field: 'acceptTerms',
        code: 'SELLER_TERMS_REQUIRED',
      });
    }
    const roleRow = await this.prisma.role.findUniqueOrThrow({ where: { key: 'SELLER' } });
    const created = await this.prisma.transaction(async (tx) => {
      const profile = await tx.sellerProfile.create({
        data: {
          userId,
          termsVersion: terms.termsVersion?.trim() || SELLER_TERMS.version,
          termsAcceptedAt: new Date(),
        },
      });
      if (!role) {
        await tx.userRole.create({
          data: { userId, roleId: roleRow.id, grantedById: null },
        });
      }
      await this.audit.record(
        {
          actorType: 'USER',
          actorId: userId,
          action: 'seller.become',
          entityType: 'seller_profile',
          entityId: profile.id,
          after: { termsVersion: profile.termsVersion, termsAreDraft: SELLER_TERMS.isDraft },
        },
        tx,
      );
      return profile;
    });
    return { id: created.id, created: true };
  }

  async terms() {
    return SELLER_TERMS;
  }

  // ---- own listings -------------------------------------------------------------------------------------------

  private async sellerOf(userId: string) {
    const s = await this.prisma.sellerProfile.findUnique({ where: { userId } });
    if (!s) throw ApiException.notFound('You are not a seller yet.');
    if (s.status === 'SUSPENDED') {
      throw ApiException.forbidden('Your seller account is suspended.');
    }
    return s;
  }

  private async owned(userId: string, id: string): Promise<Listing> {
    const row = await this.prisma.listing.findFirst({ where: { id, seller: { userId } } });
    // The same answer for "not yours" and "does not exist".
    if (!row) throw ApiException.notFound('We could not find that listing.');
    return row;
  }

  async mine(userId: string, now = new Date()): Promise<MyListingsDto> {
    const seller = await this.prisma.sellerProfile.findUnique({ where: { userId } });
    if (!seller) {
      return {
        isSeller: false,
        sellerStatus: null,
        stats: { live: 0, newInterest: 0, views30d: 0 },
        listings: [],
      };
    }
    const [rows, live, newInterest, views] = await Promise.all([
      this.prisma.listing.findMany({
        where: { sellerId: seller.id },
        include: LISTING_CARD_INCLUDE,
        orderBy: [{ updatedAt: 'desc' }, { id: 'asc' }],
        take: MAX_LISTINGS_PER_SELLER,
      }),
      this.prisma.listing.count({ where: { sellerId: seller.id, status: 'PUBLISHED' } }),
      this.prisma.enquiry.count({ where: { sellerUserId: userId, status: 'NEW' } }),
      this.prisma.listingView.count({
        where: {
          listing: { sellerId: seller.id },
          viewedOn: { gte: new Date(now.getTime() - 30 * DAY_MS) },
        },
      }),
    ]);
    return {
      isSeller: true,
      sellerStatus: seller.status,
      stats: { live, newInterest, views30d: views },
      listings: await this.views.cards(rows, userId, now),
    };
  }

  async myDetail(userId: string, id: string, now = new Date()): Promise<MyListingDto> {
    const row = await this.prisma.listing.findFirst({
      where: { id, seller: { userId } },
      include: DETAIL_INCLUDE,
    });
    if (!row) throw ApiException.notFound('We could not find that listing.');
    return this.toMine(row, userId, now);
  }

  private async toMine(row: DetailRow, userId: string, now: Date): Promise<MyListingDto> {
    const base = await this.market.toDetail(row, userId, now);
    const [newInterest, views30d] = await Promise.all([
      this.prisma.enquiry.count({ where: { listingId: row.id, status: 'NEW' } }),
      this.prisma.listingView.count({
        where: { listingId: row.id, viewedOn: { gte: new Date(now.getTime() - 30 * DAY_MS) } },
      }),
    ]);
    return {
      ...base,
      newInterest,
      views30d,
      profileServiceId: row.profileServiceId,
      missing: missingForSubmit({
        title: row.title,
        description: row.description,
        categoryId: row.categoryId,
        mediaCount: row.media.length,
        pricingType: row.pricingType,
        priceMinMinor: row.priceMinMinor,
      }).map((m) => m.message),
    };
  }

  // ---- create and edit ----------------------------------------------------------------------------------------

  async create(userId: string, dto: CreateListingDto): Promise<MyListingDto> {
    const seller = await this.ensureSeller(userId, dto);
    const count = await this.prisma.listing.count({ where: { sellerId: seller.id } });
    if (count >= MAX_LISTINGS_PER_SELLER) {
      throw ApiException.invalidState(`You can have up to ${MAX_LISTINGS_PER_SELLER} listings.`);
    }
    const title = cleanText(dto.title);
    if (title.length < MIN_TITLE) {
      throw ApiException.validation('Give your listing a title.', { field: 'title' });
    }
    if (!dto.categoryId) {
      throw ApiException.validation('Pick a category.', { field: 'categoryId' });
    }
    await this.assertCategory(dto.categoryId);
    const pricing = checkPricing({
      pricingType: dto.pricingType ?? 'ON_REQUEST',
      priceMin: dto.priceMin,
      priceMax: dto.priceMax,
    });
    if (dto.mediaIds) await this.assertMedia(userId, dto.mediaIds);
    if (dto.projectIds) await this.assertProjects(userId, dto.projectIds);
    const created = await this.prisma.transaction(async (tx) => {
      const row = await tx.listing.create({
        data: {
          sellerId: seller.id,
          type: dto.type ?? 'SERVICE',
          title,
          categoryId: dto.categoryId!,
          description: cleanText(dto.description),
          includedItems: cleanList(dto.includedItems),
          deliveryDays: dto.deliveryDays && dto.deliveryDays > 0 ? dto.deliveryDays : null,
          workMode: dto.workMode ?? 'REMOTE',
          locationText: cleanText(dto.locationText) || null,
          audienceText: cleanText(dto.audienceText) || null,
          pricingType: dto.pricingType ?? 'ON_REQUEST',
          priceMinMinor: pricing.min,
          priceMaxMinor: pricing.max,
        },
      });
      await this.replaceLinks(tx, row.id, dto.mediaIds, dto.projectIds);
      await this.audit.record(
        {
          actorType: 'USER',
          actorId: userId,
          action: 'listing.create',
          entityType: 'listing',
          entityId: row.id,
        },
        tx,
      );
      return row;
    });
    return this.myDetail(userId, created.id);
  }

  async update(userId: string, id: string, dto: ListingFieldsDto): Promise<MyListingDto> {
    await this.sellerOf(userId);
    const row = await this.owned(userId, id);
    if (!OWNER_EDITABLE.includes(row.status)) {
      throw ApiException.invalidState('This listing cannot be edited right now.', {
        status: row.status,
      });
    }
    const data: Prisma.ListingUpdateInput = {};
    if (dto.title !== undefined) {
      const t = cleanText(dto.title);
      if (t.length < MIN_TITLE) {
        throw ApiException.validation('Give your listing a title.', { field: 'title' });
      }
      data.title = t;
    }
    if (dto.type !== undefined) data.type = dto.type;
    if (dto.categoryId !== undefined) {
      await this.assertCategory(dto.categoryId);
      data.category = { connect: { id: dto.categoryId } };
    }
    if (dto.description !== undefined) data.description = cleanText(dto.description);
    if (dto.includedItems !== undefined) data.includedItems = cleanList(dto.includedItems);
    if (dto.deliveryDays !== undefined) {
      data.deliveryDays = dto.deliveryDays > 0 ? dto.deliveryDays : null;
    }
    if (dto.workMode !== undefined) data.workMode = dto.workMode;
    if (dto.locationText !== undefined) data.locationText = cleanText(dto.locationText) || null;
    if (dto.audienceText !== undefined) data.audienceText = cleanText(dto.audienceText) || null;
    if (dto.pricingType !== undefined || dto.priceMin !== undefined || dto.priceMax !== undefined) {
      const type = dto.pricingType ?? row.pricingType;
      const pricing = checkPricing({
        pricingType: type,
        priceMin: dto.priceMin ?? (row.priceMinMinor === null ? null : row.priceMinMinor / 100),
        priceMax: dto.priceMax ?? (row.priceMaxMinor === null ? null : row.priceMaxMinor / 100),
      });
      data.pricingType = type;
      data.priceMinMinor = pricing.min;
      data.priceMaxMinor = pricing.max;
    }
    if (dto.mediaIds) await this.assertMedia(userId, dto.mediaIds);
    if (dto.projectIds) await this.assertProjects(userId, dto.projectIds);

    // A live listing whose substance changes goes back for review, unless this seller publishes directly.
    if (row.status === 'PUBLISHED' && MATERIAL.some((k) => dto[k] !== undefined)) {
      const target = await this.targetFor(row.sellerId, row.id);
      if (target === 'UNDER_REVIEW') {
        assertTransition('PUBLISHED', 'UNDER_REVIEW');
        data.status = 'UNDER_REVIEW';
      }
    }
    await this.prisma.transaction(async (tx) => {
      if (Object.keys(data).length > 0) await tx.listing.update({ where: { id }, data });
      await this.replaceLinks(tx, id, dto.mediaIds, dto.projectIds);
    });
    return this.myDetail(userId, id);
  }

  // ---- state machine (owner side) -----------------------------------------------------------------------------

  private async targetFor(sellerId: string, excludeListingId: string) {
    const seller = await this.prisma.sellerProfile.findUniqueOrThrow({ where: { id: sellerId } });
    const [approvedBefore, rejectedOrSuspendedBefore, needsReview, directAfter] = await Promise.all(
      [
        this.prisma.listing.count({
          where: { sellerId, id: { not: excludeListingId }, publishedAt: { not: null } },
        }),
        this.prisma.listing.count({
          where: {
            sellerId,
            id: { not: excludeListingId },
            status: { in: ['REJECTED', 'SUSPENDED'] },
          },
        }),
        this.settings.get<boolean>('marketplace.first_listing_requires_review', true),
        this.settings.get<number>('marketplace.direct_publish_after_approvals', 3),
      ],
    );
    return submitTarget({
      canPublishDirectly: seller.canPublishDirectly,
      newSellersNeedReview: needsReview,
      approvedBefore,
      rejectedOrSuspendedBefore,
      directAfterApprovals: directAfter,
    });
  }

  async submit(userId: string, id: string): Promise<SubmitResultDto> {
    await this.sellerOf(userId);
    const row = await this.owned(userId, id);
    const mediaCount = await this.prisma.listingMedia.count({ where: { listingId: id } });
    const missing = missingForSubmit({
      title: row.title,
      description: row.description,
      categoryId: row.categoryId,
      mediaCount,
      pricingType: row.pricingType,
      priceMinMinor: row.priceMinMinor,
    });
    if (missing.length > 0) {
      throw ApiException.validation(missing[0]!.message, { field: missing[0]!.field, missing });
    }
    const target = await this.targetFor(row.sellerId, id);
    assertTransition(row.status, target);
    const now = new Date();
    const updated = await this.prisma.transaction(async (tx) => {
      const u = await tx.listing.update({
        where: { id },
        data: {
          status: target,
          rejectionReason: null,
          ...(target === 'PUBLISHED' ? { publishedAt: row.publishedAt ?? now } : {}),
        },
      });
      await this.audit.record(
        {
          actorType: 'USER',
          actorId: userId,
          action: 'listing.submit',
          entityType: 'listing',
          entityId: id,
          before: { status: row.status },
          after: { status: target },
        },
        tx,
      );
      return u;
    });
    return { listing: await this.myDetail(userId, updated.id), published: target === 'PUBLISHED' };
  }

  async withdraw(userId: string, id: string): Promise<MyListingDto> {
    const row = await this.owned(userId, id);
    assertTransition(row.status, 'DRAFT');
    await this.prisma.listing.update({ where: { id }, data: { status: 'DRAFT' } });
    return this.myDetail(userId, id);
  }

  /** Pause a live listing. It leaves the marketplace; restoring it makes it a draft to submit again. */
  async archive(userId: string, id: string): Promise<MyListingDto> {
    const row = await this.owned(userId, id);
    assertTransition(row.status, 'ARCHIVED');
    await this.prisma.listing.update({ where: { id }, data: { status: 'ARCHIVED' } });
    return this.myDetail(userId, id);
  }

  async restore(userId: string, id: string): Promise<MyListingDto> {
    await this.sellerOf(userId);
    const row = await this.owned(userId, id);
    assertTransition(row.status, 'DRAFT');
    await this.prisma.listing.update({ where: { id }, data: { status: 'DRAFT' } });
    return this.myDetail(userId, id);
  }

  async remove(userId: string, id: string): Promise<void> {
    const row = await this.owned(userId, id);
    if (row.status !== 'DRAFT') {
      throw ApiException.invalidState('Only a draft can be deleted. Pause a live listing instead.');
    }
    await this.prisma.transaction(async (tx) => {
      await tx.listing.delete({ where: { id } });
      if (row.profileServiceId) {
        await tx.profileService.update({
          where: { id: row.profileServiceId },
          data: { status: 'PROFILE_ONLY' },
        });
      }
    });
  }

  // ---- from a profile service ---------------------------------------------------------------------------------

  /** "Publish" on a profile service: a draft listing with its title, description and price, linked back. */
  async fromService(
    userId: string,
    serviceId: string,
    dto: { categoryId: string; acceptTerms?: boolean; termsVersion?: string },
  ): Promise<MyListingDto> {
    const service = await this.prisma.profileService.findFirst({
      where: { id: serviceId, profile: { userId } },
      include: { listing: { select: { id: true } } },
    });
    if (!service) throw ApiException.notFound('We could not find that service.');
    if (service.listing) return this.myDetail(userId, service.listing.id);
    const seller = await this.ensureSeller(userId, dto);
    await this.assertCategory(dto.categoryId);
    const count = await this.prisma.listing.count({ where: { sellerId: seller.id } });
    if (count >= MAX_LISTINGS_PER_SELLER) {
      throw ApiException.invalidState(`You can have up to ${MAX_LISTINGS_PER_SELLER} listings.`);
    }
    const row = await this.prisma.transaction(async (tx) => {
      const l = await tx.listing.create({
        data: {
          sellerId: seller.id,
          type: 'SERVICE',
          title: service.title,
          categoryId: dto.categoryId,
          description: service.description ?? '',
          pricingType: service.priceType,
          priceMinMinor: service.priceMin,
          priceMaxMinor: service.priceMax,
          currency: service.currency,
          profileServiceId: service.id,
        },
      });
      await tx.profileService.update({
        where: { id: service.id },
        data: { status: 'ON_MARKETPLACE' },
      });
      await this.audit.record(
        {
          actorType: 'USER',
          actorId: userId,
          action: 'listing.create',
          entityType: 'listing',
          entityId: l.id,
          after: { fromServiceId: service.id },
        },
        tx,
      );
      return l;
    });
    return this.myDetail(userId, row.id);
  }

  // ---- validation helpers -------------------------------------------------------------------------------------

  private async assertCategory(categoryId: string): Promise<void> {
    const ok = await this.prisma.marketplaceCategory.count({
      where: { id: categoryId, isActive: true },
    });
    if (!ok)
      throw ApiException.validation('Pick a category from the list.', { field: 'categoryId' });
  }

  private async assertMedia(userId: string, ids: string[]): Promise<void> {
    if (new Set(ids).size !== ids.length) {
      throw ApiException.validation('A picture was added twice.', { field: 'mediaIds' });
    }
    if (ids.length > MAX_LISTING_MEDIA) {
      throw ApiException.validation(`Add up to ${MAX_LISTING_MEDIA} pictures.`, {
        field: 'mediaIds',
      });
    }
    if (ids.length === 0) return;
    const assets = await this.prisma.mediaAsset.findMany({
      where: { id: { in: ids }, ownerId: userId, deletedAt: null },
      select: { kind: true, bucket: true, status: true },
    });
    if (assets.length !== ids.length) {
      throw ApiException.validation('One of those files could not be found.', {
        field: 'mediaIds',
      });
    }
    for (const a of assets) {
      if (a.kind !== 'IMAGE') {
        throw ApiException.validation('Listings take pictures for now.', { field: 'mediaIds' });
      }
      if (a.bucket !== 'PUBLIC') {
        throw ApiException.validation('That file was uploaded as private.', { field: 'mediaIds' });
      }
      if (a.status === 'REJECTED') {
        throw ApiException.validation(
          'One of those files was refused. Remove it and try another.',
          {
            field: 'mediaIds',
          },
        );
      }
    }
  }

  private async assertProjects(userId: string, ids: string[]): Promise<void> {
    if (new Set(ids).size !== ids.length || ids.length > MAX_LISTING_PROJECTS) {
      throw ApiException.validation(`Pick up to ${MAX_LISTING_PROJECTS} different projects.`, {
        field: 'projectIds',
      });
    }
    if (ids.length === 0) return;
    const found = await this.prisma.project.count({
      where: { id: { in: ids }, profile: { userId }, deletedAt: null },
    });
    if (found !== ids.length) {
      throw ApiException.validation('Pick projects from your own portfolio.', {
        field: 'projectIds',
      });
    }
  }

  /** Replaces the ordered media and project links when the lists were sent (even empty). */
  private async replaceLinks(
    tx: Prisma.TransactionClient,
    listingId: string,
    mediaIds: string[] | undefined,
    projectIds: string[] | undefined,
  ): Promise<void> {
    if (mediaIds) {
      await tx.listingMedia.deleteMany({ where: { listingId } });
      if (mediaIds.length) {
        await tx.listingMedia.createMany({
          data: mediaIds.map((mediaId, sortOrder) => ({ listingId, mediaId, sortOrder })),
        });
      }
    }
    if (projectIds) {
      await tx.listingPortfolioLink.deleteMany({ where: { listingId } });
      if (projectIds.length) {
        await tx.listingPortfolioLink.createMany({
          data: projectIds.map((projectId, sortOrder) => ({ listingId, projectId, sortOrder })),
        });
      }
    }
  }
}
