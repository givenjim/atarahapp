import { Injectable, Logger } from '@nestjs/common';
import { Prisma, type BroadcastTarget, type NotificationBroadcast } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type AudiencePreviewDto,
  type BroadcastDto,
  type BroadcastFieldsDto,
  type BroadcastsQueryDto,
  type PrivacyRequestDto,
  type PrivacyRequestsQueryDto,
} from './broadcasts.dto';

export interface Actor {
  userId: string;
  ip?: string | undefined;
  requestId?: string | undefined;
}

const BATCH = 200;

/**
 * Staff announcements to many members (P1-M11). A broadcast targets everyone, a role, a discipline or a county; it is
 * sent as soon as the scheduler sees it or at its scheduled time. Each recipient gets an ordinary notification (so their
 * own preferences apply) and the unique dispatch key makes a repeated run send nothing twice. Every step is audited.
 */
@Injectable()
export class BroadcastsService {
  private readonly log = new Logger(BroadcastsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
    private readonly audit: AuditService,
  ) {}

  // ---- audience --------------------------------------------------------------------------------------------

  private audienceWhere(target: BroadcastTarget, value: string | null): Prisma.UserWhereInput {
    const base: Prisma.UserWhereInput = {
      status: 'ACTIVE',
      deletedAt: null,
      // Not the placeholder that authors what deleted members wrote.
      OR: [{ statusReason: null }, { statusReason: { not: 'SYSTEM_PLACEHOLDER' } }],
    };
    switch (target) {
      case 'ALL':
        return base;
      case 'ROLE':
        return { ...base, roles: { some: { revokedAt: null, role: { key: value as never } } } };
      case 'DISCIPLINE':
        return {
          ...base,
          creativeProfile: {
            OR: [
              { primaryDisciplineId: value },
              { disciplines: { some: { disciplineId: value! } } },
            ],
          },
        };
      case 'COUNTY':
        return { ...base, creativeProfile: { countyId: value } };
    }
  }

  private async assertTarget(target: BroadcastTarget, value: string | undefined): Promise<void> {
    if (target === 'ALL') return;
    if (!value)
      throw ApiException.validation('Choose who should get it.', { field: 'targetValue' });
    const ok =
      target === 'ROLE'
        ? (await this.prisma.role.count({ where: { key: value as never } })) > 0
        : target === 'DISCIPLINE'
          ? (await this.prisma.discipline.count({ where: { id: value } })) > 0
          : (await this.prisma.county.count({ where: { id: value } })) > 0;
    if (!ok)
      throw ApiException.validation('That audience does not exist.', { field: 'targetValue' });
  }

  async preview(target: BroadcastTarget, value: string | undefined): Promise<AudiencePreviewDto> {
    await this.assertTarget(target, value);
    return {
      recipients: await this.prisma.user.count({
        where: this.audienceWhere(target, value ?? null),
      }),
    };
  }

  // ---- CRUD ------------------------------------------------------------------------------------------------

  private async label(b: NotificationBroadcast): Promise<string | null> {
    if (!b.targetValue) return null;
    if (b.target === 'ROLE')
      return (
        (
          await this.prisma.role.findUnique({
            where: { key: b.targetValue as never },
            select: { name: true },
          })
        )?.name ?? b.targetValue
      );
    if (b.target === 'DISCIPLINE')
      return (
        (
          await this.prisma.discipline.findUnique({
            where: { id: b.targetValue },
            select: { name: true },
          })
        )?.name ?? null
      );
    return (
      (
        await this.prisma.county.findUnique({
          where: { id: b.targetValue },
          select: { name: true },
        })
      )?.name ?? null
    );
  }

  private async dto(b: NotificationBroadcast): Promise<BroadcastDto> {
    return {
      id: b.id,
      title: b.title,
      body: b.body,
      deepLink: b.deepLink,
      category: b.category,
      target: b.target,
      targetValue: b.targetValue,
      targetLabel: await this.label(b),
      scheduledAt: b.scheduledAt,
      status: b.status,
      recipientCount: b.recipientCount,
      sentAt: b.sentAt,
      createdAt: b.createdAt,
    };
  }

  async create(actor: Actor, dto: BroadcastFieldsDto, now = new Date()): Promise<BroadcastDto> {
    await this.assertTarget(dto.target, dto.targetValue);
    const scheduledAt = dto.scheduledAt ? new Date(dto.scheduledAt) : null;
    if (scheduledAt && scheduledAt.getTime() < now.getTime() - 60_000) {
      throw ApiException.validation('Pick a time in the future.', { field: 'scheduledAt' });
    }
    const row = await this.prisma.$transaction(async (tx) => {
      const b = await tx.notificationBroadcast.create({
        data: {
          title: dto.title.trim(),
          body: dto.body.trim(),
          deepLink: dto.deepLink ?? null,
          category: dto.category ?? 'SYSTEM',
          target: dto.target,
          targetValue: dto.target === 'ALL' ? null : (dto.targetValue ?? null),
          scheduledAt,
          createdById: actor.userId,
        },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'broadcast.create',
          entityType: 'notification_broadcast',
          entityId: b.id,
          after: { title: b.title, target: b.target, targetValue: b.targetValue, scheduledAt },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
      return b;
    });
    return this.dto(row);
  }

  async list(q: BroadcastsQueryDto) {
    const where: Prisma.NotificationBroadcastWhereInput = q.status ? { status: q.status } : {};
    const [total, rows] = await Promise.all([
      this.prisma.notificationBroadcast.count({ where }),
      this.prisma.notificationBroadcast.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
    ]);
    return { items: await Promise.all(rows.map((r) => this.dto(r))), meta: pageMeta(q, total) };
  }

  async get(id: string): Promise<BroadcastDto> {
    const b = await this.prisma.notificationBroadcast.findUnique({ where: { id } });
    if (!b) throw ApiException.notFound('That broadcast does not exist.');
    return this.dto(b);
  }

  async cancel(actor: Actor, id: string): Promise<BroadcastDto> {
    const b = await this.prisma.notificationBroadcast.findUnique({ where: { id } });
    if (!b) throw ApiException.notFound('That broadcast does not exist.');
    if (b.status !== 'SCHEDULED')
      throw ApiException.invalidState('Only a broadcast that has not started can be cancelled.');
    const out = await this.prisma.$transaction(async (tx) => {
      const r = await tx.notificationBroadcast.update({
        where: { id },
        data: { status: 'CANCELLED' },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'broadcast.cancel',
          entityType: 'notification_broadcast',
          entityId: id,
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
      return r;
    });
    return this.dto(out);
  }

  // ---- sending (worker) ------------------------------------------------------------------------------------

  /** Every minute: send the broadcasts that are due. A claim by status makes two workers safe. */
  async dispatchDue(now = new Date()): Promise<{ sent: number; recipients: number }> {
    const due = await this.prisma.notificationBroadcast.findMany({
      where: { status: 'SCHEDULED', OR: [{ scheduledAt: null }, { scheduledAt: { lte: now } }] },
      orderBy: { createdAt: 'asc' },
      take: 5,
    });
    let sent = 0;
    let recipients = 0;
    for (const b of due) {
      const claimed = await this.prisma.notificationBroadcast.updateMany({
        where: { id: b.id, status: 'SCHEDULED' },
        data: { status: 'SENDING' },
      });
      if (claimed.count === 0) continue;
      try {
        recipients += await this.fanOut(b, now);
        sent += 1;
      } catch (e) {
        this.log.error(`Broadcast ${b.id} failed: ${e instanceof Error ? e.message : String(e)}`);
        // Back to SCHEDULED so the next run continues (recipients already told are skipped by their dispatch keys).
        await this.prisma.notificationBroadcast.update({
          where: { id: b.id },
          data: { status: 'SCHEDULED' },
        });
      }
    }
    return { sent, recipients };
  }

  async fanOut(b: NotificationBroadcast, now = new Date()): Promise<number> {
    const where = this.audienceWhere(b.target, b.targetValue);
    let cursor: string | undefined;
    let told = 0;
    for (;;) {
      const users = await this.prisma.user.findMany({
        where,
        select: { id: true },
        orderBy: { id: 'asc' },
        take: BATCH,
        ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
      });
      if (users.length === 0) break;
      for (const u of users) {
        const dedupeKey = `broadcast:${b.id}:${u.id}`;
        try {
          await this.prisma.notificationDispatch.create({
            data: { dedupeKey, userId: u.id, channel: 'in_app' },
          });
        } catch (e) {
          if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002') continue;
          throw e;
        }
        try {
          await this.notifications.notify({
            userId: u.id,
            category: b.category,
            type: 'broadcast',
            title: b.title,
            body: b.body,
            ...(b.deepLink ? { deepLink: b.deepLink } : {}),
            data: { broadcastId: b.id },
          });
          told += 1;
        } catch (e) {
          await this.prisma.notificationDispatch.deleteMany({ where: { dedupeKey } });
          this.log.warn(
            `Broadcast ${b.id} to ${u.id} failed: ${e instanceof Error ? e.message : String(e)}`,
          );
        }
      }
      cursor = users[users.length - 1]!.id;
      if (users.length < BATCH) break;
    }
    const total = await this.prisma.notificationDispatch.count({
      where: { dedupeKey: { startsWith: `broadcast:${b.id}:` } },
    });
    await this.prisma.notificationBroadcast.update({
      where: { id: b.id },
      data: { status: 'SENT', sentAt: now, recipientCount: total },
    });
    return told;
  }

  // ---- privacy requests log --------------------------------------------------------------------------------

  /** Exports and deletions in one list, newest first. Deletion rows stay after the account is purged (id only). */
  async privacyRequests(
    q: PrivacyRequestsQueryDto,
  ): Promise<{ items: PrivacyRequestDto[]; meta: ReturnType<typeof pageMeta> }> {
    const wantExport = !q.kind || q.kind === 'EXPORT';
    const wantDeletion = !q.kind || q.kind === 'DELETION';
    const [exports, deletions] = await Promise.all([
      wantExport
        ? this.prisma.dataExportRequest
            .findMany({
              where: q.status ? { status: q.status as never } : {},
              orderBy: { requestedAt: 'desc' },
              take: 500,
              include: { user: { select: { fullName: true } } },
            })
            .catch(() => [])
        : [],
      wantDeletion
        ? this.prisma.accountDeletionRequest
            .findMany({
              where: q.status ? { status: q.status as never } : {},
              orderBy: { requestedAt: 'desc' },
              take: 500,
            })
            .catch(() => [])
        : [],
    ]);
    const names = new Map(
      (
        await this.prisma.user.findMany({
          where: { id: { in: deletions.map((d) => d.userId) } },
          select: { id: true, fullName: true },
        })
      ).map((u) => [u.id, u.fullName]),
    );
    const items: PrivacyRequestDto[] = [
      ...exports.map((e) => ({
        kind: 'EXPORT' as const,
        id: e.id,
        userId: e.userId,
        memberName: e.user.fullName,
        status: e.status,
        requestedAt: e.requestedAt,
        dueAt: e.expiresAt,
        completedAt: e.readyAt,
      })),
      ...deletions.map((d) => ({
        kind: 'DELETION' as const,
        id: d.id,
        userId: d.userId,
        memberName: names.get(d.userId) ?? null,
        status: d.status,
        requestedAt: d.requestedAt,
        dueAt: d.purgeAfter,
        completedAt: d.purgedAt ?? d.cancelledAt,
      })),
    ].sort((a, b) => b.requestedAt.getTime() - a.requestedAt.getTime());
    const skip = (q.page - 1) * q.limit;
    return { items: items.slice(skip, skip + q.limit), meta: pageMeta(q, items.length) };
  }
}
