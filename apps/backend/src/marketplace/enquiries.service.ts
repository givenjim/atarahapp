import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type CreateEnquiryDto,
  type EnquiriesQueryDto,
  type EnquiryDto,
  type EnquiryThreadDto,
  type ReviewDto,
} from './marketplace.dto';
import { assertCanClose, cleanText, fromMinor, toMinor } from './marketplace-logic';
import { MarketplaceSupportService } from './marketplace-support.service';
import { listingVisibleWhere } from './marketplace-views.service';

/** Requests a member may send per day: stops one account from flooding sellers. */
const MAX_NEW_PER_DAY = 20;

const ENQUIRY_INCLUDE = {
  listing: {
    select: {
      id: true,
      title: true,
      media: { orderBy: { sortOrder: 'asc' }, take: 1, select: { mediaId: true } },
    },
  },
  buyer: {
    select: {
      id: true,
      fullName: true,
      creativeProfile: { select: { displayName: true, handle: true, avatarMediaId: true } },
    },
  },
  seller: {
    select: {
      id: true,
      fullName: true,
      creativeProfile: { select: { displayName: true, handle: true, avatarMediaId: true } },
    },
  },
  review: { select: { id: true } },
} satisfies Prisma.EnquiryInclude;
type EnquiryRow = Prisma.EnquiryGetPayload<{ include: typeof ENQUIRY_INCLUDE }>;

@Injectable()
export class EnquiriesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
    private readonly audit: AuditService,
    private readonly support: MarketplaceSupportService,
  ) {}

  // ---- sending a request --------------------------------------------------------------------------------------

  async create(
    buyerId: string,
    listingId: string,
    dto: CreateEnquiryDto,
  ): Promise<EnquiryThreadDto> {
    const listing = await this.prisma.listing.findFirst({
      where: { id: listingId, ...listingVisibleWhere(buyerId) },
      select: { id: true, title: true, seller: { select: { userId: true } } },
    });
    if (!listing) throw ApiException.notFound('We could not find that listing.');
    const sellerUserId = listing.seller.userId;
    if (sellerUserId === buyerId) {
      throw ApiException.invalidState('You cannot send a request to yourself.');
    }
    const open = await this.prisma.enquiry.findFirst({
      where: { listingId, buyerId, status: { not: 'CLOSED' } },
      select: { id: true },
    });
    if (open) {
      throw ApiException.conflict('You already sent a request for this listing.', {
        enquiryId: open.id,
      });
    }
    const today = await this.prisma.enquiry.count({
      where: { buyerId, createdAt: { gt: new Date(Date.now() - 86_400_000) } },
    });
    if (today >= MAX_NEW_PER_DAY) {
      throw ApiException.invalidState('You have sent a lot of requests today. Try again tomorrow.');
    }
    const message = dto.message.trim();
    let row;
    try {
      row = await this.prisma.transaction(async (tx) => {
        const e = await tx.enquiry.create({
          data: {
            listingId,
            buyerId,
            sellerUserId,
            message,
            budgetMinor: toMinor(dto.budget),
            preferredTiming: cleanText(dto.preferredTiming) || null,
            buyerReadAt: new Date(),
          },
        });
        await tx.enquiryMessage.create({
          data: { enquiryId: e.id, senderId: buyerId, body: message },
        });
        return e;
      });
    } catch (e) {
      // Two taps at once: the partial unique index lets only one open request through.
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002') {
        throw ApiException.conflict('You already sent a request for this listing.');
      }
      throw e;
    }
    await this.support.tell(sellerUserId, {
      type: 'marketplace.enquiry.new',
      title: 'New request on your listing',
      body: `Someone asked about ${listing.title}.`,
      deepLink: `/marketplace/enquiries/${row.id}`,
    });
    return this.thread(buyerId, row.id, false);
  }

  // ---- reading ------------------------------------------------------------------------------------------------

  private async party(userId: string, id: string): Promise<EnquiryRow> {
    const row = await this.prisma.enquiry.findFirst({
      where: { id, OR: [{ buyerId: userId }, { sellerUserId: userId }] },
      include: ENQUIRY_INCLUDE,
    });
    // Only the two parties ever see a thread. Anyone else gets the same answer as for a missing one.
    if (!row) throw ApiException.notFound('We could not find that request.');
    return row;
  }

  private async toDto(
    row: EnquiryRow,
    userId: string,
    lastSender: string | null,
  ): Promise<EnquiryDto> {
    const role = row.buyerId === userId ? 'BUYER' : 'SELLER';
    const other = role === 'BUYER' ? row.seller : row.buyer;
    const readAt = role === 'BUYER' ? row.buyerReadAt : row.sellerReadAt;
    const unread =
      lastSender !== null &&
      lastSender !== userId &&
      (readAt === null || readAt < row.lastMessageAt);
    return {
      id: row.id,
      listingId: row.listingId,
      listingTitle: row.listing.title,
      listingCoverUrl: await this.media.imageUrl(row.listing.media[0]?.mediaId ?? null, 200),
      status: row.status,
      role,
      counterpart: {
        userId: other.id,
        displayName: other.creativeProfile?.displayName ?? other.fullName,
        handle: other.creativeProfile?.handle ?? null,
        avatarUrl: await this.media.imageUrl(other.creativeProfile?.avatarMediaId ?? null, 200),
      },
      message: row.message,
      budget: fromMinor(row.budgetMinor),
      preferredTiming: row.preferredTiming,
      unread,
      lastMessageAt: row.lastMessageAt,
      createdAt: row.createdAt,
      closedAt: row.closedAt,
      canReview: role === 'BUYER' && row.status === 'CLOSED' && !row.review,
      canClose: row.status === 'REPLIED',
      reviewed: !!row.review,
    };
  }

  async list(userId: string, q: EnquiriesQueryDto) {
    const side: Prisma.EnquiryWhereInput =
      q.as === 'buyer'
        ? { buyerId: userId }
        : q.as === 'seller'
          ? { sellerUserId: userId }
          : { OR: [{ buyerId: userId }, { sellerUserId: userId }] };
    const where: Prisma.EnquiryWhereInput = {
      AND: [
        side,
        ...(q.status ? [{ status: q.status }] : []),
        ...(q.listingId ? [{ listingId: q.listingId }] : []),
      ],
    };
    const [rows, total] = await Promise.all([
      this.prisma.enquiry.findMany({
        where,
        include: ENQUIRY_INCLUDE,
        orderBy: [{ lastMessageAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.enquiry.count({ where }),
    ]);
    const last = await this.prisma.enquiryMessage.findMany({
      where: { enquiryId: { in: rows.map((r) => r.id) } },
      orderBy: { createdAt: 'desc' },
      distinct: ['enquiryId'],
      select: { enquiryId: true, senderId: true },
    });
    const lastBy = new Map(last.map((l) => [l.enquiryId, l.senderId]));
    const items = await Promise.all(
      rows.map((r) => this.toDto(r, userId, lastBy.get(r.id) ?? null)),
    );
    return { items, meta: pageMeta(q, total) };
  }

  /** The thread, oldest message first. Opening it marks it read for the viewer. */
  async thread(userId: string, id: string, markRead = true): Promise<EnquiryThreadDto> {
    const row = await this.party(userId, id);
    const messages = await this.prisma.enquiryMessage.findMany({
      where: { enquiryId: id },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
      take: 500,
    });
    const lastSender = messages[messages.length - 1]?.senderId ?? null;
    const dto = await this.toDto(row, userId, lastSender);
    if (markRead) {
      const now = new Date();
      await this.prisma.enquiry.update({
        where: { id },
        data: row.buyerId === userId ? { buyerReadAt: now } : { sellerReadAt: now },
      });
      dto.unread = false;
    }
    return {
      ...dto,
      messages: messages.map((m) => ({
        id: m.id,
        senderId: m.senderId,
        body: m.body,
        fromMe: m.senderId === userId,
        createdAt: m.createdAt,
      })),
    };
  }

  // ---- replying, closing, reviewing ---------------------------------------------------------------------------

  private async assertCanReplyAsSeller(userId: string): Promise<void> {
    const seller = await this.prisma.sellerProfile.findUnique({
      where: { userId },
      select: { status: true },
    });
    const role = await this.prisma.userRole.findFirst({
      where: { userId, revokedAt: null, role: { key: 'SELLER' } },
      select: { id: true },
    });
    if (!seller || !role || seller.status !== 'ACTIVE') {
      throw ApiException.forbidden('You cannot reply to requests right now.');
    }
  }

  private async assertNotBlocked(a: string, b: string): Promise<void> {
    const n = await this.prisma.block.count({
      where: {
        OR: [
          { blockerId: a, blockedId: b },
          { blockerId: b, blockedId: a },
        ],
      },
    });
    if (n > 0) throw ApiException.forbidden('You cannot message this person.');
  }

  async send(userId: string, id: string, body: string): Promise<EnquiryThreadDto> {
    const row = await this.party(userId, id);
    if (row.status === 'CLOSED') {
      throw ApiException.invalidState('This request is closed.');
    }
    const isSeller = row.sellerUserId === userId;
    if (isSeller) await this.assertCanReplyAsSeller(userId);
    await this.assertNotBlocked(row.buyerId, row.sellerUserId);
    const now = new Date();
    const firstReply = isSeller && row.firstReplyAt === null;
    await this.prisma.transaction(async (tx) => {
      await tx.enquiryMessage.create({
        data: { enquiryId: id, senderId: userId, body: body.trim() },
      });
      await tx.enquiry.update({
        where: { id },
        data: {
          lastMessageAt: now,
          ...(isSeller ? { sellerReadAt: now, status: 'REPLIED' } : { buyerReadAt: now }),
          ...(firstReply ? { firstReplyAt: now } : {}),
        },
      });
    });
    if (firstReply) {
      const seller = await this.prisma.sellerProfile.findUnique({
        where: { userId },
        select: { id: true },
      });
      if (seller) await this.support.refreshSellerStats(seller.id);
    }
    await this.support.tell(isSeller ? row.buyerId : row.sellerUserId, {
      type: isSeller ? 'marketplace.enquiry.reply' : 'marketplace.enquiry.message',
      title: isSeller ? 'You have a reply' : 'New message on a request',
      body: `About ${row.listing.title}.`,
      deepLink: `/marketplace/enquiries/${id}`,
    });
    return this.thread(userId, id, false);
  }

  async close(userId: string, id: string): Promise<EnquiryThreadDto> {
    const row = await this.party(userId, id);
    assertCanClose(row.status);
    await this.prisma.transaction(async (tx) => {
      await tx.enquiry.update({
        where: { id },
        data: { status: 'CLOSED', closedAt: new Date(), closedById: userId },
      });
      await this.audit.record(
        {
          actorType: 'USER',
          actorId: userId,
          action: 'enquiry.close',
          entityType: 'enquiry',
          entityId: id,
        },
        tx,
      );
    });
    const seller = await this.prisma.sellerProfile.findUnique({
      where: { userId: row.sellerUserId },
      select: { id: true },
    });
    if (seller) await this.support.refreshSellerStats(seller.id);
    const buyerClosed = row.buyerId === userId;
    await this.support.tell(buyerClosed ? row.sellerUserId : row.buyerId, {
      type: 'marketplace.enquiry.closed',
      title: buyerClosed ? 'A request was marked done' : 'Your request was marked done',
      body: buyerClosed
        ? `The request about ${row.listing.title} is closed.`
        : `You can now leave a review for ${row.listing.title}.`,
      deepLink: `/marketplace/enquiries/${id}`,
    });
    return this.thread(userId, id, false);
  }

  /** One review per closed request, by the person who asked. Anyone else, or an open request, is refused. */
  async review(userId: string, id: string, dto: ReviewDto): Promise<EnquiryThreadDto> {
    const row = await this.party(userId, id);
    if (row.buyerId !== userId) {
      throw ApiException.forbidden('Only the person who sent the request can review it.');
    }
    if (row.status !== 'CLOSED') {
      throw ApiException.invalidState('You can review once the request is closed.');
    }
    if (row.review) throw ApiException.conflict('You already reviewed this.');
    try {
      await this.prisma.listingReview.create({
        data: {
          listingId: row.listingId,
          enquiryId: id,
          reviewerId: userId,
          rating: dto.rating,
          body: dto.body?.trim() || null,
        },
      });
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002') {
        throw ApiException.conflict('You already reviewed this.');
      }
      throw e;
    }
    const seller = await this.prisma.sellerProfile.findUnique({
      where: { userId: row.sellerUserId },
      select: { id: true },
    });
    if (seller) await this.support.refreshSellerStats(seller.id);
    await this.support.tell(row.sellerUserId, {
      type: 'marketplace.review.new',
      title: 'You got a review',
      body: `${dto.rating} out of 5 on ${row.listing.title}.`,
      deepLink: `/marketplace/listings/${row.listingId}`,
    });
    return this.thread(userId, id, false);
  }
}
