import { Injectable, Logger } from '@nestjs/common';
import {
  type ModerationAction,
  type OpportunityOutcome,
  type PaymentPurpose,
  type PostAudience,
  type ReportTargetType,
} from '@prisma/client';

/** In-process domain events (P1-M8, P1-M9). Consumers: notifications now; search (a generated column) and analytics later. */
export type DomainEvent =
  | {
      type: 'PostCreated';
      postId: string;
      authorId: string;
      groupId: string | null;
      audience: PostAudience;
    }
  | {
      type: 'CommentCreated';
      commentId: string;
      postId: string;
      authorId: string;
      parentCommentId: string | null;
    }
  | { type: 'ReactionAdded'; postId: string; userId: string }
  | { type: 'OnboardingCompleted'; userId: string }
  | { type: 'ProfileCompleted'; userId: string }
  | { type: 'ProjectCreated'; userId: string; projectId: string }
  | { type: 'OpportunityViewed'; opportunityId: string; userId: string }
  | {
      type: 'SearchPerformed';
      userId: string;
      scope: string;
      resultCount: number;
      queryLength: number;
    }
  | { type: 'CourseStarted'; userId: string; courseId: string }
  | { type: 'LessonCompleted'; userId: string; courseId: string; lessonId: string }
  | { type: 'CourseCompleted'; userId: string; courseId: string; certificateId: string }
  | { type: 'OpportunityPublished'; opportunityId: string; actorId: string }
  | { type: 'OpportunityRejected'; opportunityId: string; actorId: string; reason: string }
  | { type: 'OpportunitySaved'; opportunityId: string; userId: string }
  | { type: 'OpportunityApplied'; opportunityId: string; userId: string }
  | {
      type: 'OpportunityCompleted';
      opportunityId: string;
      userId: string;
      outcome: OpportunityOutcome;
    }
  // Payments (P2-M1). Consumed by membership (P2-M2) and mentorship (P2-M5). Raised only after the change is committed.
  | {
      type: 'PaymentSucceeded';
      paymentId: string;
      purpose: PaymentPurpose;
      referenceType: string | null;
      referenceId: string | null;
      payerId: string;
      amountMinor: number;
      currency: string;
    }
  | {
      type: 'PaymentFailed';
      paymentId: string;
      purpose: PaymentPurpose;
      referenceType: string | null;
      referenceId: string | null;
      payerId: string;
      /** FAILED (declined, timed out, mismatch) or CANCELLED (the member dismissed the prompt). */
      status: 'FAILED' | 'CANCELLED';
      failureCode: string | null;
      failureReason: string | null;
    }
  | {
      type: 'PaymentRefunded';
      paymentId: string;
      refundId: string;
      purpose: PaymentPurpose;
      referenceType: string | null;
      referenceId: string | null;
      payerId: string;
      amountMinor: number;
      /** True once the whole payment has been refunded. */
      fullyRefunded: boolean;
    }
  | { type: 'ConnectionRequested'; connectionId: string; requesterId: string; addresseeId: string }
  | { type: 'ConnectionAccepted'; connectionId: string; requesterId: string; addresseeId: string }
  | {
      type: 'ReportSubmitted';
      reportId: string;
      caseId: string;
      reporterId: string;
      targetType: ReportTargetType;
      targetId: string;
    }
  | {
      type: 'ModerationActionTaken';
      caseId: string;
      action: ModerationAction;
      actorId: string;
      targetType: ReportTargetType;
      targetId: string;
      targetAuthorId: string | null;
      /** Reports closed by this decision whose reporters have not been told yet. */
      closedReportIds: string[];
    };

export type DomainEventType = DomainEvent['type'];
type Handler<T extends DomainEventType> = (
  event: Extract<DomainEvent, { type: T }>,
) => Promise<void>;

/**
 * A tiny typed bus. `emit` waits for every handler, and a failing handler is logged and never undoes the action
 * that raised the event (a notification problem must not fail a post).
 */
@Injectable()
export class DomainEventBus {
  private readonly logger = new Logger(DomainEventBus.name);
  private readonly handlers = new Map<DomainEventType, Array<(e: DomainEvent) => Promise<void>>>();

  on<T extends DomainEventType>(type: T, handler: Handler<T>): void {
    const list = this.handlers.get(type) ?? [];
    list.push(handler as (e: DomainEvent) => Promise<void>);
    this.handlers.set(type, list);
  }

  async emit(event: DomainEvent): Promise<void> {
    const list = this.handlers.get(event.type) ?? [];
    const results = await Promise.allSettled(list.map((h) => h(event)));
    for (const r of results) {
      if (r.status === 'rejected') {
        this.logger.error(
          `Handler for ${event.type} failed: ${r.reason instanceof Error ? r.reason.message : String(r.reason)}`,
        );
      }
    }
  }
}
