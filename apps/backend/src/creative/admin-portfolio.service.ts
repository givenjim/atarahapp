import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { AuditService } from '../audit/audit.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { CreativeProfileService } from './creative-profile.service';
import { type AdminProjectsQueryDto } from './portfolio.dto';
import { PortfolioService, PROJECT_INCLUDE } from './portfolio.service';

export interface AdminActor {
  userId: string;
  ip?: string;
  requestId?: string;
}

const OWNER = {
  profile: { select: { userId: true, displayName: true, handle: true } },
} satisfies Prisma.ProjectInclude;

/** Portfolio moderation: see any member's projects, hide one with a reason, restore it. Every action is audited. */
@Injectable()
export class AdminPortfolioService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly portfolio: PortfolioService,
    private readonly profiles: CreativeProfileService,
    private readonly audit: AuditService,
    private readonly notifications: NotificationsService,
  ) {}

  async list(q: AdminProjectsQueryDto) {
    const term = q.q?.trim();
    const where: Prisma.ProjectWhereInput = {
      deletedAt: null,
      // Drafts are private to the member until published; moderators review what others can see.
      status: 'PUBLISHED',
      ...(q.hiddenOnly ? { hiddenAt: { not: null } } : {}),
      ...(term
        ? {
            OR: [
              { title: { contains: term, mode: 'insensitive' } },
              { profile: { displayName: { contains: term, mode: 'insensitive' } } },
              { profile: { handle: { contains: term.replace(/^@/, ''), mode: 'insensitive' } } },
            ],
          }
        : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.project.count({ where }),
      this.prisma.project.findMany({
        where,
        include: { ...PROJECT_INCLUDE, ...OWNER },
        orderBy: [{ publishedAt: 'desc' }],
        ...toSkipTake(q),
      }),
    ]);
    const cards = await this.portfolio.cards(rows);
    return {
      items: rows.map((r, i) => ({
        ...cards[i]!,
        ownerUserId: r.profile.userId,
        ownerName: r.profile.displayName,
        ownerHandle: r.profile.handle,
        hiddenReason: r.hiddenReason,
        hiddenAt: r.hiddenAt,
      })),
      meta: pageMeta(q, total),
    };
  }

  async get(id: string) {
    const row = await this.prisma.project.findFirst({
      where: { id, deletedAt: null, status: 'PUBLISHED' },
      include: { ...PROJECT_INCLUDE, ...OWNER },
    });
    if (!row) throw ApiException.notFound('We could not find that project.');
    return {
      ...(await this.portfolio.detail(row, true)),
      ownerUserId: row.profile.userId,
      ownerName: row.profile.displayName,
      ownerHandle: row.profile.handle,
      hiddenAt: row.hiddenAt,
    };
  }

  async hide(actor: AdminActor, id: string, reason: string) {
    return this.change(actor, id, 'hide', reason.trim());
  }

  async restore(actor: AdminActor, id: string) {
    return this.change(actor, id, 'restore');
  }

  private async change(actor: AdminActor, id: string, action: 'hide' | 'restore', reason?: string) {
    const row = await this.prisma.project.findFirst({
      where: { id, deletedAt: null, status: 'PUBLISHED' },
      include: { profile: { select: { id: true, userId: true } } },
    });
    if (!row) throw ApiException.notFound('We could not find that project.');
    const hiding = action === 'hide';
    if (hiding === (row.hiddenAt !== null)) {
      throw ApiException.invalidState(
        hiding ? 'That project is already hidden.' : 'That project is not hidden.',
      );
    }
    await this.prisma.transaction(async (tx) => {
      await tx.project.update({
        where: { id },
        data: hiding
          ? { hiddenAt: new Date(), hiddenReason: reason, hiddenById: actor.userId }
          : { hiddenAt: null, hiddenReason: null, hiddenById: null },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: `portfolio.project.${action}`,
          entityType: 'Project',
          entityId: id,
          before: { hidden: !hiding },
          after: { hidden: hiding, reason: reason ?? null, ownerUserId: row.profile.userId },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    await this.profiles.refreshCompletion(row.profile.id);
    // A notification failing must never undo a moderation decision.
    await this.notifications
      .notify({
        userId: row.profile.userId,
        category: 'PROFILE',
        title: hiding ? 'A project was hidden' : 'A project is visible again',
        body: hiding
          ? `“${row.title}” was hidden by a moderator: ${reason}. Edit it and contact support if you think this is a mistake.`
          : `“${row.title}” is visible on your profile again.`,
        deepLink: '/portfolio',
      })
      .catch(() => undefined);
    return this.get(id);
  }
}
