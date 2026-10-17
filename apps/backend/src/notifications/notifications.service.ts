import { InjectQueue } from '@nestjs/bullmq';
import { Injectable } from '@nestjs/common';
import { type DevicePlatform, type NotificationCategory } from '@prisma/client';
import { type Queue } from 'bullmq';
import { ApiException } from '../common/api.exception';
import { PrismaService } from '../prisma/prisma.service';

export const NOTIFICATION_CATEGORIES: readonly NotificationCategory[] = [
  'OPPORTUNITIES',
  'MENTORSHIP',
  'COMMUNITY',
  'LEARNING',
  'PROFILE',
  'MARKETPLACE',
  'SYSTEM',
];

export type Channel = 'in_app' | 'push' | 'email' | 'sms';

export interface NotifyInput {
  userId: string;
  category: NotificationCategory;
  title: string;
  body: string;
  /** In-app route the notification opens, e.g. `/opportunities/{id}`. Must start with a single `/`. */
  deepLink?: string;
  data?: Record<string, string | number | boolean | null>;
  /**
   * Security and account notices (password changed, suspension, payment failed). They ignore the member's
   * push and email preferences, because staying silent about them would be unsafe. Never use for marketing.
   */
  critical?: boolean;
  /** Also send a short SMS to the verified phone number. Only for time-critical messages. */
  sms?: boolean;
}

export interface NotifyResult {
  notificationId: string;
  /** Channels a delivery job was queued for. `in_app` is always present. */
  channels: Channel[];
}

const MAX_ACTIVE_DEVICES = 10;

/** In-app deep links are paths inside the app. Anything else could send a member off-platform. */
export const isInAppPath = (v: string): boolean => /^\/(?!\/)[^\s\\]*$/.test(v);

@Injectable()
export class NotificationsService {
  constructor(
    private readonly prisma: PrismaService,
    @InjectQueue('notifications') private readonly queue: Queue,
  ) {}

  /**
   * Store the in-app notification, then queue delivery for each other channel the member has enabled and
   * can receive on. Feature modules call this; nothing else sends a message to a member.
   */
  async notify(input: NotifyInput): Promise<NotifyResult> {
    if (input.deepLink !== undefined && !isInAppPath(input.deepLink)) {
      throw new Error(`Notification deep link must be an in-app path, got "${input.deepLink}".`);
    }
    const user = await this.prisma.user.findUnique({
      where: { id: input.userId },
      select: { id: true, email: true, emailVerifiedAt: true, phone: true, phoneVerifiedAt: true },
    });
    if (!user) throw ApiException.notFound('That member does not exist.');

    const notification = await this.prisma.notification.create({
      data: {
        userId: user.id,
        category: input.category,
        title: input.title,
        body: input.body,
        deepLink: input.deepLink ?? null,
        data: input.data ?? undefined,
      },
      select: { id: true },
    });

    const pref = await this.prisma.notificationPreference.findUnique({
      where: { userId_category: { userId: user.id, category: input.category } },
    });
    const pushOn = input.critical || (pref?.pushEnabled ?? true);
    const emailOn = input.critical || (pref?.emailEnabled ?? true);

    const channels: Channel[] = ['in_app'];
    const queued: Array<Promise<unknown>> = [];
    const enqueue = (channel: Exclude<Channel, 'in_app'>) => {
      channels.push(channel);
      queued.push(
        this.queue.add(
          `deliver-${channel}`,
          { notificationId: notification.id },
          { jobId: `${notification.id}-${channel}` },
        ),
      );
    };

    if (pushOn) {
      const devices = await this.prisma.deviceToken.count({
        where: { userId: user.id, revokedAt: null },
      });
      if (devices > 0) enqueue('push');
    }
    if (emailOn && user.email && user.emailVerifiedAt) enqueue('email');
    if (input.sms && user.phone && user.phoneVerifiedAt) enqueue('sms');

    await Promise.all(queued);
    return { notificationId: notification.id, channels };
  }

  // ---- preferences ----

  /** Effective preference for every category. Missing rows mean "on". */
  async preferences(userId: string) {
    const rows = await this.prisma.notificationPreference.findMany({ where: { userId } });
    const byCategory = new Map(rows.map((r) => [r.category, r]));
    return NOTIFICATION_CATEGORIES.map((category) => ({
      category,
      pushEnabled: byCategory.get(category)?.pushEnabled ?? true,
      emailEnabled: byCategory.get(category)?.emailEnabled ?? true,
    }));
  }

  async updatePreferences(
    userId: string,
    updates: Array<{ category: NotificationCategory; pushEnabled: boolean; emailEnabled: boolean }>,
  ) {
    await this.prisma.$transaction(
      updates.map((u) =>
        this.prisma.notificationPreference.upsert({
          where: { userId_category: { userId, category: u.category } },
          create: { userId, ...u },
          update: { pushEnabled: u.pushEnabled, emailEnabled: u.emailEnabled },
        }),
      ),
    );
    return this.preferences(userId);
  }

  // ---- devices ----

  /** Register (or refresh) a push token. A token that moves to another member's sign-in is reassigned. */
  async registerDevice(
    userId: string,
    input: { token: string; platform: DevicePlatform; appVersion?: string },
  ) {
    const device = await this.prisma.deviceToken.upsert({
      where: { token: input.token },
      create: {
        userId,
        token: input.token,
        platform: input.platform,
        appVersion: input.appVersion ?? null,
      },
      update: {
        userId,
        platform: input.platform,
        appVersion: input.appVersion ?? null,
        revokedAt: null,
        lastSeenAt: new Date(),
      },
      select: { id: true },
    });
    // Keep the newest few: old phones that never signed out should not receive pushes forever.
    const active = await this.prisma.deviceToken.findMany({
      where: { userId, revokedAt: null },
      orderBy: { lastSeenAt: 'desc' },
      select: { id: true },
    });
    const stale = active.slice(MAX_ACTIVE_DEVICES).map((d) => d.id);
    if (stale.length) {
      await this.prisma.deviceToken.updateMany({
        where: { id: { in: stale } },
        data: { revokedAt: new Date() },
      });
    }
    return device;
  }

  async removeDevice(userId: string, id: string): Promise<void> {
    const res = await this.prisma.deviceToken.updateMany({
      where: { id, userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    if (res.count === 0) throw ApiException.notFound('We could not find that device.');
  }
}
