import { Module } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { AccountJobsModule } from './account/jobs/account-jobs.module';
import { AnalyticsJobsModule } from './analytics/analytics-jobs.module';
import { AnalyticsProcessor } from './analytics/analytics.processor';
import { AuditModule } from './audit/audit.module';
import { buildLoggerParams } from './common/logger.config';
import { AppConfigService } from './config/app-config.service';
import { AppConfigModule } from './config/config.module';
import { CommunityCoreModule } from './community-core/community-core.module';
import { CommunityJobsModule } from './community/jobs/community-jobs.module';
import { CommunityProcessor } from './community/jobs/community.processor';
import { OpportunityJobsModule } from './opportunities/jobs/opportunity-jobs.module';
import { LearningJobsModule } from './learning/jobs/learning-jobs.module';
import { MediaModule } from './media/media.module';
import { MediaProcessor } from './media/media.processor';
import { MessagingModule } from './messaging/messaging.module';
import { NotificationsModule } from './notifications/notifications.module';
import { NotificationsProcessor } from './notifications/notifications.processor';
import { PlatformModule } from './feature-flags/platform.module';
import { PrismaModule } from './prisma/prisma.module';
import { QueuesModule } from './queues/queues.module';
import { SystemProcessor } from './queues/system.processor';
import { RedisModule } from './redis/redis.module';
import { StorageModule } from './storage/storage.module';
import { SupabaseModule } from './supabase/supabase.module';

/** Worker process: same infrastructure modules as the API, plus the queue processors. No HTTP server. */
@Module({
  imports: [
    AppConfigModule,
    LoggerModule.forRootAsync({
      inject: [AppConfigService],
      useFactory: (config: AppConfigService) => buildLoggerParams(config),
    }),
    PrismaModule,
    RedisModule,
    SupabaseModule,
    StorageModule,
    AuditModule,
    PlatformModule,
    QueuesModule,
    MediaModule,
    MessagingModule,
    NotificationsModule,
    CommunityCoreModule,
    CommunityJobsModule,
    OpportunityJobsModule,
    LearningJobsModule,
    AccountJobsModule,
    AnalyticsJobsModule,
  ],
  providers: [SystemProcessor, MediaProcessor, NotificationsProcessor, CommunityProcessor, AnalyticsProcessor],
})
export class WorkerModule {}
