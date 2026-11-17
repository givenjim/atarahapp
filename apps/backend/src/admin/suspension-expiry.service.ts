import { Injectable, Logger } from '@nestjs/common';
import { AuditService } from '../audit/audit.service';
import { PrismaService } from '../prisma/prisma.service';
import { SupabaseAdminService } from '../supabase/supabase-admin.service';

/** Hourly: ends temporary suspensions whose time has passed. Idempotent: only SUSPENDED accounts with an end time. */
@Injectable()
export class SuspensionExpiryService {
  private readonly log = new Logger(SuspensionExpiryService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly supabase: SupabaseAdminService,
  ) {}

  async reactivateExpired(now = new Date()): Promise<{ reactivated: number }> {
    const due = await this.prisma.user.findMany({
      where: { status: 'SUSPENDED', suspendedUntil: { lte: now }, deletedAt: null },
      select: { id: true },
      take: 500,
    });
    let reactivated = 0;
    for (const { id } of due) {
      const changed = await this.prisma.$transaction(async (tx) => {
        const res = await tx.user.updateMany({
          where: { id, status: 'SUSPENDED', suspendedUntil: { lte: now } },
          data: {
            status: 'ACTIVE',
            statusReason: null,
            suspendedUntil: null,
            statusChangedAt: now,
          },
        });
        if (res.count === 0) return false;
        await this.audit.record(
          {
            actorType: 'SYSTEM',
            action: 'user.reactivate',
            entityType: 'user',
            entityId: id,
            before: { status: 'SUSPENDED' },
            after: { status: 'ACTIVE', reason: 'Suspension period ended' },
          },
          tx,
        );
        return true;
      });
      if (!changed) continue;
      const lift = await this.supabase.auth.updateUserById(id, { ban_duration: 'none' });
      if (lift.error)
        this.log.warn(`Could not lift the sign-in block for ${id}: ${lift.error.message}`);
      reactivated += 1;
    }
    return { reactivated };
  }
}
