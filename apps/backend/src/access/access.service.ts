import { Injectable } from '@nestjs/common';
import { type AccountStatus, type EntitlementKey, type RoleKey } from '@prisma/client';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { PrismaService } from '../prisma/prisma.service';

export interface EffectiveAccess {
  roles: RoleKey[];
  permissions: Set<string>;
  isStaff: boolean;
}

const DAY_MS = 24 * 3600 * 1000;

/**
 * Computes what a person may do. Account status, roles, entitlements, verification, ownership,
 * visibility and platform policy stay separate; this service answers the role/permission and
 * entitlement questions only.
 */
@Injectable()
export class AccessService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly settings: PlatformSettingsService,
  ) {}

  /**
   * Member-default permissions (only while the account is ACTIVE) plus the permissions of every
   * currently-held role. Additive, never subtractive.
   */
  async effectiveAccess(userId: string, status: AccountStatus): Promise<EffectiveAccess> {
    const userRoles = await this.prisma.userRole.findMany({
      where: { userId, revokedAt: null },
      include: { role: { include: { permissions: { include: { permission: true } } } } },
    });
    const permissions = new Set<string>();
    if (status === 'ACTIVE') {
      const defaults = await this.prisma.permission.findMany({
        where: { isMemberDefault: true },
        select: { key: true },
      });
      defaults.forEach((p) => permissions.add(p.key));
    }
    // Roles only count while the account is usable.
    if (status === 'ACTIVE') {
      for (const ur of userRoles)
        ur.role.permissions.forEach((rp) => permissions.add(rp.permission.key));
    }
    return {
      roles: userRoles.map((ur) => ur.role.key),
      permissions,
      isStaff: userRoles.some((ur) => ur.role.isStaff),
    };
  }

  async hasPermission(userId: string, status: AccountStatus, key: string): Promise<boolean> {
    return (await this.effectiveAccess(userId, status)).permissions.has(key);
  }

  /** Entitlements granted by the member's live membership. Empty for Free, expired or cancelled-past-period. */
  async entitlements(userId: string, now = new Date()): Promise<Set<EntitlementKey>> {
    const membership = await this.prisma.membership.findFirst({
      where: { userId, status: { in: ['ACTIVE', 'PAST_DUE', 'CANCELLED'] } },
      orderBy: { startsAt: 'desc' },
      include: { plan: { include: { entitlements: { include: { entitlement: true } } } } },
    });
    if (!membership || !(await this.isLive(membership, now))) return new Set();
    return new Set(membership.plan.entitlements.map((e) => e.entitlement.key));
  }

  async hasEntitlement(userId: string, key: EntitlementKey, now = new Date()): Promise<boolean> {
    return (await this.entitlements(userId, now)).has(key);
  }

  private async isLive(
    m: { status: string; currentPeriodEnd: Date | null },
    now: Date,
  ): Promise<boolean> {
    const end = m.currentPeriodEnd;
    switch (m.status) {
      case 'ACTIVE':
        return end === null || end > now;
      case 'CANCELLED':
        // Cancelled memberships stay active until the paid period ends.
        return end !== null && end > now;
      case 'PAST_DUE': {
        const graceDays = await this.settings.get<number>('membership.grace_period_days', 3);
        return end !== null && now.getTime() <= end.getTime() + graceDays * DAY_MS;
      }
      default:
        return false;
    }
  }
}
