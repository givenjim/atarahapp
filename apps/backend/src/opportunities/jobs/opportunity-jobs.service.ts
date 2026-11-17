import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { SafeFetcher, UnsafeUrlError } from '../../community/jobs/safe-fetch';
import { NotificationsService } from '../../notifications/notifications.service';
import { PrismaService } from '../../prisma/prisma.service';
import { refreshProviderCounts } from '../admin-opportunities.service';
import { DAY_MS, eatDaysUntil, REMINDER_DAYS } from '../opportunity-logic';

const LINK_BATCH = 200;
/** A listing is re-checked at most once a week. */
const LINK_RECHECK_DAYS = 6;
const LINK_CHECK_RETENTION_DAYS = 90;
/** Servers that refuse automated visitors answer 401, 403 or 429: that says nothing about the link, so it is not flagged. */
const NOT_A_VERDICT = new Set([401, 403, 429]);

const isUnique = (e: unknown) =>
  e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002';

export interface ReminderResult {
  considered: number;
  sent: number;
  skipped: number;
}

/** The scheduled work of the Opportunities module. Runs in the worker; integration tests call the methods directly. */
@Injectable()
export class OpportunityJobsService {
  private readonly log = new Logger(OpportunityJobsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
    private readonly fetcher: SafeFetcher,
  ) {}

  /** Hourly: published listings past their deadline become EXPIRED, then provider counts follow. */
  async expireOverdue(now = new Date()): Promise<{ expired: number }> {
    const overdue = await this.prisma.opportunity.findMany({
      where: { status: 'PUBLISHED', deadlineAt: { lte: now } },
      select: { id: true, providerId: true },
    });
    if (overdue.length === 0) return { expired: 0 };
    await this.prisma.$transaction(async (tx) => {
      await tx.opportunity.updateMany({
        where: { id: { in: overdue.map((o) => o.id) }, status: 'PUBLISHED' },
        data: { status: 'EXPIRED', featuredUntil: null },
      });
      await refreshProviderCounts(tx, [...new Set(overdue.map((o) => o.providerId))]);
    });
    this.log.log(`Expired ${overdue.length} opportunities past their deadline`);
    return { expired: overdue.length };
  }

  /**
   * Daily at 08:00 EAT: members who saved or started an opportunity are reminded 7 days and 1 day before the deadline
   * (Nairobi calendar days). A member who switched both push and email off for Opportunities is not messaged, and the
   * unique `notification_dispatches` key means running the job twice (or two workers) sends each reminder once.
   */
  async sendDeadlineReminders(now = new Date()): Promise<ReminderResult> {
    const horizon = new Date(now.getTime() + (Math.max(...REMINDER_DAYS) + 1) * DAY_MS);
    const trackings = await this.prisma.opportunityTracking.findMany({
      where: {
        status: { in: ['SAVED', 'IN_PROGRESS'] },
        user: { status: 'ACTIVE', deletedAt: null },
        opportunity: { status: 'PUBLISHED', deadlineAt: { gt: now, lte: horizon } },
      },
      select: {
        userId: true,
        opportunityId: true,
        opportunity: { select: { title: true, deadlineAt: true } },
      },
    });
    const result: ReminderResult = { considered: trackings.length, sent: 0, skipped: 0 };
    const optedOut = await this.optedOutUsers(trackings.map((t) => t.userId));

    for (const t of trackings) {
      const days = eatDaysUntil(t.opportunity.deadlineAt!, now);
      if (!(REMINDER_DAYS as readonly number[]).includes(days)) continue;
      if (optedOut.has(t.userId)) {
        result.skipped += 1;
        continue;
      }
      const dedupeKey = `opp-reminder:${t.userId}:${t.opportunityId}:${days}`;
      try {
        await this.prisma.notificationDispatch.create({
          data: { dedupeKey, userId: t.userId, channel: 'in_app' },
        });
      } catch (e) {
        if (isUnique(e)) {
          result.skipped += 1;
          continue;
        }
        throw e;
      }
      try {
        await this.notifications.notify({
          userId: t.userId,
          category: 'OPPORTUNITIES',
          title: days === 1 ? 'Closes tomorrow' : 'One week left',
          body:
            days === 1
              ? `${t.opportunity.title} closes tomorrow. Finish your application today.`
              : `${t.opportunity.title} closes in 7 days. Check what is still missing.`,
          deepLink: `/opportunities/${t.opportunityId}`,
          data: { opportunityId: t.opportunityId, daysLeft: days },
        });
        result.sent += 1;
      } catch (e) {
        // Free the key so the next run can try again.
        await this.prisma.notificationDispatch.deleteMany({ where: { dedupeKey } });
        this.log.warn(
          `Reminder for ${t.opportunityId} to ${t.userId} failed: ${e instanceof Error ? e.message : String(e)}`,
        );
      }
    }
    return result;
  }

  private async optedOutUsers(userIds: string[]): Promise<Set<string>> {
    if (userIds.length === 0) return new Set();
    const prefs = await this.prisma.notificationPreference.findMany({
      where: {
        userId: { in: [...new Set(userIds)] },
        category: 'OPPORTUNITIES',
        pushEnabled: false,
        emailEnabled: false,
      },
      select: { userId: true },
    });
    return new Set(prefs.map((p) => p.userId));
  }

  /**
   * Weekly: checks the application link of published and pending listings that have not been checked this week. It only
   * flags (`linkStatus`, a check row for admins); it never unpublishes, edits or removes anything.
   */
  async checkLinks(now = new Date()): Promise<{ checked: number; broken: number }> {
    const cutoff = new Date(now.getTime() - LINK_RECHECK_DAYS * DAY_MS);
    const due = await this.prisma.opportunity.findMany({
      where: {
        status: { in: ['PUBLISHED', 'PENDING_REVIEW'] },
        applicationMethod: 'EXTERNAL_WEBSITE',
        applicationUrl: { not: null },
        OR: [{ lastCheckedAt: null }, { lastCheckedAt: { lt: cutoff } }],
      },
      select: { id: true, applicationUrl: true },
      orderBy: [{ lastCheckedAt: { sort: 'asc', nulls: 'first' } }, { id: 'asc' }],
      take: LINK_BATCH,
    });
    let broken = 0;
    for (const o of due) {
      const url = o.applicationUrl!;
      let httpStatus: number | null = null;
      let error: string | null = null;
      let result: 'OK' | 'BROKEN' = 'OK';
      try {
        const res = await this.fetcher.probe(url);
        httpStatus = res.status;
        if (res.status >= 400 && !NOT_A_VERDICT.has(res.status)) {
          result = 'BROKEN';
          error = `The site answered ${res.status}.`;
        }
      } catch (e) {
        result = 'BROKEN';
        error =
          e instanceof UnsafeUrlError
            ? e.message
            : `Could not reach the site (${(e as Error).message}).`;
      }
      if (result === 'BROKEN') broken += 1;
      await this.prisma.$transaction([
        this.prisma.externalLinkCheck.create({
          data: { opportunityId: o.id, url, httpStatus, result, error },
        }),
        this.prisma.opportunity.update({
          where: { id: o.id },
          data: { linkStatus: result, lastCheckedAt: now },
        }),
      ]);
    }
    await this.prisma.externalLinkCheck.deleteMany({
      where: { checkedAt: { lt: new Date(now.getTime() - LINK_CHECK_RETENTION_DAYS * DAY_MS) } },
    });
    return { checked: due.length, broken };
  }

  /** Nightly: provider counts (published listings per provider). County counts are computed when read. */
  async refreshCounts(): Promise<{ providersFixed: number }> {
    return { providersFixed: await refreshProviderCounts(this.prisma) };
  }
}
