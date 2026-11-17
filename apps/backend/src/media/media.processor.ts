import { Processor, WorkerHost } from '@nestjs/bullmq';
import { type Job } from 'bullmq';
import { MediaService } from './media.service';
import { VideoTranscoder } from './video-transcode';

/** Consumes the `media` queue in the worker process. Retries use the platform default backoff. */
@Processor('media')
export class MediaProcessor extends WorkerHost {
  constructor(
    private readonly media: MediaService,
    private readonly video: VideoTranscoder,
  ) {
    super();
  }

  async process(job: Job<{ assetId: string }>): Promise<void> {
    if (job.name === 'process') return this.media.process(job.data.assetId);
    if (job.name === 'transcode') {
      await this.video.transcode(job.data.assetId);
      return;
    }
    throw new Error(`Unknown media job "${job.name}"`);
  }
}
