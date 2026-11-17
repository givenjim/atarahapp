import { Module } from '@nestjs/common';
import { CommunityJobsModule } from '../../community/jobs/community-jobs.module';
import { OpportunityJobsService } from './opportunity-jobs.service';

/** Worker-side opportunity job logic (the processor lives with the maintenance processor). Reuses the safe fetcher. */
@Module({
  imports: [CommunityJobsModule],
  providers: [OpportunityJobsService],
  exports: [OpportunityJobsService],
})
export class OpportunityJobsModule {}
