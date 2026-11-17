import { InjectQueue, Processor, WorkerHost } from '@nestjs/bullmq';
import { type OnApplicationBootstrap } from '@nestjs/common';
import { type Job, type Queue } from 'bullmq';
import { SuspensionExpiryService } from '../admin/suspension-expiry.service';
import { AnalyticsJobsService } from './analytics-jobs.service';

export const ANALYTICS_AGGREGATE_JOB = 'analytics-aggregate';
export const ANALYTICS_PARTITIONS_JOB = 'analytics-partitions';
export const ANALYTICS_PURGE_JOB = 'analytics-purge';
export const SUSPENSIONS_EXPIRE_JOB = 'suspensions-expire';

/**
 * Consumes the `analytics` queue in the worker process. It also carries the admin housekeeping job that ends temporary
 * suspensions (one processor owns the queue, so every job here is for it). Handlers are idempotent; failures retry
 * with the platform backoff and land in the failed-jobs view.
 */
@Processor('analytics')
export class AnalyticsProcessor extends WorkerHost implements OnApplicationBootstrap {
  constructor(
    private readonly jobs: AnalyticsJobsService,
    private readonly suspensions: SuspensionExpiryService,
    @InjectQueue('analytics') private readonly queue: Queue,
  ) {
    super();
  }

  async onApplicationBootstrap(): Promise<void> {
    // 21:30 UTC is 00:30 in Nairobi: after midnight, so the day just ended is complete.
    await this.queue.upsertJobScheduler(
      ANALYTICS_AGGREGATE_JOB,
      { pattern: '30 21 * * *' },
      { name: ANALYTICS_AGGREGATE_JOB },
    );
    await this.queue.upsertJobScheduler(
      ANALYTICS_PARTITIONS_JOB,
      { pattern: '10 0 * * *' },
      { name: ANALYTICS_PARTITIONS_JOB },
    );
    await this.queue.upsertJobScheduler(
      ANALYTICS_PURGE_JOB,
      { pattern: '40 21 * * 0' },
      { name: ANALYTICS_PURGE_JOB },
    );
    await this.queue.upsertJobScheduler(
      SUSPENSIONS_EXPIRE_JOB,
      { pattern: '15 * * * *' },
      { name: SUSPENSIONS_EXPIRE_JOB },
    );
  }

  async process(job: Job): Promise<unknown> {
    switch (job.name) {
      case ANALYTICS_AGGREGATE_JOB:
        return this.jobs.aggregate();
      case ANALYTICS_PARTITIONS_JOB:
        return this.jobs.ensurePartitions();
      case ANALYTICS_PURGE_JOB:
        return this.jobs.purge();
      case SUSPENSIONS_EXPIRE_JOB:
        return this.suspensions.reactivateExpired();
      default:
        throw new Error(`Unknown analytics job "${job.name}"`);
    }
  }
}
