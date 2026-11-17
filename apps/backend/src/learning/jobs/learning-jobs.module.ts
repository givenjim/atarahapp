import { Module } from '@nestjs/common';
import { CommunityJobsModule } from '../../community/jobs/community-jobs.module';
import { LearningJobsService } from './learning-jobs.service';

/** Worker-side learning job logic (the processor lives with the maintenance processor). Reuses the safe fetcher. */
@Module({
  imports: [CommunityJobsModule],
  providers: [LearningJobsService],
  exports: [LearningJobsService],
})
export class LearningJobsModule {}
