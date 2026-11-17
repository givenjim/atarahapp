import { InjectQueue } from '@nestjs/bullmq';
import { Inject, Injectable } from '@nestjs/common';
import { type DevicePlatform, type NotificationCategory } from '@prisma/client';
import { type Queue } from 'bullmq';
import { type Redis } from 'ioredis';
import { ApiException } from '../common/api.exception';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';

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
  /** What happened, a dotted key such as `opportunity.reminder`. The app picks the icon from it. */
  type?: string;
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
    @Inject(REDIS) private readonly redis: Redis,
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
        type: input.type ?? null,
        title: input.title,
        body: input.body,
        deepLink: input.deepLink ?? null,
        data: input.data ?? undefined,
      },
      select: { id: true },
    });

    await this.invalidateUnread(user.id);

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

  // ---- the notification centre ----

  private unreadKey = (userId: string) => `notif:unread:${userId}`;

  async invalidateUnread(userId: string): Promise<void> {
    await this.redis.del(this.unreadKey(userId)).catch(() => undefined);
  }

  /** Unread total and per category. Cached in Redis (invalidated on every write); the database is the fallback. */
  async unreadCount(
    userId: string,
  ): Promise<{ unread: number; byCategory: Record<string, number> }> {
    const hit = await this.redis.get(this.unreadKey(userId)).catch(() => null);
    if (hit) {
      try {
        return JSON.parse(hit) as { unread: number; byCategory: Record<string, number> };
      } catch {
        // A damaged entry is recomputed.
      }
    }
    const groups = await this.prisma.notification.groupBy({
      by: ['category'],
      where: { userId, readAt: null },
      _count: { _all: true },
    });
    const byCategory = Object.fromEntries(groups.map((g) => [g.category, g._count._all]));
    const out = { unread: groups.reduce((n, g) => n + g._count._all, 0), byCategory };
    await this.redis
      .set(this.unreadKey(userId), JSON.stringify(out), 'EX', 300)
      .catch(() => undefined);
    return out;
  }

  /** Newest first. `group` is TODAY or EARLIER by the Nairobi calendar day, so the app can draw the two headings. */
  async list(
    userId: string,
    q: { category?: NotificationCategory; unreadOnly?: boolean; page: number; limit: number },
    now = new Date(),
  ) {
    const where = {
      userId,
      ...(q.category ? { category: q.category } : {}),
      ...(q.unreadOnly ? { readAt: null } : {}),
    };
    const [total, rows, unread] = await Promise.all([
      this.prisma.notification.count({ where }),
      this.prisma.notification.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        skip: (q.page - 1) * q.limit,
        take: q.limit,
      }),
      this.unreadCount(userId),
    ]);
    const day = (d: Date) => Math.floor((d.getTime() + 3 * 3_600_000) / 86_400_000);
    return {
      items: rows.map((n) => ({
        id: n.id,
        category: n.category,
        type: n.type,
        title: n.title,
        body: n.body,
        deepLink: n.deepLink,
        data: (n.data ?? null) as Record<string, string | number | boolean | null> | null,
        read: n.readAt !== null,
        createdAt: n.createdAt,
        group: day(n.createdAt) === day(now) ? ('TODAY' as const) : ('EARLIER' as const),
      })),
      meta: { page: q.page, limit: q.limit, total, unread: unread.unread },
    };
  }

  async markRead(userId: string, id: string): Promise<{ unread: number }> {
    const res = await this.prisma.notification.updateMany({
      where: { id, userId, readAt: null },
      data: { readAt: new Date() },
    });
    if (res.count === 0) {
      const exists = await this.prisma.notification.count({ where: { id, userId } });
      if (!exists) throw ApiException.notFound('We could not find that notification.');
    }
    await this.invalidateUnread(userId);
    return { unread: (await this.unreadCount(userId)).unread };
  }

  async markAllRead(
    userId: string,
    category?: NotificationCategory,
  ): Promise<{ unread: number; marked: number }> {
    const res = await this.prisma.notification.updateMany({
      where: { userId, readAt: null, ...(category ? { category } : {}) },
      data: { readAt: new Date() },
    });
    await this.invalidateUnread(userId);
    return { unread: (await this.unreadCount(userId)).unread, marked: res.count };
  }

  /** Daily: notifications older than 180 days are deleted (retention). */
  async purgeOld(now = new Date(), days = 180): Promise<number> {
    const res = await this.prisma.notification.deleteMany({
      where: { createdAt: { lt: new Date(now.getTime() - days * 86_400_000) } },
    });
    return res.count;
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
