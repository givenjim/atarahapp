import { Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { DomainEventBus } from '../community-core/domain-events';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';

/**
 * Turns opportunity events into notifications. Saving, applying and completing are the member's own actions and say
 * nothing to anyone; the messages that matter are to a provider whose submission was published or sent back. (Members
 * hear about listings through deadline reminders, not a broadcast for every new one.) A notification problem never
 * fails the action that raised the event.
 */
@Injectable()
export class OpportunityNotificationsListener implements OnModuleInit {
  private readonly log = new Logger(OpportunityNotificationsListener.name);

  constructor(
    private readonly bus: DomainEventBus,
    private readonly notifications: NotificationsService,
    private readonly prisma: PrismaService,
  ) {}

  onModuleInit(): void {
    this.bus.on('OpportunityPublished', async (e) => {
      const o = await this.submission(e.opportunityId);
      if (!o) return;
      await this.tell(o.ownerId, {
        title: 'Your opportunity is live',
        body: `${o.title} is now published on Atarah.`,
        deepLink: `/opportunities/${e.opportunityId}`,
      });
    });

    this.bus.on('OpportunityRejected', async (e) => {
      const o = await this.submission(e.opportunityId);
      if (!o) return;
      await this.tell(o.ownerId, {
        title: 'Changes needed on your opportunity',
        body: `${o.title} was not published yet: ${e.reason}`,
      });
    });
  }

  /** The provider account that submitted a listing, when there is one. Staff-created listings have no recipient. */
  private async submission(
    opportunityId: string,
  ): Promise<{ ownerId: string; title: string } | null> {
    const o = await this.prisma.opportunity.findUnique({
      where: { id: opportunityId },
      select: { title: true, createdById: true, provider: { select: { ownerUserId: true } } },
    });
    const owner = o?.provider.ownerUserId;
    if (!o || !owner || o.createdById !== owner) return null;
    return { ownerId: owner, title: o.title };
  }

  private async tell(
    userId: string,
    n: { title: string; body: string; deepLink?: string },
  ): Promise<void> {
    try {
      await this.notifications.notify({ userId, category: 'OPPORTUNITIES', ...n });
    } catch (e) {
      this.log.warn(
        `Notification to ${userId} failed: ${e instanceof Error ? e.message : String(e)}`,
      );
    }
  }
}
