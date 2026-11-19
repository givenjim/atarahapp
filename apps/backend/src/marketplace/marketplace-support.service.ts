import { Injectable, Logger } from '@nestjs/common';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { median } from './marketplace-logic';

const REPLY_WINDOW_DAYS = 90;
const DAY_MS = 86_400_000;

/** Seller statistics and marketplace notifications. A notification problem never fails the action behind it. */
@Injectable()
export class MarketplaceSupportService {
  private readonly log = new Logger(MarketplaceSupportService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

  /**
   * Recomputes rating (visible reviews only), completed count (closed requests) and median first-reply time
   * (last 90 days) from the source rows. Called after a review, a reply, a close or a review being hidden.
   */
  async refreshSellerStats(sellerId: string, now = new Date()): Promise<void> {
    const seller = await this.prisma.sellerProfile.findUnique({
      where: { id: sellerId },
      select: { userId: true },
    });
    if (!seller) return;
    const [reviews, completed, replies] = await Promise.all([
      this.prisma.listingReview.aggregate({
        where: { status: 'VISIBLE', listing: { sellerId } },
        _avg: { rating: true },
        _count: { _all: true },
      }),
      this.prisma.enquiry.count({ where: { sellerUserId: seller.userId, status: 'CLOSED' } }),
      this.prisma.enquiry.findMany({
        where: {
          sellerUserId: seller.userId,
          firstReplyAt: { not: null },
          createdAt: { gt: new Date(now.getTime() - REPLY_WINDOW_DAYS * DAY_MS) },
        },
        select: { createdAt: true, firstReplyAt: true },
        take: 500,
        orderBy: { createdAt: 'desc' },
      }),
    ]);
    const minutes = replies.map((r) =>
      Math.max(0, Math.round((r.firstReplyAt!.getTime() - r.createdAt.getTime()) / 60_000)),
    );
    await this.prisma.sellerProfile.update({
      where: { id: sellerId },
      data: {
        ratingAverage: reviews._count._all > 0 ? (reviews._avg.rating ?? null) : null,
        ratingCount: reviews._count._all,
        completedCount: completed,
        medianReplyMinutes: median(minutes),
      },
    });
  }

  async tell(
    userId: string,
    n: { type: string; title: string; body: string; deepLink?: string },
  ): Promise<void> {
    try {
      await this.notifications.notify({ userId, category: 'MARKETPLACE', ...n });
    } catch (e) {
      this.log.warn(
        `Notification to ${userId} failed: ${e instanceof Error ? e.message : String(e)}`,
      );
    }
  }
}
