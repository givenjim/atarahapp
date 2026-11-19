import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { notBlockedWhere } from '../community-core/blocks';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import { type ListingCardDto, type SellerCardDto } from './marketplace.dto';
import { priceLabel } from './marketplace-logic';

export const LISTING_CARD_INCLUDE = {
  category: { select: { name: true } },
  seller: {
    include: {
      user: {
        select: {
          fullName: true,
          creativeProfile: {
            select: { displayName: true, handle: true, headline: true, avatarMediaId: true },
          },
        },
      },
    },
  },
  media: { orderBy: { sortOrder: 'asc' }, take: 1, select: { mediaId: true } },
} satisfies Prisma.ListingInclude;

export type ListingCardRow = Prisma.ListingGetPayload<{ include: typeof LISTING_CARD_INCLUDE }>;
export type SellerRow = Prisma.SellerProfileGetPayload<{
  include: {
    user: {
      select: {
        fullName: true;
        creativeProfile: {
          select: { displayName: true; handle: true; headline: true; avatarMediaId: true };
        };
      };
    };
  };
}>;

export const SELLER_INCLUDE = LISTING_CARD_INCLUDE.seller.include;

/** What a member may see of a listing: live, from an active seller, and not from anyone they have a block with. */
export const listingVisibleWhere = (viewerId: string): Prisma.ListingWhereInput => ({
  status: 'PUBLISHED',
  seller: {
    status: 'ACTIVE',
    user: { status: 'ACTIVE', deletedAt: null, ...notBlockedWhere(viewerId) },
  },
  category: { isActive: true },
});

/** Turns rows into the shapes the app shows. Every reader of listings goes through here. */
@Injectable()
export class MarketplaceViewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
  ) {}

  async sellerCards(rows: SellerRow[]): Promise<SellerCardDto[]> {
    if (rows.length === 0) return [];
    const counts = await this.prisma.listing.groupBy({
      by: ['sellerId'],
      where: { sellerId: { in: rows.map((r) => r.id) }, status: 'PUBLISHED' },
      _count: { _all: true },
    });
    const byId = new Map(counts.map((c) => [c.sellerId, c._count._all]));
    return Promise.all(rows.map(async (r) => this.sellerCard(r, byId.get(r.id) ?? 0)));
  }

  async sellerCard(r: SellerRow, listingCount: number): Promise<SellerCardDto> {
    const cp = r.user.creativeProfile;
    return {
      id: r.id,
      displayName: cp?.displayName ?? r.user.fullName,
      handle: cp?.handle ?? null,
      headline: cp?.headline ?? null,
      avatarUrl: await this.media.imageUrl(cp?.avatarMediaId ?? null, 200),
      ratingAverage: r.ratingAverage === null ? null : Math.round(r.ratingAverage * 10) / 10,
      ratingCount: r.ratingCount,
      completedCount: r.completedCount,
      listingCount,
      verified: r.verificationStatus === 'VERIFIED',
    };
  }

  /** Average and count of visible reviews per listing. */
  async ratings(listingIds: string[]): Promise<Map<string, { avg: number; count: number }>> {
    if (listingIds.length === 0) return new Map();
    const g = await this.prisma.listingReview.groupBy({
      by: ['listingId'],
      where: { listingId: { in: listingIds }, status: 'VISIBLE' },
      _avg: { rating: true },
      _count: { _all: true },
    });
    return new Map(
      g.map((x) => [
        x.listingId,
        { avg: Math.round((x._avg.rating ?? 0) * 10) / 10, count: x._count._all },
      ]),
    );
  }

  async savedSet(viewerId: string, listingIds: string[]): Promise<Set<string>> {
    if (listingIds.length === 0) return new Set();
    const rows = await this.prisma.savedItem.findMany({
      where: { userId: viewerId, type: 'LISTING', targetId: { in: listingIds } },
      select: { targetId: true },
    });
    return new Set(rows.map((r) => r.targetId));
  }

  async cards(
    rows: ListingCardRow[],
    viewerId: string,
    now = new Date(),
  ): Promise<ListingCardDto[]> {
    if (rows.length === 0) return [];
    const ids = rows.map((r) => r.id);
    const sellerCounts = await this.prisma.listing.groupBy({
      by: ['sellerId'],
      where: { sellerId: { in: [...new Set(rows.map((r) => r.sellerId))] }, status: 'PUBLISHED' },
      _count: { _all: true },
    });
    const countBySeller = new Map(sellerCounts.map((c) => [c.sellerId, c._count._all]));
    const [ratings, saved] = await Promise.all([this.ratings(ids), this.savedSet(viewerId, ids)]);
    return Promise.all(
      rows.map(async (r) => {
        const price = priceLabel(r.pricingType, r.priceMinMinor, r.priceMaxMinor);
        const rating = ratings.get(r.id);
        return {
          id: r.id,
          type: r.type,
          title: r.title,
          categoryName: r.category.name,
          coverUrl: await this.media.imageUrl(r.media[0]?.mediaId ?? null, 600),
          pricingType: r.pricingType,
          priceLabel: price.label,
          fromLabel: price.from,
          seller: await this.sellerCard(r.seller, countBySeller.get(r.sellerId) ?? 0),
          ratingAverage: rating?.avg ?? null,
          ratingCount: rating?.count ?? 0,
          featured: r.featuredUntil !== null && r.featuredUntil > now,
          saved: saved.has(r.id),
          status: r.status,
        };
      }),
    );
  }
}
