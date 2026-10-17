import { Module } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { AccessModule } from './access/access.module';
import { AdminModule } from './admin/admin.module';
import { AuditModule } from './audit/audit.module';
import { CreativeModule } from './creative/creative.module';
import { buildLoggerParams } from './common/logger.config';
import { RateLimitModule } from './common/rate-limit.module';
import { AppConfigService } from './config/app-config.service';
import { AppConfigModule } from './config/config.module';
import { PlatformModule } from './feature-flags/platform.module';
import { HealthModule } from './health/health.module';
import { IdentityModule } from './identity/identity.module';
import { MediaModule } from './media/media.module';
import { MessagingModule } from './messaging/messaging.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PrismaModule } from './prisma/prisma.module';
import { PublicContentModule } from './public-content/public-content.module';
import { QueuesModule } from './queues/queues.module';
import { RedisModule } from './redis/redis.module';
import { StorageModule } from './storage/storage.module';

@Module({
  imports: [
    AppConfigModule,
    LoggerModule.forRootAsync({
      inject: [AppConfigService],
      useFactory: (config: AppConfigService) => buildLoggerParams(config),
    }),
    PrismaModule,
    RedisModule,
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
    MediaModule,
    NotificationsModule,
    PublicContentModule,
    CreativeModule,
    HealthModule,
  ],
})
export class AppModule {}
