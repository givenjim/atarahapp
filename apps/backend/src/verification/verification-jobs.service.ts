import { Injectable, Logger } from '@nestjs/common';
import { AuditService } from '../audit/audit.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { VerificationBadgeService } from './verification-badge.service';

export const VER_EXPIRE_JOB = 'verification-expire';
export const VER_PURGE_JOB = 'verification-purge-ids';
export const VER_REFERENCES_JOB = 'verification-references-expire';

const DAY_MS = 86_400_000;
const REMINDER_DAYS = 30;
/** A draft nobody touched for this long loses its uploaded ID image (it was never submitted, so no decision exists). */
const ABANDONED_DRAFT_DAYS = 30;

/**
 * Background work for verification (P2-M6). Each handler is idempotent and can run twice without harm:
 *  - expiry ends badges whose date has passed and puts EXPIRED on the subject (the tick disappears everywhere),
 *    after a one-time reminder 30 days before;
 *  - retention deletes government ID images once `verification.id_retention_days` have passed since the decision
 *    (and those of abandoned drafts), keeping the decision record;
 *  - unanswered reference links expire.
 */
@Injectable()
export class VerificationJobsService {
  private readonly log = new Logger(VerificationJobsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly badges: VerificationBadgeService,
    private readonly audit: AuditService,
    private readonly storage: StorageService,
    private readonly notifications: NotificationsService,
  ) {}

  /** End every verified case whose expiry date has passed; remind owners of those expiring within 30 days. */
  async expire(now = new Date()): Promise<{ expired: number; reminded: number }> {
    const due = await this.prisma.verificationCase.findMany({
      where: { status: 'VERIFIED', expiresAt: { lte: now } },
      select: { id: true, applicantId: true, subjectType: true, subjectId: true, subjectMeta: true },
      take: 500,
    });
    let expired = 0;
    for (const c of due) {
      const done = await this.prisma.transaction(async (tx) => {
        const won = await tx.verificationCase.updateMany({
          where: { id: c.id, status: 'VERIFIED' },
          data: { status: 'EXPIRED', version: { increment: 1 } },
        });
        if (won.count !== 1) return false;
        await this.badges.end(tx, c, 'EXPIRED', now);
        await tx.verificationCaseEvent.create({ data: { caseId: c.id, action: 'EXPIRED' } });
        await this.audit.record(
          {
            actorType: 'SYSTEM',
            action: 'verification.expire',
            entityType: 'verification_case',
            entityId: c.id,
            after: { subjectType: c.subjectType, status: 'EXPIRED' },
          },
          tx,
        );
        return true;
      });
      if (!done) continue;
      expired += 1;
      await this.tell(
        c.applicantId,
        'verification.expired',
        c.subjectType,
        'Your verification has expired and the badge is hidden. You can apply again at any time.',
      );
    }

    const soon = await this.prisma.verificationCase.findMany({
      where: {
        status: 'VERIFIED',
        expiryReminderSentAt: null,
        expiresAt: { gt: now, lte: new Date(now.getTime() + REMINDER_DAYS * DAY_MS) },
      },
      select: { id: true, applicantId: true, subjectType: true },
      take: 500,
    });
    let reminded = 0;
    for (const c of soon) {
      const marked = await this.prisma.verificationCase.updateMany({
        where: { id: c.id, expiryReminderSentAt: null },
        data: { expiryReminderSentAt: now },
      });
      if (marked.count !== 1) continue;
      reminded += 1;
      await this.tell(
        c.applicantId,
        'verification.expiring',
        c.subjectType,
        'Your verification expires within 30 days. Apply again to keep your badge.',
      );
    }
    return { expired, reminded };
  }

  /** Delete government ID images past their retention date. The evidence row stays, marked as purged. */
  async purgeIds(now = new Date()): Promise<{ purged: number }> {
    const abandoned = new Date(now.getTime() - ABANDONED_DRAFT_DAYS * DAY_MS);
    const rows = await this.prisma.verificationEvidence.findMany({
      where: {
        type: 'GOVERNMENT_ID',
        purgedAt: null,
        OR: [
          { purgeAfter: { lte: now } },
          { purgeAfter: null, case: { status: 'NOT_SUBMITTED', updatedAt: { lt: abandoned } } },
        ],
      },
      select: { id: true, caseId: true, mediaAssetId: true },
      take: 200,
    });
    let purged = 0;
    for (const e of rows) {
      if (e.mediaAssetId) {
        const asset = await this.prisma.mediaAsset.findUnique({ where: { id: e.mediaAssetId } });
        if (asset) {
          const keys = [
            asset.objectKey,
            ...Object.values((asset.variants as Record<string, string> | null) ?? {}),
          ];
          for (const key of keys) {
            // A missing object is fine (already gone); any other failure retries on the next run.
            await this.storage.remove('evidence', key);
          }
          await this.prisma.mediaAsset.update({
            where: { id: asset.id },
            data: { status: 'DELETED', deletedAt: now },
          });
        }
      }
      await this.prisma.verificationEvidence.update({ where: { id: e.id }, data: { purgedAt: now } });
      await this.audit.record({
        actorType: 'SYSTEM',
        action: 'verification.id.purge',
        entityType: 'verification_case',
        entityId: e.caseId,
        after: { evidenceId: e.id },
      });
      purged += 1;
    }
    if (purged > 0) this.log.log(`Purged ${purged} government ID file(s)`);
    return { purged };
  }

  async expireReferences(now = new Date()): Promise<{ expired: number }> {
    const res = await this.prisma.verificationReference.updateMany({
      where: { status: 'PENDING', tokenExpiresAt: { lte: now } },
      data: { status: 'EXPIRED' },
    });
    return { expired: res.count };
  }

  private async tell(userId: string, type: string, subjectType: string, body: string): Promise<void> {
    try {
      await this.notifications.notify({
        userId,
        category: 'PROFILE',
        type,
        title: subjectType === 'SKILL' ? 'Skill verification' : 'Verified Creative',
        body,
        deepLink: subjectType === 'SKILL' ? '/skills' : '/verification',
      });
    } catch (err) {
      this.log.warn(`Could not notify ${userId}: ${(err as Error).message}`);
    }
  }
}
