import { InjectQueue, Processor, WorkerHost } from '@nestjs/bullmq';
import { type OnApplicationBootstrap } from '@nestjs/common';
import { type Job, type Queue } from 'bullmq';
import { PaymentsService } from './payments.service';

export const PAYMENTS_RECONCILE_JOB = 'payments-reconcile';

/**
 * Consumes the `payments` queue in the worker process. Every minute it asks the provider about payments whose time limit
 * has passed without a callback (the status query fallback), fails prompts that never reached the provider, and re-checks
 * recent timeouts for a late success. Idempotent: running it twice, or on two workers, applies each change once.
 */
@Processor('payments')
export class PaymentsProcessor extends WorkerHost implements OnApplicationBootstrap {
  constructor(
    private readonly payments: PaymentsService,
    @InjectQueue('payments') private readonly queue: Queue,
  ) {
    super();
  }

  async onApplicationBootstrap(): Promise<void> {
    await this.queue.upsertJobScheduler(
      PAYMENTS_RECONCILE_JOB,
      { pattern: '* * * * *' },
      { name: PAYMENTS_RECONCILE_JOB },
    );
  }

  async process(job: Job): Promise<unknown> {
    switch (job.name) {
      case PAYMENTS_RECONCILE_JOB:
        return this.payments.reconcilePending();
      default:
        throw new Error(`Unknown payments job: ${job.name}`);
    }
  }
}
