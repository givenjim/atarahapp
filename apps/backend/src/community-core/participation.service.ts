import { Injectable } from '@nestjs/common';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { PrismaService } from '../prisma/prisma.service';

/**
 * Who may take part in the community: posting, commenting and sending connection requests need an ACTIVE account
 * with a verified email or phone and no standing restriction. (Reading and reacting only need an active account.)
 */
@Injectable()
export class ParticipationService {
  constructor(private readonly prisma: PrismaService) {}

  async assertCanParticipate(userId: string, now = new Date()): Promise<void> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { status: true, deletedAt: true, emailVerifiedAt: true, phoneVerifiedAt: true },
    });
    if (!user || user.deletedAt || user.status !== 'ACTIVE') {
      throw ApiException.forbidden('This account cannot do that right now.', {
        reason: 'ACCOUNT_NOT_ACTIVE',
      });
    }
    if (!user.emailVerifiedAt && !user.phoneVerifiedAt) {
      throw new ApiException(
        ErrorCode.VERIFICATION_REQUIRED,
        'Verify your email or phone number to take part in the community.',
        403,
        { reason: 'CONTACT_NOT_VERIFIED' },
      );
    }
    const restriction = await this.prisma.communityRestriction.findFirst({
      where: { userId, liftedAt: null, OR: [{ expiresAt: null }, { expiresAt: { gt: now } }] },
      select: { id: true },
    });
    if (restriction) {
      throw ApiException.forbidden(
        'Your account is limited from posting and connecting for now. Check your notifications for details.',
        { reason: 'ACCOUNT_RESTRICTED' },
      );
    }
  }

  /** True when either member has blocked the other. */
  async isBlockedEitherWay(a: string, b: string): Promise<boolean> {
    const n = await this.prisma.block.count({
      where: {
        OR: [
          { blockerId: a, blockedId: b },
          { blockerId: b, blockedId: a },
        ],
      },
    });
    return n > 0;
  }
}
