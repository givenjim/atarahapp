import { Injectable, Logger } from '@nestjs/common';
import { type OpportunityOutcome, type OpportunityTrackingStatus } from '@prisma/client';
import { pageMeta, toSkipTake } from '../common/pagination';
import { NotificationsService } from '../notifications/notifications.service';
import {
  CARD_INCLUDE,
  OpportunityViewsService,
  trackingState,
} from '../opportunities/opportunity-views.service';
import { RuleEngineService } from '../opportunities/rule-engine.service';
import { PrismaService } from '../prisma/prisma.service';
import { SavedService } from '../saved/saved.service';
import { type ActivityDto, type ApplicationsQueryDto, type ResumeCardDto } from './activity.dto';

const MAX_GAP_CANDIDATES = 8;

const OUTCOME_LABEL: Record<OpportunityOutcome, string> = {
  AWARDED: 'Awarded',
  NOT_SELECTED: 'Not selected',
  WITHDRAWN: 'Withdrawn',
  UNKNOWN: 'Outcome not known',
};

const shortDate = (d: Date) =>
  d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', timeZone: 'Africa/Nairobi' });

/**
 * The Activity hub: what the member left unfinished and a count behind every tile. It reads each module through that
 * module's own services or its tables read-only; modules that do not exist yet (Mentorship, Marketplace) have no tile
 * here, and the app shows "Soon · P2" for them.
 */
@Injectable()
export class ActivityService {
  private readonly log = new Logger(ActivityService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly views: OpportunityViewsService,
    private readonly rules: RuleEngineService,
    private readonly notifications: NotificationsService,
    private readonly saved: SavedService,
  ) {}

  async activity(userId: string, now = new Date()): Promise<ActivityDto> {
    const safe = async <T>(name: string, fn: () => Promise<T>, fallback: T): Promise<T> => {
      try {
        return await fn();
      } catch (e) {
        this.log.warn(`Activity part "${name}" failed: ${(e as Error).message}`);
        return fallback;
      }
    };
    const [lesson, gap, draft, counts] = await Promise.all([
      safe('lesson', () => this.unfinishedLesson(userId), null),
      safe('gap', () => this.opportunityWithGap(userId, now), null),
      safe('draft', () => this.draftProject(userId), null),
      safe('counts', () => this.counts(userId), {
        saved: 0,
        applications: 0,
        unreadNotifications: 0,
        learningInProgress: 0,
        portfolio: 0,
        pendingConnections: 0,
      }),
    ]);
    const resume = [lesson, gap, draft]
      .filter((c): c is ResumeCardDto => c !== null)
      .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime());
    return { resume, counts };
  }

  /** The lesson the member touched last and did not finish, with the course's progress. */
  private async unfinishedLesson(userId: string): Promise<ResumeCardDto | null> {
    const p = await this.prisma.lessonProgress.findFirst({
      where: {
        userId,
        status: 'IN_PROGRESS',
        lesson: { course: { content: { status: 'PUBLISHED' } } },
      },
      orderBy: { updatedAt: 'desc' },
      include: {
        lesson: {
          include: { course: { include: { content: { select: { id: true, title: true } } } } },
        },
      },
    });
    if (!p) return null;
    const course = p.lesson.course;
    const done = await this.prisma.lessonProgress.count({
      where: { userId, status: 'COMPLETED', lesson: { courseId: course.contentId } },
    });
    return {
      kind: 'LESSON',
      title: p.lesson.title,
      subtitle: course.content.title,
      progressPercent: course.lessonCount > 0 ? Math.round((done / course.lessonCount) * 100) : 0,
      path: `/learning/courses/${course.contentId}`,
      updatedAt: p.updatedAt,
    };
  }

  /** A saved or started opportunity (still open) where something the member can fix is missing, soonest deadline first. */
  private async opportunityWithGap(userId: string, now: Date): Promise<ResumeCardDto | null> {
    const rows = await this.prisma.opportunityTracking.findMany({
      where: {
        userId,
        status: { in: ['SAVED', 'IN_PROGRESS'] },
        opportunity: {
          status: 'PUBLISHED',
          OR: [{ deadlineAt: null }, { deadlineAt: { gt: now } }],
        },
      },
      include: { opportunity: { select: { id: true, title: true, deadlineAt: true } } },
      orderBy: [{ opportunity: { deadlineAt: { sort: 'asc', nulls: 'last' } } }, { id: 'asc' }],
      take: MAX_GAP_CANDIDATES,
    });
    for (const t of rows) {
      const gap = await this.rules.gap(userId, t.opportunityId);
      if (gap.blockingMissingCount > 0) {
        const n = gap.blockingMissingCount;
        return {
          kind: 'OPPORTUNITY_GAP',
          title: t.opportunity.title,
          subtitle: `Missing ${n} requirement${n === 1 ? '' : 's'}`,
          progressPercent: null,
          path: `/opportunities/${t.opportunityId}`,
          updatedAt: t.updatedAt,
        };
      }
    }
    return null;
  }

  private async draftProject(userId: string): Promise<ResumeCardDto | null> {
    const d = await this.prisma.project.findFirst({
      where: { status: 'DRAFT', deletedAt: null, profile: { userId } },
      orderBy: { updatedAt: 'desc' },
      select: { id: true, title: true, updatedAt: true },
    });
    if (!d) return null;
    return {
      kind: 'DRAFT_PROJECT',
      title: d.title || 'Untitled project',
      subtitle: 'Draft in your portfolio',
      progressPercent: null,
      path: `/portfolio/${d.id}/edit`,
      updatedAt: d.updatedAt,
    };
  }

  private async counts(userId: string): Promise<ActivityDto['counts']> {
    const [saved, applications, unread, learning, portfolio, pending] = await Promise.all([
      this.saved.counts(userId),
      this.prisma.opportunityTracking.count({
        where: { userId, status: { in: ['IN_PROGRESS', 'APPLIED', 'COMPLETED'] } },
      }),
      this.notifications.unreadCount(userId),
      this.prisma.enrolment.count({
        where: { userId, completedAt: null, course: { content: { status: 'PUBLISHED' } } },
      }),
      this.prisma.project.count({
        where: { status: 'PUBLISHED', deletedAt: null, hiddenAt: null, profile: { userId } },
      }),
      this.prisma.connection.count({ where: { addresseeId: userId, status: 'PENDING' } }),
    ]);
    return {
      saved: saved.total,
      applications,
      unreadNotifications: unread.unread,
      learningInProgress: learning,
      portfolio,
      pendingConnections: pending,
    };
  }

  // ---- applications -------------------------------------------------------------------------------------

  /** Tracked opportunities the member started, applied for or finished, most recently touched first. */
  async applications(userId: string, q: ApplicationsQueryDto, now = new Date()) {
    const where = {
      userId,
      status: { in: ['IN_PROGRESS', 'APPLIED', 'COMPLETED'] as OpportunityTrackingStatus[] },
    };
    const [total, rows] = await Promise.all([
      this.prisma.opportunityTracking.count({ where }),
      this.prisma.opportunityTracking.findMany({
        where,
        include: { opportunity: { include: CARD_INCLUDE } },
        orderBy: [{ updatedAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
    ]);
    const cards = await this.views.cards(
      rows.map((r) => r.opportunity),
      userId,
      now,
    );
    const items = rows.map((r, i) => ({
      opportunity: cards[i]!,
      tracking: trackingState(r),
      status: r.status,
      metaLine:
        r.status === 'COMPLETED'
          ? `Completed · ${OUTCOME_LABEL[r.outcome ?? 'UNKNOWN']}`
          : r.status === 'APPLIED'
            ? `Applied ${r.appliedAt ? shortDate(r.appliedAt) : ''}`.trim()
            : 'In progress',
    }));
    return { items, meta: pageMeta(q, total) };
  }
}
