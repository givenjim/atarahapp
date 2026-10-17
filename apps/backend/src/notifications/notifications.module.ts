import { Global, Module } from '@nestjs/common';
import { AppConfigService } from '../config/app-config.service';
import { NotificationDeliveryService } from './notification-delivery.service';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import {
  DevPushProvider,
  FcmPushProvider,
  PUSH_PROVIDER,
  type PushProvider,
  UnconfiguredPushProvider,
  firebaseMessaging,
} from './push';

/**
 * Global so any feature module can inject NotificationsService and call `notify()`. The delivery service and
 * `NotificationsProcessor` run in the worker process.
 */
@Global()
@Module({
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    NotificationDeliveryService,
    DevPushProvider,
    UnconfiguredPushProvider,
    {
      provide: PUSH_PROVIDER,
      inject: [AppConfigService, DevPushProvider, UnconfiguredPushProvider],
      useFactory: async (
        config: AppConfigService,
        dev: DevPushProvider,
        unconfigured: UnconfiguredPushProvider,
      ): Promise<PushProvider> => {
        if (config.fcmServiceAccountJson) {
          return new FcmPushProvider(await firebaseMessaging(config.fcmServiceAccountJson));
        }
        return config.isDeployed ? unconfigured : dev;
      },
    },
  ],
  exports: [NotificationsService, NotificationDeliveryService, PUSH_PROVIDER],
})
export class NotificationsModule {}
