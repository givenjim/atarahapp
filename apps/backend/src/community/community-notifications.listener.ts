import { Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { DomainEventBus } from '../community-core/domain-events';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';

/** Copy for the member who reported something. Deliberately says nothing about who decided, how, or why. */
export const REPORT_OUTCOME_COPY = {
  ACTION_TAKEN: {
    title: 'Update on your report',
    body: 'We reviewed your report and took action. Thank you for helping keep Atarah safe.',
  },
  NO_ACTION: {
    title: 'Update on your report',
    body: 'We reviewed your report and did not find a breach of our Community Guidelines. Thank you for telling us.',
  },
} as const;

const snippet = (s: string, n = 80) => (s.length > n ? `${s.slice(0, n - 1)}…` : s);

/**
 * Turns community events into notifications (in-app now; push through the existing dispatcher, which delivers to
 * members who have a registered device and the category on). A notification problem never fails the action.
 */
@Injectable()
export class CommunityNotificationsListener implements OnModuleInit {
  private readonly logger = new Logger(CommunityNotificationsListener.name);

  constructor(
    private readonly bus: DomainEventBus,
    private readonly notifications: NotificationsService,
    private readonly prisma: PrismaService,
  ) {}

  onModuleInit(): void {
    this.bus.on('ConnectionRequested', async (e) => {
      const who = await this.person(e.requesterId);
      await this.tell(e.addresseeId, {
        title: 'New connection request',
        body: `${who.name} wants to connect with you.`,
        deepLink: who.handle ? `/creatives/${who.handle}` : undefined,
      });
    });

    this.bus.on('ConnectionAccepted', async (e) => {
      const who = await this.person(e.addresseeId);
      await this.tell(e.requesterId, {
        title: 'Connection accepted',
        body: `${who.name} accepted your request.`,
        deepLink: who.handle ? `/creatives/${who.handle}` : undefined,
      });
    });

    this.bus.on('CommentCreated', async (e) => {
      const post = await this.prisma.post.findUnique({
        where: { id: e.postId },
        select: { authorId: true, body: true },
      });
      if (!post) return;
      const who = await this.person(e.authorId);
      const targets = new Set<string>([post.authorId]);
      if (e.parentCommentId) {
        const parent = await this.prisma.comment.findUnique({
          where: { id: e.parentCommentId },
          select: { authorId: true },
        });
        if (parent) targets.add(parent.authorId);
      }
      targets.delete(e.authorId);
      for (const userId of targets) {
        if (await this.suppressed(userId, e.authorId, e.postId)) continue;
        await this.tell(userId, {
          title:
            e.parentCommentId && userId !== post.authorId
              ? 'New reply to your comment'
              : 'New comment on your post',
          body: `${who.name} commented: ${snippet(post.body || 'on your post')}`,
          deepLink: `/community/posts/${e.postId}`,
        });
      }
    });

    this.bus.on('ModerationActionTaken', async (e) => {
      // 1. The reporters are told that a decision was made, nothing more.
      if (e.closedReportIds.length > 0) {
        const reports = await this.prisma.report.findMany({
          where: { id: { in: e.closedReportIds }, notifiedAt: null },
          select: { id: true, reporterId: true, status: true },
        });
        for (const r of reports) {
          const copy =
            r.status === 'RESOLVED'
              ? REPORT_OUTCOME_COPY.ACTION_TAKEN
              : REPORT_OUTCOME_COPY.NO_ACTION;
          await this.tell(r.reporterId, { ...copy, deepLink: undefined });
          await this.prisma.report.update({
            where: { id: r.id },
            data: { notifiedAt: new Date() },
          });
        }
      }
      // 2. The member whose content was acted on is told what happened to it, not who reported it.
      if (!e.targetAuthorId || e.targetType === 'GROUP') return;
      const what =
        e.targetType === 'POST' ? 'post' : e.targetType === 'COMMENT' ? 'comment' : 'account';
      const copy: Partial<Record<typeof e.action, string>> = {
        WARN_USER: `A moderator reviewed your ${what}. It goes against our Community Guidelines, so please keep to them.`,
        HIDE_CONTENT: `Your ${what} was hidden because it goes against our Community Guidelines.`,
        REMOVE_CONTENT: `Your ${what} was removed because it goes against our Community Guidelines.`,
        RESTRICT_ACCOUNT:
          'Your account is limited from posting and connecting for now because of our Community Guidelines.',
      };
      const body = copy[e.action];
      if (body) {
        await this.tell(e.targetAuthorId, {
          title: 'A moderator reviewed your activity',
          body,
          critical: e.action === 'WARN_USER' || e.action === 'RESTRICT_ACCOUNT',
        });
      }
    });
  }

  private async person(userId: string): Promise<{ name: string; handle: string | null }> {
    const u = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { fullName: true, creativeProfile: { select: { displayName: true, handle: true } } },
    });
    return {
      name: u?.creativeProfile?.displayName ?? u?.fullName ?? 'Someone',
      handle: u?.creativeProfile?.handle ?? null,
    };
  }

  /** No notification between members who blocked each other, or about a thread the member muted. */
  private async suppressed(userId: string, actorId: string, postId: string): Promise<boolean> {
    const [blocked, muted] = await Promise.all([
      this.prisma.block.count({
        where: {
          OR: [
            { blockerId: userId, blockedId: actorId },
            { blockerId: actorId, blockedId: userId },
          ],
        },
      }),
      this.prisma.mute.count({
        where: {
          userId,
          OR: [
            { targetType: 'POST', targetId: postId },
            { targetType: 'USER', targetId: actorId },
          ],
        },
      }),
    ]);
    return blocked + muted > 0;
  }

  private async tell(
    userId: string,
    n: { title: string; body: string; deepLink?: string; critical?: boolean },
  ): Promise<void> {
    try {
      await this.notifications.notify({
        userId,
        category: 'COMMUNITY',
        title: n.title,
        body: n.body,
        deepLink: n.deepLink,
        critical: n.critical,
      });
    } catch (e) {
      this.logger.warn(`Could not notify ${userId}: ${e instanceof Error ? e.message : String(e)}`);
    }
  }
}
