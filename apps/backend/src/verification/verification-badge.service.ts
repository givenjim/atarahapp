import { Injectable } from '@nestjs/common';
import {
  type Prisma,
  type SkillSource,
  type VerificationBadgeEndReason,
  type VerificationStatus,
  type VerificationSubjectType,
} from '@prisma/client';
import { PrismaService, type TxClient } from '../prisma/prisma.service';

/** The facts of a case a badge is built from. */
export interface BadgeCase {
  id: string;
  applicantId: string;
  subjectType: VerificationSubjectType;
  subjectId: string;
  subjectMeta?: Prisma.JsonValue | null;
}

export interface ActiveBadge {
  id: string;
  subjectType: VerificationSubjectType;
  subjectId: string;
  grantedAt: Date;
  expiresAt: Date | null;
}

/** Where a badge shows: a subject is "active" when its badge has not ended and has not passed its expiry date. */
export const activeBadgeWhere = (now = new Date()): Prisma.VerificationBadgeWhereInput => ({
  endedAt: null,
  OR: [{ expiresAt: null }, { expiresAt: { gt: now } }],
});

/**
 * The single place a verification decision becomes visible (P2-M6, DEC-152). `VerificationBadge` is the source of truth;
 * the status columns the other modules already read (creative_verifications, seller and mentor profiles, opportunity
 * providers, the skill source) are written here, in the same transaction as the badge, so they can never disagree.
 */
@Injectable()
export class VerificationBadgeService {
  constructor(private readonly prisma: PrismaService) {}

  // ---- write side (always inside the caller's transaction) ----

  /** Mirror a non-final case status (submitted, under review, rejected) onto the subject so the member sees it. */
  async mirrorStatus(tx: TxClient, c: BadgeCase, status: VerificationStatus): Promise<void> {
    await this.writeSubjectStatus(tx, c, status, undefined);
  }

  /** Approval: one active badge, the subject marked VERIFIED. Any earlier active badge for the subject is superseded. */
  async grant(tx: TxClient, c: BadgeCase, expiresAt: Date | null, now = new Date()): Promise<string> {
    await tx.verificationBadge.updateMany({
      where: {
        userId: c.applicantId,
        subjectType: c.subjectType,
        subjectId: c.subjectId,
        endedAt: null,
      },
      data: { endedAt: now, endReason: 'SUPERSEDED' },
    });
    const badge = await tx.verificationBadge.create({
      data: {
        userId: c.applicantId,
        subjectType: c.subjectType,
        subjectId: c.subjectId,
        caseId: c.id,
        grantedAt: now,
        expiresAt,
      },
      select: { id: true },
    });
    await this.writeSubjectStatus(tx, c, 'VERIFIED', now);
    return badge.id;
  }

  /** Expiry or revocation: the badge ends and the subject gets the matching status, so the tick disappears everywhere. */
  async end(
    tx: TxClient,
    c: BadgeCase,
    reason: Extract<VerificationBadgeEndReason, 'EXPIRED' | 'REVOKED'>,
    now = new Date(),
  ): Promise<void> {
    await tx.verificationBadge.updateMany({
      where: { caseId: c.id, endedAt: null },
      data: { endedAt: now, endReason: reason },
    });
    await this.writeSubjectStatus(tx, c, reason, undefined);
  }

  private async writeSubjectStatus(
    tx: TxClient,
    c: BadgeCase,
    status: VerificationStatus,
    verifiedAt: Date | undefined,
  ): Promise<void> {
    switch (c.subjectType) {
      case 'CREATIVE_IDENTITY':
        await tx.creativeVerification.upsert({
          where: { profileId: c.subjectId },
          create: { profileId: c.subjectId, status, verifiedAt: verifiedAt ?? null },
          update: { status, ...(status === 'VERIFIED' ? { verifiedAt: verifiedAt ?? new Date() } : {}) },
        });
        return;
      case 'SELLER':
        await tx.sellerProfile.updateMany({ where: { id: c.subjectId }, data: { verificationStatus: status } });
        return;
      case 'MENTOR':
        await tx.mentorProfile.updateMany({ where: { id: c.subjectId }, data: { verificationStatus: status } });
        return;
      case 'OPPORTUNITY_PROVIDER':
        await tx.opportunityProvider.updateMany({
          where: { id: c.subjectId },
          data: { verificationStatus: status },
        });
        return;
      case 'SKILL': {
        // The skill's status is the case status; the stored `source` is what other modules read.
        const profile = await tx.creativeProfile.findUnique({
          where: { userId: c.applicantId },
          select: { id: true },
        });
        if (!profile) return;
        const where = { profileId_skillId: { profileId: profile.id, skillId: c.subjectId } };
        const row = await tx.creativeSkill.findUnique({ where });
        if (!row) return;
        if (status === 'VERIFIED') {
          if (row.source !== 'VERIFIED') {
            await tx.verificationCase.update({
              where: { id: c.id },
              data: { subjectMeta: { previousSource: row.source } },
            });
            await tx.creativeSkill.update({ where, data: { source: 'VERIFIED' } });
          }
        } else if ((status === 'EXPIRED' || status === 'REVOKED') && row.source === 'VERIFIED') {
          const previous = (c.subjectMeta as { previousSource?: SkillSource } | null)?.previousSource;
          await tx.creativeSkill.update({
            where,
            data: { source: previous && previous !== 'VERIFIED' ? previous : 'SELF_DECLARED' },
          });
        }
        return;
      }
    }
  }

  // ---- read side ----

  /** A creative's identity badge is active. */
  async identityVerified(profileId: string, now = new Date()): Promise<boolean> {
    return (
      (await this.prisma.verificationBadge.count({
        where: { subjectType: 'CREATIVE_IDENTITY', subjectId: profileId, ...activeBadgeWhere(now) },
      })) > 0
    );
  }

  /** Taxonomy skill ids a member has an active skill badge for. */
  async verifiedSkillIds(userId: string, now = new Date()): Promise<Set<string>> {
    const rows = await this.prisma.verificationBadge.findMany({
      where: { userId, subjectType: 'SKILL', ...activeBadgeWhere(now) },
      select: { subjectId: true },
    });
    return new Set(rows.map((r) => r.subjectId));
  }

  /** Names of skills a member is verified in, for trust lines ("Skill verified: Illustration"). */
  async verifiedSkillNames(userId: string, now = new Date()): Promise<string[]> {
    const ids = [...(await this.verifiedSkillIds(userId, now))];
    if (ids.length === 0) return [];
    const skills = await this.prisma.skill.findMany({
      where: { id: { in: ids } },
      select: { name: true },
      orderBy: { name: 'asc' },
    });
    return skills.map((s) => s.name);
  }

  async activeBadges(userId: string, now = new Date()): Promise<ActiveBadge[]> {
    return this.prisma.verificationBadge.findMany({
      where: { userId, ...activeBadgeWhere(now) },
      select: { id: true, subjectType: true, subjectId: true, grantedAt: true, expiresAt: true },
      orderBy: { grantedAt: 'asc' },
    });
  }
}
