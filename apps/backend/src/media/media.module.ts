import { Module } from '@nestjs/common';
import { MediaController } from './media.controller';
import { MediaService } from './media.service';
import { VideoTranscoder } from './video-transcode';

/** The processor (`MediaProcessor`) is registered by the worker process, not the API. */
@Module({
  controllers: [MediaController],
  providers: [MediaService, VideoTranscoder],
  exports: [MediaService, VideoTranscoder],
})
export class MediaModule {}
