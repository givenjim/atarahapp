import { InjectQueue, Processor, WorkerHost } from '@nestjs/bullmq';
import { type OnApplicationBootstrap } from '@nestjs/common';
import { type Job, type Queue } from 'bullmq';
import { OpportunityJobsService } from '../../opportunities/jobs/opportunity-jobs.service';
import {
  OPP_COUNTS_JOB,
  OPP_EXPIRE_JOB,
  OPP_LINKS_JOB,
  OPP_REMINDERS_JOB,
} from '../../opportunities/jobs/job-names';
import {
  LEARNING_LINKS_JOB,
  LearningJobsService,
} from '../../learning/jobs/learning-jobs.service';
import { AccountJobsService } from '../../account/jobs/account-jobs.service';
import {
  ACC_BROADCAST_JOB,
  ACC_CONTACT_RECONCILE_JOB,
  ACC_EXPORT_SWEEP_JOB,
  ACC_NOTIF_RETENTION_JOB,
  ACC_PURGE_JOB,
  ACC_SAVED_CLEANUP_JOB,
} from '../../account/jobs/job-names';
import { EXPORT_JOB } from '../../account/export.service';
import { CommunityJobsService } from './community-jobs.service';
import { BACKLOG_JOB, LINK_PREVIEW_JOB, RECONCILE_JOB } from './job-names';

/**
 * Consumes the `maintenance` queue in the worker process: the community jobs and (P1-M9) the opportunity jobs. One
 * processor owns the queue because every worker on a queue would otherwise receive the other module's jobs.
 */
@Processor('maintenance')
export class CommunityProcessor extends WorkerHost implements OnApplicationBootstrap {
  constructor(
    private readonly jobs: CommunityJobsService,
    private readonly opportunityJobs: OpportunityJobsService,
    private readonly learningJobs: LearningJobsService,
    private readonly accountJobs: AccountJobsService,
    @InjectQueue('maintenance') private readonly queue: Queue,
  ) {
    super();
  }

  /** Repeating jobs are registered once per deployment; upserting keeps one schedule however many workers start. */
  async onApplicationBootstrap(): Promise<void> {
    // 23:00 UTC is 02:00 in Nairobi.
    await this.queue.upsertJobScheduler(
      RECONCILE_JOB,
      { pattern: '0 23 * * *' },
      { name: RECONCILE_JOB },
    );
    await this.queue.upsertJobScheduler(
      BACKLOG_JOB,
      { pattern: '0 * * * *' },
      { name: BACKLOG_JOB },
    );
    // Opportunities: hourly expiry, 08:00 EAT (05:00 UTC) reminders, Monday 03:00 EAT (00:00 UTC) link health,
    // nightly counts at 02:30 EAT.
    await this.queue.upsertJobScheduler(
      OPP_EXPIRE_JOB,
      { pattern: '5 * * * *' },
      { name: OPP_EXPIRE_JOB },
    );
    await this.queue.upsertJobScheduler(
      OPP_REMINDERS_JOB,
      { pattern: '0 5 * * *' },
      { name: OPP_REMINDERS_JOB },
    );
    await this.queue.upsertJobScheduler(
      OPP_LINKS_JOB,
      { pattern: '0 0 * * 1' },
      { name: OPP_LINKS_JOB },
    );
    // Skill Labs: Monday 03:30 EAT (00:30 UTC) embed and link availability.
    await this.queue.upsertJobScheduler(
      LEARNING_LINKS_JOB,
      { pattern: '30 0 * * 1' },
      { name: LEARNING_LINKS_JOB },
    );
    await this.queue.upsertJobScheduler(
      OPP_COUNTS_JOB,
      { pattern: '30 23 * * *' },
      { name: OPP_COUNTS_JOB },
    );
    // Account and notifications (P1-M11): broadcasts every minute, export sweep every 10 minutes, contact changes every
    // 15 minutes, saved-item cleanup at 03:00 EAT (00:00 UTC), notification retention at 03:15 EAT, deletion purge at
    // 03:30 EAT (all times UTC below).
    for (const [name, pattern] of [
      [ACC_BROADCAST_JOB, '* * * * *'],
      [ACC_EXPORT_SWEEP_JOB, '*/10 * * * *'],
      [ACC_CONTACT_RECONCILE_JOB, '*/15 * * * *'],
      [ACC_SAVED_CLEANUP_JOB, '0 0 * * *'],
      [ACC_NOTIF_RETENTION_JOB, '15 0 * * *'],
      [ACC_PURGE_JOB, '30 0 * * *'],
    ] as const) {
      await this.queue.upsertJobScheduler(name, { pattern }, { name });
    }
  }

  async process(job: Job<{ postId?: string; requestId?: string }>): Promise<unknown> {
    switch (job.name) {
      case LINK_PREVIEW_JOB:
        return this.jobs.fetchLinkPreview(String(job.data.postId));
      case RECONCILE_JOB:
        return this.jobs.reconcileCounters();
      case BACKLOG_JOB:
        return this.jobs.alertModerationBacklog();
      case OPP_EXPIRE_JOB:
        return this.opportunityJobs.expireOverdue();
      case OPP_REMINDERS_JOB:
        return this.opportunityJobs.sendDeadlineReminders();
      case OPP_LINKS_JOB:
        return this.opportunityJobs.checkLinks();
      case OPP_COUNTS_JOB:
        return this.opportunityJobs.refreshCounts();
      case LEARNING_LINKS_JOB:
        return this.learningJobs.checkLinks();
      case EXPORT_JOB:
        return this.accountJobs.buildExport(String(job.data.requestId));
      case ACC_BROADCAST_JOB:
        return this.accountJobs.dispatchBroadcasts();
      case ACC_EXPORT_SWEEP_JOB:
        return this.accountJobs.exportSweep();
      case ACC_CONTACT_RECONCILE_JOB:
        return this.accountJobs.reconcileContacts();
      case ACC_SAVED_CLEANUP_JOB:
        return this.accountJobs.cleanSaved();
      case ACC_NOTIF_RETENTION_JOB:
        return this.accountJobs.notificationRetention();
      case ACC_PURGE_JOB:
        return this.accountJobs.purgeAccounts();
      default:
        throw new Error(`Unknown maintenance job "${job.name}"`);
    }
  }
}
