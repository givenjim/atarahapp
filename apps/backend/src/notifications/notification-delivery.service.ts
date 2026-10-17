import { Inject, Injectable, Logger } from '@nestjs/common';
import { AppConfigService } from '../config/app-config.service';
import {
  EMAIL_PROVIDER,
  type EmailProvider,
  SMS_PROVIDER,
  type SmsProvider,
} from '../messaging/messaging';
import { PrismaService } from '../prisma/prisma.service';
import { renderNotificationEmail } from './notification-email';
import { PUSH_PROVIDER, type PushProvider } from './push';

/**
 * Runs inside the worker. Each method delivers one notification on one channel. Failures throw, so BullMQ
 * retries with exponential backoff; a notification that no longer needs delivery (member deleted, devices
 * gone, email removed) is skipped quietly.
 */
@Injectable()
export class NotificationDeliveryService {
  private readonly logger = new Logger(NotificationDeliveryService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfigService,
    @Inject(PUSH_PROVIDER) private readonly push: PushProvider,
    @Inject(EMAIL_PROVIDER) private readonly email: EmailProvider,
    @Inject(SMS_PROVIDER) private readonly sms: SmsProvider,
  ) {}

  private load(notificationId: string) {
    return this.prisma.notification.findUnique({
      where: { id: notificationId },
      include: {
        user: {
          select: {
            email: true,
            emailVerifiedAt: true,
            phone: true,
            phoneVerifiedAt: true,
            status: true,
          },
        },
      },
    });
  }

  async deliverPush(notificationId: string): Promise<void> {
    const n = await this.load(notificationId);
    if (!n || n.user.status === 'SUSPENDED' || n.user.status === 'DELETED') return;
    const devices = await this.prisma.deviceToken.findMany({
      where: { userId: n.userId, revokedAt: null },
      select: { token: true },
    });
    if (devices.length === 0) return;

    const data: Record<string, string> = { notificationId: n.id, category: n.category };
    if (n.deepLink) data.deepLink = n.deepLink;
    const { invalidTokens } = await this.push.send({
      tokens: devices.map((d) => d.token),
      title: n.title,
      body: n.body,
      data,
    });
    if (invalidTokens.length) {
      await this.prisma.deviceToken.updateMany({
        where: { token: { in: invalidTokens } },
        data: { revokedAt: new Date() },
      });
      this.logger.log(`Revoked ${invalidTokens.length} invalid push token(s)`);
    }
  }

  async deliverEmail(notificationId: string): Promise<void> {
    const n = await this.load(notificationId);
    if (!n || !n.user.email || !n.user.emailVerifiedAt) return;
    if (n.user.status === 'SUSPENDED' || n.user.status === 'DELETED') return;
    const link = n.deepLink ? `${this.config.appLinkBaseUrl}${n.deepLink}` : undefined;
    const { subject, text, html } = renderNotificationEmail({ title: n.title, body: n.body, link });
    await this.email.send({ to: n.user.email, subject, text, html });
  }

  async deliverSms(notificationId: string): Promise<void> {
    const n = await this.load(notificationId);
    if (!n || !n.user.phone || !n.user.phoneVerifiedAt) return;
    const text = `Atarah: ${n.title}. ${n.body}`.slice(0, 160);
    await this.sms.send({ to: n.user.phone, text });
  }
}
