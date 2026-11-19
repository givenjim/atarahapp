import { InjectQueue, Processor, WorkerHost } from '@nestjs/bullmq';
import { type OnApplicationBootstrap } from '@nestjs/common';
import { type Job, type Queue } from 'bullmq';
import {
  VER_EXPIRE_JOB,
  VER_PURGE_JOB,
  VER_REFERENCES_JOB,
  VerificationJobsService,
} from './verification-jobs.service';

/**
 * Consumes the `verification` queue in the worker process (P2-M6): badge expiry (hourly), government ID retention
 * (daily, 03:45 EAT) and reference expiry (daily). One processor owns the queue.
 */
@Processor('verification')
export class VerificationProcessor extends WorkerHost implements OnApplicationBootstrap {
  constructor(
    private readonly jobs: VerificationJobsService,
    @InjectQueue('verification') private readonly queue: Queue,
  ) {
    super();
  }

  async onApplicationBootstrap(): Promise<void> {
    // 00:45 UTC is 03:45 in Nairobi.
    for (const [name, pattern] of [
      [VER_EXPIRE_JOB, '20 * * * *'],
      [VER_PURGE_JOB, '45 0 * * *'],
      [VER_REFERENCES_JOB, '50 0 * * *'],
    ] as const) {
      await this.queue.upsertJobScheduler(name, { pattern }, { name });
    }
  }

  async process(job: Job): Promise<unknown> {
    switch (job.name) {
      case VER_EXPIRE_JOB:
        return this.jobs.expire();
      case VER_PURGE_JOB:
        return this.jobs.purgeIds();
      case VER_REFERENCES_JOB:
        return this.jobs.expireReferences();
      default:
        throw new Error(`Unknown verification job: ${job.name}`);
    }
  }
}
