import { Module } from '@nestjs/common';
import { CommunityJobsService } from './community-jobs.service';
import { SafeFetcher } from './safe-fetch';

/** Worker-side community job logic. The worker module adds the BullMQ processor on top; integration tests import this
 * module to run the jobs directly. */
@Module({
  providers: [SafeFetcher, CommunityJobsService],
  exports: [SafeFetcher, CommunityJobsService],
})
export class CommunityJobsModule {}
