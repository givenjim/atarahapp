import { Injectable, type OnModuleInit } from '@nestjs/common';
import { DomainEventBus } from '../community-core/domain-events';
import { PrismaService } from '../prisma/prisma.service';
import { lengthBucket, resultBucket } from './analytics.events';
import { AnalyticsService } from './analytics.service';

const SCOPES = new Set([
  'creatives',
  'articles',
  'posts',
  'opportunities',
  'learning',
  'marketplace',
  'mentors',
]);

/**
 * Turns domain events into analytics events. Handlers never throw (the bus would only log it) and never block the
 * action that raised the event: `track` is fire-and-forget. `registration` is recorded by a database trigger on
 * `users`, because the account is created by Supabase Auth, outside the API.
 */
@Injectable()
export class AnalyticsListener implements OnModuleInit {
  constructor(
    private readonly bus: DomainEventBus,
    private readonly analytics: AnalyticsService,
    private readonly prisma: PrismaService,
  ) {}

  onModuleInit(): void {
    this.bus.on('OnboardingCompleted', async (e) => {
      this.analytics.track('onboarding_completed', {}, e.userId);
    });
    this.bus.on('ProfileCompleted', async (e) => {
      this.analytics.track('profile_completed', {}, e.userId);
    });
    this.bus.on('ProjectCreated', async (e) => {
      this.analytics.track('project_created', {}, e.userId);
    });
    this.bus.on('PostCreated', async (e) => {
      this.analytics.track(
        'post_created',
        { audience: e.audience, inGroup: e.groupId !== null },
        e.authorId,
      );
    });
    this.bus.on('ConnectionAccepted', async (e) => {
      this.analytics.track('connection_created', {}, e.requesterId);
    });
    this.bus.on('OpportunityViewed', (e) => this.opportunity('opportunity_viewed', e));
    this.bus.on('OpportunitySaved', (e) => this.opportunity('opportunity_saved', e));
    this.bus.on('OpportunityApplied', (e) => this.opportunity('opportunity_applied', e));
    this.bus.on('CourseStarted', async (e) => {
      this.analytics.track('course_started', { courseId: e.courseId }, e.userId);
    });
    this.bus.on('CourseCompleted', async (e) => {
      this.analytics.track('course_completed', { courseId: e.courseId }, e.userId);
    });
    this.bus.on('SearchPerformed', async (e) => {
      this.analytics.track(
        'search_performed',
        {
          scope: (SCOPES.has(e.scope) ? e.scope : 'all') as 'all',
          results: resultBucket(e.resultCount),
          queryLength: lengthBucket(e.queryLength),
        },
        e.userId,
      );
    });
  }

  private async opportunity(
    name: 'opportunity_viewed' | 'opportunity_saved' | 'opportunity_applied',
    e: { opportunityId: string; userId: string },
  ): Promise<void> {
    const o = await this.prisma.opportunity.findUnique({
      where: { id: e.opportunityId },
      select: { type: true },
    });
    if (o) this.analytics.track(name, { opportunityId: e.opportunityId, type: o.type }, e.userId);
  }
}
