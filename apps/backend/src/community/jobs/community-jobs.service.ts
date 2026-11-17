import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { NotificationsService } from '../../notifications/notifications.service';
import { PrismaService } from '../../prisma/prisma.service';
import { MODERATION_BACKLOG_HOURS } from '../rules';
import { parseLinkPreview } from './link-preview';
import { SafeFetcher, UnsafeUrlError } from './safe-fetch';

export interface ReconcileResult {
  reactionCounts: number;
  replyCounts: number;
  memberCounts: number;
}

/** The background work of the community: link previews, nightly counter reconciliation, the moderation backlog alert. */
@Injectable()
export class CommunityJobsService {
  private readonly logger = new Logger(CommunityJobsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly fetcher: SafeFetcher,
    private readonly notifications: NotificationsService,
  ) {}

  /**
   * Fetch the page behind a post's link and store its preview. A link that cannot be fetched (private address,
   * not a web page, timeout) simply keeps no preview; the job never retries a refusal, and `fetchedAt` records
   * that it was tried.
   */
  async fetchLinkPreview(
    postId: string,
  ): Promise<{ status: 'stored' | 'refused' | 'failed' | 'skipped' }> {
    const link = await this.prisma.postLink.findUnique({ where: { postId } });
    if (!link || link.fetchedAt) return { status: 'skipped' };
    try {
      const page = await this.fetcher.fetchHtml(link.url);
      const preview = parseLinkPreview(page.body, page.url);
      await this.prisma.postLink.update({
        where: { postId },
        data: { ...preview, fetchedAt: new Date() },
      });
      return { status: 'stored' };
    } catch (err) {
      if (err instanceof UnsafeUrlError) {
        this.logger.warn(`Link preview refused for post ${postId}: ${err.message}`);
        await this.prisma.postLink.update({ where: { postId }, data: { fetchedAt: new Date() } });
        return { status: 'refused' };
      }
      // A network problem: leave it for the next attempt (BullMQ retries with backoff), then give up quietly.
      this.logger.warn(
        `Link preview failed for post ${postId}: ${err instanceof Error ? err.message : String(err)}`,
      );
      await this.prisma.postLink.update({ where: { postId }, data: { fetchedAt: new Date() } });
      return { status: 'failed' };
    }
  }

  /** Recomputes every denormalised counter from its source rows and fixes any that drifted. */
  async reconcileCounters(): Promise<ReconcileResult> {
    const reactionCounts = await this.prisma.$executeRaw(Prisma.sql`
      UPDATE posts p SET "reactionCount" = s.n
      FROM (SELECT p2.id, (SELECT count(*) FROM reactions r WHERE r."postId" = p2.id)::int AS n FROM posts p2) s
      WHERE s.id = p.id AND p."reactionCount" <> s.n`);
    const replyCounts = await this.prisma.$executeRaw(Prisma.sql`
      UPDATE posts p SET "replyCount" = s.n
      FROM (
        SELECT p2.id, (
          SELECT count(*) FROM comments c LEFT JOIN comments pc ON pc.id = c."parentCommentId"
          WHERE c."postId" = p2.id AND c.status::text = 'VISIBLE' AND c."deletedAt" IS NULL
            AND (c."parentCommentId" IS NULL OR (pc.status::text = 'VISIBLE' AND pc."deletedAt" IS NULL))
        )::int AS n FROM posts p2) s
      WHERE s.id = p.id AND p."replyCount" <> s.n`);
    const memberCounts = await this.prisma.$executeRaw(Prisma.sql`
      UPDATE groups g SET "memberCount" = s.n
      FROM (SELECT g2.id, (SELECT count(*) FROM group_memberships m WHERE m."groupId" = g2.id)::int AS n FROM groups g2) s
      WHERE s.id = g.id AND g."memberCount" <> s.n`);
    const result = { reactionCounts, replyCounts, memberCounts };
    if (reactionCounts + replyCounts + memberCounts > 0) {
      this.logger.warn(`Counter reconciliation fixed ${JSON.stringify(result)}`);
    }
    return result;
  }

  /**
   * Cases still waiting for a decision after 48 hours: every active staff member who can resolve reports gets one
   * summary notification, and each case is raised at most once a day.
   */
  async alertModerationBacklog(now = new Date()): Promise<{ cases: number; notified: number }> {
    const cutoff = new Date(now.getTime() - MODERATION_BACKLOG_HOURS * 3_600_000);
    const dayAgo = new Date(now.getTime() - 24 * 3_600_000);
    const stale = await this.prisma.moderationCase.findMany({
      where: {
        status: { in: ['SUBMITTED', 'IN_REVIEW', 'ESCALATED'] },
        createdAt: { lt: cutoff },
        OR: [{ alertedAt: null }, { alertedAt: { lt: dayAgo } }],
      },
      select: { id: true },
    });
    if (stale.length === 0) return { cases: 0, notified: 0 };

    const staff = await this.prisma.user.findMany({
      where: {
        status: 'ACTIVE',
        deletedAt: null,
        roles: {
          some: {
            revokedAt: null,
            role: { permissions: { some: { permission: { key: 'report.resolve' } } } },
          },
        },
      },
      select: { id: true },
    });
    let notified = 0;
    for (const s of staff) {
      try {
        await this.notifications.notify({
          userId: s.id,
          category: 'SYSTEM',
          title: 'Moderation cases are waiting',
          body: `${stale.length} report${stale.length === 1 ? ' has' : 's have'} been waiting for over ${MODERATION_BACKLOG_HOURS} hours.`,
          critical: true,
        });
        notified += 1;
      } catch (e) {
        this.logger.warn(
          `Backlog alert to ${s.id} failed: ${e instanceof Error ? e.message : String(e)}`,
        );
      }
    }
    await this.prisma.moderationCase.updateMany({
      where: { id: { in: stale.map((c) => c.id) } },
      data: { alertedAt: now },
    });
    this.logger.warn(
      `Moderation backlog: ${stale.length} case(s) older than ${MODERATION_BACKLOG_HOURS} h; ${notified} staff notified`,
    );
    return { cases: stale.length, notified };
  }
}
