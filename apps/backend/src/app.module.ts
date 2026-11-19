import { Module } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { AccessModule } from './access/access.module';
import { AccountModule } from './account/account.module';
import { ActivityModule } from './activity/activity.module';
import { BroadcastsModule } from './broadcasts/broadcasts.module';
import { HelpModule } from './help/help.module';
import { SavedModule } from './saved/saved.module';
import { AdminModule } from './admin/admin.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { AuditModule } from './audit/audit.module';
import { CommunityCoreModule } from './community-core/community-core.module';
import { CommunityModule } from './community/community.module';
import { PeopleModule } from './community/people.module';
import { ContentModule } from './content/content.module';
import { CreativeModule } from './creative/creative.module';
import { CvModule } from './cv/cv.module';
import { DiscoverModule } from './discover/discover.module';
import { buildLoggerParams } from './common/logger.config';
import { RateLimitModule } from './common/rate-limit.module';
import { AppConfigService } from './config/app-config.service';
import { AppConfigModule } from './config/config.module';
import { MarketplaceModule } from './marketplace/marketplace.module';
import { OpportunitiesModule } from './opportunities/opportunities.module';
import { PaymentsModule } from './payments/payments.module';
import { PlatformModule } from './feature-flags/platform.module';
import { HealthModule } from './health/health.module';
import { IdentityModule } from './identity/identity.module';
import { LearningModule } from './learning/learning.module';
import { MentorshipModule } from './mentorship/mentorship.module';
import { MediaModule } from './media/media.module';
import { MetricsModule } from './metrics/metrics.module';
import { MessagingModule } from './messaging/messaging.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PrismaModule } from './prisma/prisma.module';
import { PublicContentModule } from './public-content/public-content.module';
import { QueuesModule } from './queues/queues.module';
import { RedisModule } from './redis/redis.module';
import { StorageModule } from './storage/storage.module';
import { SupabaseModule } from './supabase/supabase.module';

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
    MessagingModule,
    // Global guard order matters: rate limit first, then authentication and authorisation.
    RateLimitModule,
    AccessModule,
    IdentityModule,
    AdminModule,
    AnalyticsModule,
    MediaModule,
    NotificationsModule,
    PublicContentModule,
    CommunityCoreModule,
    // Before CreativeModule: GET /creatives/suggestions must be registered ahead of GET /creatives/:handle.
    PeopleModule,
    CreativeModule,
    ContentModule,
    DiscoverModule,
    CommunityModule,
    OpportunitiesModule,
    MarketplaceModule,
    LearningModule,
    MentorshipModule,
    SavedModule,
    ActivityModule,
    AccountModule,
    CvModule,
    HelpModule,
    BroadcastsModule,
    PaymentsModule,
    HealthModule,
    MetricsModule,
  ],
})
export class AppModule {}
