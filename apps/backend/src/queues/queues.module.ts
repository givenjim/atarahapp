import { BullModule } from '@nestjs/bullmq';
import { Global, Module } from '@nestjs/common';
import { type ConnectionOptions } from 'bullmq';
import { AppConfigService } from '../config/app-config.service';
import { QueueAdminService } from './queue-admin.service';
import { DEFAULT_JOB_OPTIONS, QUEUE_NAMES } from './queues.constants';
import { redisConnectionFromUrl } from './redis-connection';

@Global()
@Module({
  imports: [
    BullModule.forRootAsync({
      inject: [AppConfigService],
      useFactory: (config: AppConfigService) => ({
        // bullmq bundles its own ioredis types; the options object is structurally identical.
        connection: redisConnectionFromUrl(
          config.redisUrl,
          config.skipConnect,
        ) as unknown as ConnectionOptions,
        prefix: `atarah:${config.environment}`,
        defaultJobOptions: DEFAULT_JOB_OPTIONS,
      }),
    }),
    BullModule.registerQueue(...QUEUE_NAMES.map((name) => ({ name }))),
  ],
  providers: [QueueAdminService],
  exports: [BullModule, QueueAdminService],
})
export class QueuesModule {}
