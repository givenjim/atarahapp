import { Processor, WorkerHost } from '@nestjs/bullmq';
import { type Job } from 'bullmq';
import { NotificationDeliveryService } from './notification-delivery.service';

/** Consumes the `notifications` queue in the worker process. */
@Processor('notifications')
export class NotificationsProcessor extends WorkerHost {
  constructor(private readonly delivery: NotificationDeliveryService) {
    super();
  }

  async process(job: Job<{ notificationId: string }>): Promise<void> {
    const id = job.data.notificationId;
    switch (job.name) {
      case 'deliver-push':
        return this.delivery.deliverPush(id);
      case 'deliver-email':
        return this.delivery.deliverEmail(id);
      case 'deliver-sms':
        return this.delivery.deliverSms(id);
      default:
        throw new Error(`Unknown notifications job "${job.name}"`);
    }
  }
}
