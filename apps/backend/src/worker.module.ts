import { Module } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { AuditModule } from './audit/audit.module';
import { buildLoggerParams } from './common/logger.config';
import { AppConfigService } from './config/app-config.service';
import { AppConfigModule } from './config/config.module';
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
    StorageModule,
    AuditModule,
    PlatformModule,
    QueuesModule,
    MediaModule,
    MessagingModule,
    NotificationsModule,
  ],
  providers: [SystemProcessor, MediaProcessor, NotificationsProcessor],
})
export class WorkerModule {}
