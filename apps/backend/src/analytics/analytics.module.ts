import { Module } from '@nestjs/common';
import { AnalyticsListener } from './analytics.listener';
import { AnalyticsService } from './analytics.service';

/** Analytics (P1-M12): the event log, its writer and the bus listener. Admin reads live in the admin module. */
@Module({
  providers: [AnalyticsService, AnalyticsListener],
  exports: [AnalyticsService],
})
export class AnalyticsModule {}
