import { Injectable } from '@nestjs/common';
import { type AccountStatus, Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { SessionService } from '../identity/session.service';
import { PrismaService } from '../prisma/prisma.service';
import { type AdminAuditQueryDto, type AdminUsersQueryDto } from './admin.dto';

interface Actor {
  userId: string;
  ip?: string;
  requestId?: string;
}

const USER_SELECT = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  status: true,
  statusReason: true,
  lastLoginAt: true,
  createdAt: true,
  roles: { where: { revokedAt: null }, select: { role: { select: { key: true } } } },
} satisfies Prisma.UserSelect;

type UserRow = Prisma.UserGetPayload<{ select: typeof USER_SELECT }>;

const toView = (u: UserRow) => ({
  id: u.id,
  fullName: u.fullName,
  email: u.email,
  phone: u.phone,
  status: u.status,
  statusReason: u.statusReason,
  roles: u.roles.map((r) => r.role.key as string),
  lastLoginAt: u.lastLoginAt,
  createdAt: u.createdAt,
});

/** Accounts holding these roles can only be actioned by a super admin. */
const PROTECTED_ROLES = ['SUPER_ADMIN', 'PLATFORM_ADMIN'];

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly sessions: SessionService,
  ) {}

  async listUsers(q: AdminUsersQueryDto) {
    const term = q.q?.trim();
    const where: Prisma.UserWhereInput = {
      deletedAt: null,
      ...(q.status ? { status: q.status } : {}),
      ...(term
        ? {
            OR: [
              { fullName: { contains: term, mode: 'insensitive' } },
              { email: { contains: term, mode: 'insensitive' } },
              { phone: { contains: term } },
            ],
          }
        : {}),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.user.findMany({
        where,
        select: USER_SELECT,
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.user.count({ where }),
    ]);
    return { items: rows.map(toView), meta: pageMeta(q, total) };
  }

  async getUser(id: string) {
    const u = await this.prisma.user.findFirst({
      where: { id, deletedAt: null },
      select: USER_SELECT,
    });
    if (!u) throw ApiException.notFound('That user does not exist.');
    return toView(u);
  }

  suspend(actor: Actor, targetId: string, reason: string) {
    return this.changeStatus(actor, targetId, 'SUSPENDED', reason);
  }

  reactivate(actor: Actor, targetId: string, reason?: string) {
    return this.changeStatus(actor, targetId, 'ACTIVE', reason);
  }

  private async changeStatus(
    actor: Actor,
    targetId: string,
    next: Extract<AccountStatus, 'SUSPENDED' | 'ACTIVE'>,
    reason?: string,
  ) {
    if (targetId === actor.userId) {
      throw ApiException.forbidden('You cannot change the status of your own account.');
    }
    const target = await this.getUser(targetId);
    const actorRoles = await this.prisma.userRole.findMany({
      where: { userId: actor.userId, revokedAt: null },
      select: { role: { select: { key: true } } },
    });
    const actorIsSuper = actorRoles.some((r) => r.role.key === 'SUPER_ADMIN');
    // A platform admin must not be able to lock out peers; only a super admin acts on administrators.
    if (!actorIsSuper && target.roles.some((r) => PROTECTED_ROLES.includes(r))) {
      throw ApiException.forbidden('Only a super admin can change an administrator account.');
    }
    if (next === 'SUSPENDED') {
      if (target.status === 'SUSPENDED') {
        throw ApiException.invalidState('This account is already suspended.');
      }
      if (target.status !== 'ACTIVE' && target.status !== 'PENDING_VERIFICATION') {
        throw ApiException.invalidState('This account cannot be suspended in its current state.');
      }
    } else if (target.status !== 'SUSPENDED') {
      throw ApiException.invalidState('Only a suspended account can be reactivated.');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.user.update({
        where: { id: targetId },
        data: {
          status: next,
          statusReason: next === 'SUSPENDED' ? (reason ?? null) : null,
          statusChangedAt: new Date(),
        },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: next === 'SUSPENDED' ? 'user.suspend' : 'user.reactivate',
          entityType: 'user',
          entityId: targetId,
          before: { status: target.status },
          after: { status: next, reason: reason ?? null },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    // Takes effect immediately: every live session of a suspended account is ended.
    if (next === 'SUSPENDED') await this.sessions.revokeAllForUser(targetId, 'account_suspended');
    return this.getUser(targetId);
  }

  async listAudit(q: AdminAuditQueryDto) {
    const where: Prisma.AuditLogWhereInput = {
      ...(q.action ? { action: q.action } : {}),
      ...(q.entityType ? { entityType: q.entityType } : {}),
      ...(q.entityId ? { entityId: q.entityId } : {}),
      ...(q.actorId ? { actorId: q.actorId } : {}),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.auditLog.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        ...toSkipTake(q),
      }),
      this.prisma.auditLog.count({ where }),
    ]);
    const actorIds = [...new Set(rows.map((r) => r.actorId).filter((v): v is string => !!v))];
    const actors = actorIds.length
      ? await this.prisma.user.findMany({
          where: { id: { in: actorIds } },
          select: { id: true, fullName: true },
        })
      : [];
    const names = new Map(actors.map((a) => [a.id, a.fullName]));
    return {
      items: rows.map((r) => ({
        id: r.id,
        actorType: r.actorType,
        actorId: r.actorId,
        actorName: r.actorId ? (names.get(r.actorId) ?? null) : null,
        action: r.action,
        entityType: r.entityType,
        entityId: r.entityId,
        before: r.before,
        after: r.after,
        ip: r.ip,
        requestId: r.requestId,
        createdAt: r.createdAt,
      })),
      meta: pageMeta(q, total),
    };
  }
}
