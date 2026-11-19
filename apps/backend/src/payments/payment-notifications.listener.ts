import { Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { DomainEventBus } from '../community-core/domain-events';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { formatMoney } from './payment-money';

/**
 * Tells the payer what happened to their money. Payment notices are SYSTEM notifications and critical (they ignore the
 * push and email preferences: staying silent about money would be unsafe). A notification problem never undoes a payment.
 */
@Injectable()
export class PaymentNotificationsListener implements OnModuleInit {
  private readonly log = new Logger(PaymentNotificationsListener.name);

  constructor(
    private readonly bus: DomainEventBus,
    private readonly notifications: NotificationsService,
    private readonly prisma: PrismaService,
  ) {}

  onModuleInit(): void {
    this.bus.on('PaymentSucceeded', async (e) => {
      await this.tell(e.payerId, 'payment.succeeded', {
        title: 'Payment received',
        body: `We received ${formatMoney(e.amountMinor, e.currency)}. Thank you.`,
        data: { paymentId: e.paymentId, purpose: e.purpose },
      });
    });

    this.bus.on('PaymentFailed', async (e) => {
      await this.tell(e.payerId, 'payment.failed', {
        title: e.status === 'CANCELLED' ? 'Payment cancelled' : 'Payment did not go through',
        body: e.failureReason ?? 'The payment did not go through. Please try again.',
        data: { paymentId: e.paymentId, purpose: e.purpose },
      });
    });

    this.bus.on('PaymentRefunded', async (e) => {
      const p = await this.prisma.payment.findUnique({
        where: { id: e.paymentId },
        select: { currency: true },
      });
      await this.tell(e.payerId, 'payment.refunded', {
        title: 'Refund sent',
        body: `${formatMoney(e.amountMinor, p?.currency ?? 'KES')} has been refunded to you.`,
        data: { paymentId: e.paymentId, refundId: e.refundId },
      });
    });
  }

  private async tell(
    userId: string,
    type: string,
    n: { title: string; body: string; data: Record<string, string> },
  ): Promise<void> {
    try {
      await this.notifications.notify({ userId, category: 'SYSTEM', type, critical: true, ...n });
    } catch (e) {
      this.log.warn(
        `Notification to ${userId} failed: ${e instanceof Error ? e.message : String(e)}`,
      );
    }
  }
}
