import { Injectable, Logger } from '@nestjs/common';
import { createClient } from '@supabase/supabase-js';
import { randomBytes, randomUUID } from 'node:crypto';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { SessionService } from '../identity/session.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { type BucketKind, StorageService } from '../storage/storage.service';
import { SupabaseAdminService } from '../supabase/supabase-admin.service';
import { type DeleteAccountDto } from './account.dto';

/** Personal data stays for 30 days after the member asks to delete, so a change of mind costs nothing. */
export const GRACE_DAYS = 30;
/** Signing in this recently counts as "recent re-authentication" for the delete confirmation. */
export const RECENT_SIGN_IN_MINUTES = 5;
const PLACEHOLDER_SETTING = 'system.deleted_member_user_id';

const bucketKind = (b: string): BucketKind =>
  b === 'PUBLIC' ? 'public' : b === 'PRIVATE' ? 'private' : 'evidence';

/**
 * Delete my account (P1-M11).
 *
 * Asking: the member types DELETE and proves it is them (a sign-in in the last 5 minutes, or their password). The account
 * becomes DEACTIVATED at once, the profile disappears everywhere (every reader requires an ACTIVE owner), every session
 * is signed out and a 30-day grace period starts. Signing in again during the grace period offers "Restore account".
 *
 * Purging (daily job, after the grace period): the posts and comments the member wrote stay, credited to one shared
 * "Deleted member" account, so conversations keep making sense. Everything else personal is deleted: the profile and all
 * that hangs off it, connections, saved items, progress, notifications, and every picture and file in storage; then the
 * Supabase Auth user is deleted, which removes the account itself. The audit trail keeps only the non-personal user id.
 */
@Injectable()
export class DeletionService {
  private readonly log = new Logger(DeletionService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfigService,
    private readonly admin: SupabaseAdminService,
    private readonly sessions: SessionService,
    private readonly notifications: NotificationsService,
    private readonly audit: AuditService,
    private readonly storage: StorageService,
    private readonly settings: PlatformSettingsService,
  ) {}

  // ---- asking and restoring --------------------------------------------------------------------------------

  async request(
    userId: string,
    dto: DeleteAccountDto,
    ctx: { ip?: string } = {},
    now = new Date(),
  ) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { email: true, phone: true, lastLoginAt: true, status: true },
    });
    const recentSignIn =
      user.lastLoginAt !== null &&
      now.getTime() - user.lastLoginAt.getTime() < RECENT_SIGN_IN_MINUTES * 60_000;
    if (!recentSignIn) {
      if (!dto.password) {
        throw ApiException.forbidden('Enter your password to confirm it is you.', {
          reason: 'REAUTH_REQUIRED',
        });
      }
      await this.checkPassword(user, dto.password);
    }
    const purgeAfter = new Date(now.getTime() + GRACE_DAYS * 86_400_000);
    await this.prisma.$transaction(async (tx) => {
      const open = await tx.accountDeletionRequest.findFirst({
        where: { userId, status: 'PENDING' },
      });
      if (!open) await tx.accountDeletionRequest.create({ data: { userId, purgeAfter } });
      await tx.user.update({
        where: { id: userId },
        data: { status: 'DEACTIVATED', statusReason: 'DELETION_REQUESTED', statusChangedAt: now },
      });
      await this.audit.record(
        {
          actorType: 'USER',
          actorId: userId,
          action: 'account.delete_request',
          entityType: 'user',
          entityId: userId,
          after: { purgeAfter },
          ip: ctx.ip ?? null,
        },
        tx,
      );
    });
    const sessionsRevoked = await this.sessions.revokeAllForUser(userId);
    const pending = await this.prisma.accountDeletionRequest.findFirstOrThrow({
      where: { userId, status: 'PENDING' },
    });
    // The account is deactivated now, so the notice is written straight to the inbox and emailed by the dispatcher.
    await this.notifications
      .notify({
        userId,
        category: 'SYSTEM',
        type: 'account.deletion_scheduled',
        title: 'Your account will be deleted',
        body: `We deleted your profile from view. Your data is removed for good on ${pending.purgeAfter.toISOString().slice(0, 10)}. Sign in before then to restore your account.`,
        critical: true,
      })
      .catch(() => undefined);
    return { purgeAfter: pending.purgeAfter, sessionsRevoked };
  }

  /** Bring the account back during the grace period. */
  async restore(userId: string, now = new Date()): Promise<{ restored: boolean }> {
    const open = await this.prisma.accountDeletionRequest.findFirst({
      where: { userId, status: 'PENDING' },
    });
    if (!open || open.purgeAfter <= now) {
      throw ApiException.invalidState('This account can no longer be restored.');
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.accountDeletionRequest.update({
        where: { id: open.id },
        data: { status: 'CANCELLED', cancelledAt: now },
      });
      await tx.user.update({
        where: { id: userId },
        data: { status: 'ACTIVE', statusReason: null, statusChangedAt: now },
      });
      await this.audit.record(
        {
          actorType: 'USER',
          actorId: userId,
          action: 'account.restore',
          entityType: 'user',
          entityId: userId,
        },
        tx,
      );
    });
    await this.notifications
      .notify({
        userId,
        category: 'SYSTEM',
        type: 'account.restored',
        title: 'Welcome back',
        body: 'Your account is restored and your profile is visible again.',
        critical: true,
      })
      .catch(() => undefined);
    return { restored: true };
  }

  private async checkPassword(
    user: { email: string | null; phone: string | null },
    password: string,
  ): Promise<void> {
    const key = this.config.supabase.publishableKey;
    if (!key) throw ApiException.external('Deleting the account is not available right now.');
    const anon = createClient(this.config.supabase.url, key, {
      auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
    });
    const creds = user.email ? { email: user.email, password } : { phone: user.phone!, password };
    const { error } = await anon.auth.signInWithPassword(creds);
    if (error) throw ApiException.validation('That password is not right.', { field: 'password' });
  }

  // ---- purging ---------------------------------------------------------------------------------------------

  /** Daily job: purge every account whose grace period ended. One failure does not stop the others. */
  async purgeDue(now = new Date()): Promise<{ purged: number; failed: number }> {
    const due = await this.prisma.accountDeletionRequest.findMany({
      where: { status: 'PENDING', purgeAfter: { lte: now } },
      orderBy: { purgeAfter: 'asc' },
      take: 50,
    });
    let purged = 0;
    let failed = 0;
    for (const r of due) {
      try {
        await this.purge(r.id, now);
        purged += 1;
      } catch (e) {
        failed += 1;
        this.log.error(
          `Purge of request ${r.id} failed: ${e instanceof Error ? e.message : String(e)}`,
        );
      }
    }
    return { purged, failed };
  }

  /** The one account that authors what deleted members wrote. Created on first use; nobody can sign in as it. */
  async deletedMemberId(): Promise<string> {
    const known = await this.settings.get<string | null>(PLACEHOLDER_SETTING, null);
    if (known && (await this.prisma.user.count({ where: { id: known } })) > 0) return known;
    const created = await this.admin.auth.createUser({
      email: `deleted-member-${randomUUID()}@placeholder.atarah.invalid`,
      password: randomBytes(32).toString('base64url'),
      email_confirm: true,
      user_metadata: { full_name: 'Deleted member' },
    });
    if (created.error || !created.data.user)
      throw new Error(`Could not create the placeholder: ${created.error?.message}`);
    const id = created.data.user.id;
    await this.prisma.user.update({
      where: { id },
      data: {
        fullName: 'Deleted member',
        // ACTIVE so what it authored stays visible (every reader requires an active author). It cannot sign in
        // (banned, random password) and has no profile, so nobody can find or contact it.
        status: 'ACTIVE',
        statusReason: 'SYSTEM_PLACEHOLDER',
        isDemo: false,
      },
    });
    await this.admin.auth.updateUserById(id, { ban_duration: '876000h' }).catch(() => undefined);
    await this.prisma.platformSetting.upsert({
      where: { key: PLACEHOLDER_SETTING },
      create: {
        key: PLACEHOLDER_SETTING,
        value: id,
        description: 'The account that authors the content of deleted members.',
      },
      update: { value: id },
    });
    return id;
  }

  async purge(requestId: string, now = new Date()): Promise<void> {
    const req = await this.prisma.accountDeletionRequest.findUnique({ where: { id: requestId } });
    if (!req || req.status !== 'PENDING') return;
    const userId = req.userId;

    const exists = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });
    if (exists) {
      const placeholder = await this.deletedMemberId();
      // 1. Keep what the member wrote, credited to "Deleted member".
      await this.prisma.$transaction([
        this.prisma.post.updateMany({
          where: { authorId: userId },
          data: { authorId: placeholder },
        }),
        this.prisma.comment.updateMany({
          where: { authorId: userId },
          data: { authorId: placeholder },
        }),
        // Payment records are kept for the books (P2-M1), credited to the placeholder instead of the member.
        this.prisma.payment.updateMany({
          where: { payerId: userId },
          data: { payerId: placeholder },
        }),
      ]);
      // 2. Delete every file they uploaded (and the renditions made from it).
      const assets = await this.prisma.mediaAsset.findMany({ where: { ownerId: userId } });
      for (const a of assets) {
        const keys = [a.objectKey, ...Object.values((a.variants ?? {}) as Record<string, string>)];
        for (const k of keys)
          await this.storage.remove(bucketKind(a.bucket), k).catch(() => undefined);
      }
      await this.prisma.mediaAsset.deleteMany({ where: { ownerId: userId } });
      // 2b. Delete the CV / EPK PDFs (P2-M7). The document, build and share-link rows go with the profile.
      const pdfs = await this.prisma.creativeDocumentRender.findMany({
        where: { document: { profile: { userId } }, objectKey: { not: null } },
        select: { objectKey: true },
      });
      for (const r of pdfs) {
        if (r.objectKey) await this.storage.remove('private', r.objectKey).catch(() => undefined);
      }
      // 3. Delete the account. Everything personal hangs off it and goes with it.
      const del = await this.admin.auth.deleteUser(userId);
      if (del.error && !/not found/i.test(del.error.message)) throw new Error(del.error.message);
      await this.prisma.user.deleteMany({ where: { id: userId } });
    }
    await this.prisma.accountDeletionRequest.update({
      where: { id: requestId },
      data: { status: 'PURGED', purgedAt: now },
    });
    // Only the non-personal id is kept.
    await this.audit.record({
      actorType: 'SYSTEM',
      action: 'account.purge',
      entityType: 'user',
      entityId: userId,
      after: { requestId },
    });
  }
}
