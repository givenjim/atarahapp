import { Injectable } from '@nestjs/common';
import { type AccountStatus, type EntitlementKey, type RoleKey } from '@prisma/client';
import { AccessService } from '../access/access.service';
import { ApiException } from '../common/api.exception';
import { PrismaService } from '../prisma/prisma.service';

export interface MeView {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  emailVerified: boolean;
  phoneVerified: boolean;
  status: AccountStatus;
  timeZone: string;
  locale: string;
  roles: RoleKey[];
  /** Hints for hiding controls. The server decides every action regardless. */
  entitlements: EntitlementKey[];
  membership: { plan: 'FREE' | 'PRO'; status: string | null; currentPeriodEnd: Date | null };
  createdAt: Date;
}

@Injectable()
export class UserViewService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly access: AccessService,
  ) {}

  async me(userId: string): Promise<MeView> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || user.deletedAt) throw ApiException.notFound('That account does not exist.');

    const [roles, entitlements, membership] = await Promise.all([
      this.access.effectiveAccess(user.id, user.status).then((a) => a.roles),
      this.access.entitlements(user.id),
      this.prisma.membership.findFirst({
        where: { userId: user.id, status: { in: ['ACTIVE', 'PAST_DUE', 'CANCELLED'] } },
        orderBy: { startsAt: 'desc' },
        include: { plan: true },
      }),
    ]);
    const live = entitlements.size > 0;
    return {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      emailVerified: user.emailVerifiedAt !== null,
      phoneVerified: user.phoneVerifiedAt !== null,
      status: user.status,
      timeZone: user.timeZone,
      locale: user.locale,
      roles,
      entitlements: [...entitlements],
      membership: {
        plan: live ? 'PRO' : 'FREE',
        status: live ? (membership?.status ?? null) : null,
        currentPeriodEnd: live ? (membership?.currentPeriodEnd ?? null) : null,
      },
      createdAt: user.createdAt,
    };
  }
}
