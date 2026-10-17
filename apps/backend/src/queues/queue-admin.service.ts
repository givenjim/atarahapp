import { InjectQueue } from '@nestjs/bullmq';
import { Injectable } from '@nestjs/common';
import { Queue } from 'bullmq';
import { ApiException } from '../common/api.exception';
import { QUEUE_NAMES, type QueueName } from './queues.constants';

export interface FailedJobView {
  id: string;
  name: string;
  failedReason: string;
  attemptsMade: number;
  failedAt: string | null;
}

export interface QueueCounts {
  waiting: number;
  active: number;
  delayed: number;
  failed: number;
  completed: number;
}

/**
 * Backs the admin "failed jobs" view (wired to an endpoint when admin auth lands in P0-M5/P0-M8).
 * Job payloads are never returned: they may contain personal data.
 */
@Injectable()
export class QueueAdminService {
  private readonly queues: Record<QueueName, Queue>;

  constructor(
    @InjectQueue('system') system: Queue,
    @InjectQueue('notifications') notifications: Queue,
    @InjectQueue('media') media: Queue,
    @InjectQueue('payments') payments: Queue,
    @InjectQueue('analytics') analytics: Queue,
    @InjectQueue('maintenance') maintenance: Queue,
  ) {
    this.queues = { system, notifications, media, payments, analytics, maintenance };
  }

  private queue(name: string): Queue {
    if (!(QUEUE_NAMES as readonly string[]).includes(name)) {
      throw ApiException.notFound('That queue does not exist.');
    }
    return this.queues[name as QueueName];
  }

  async counts(name: string): Promise<QueueCounts> {
    const c = await this.queue(name).getJobCounts(
      'waiting',
      'active',
      'delayed',
      'failed',
      'completed',
    );
    return {
      waiting: c.waiting ?? 0,
      active: c.active ?? 0,
      delayed: c.delayed ?? 0,
      failed: c.failed ?? 0,
      completed: c.completed ?? 0,
    };
  }

  async failed(name: string, start = 0, end = 49): Promise<FailedJobView[]> {
    const jobs = await this.queue(name).getFailed(start, end);
    return jobs.map((j) => ({
      id: String(j.id),
      name: j.name,
      failedReason: j.failedReason ?? 'unknown',
      attemptsMade: j.attemptsMade,
      failedAt: j.finishedOn ? new Date(j.finishedOn).toISOString() : null,
    }));
  }

  async retry(name: string, jobId: string): Promise<void> {
    const job = await this.queue(name).getJob(jobId);
    if (!job) throw ApiException.notFound('That job does not exist.');
    await job.retry();
  }
}
