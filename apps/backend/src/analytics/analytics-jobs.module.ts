import { Module } from '@nestjs/common';
import { SuspensionExpiryService } from '../admin/suspension-expiry.service';
import { AnalyticsJobsService } from './analytics-jobs.service';

/** Worker-side housekeeping logic (the processor is registered by the worker module). */
@Module({
  providers: [AnalyticsJobsService, SuspensionExpiryService],
  exports: [AnalyticsJobsService, SuspensionExpiryService],
})
export class AnalyticsJobsModule {}
