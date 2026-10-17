import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { type Job } from 'bullmq';

/** Minimal processor proving the worker process consumes jobs end to end. */
@Processor('system')
export class SystemProcessor extends WorkerHost {
  private readonly logger = new Logger(SystemProcessor.name);

  async process(job: Job<{ echo?: string }>): Promise<{ pong: true; echo: string | null }> {
    if (job.name === 'ping') {
      this.logger.log(`ping received (job ${job.id})`);
      return { pong: true, echo: job.data.echo ?? null };
    }
    throw new Error(`Unknown system job "${job.name}"`);
  }
}
