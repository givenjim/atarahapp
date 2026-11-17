import { Inject, Injectable } from '@nestjs/common';
import { createClient } from '@supabase/supabase-js';
import { Prisma } from '@prisma/client';
import { type Redis } from 'ioredis';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { AppConfigService } from '../config/app-config.service';
import { handleProblem, normaliseHandle } from '../creative/handle';
import { SessionService } from '../identity/session.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';
import { SupabaseAdminService } from '../supabase/supabase-admin.service';
import {
  type AccountDto,
  type ChangeEmailDto,
  type ChangePasswordDto,
  type ChangePhoneDto,
  type UpdateAccountDto,
  type VerifyPhoneChangeDto,
} from './account.dto';

const CHANGE_LIMIT_PER_HOUR = 5;
const PASSWORD_LIMIT_PER_HOUR = 5;

/** `jo***@gmail.com` and `+2547*****678`: enough for a member to recognise it, not enough to leak it. */
export const maskContact = (v: string): string => {
  if (v.includes('@')) {
    const [name = '', host = ''] = v.split('@');
    return `${name.slice(0, 2)}***@${host}`;
  }
  return `${v.slice(0, 5)}*****${v.slice(-3)}`;
};

const isUnique = (e: unknown) =>
  e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002';

/**
 * The Account and Security settings that need more than a database write. Names and the username are plain updates.
 * Email and phone changes go through Supabase Auth's own change flows (confirmation on both addresses; an OTP for a
 * phone) made with the member's own session; Atarah records the request, tells the old contact, and when the new value
 * appears on the account it signs the other devices out. A password change needs the current password.
 */
@Injectable()
export class AccountService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfigService,
    private readonly admin: SupabaseAdminService,
    private readonly sessions: SessionService,
    private readonly notifications: NotificationsService,
    private readonly audit: AuditService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  // ---- reading ---------------------------------------------------------------------------------------------

  async get(userId: string, currentSessionId?: string): Promise<AccountDto> {
    await this.reconcile(userId, currentSessionId);
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: {
        fullName: true,
        email: true,
        phone: true,
        emailVerifiedAt: true,
        phoneVerifiedAt: true,
        creativeProfile: { select: { handle: true } },
        contactChanges: { where: { completedAt: null }, orderBy: { requestedAt: 'desc' } },
      },
    });
    const pending = (k: 'EMAIL' | 'PHONE') =>
      user.contactChanges.find((c) => c.kind === k)?.newValue ?? null;
    return {
      fullName: user.fullName,
      handle: user.creativeProfile?.handle ?? null,
      email: user.email,
      emailVerified: user.emailVerifiedAt !== null,
      phone: user.phone,
      phoneVerified: user.phoneVerifiedAt !== null,
      pendingEmail: pending('EMAIL'),
      pendingPhone: pending('PHONE'),
    };
  }

  // ---- name and username -----------------------------------------------------------------------------------

  async update(
    userId: string,
    dto: UpdateAccountDto,
    ctx: { ip?: string } = {},
  ): Promise<AccountDto> {
    const fullName = dto.fullName?.trim().replace(/\s+/g, ' ');
    if (dto.fullName !== undefined && (fullName?.length ?? 0) < 2) {
      throw ApiException.validation('Enter your name.', { field: 'fullName' });
    }
    const handle = dto.handle !== undefined ? normaliseHandle(dto.handle) : undefined;
    if (handle !== undefined) {
      const problem = handleProblem(handle);
      if (problem) {
        throw ApiException.validation(
          problem === 'RESERVED'
            ? 'That username is reserved. Try another.'
            : 'Use 3 to 30 lower-case letters, digits or underscores.',
          { field: 'handle', reason: problem },
        );
      }
    }
    const before = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: {
        fullName: true,
        creativeProfile: { select: { id: true, handle: true, displayName: true } },
      },
    });
    if (handle !== undefined && !before.creativeProfile) {
      throw ApiException.invalidState('Finish setting up your profile before choosing a username.');
    }
    try {
      await this.prisma.$transaction(async (tx) => {
        if (fullName !== undefined) {
          await tx.user.update({ where: { id: userId }, data: { fullName } });
          // The profile shows the same name unless the member wrote a different one on purpose.
          if (before.creativeProfile && before.creativeProfile.displayName === before.fullName) {
            await tx.creativeProfile.update({
              where: { id: before.creativeProfile.id },
              data: { displayName: fullName },
            });
          }
        }
        if (handle !== undefined && handle !== before.creativeProfile?.handle) {
          await tx.creativeProfile.update({
            where: { id: before.creativeProfile!.id },
            data: { handle },
          });
        }
        await this.audit.record(
          {
            actorType: 'USER',
            actorId: userId,
            action: 'account.update',
            entityType: 'user',
            entityId: userId,
            before: { fullName: before.fullName, handle: before.creativeProfile?.handle ?? null },
            after: { fullName, handle },
            ip: ctx.ip ?? null,
          },
          tx,
        );
      });
    } catch (e) {
      if (isUnique(e)) {
        throw new ApiException(ErrorCode.CONFLICT, 'That username is taken. Try another.', 409, {
          field: 'handle',
          reason: 'TAKEN',
        });
      }
      throw e;
    }
    return this.get(userId);
  }

  // ---- email and phone -------------------------------------------------------------------------------------

  /**
   * A call to Supabase Auth made as the member with their own access token (the way the app itself would). Used for the
   * flows only the member's own session may start: changing the email or phone, and changing the password (which, done
   * this way, ends every other session and keeps this one; the admin API would end this one too).
   */
  private async asMember(
    method: 'PUT' | 'POST',
    path: string,
    token: string,
    body: Record<string, unknown>,
  ): Promise<{ ok: boolean; status: number; message: string }> {
    const key = this.config.supabase.publishableKey;
    if (!key) {
      throw ApiException.external(
        'This change is not available right now. Please try again later.',
      );
    }
    const res = await fetch(`${this.config.supabase.url}/auth/v1${path}`, {
      method,
      headers: {
        apikey: key,
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });
    const json = (await res.json().catch(() => ({}))) as {
      msg?: string;
      message?: string;
      error_description?: string;
    };
    return {
      ok: res.ok,
      status: res.status,
      message: json.msg ?? json.message ?? json.error_description ?? '',
    };
  }

  private async limit(kind: string, userId: string, max: number): Promise<void> {
    const key = `acct:rl:${kind}:${userId}`;
    const n = await this.redis.incr(key).catch(() => 0);
    if (n === 1) await this.redis.expire(key, 3600).catch(() => undefined);
    if (n > max) {
      throw new ApiException(
        ErrorCode.RATE_LIMITED,
        'Too many tries. Please wait an hour and try again.',
        429,
      );
    }
  }

  async startEmailChange(userId: string, token: string, dto: ChangeEmailDto) {
    await this.limit('contact', userId, CHANGE_LIMIT_PER_HOUR);
    const email = dto.email.trim().toLowerCase();
    const me = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { email: true },
    });
    if (me.email?.toLowerCase() === email) {
      throw ApiException.validation('That is already your email.', { field: 'email' });
    }
    const res = await this.asMember('PUT', '/user', token, { email });
    if (!res.ok) throw this.mapAuthError(res.message, 'email');
    await this.prisma.contactChangeRequest.create({
      data: { userId, kind: 'EMAIL', oldValue: me.email, newValue: email },
    });
    if (me.email) {
      await this.tell(userId, {
        type: 'account.email_change_requested',
        title: 'Email change requested',
        body: `Someone asked to change your Atarah email to ${maskContact(email)}. If it was not you, change your password now.`,
      });
    }
    return { kind: 'EMAIL' as const, sentTo: maskContact(email) };
  }

  async startPhoneChange(userId: string, token: string, dto: ChangePhoneDto) {
    await this.limit('contact', userId, CHANGE_LIMIT_PER_HOUR);
    const me = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { phone: true },
    });
    if (me.phone === dto.phone)
      throw ApiException.validation('That is already your number.', { field: 'phone' });
    const res = await this.asMember('PUT', '/user', token, { phone: dto.phone });
    if (!res.ok) throw this.mapAuthError(res.message, 'phone');
    await this.prisma.contactChangeRequest.create({
      data: { userId, kind: 'PHONE', oldValue: me.phone, newValue: dto.phone },
    });
    return { kind: 'PHONE' as const, sentTo: maskContact(dto.phone) };
  }

  async verifyPhoneChange(
    userId: string,
    token: string,
    sessionId: string,
    dto: VerifyPhoneChangeDto,
  ) {
    await this.limit('contact', userId, CHANGE_LIMIT_PER_HOUR * 2);
    const res = await this.asMember('POST', '/verify', token, {
      phone: dto.phone,
      token: dto.code,
      type: 'phone_change',
    });
    if (!res.ok)
      throw ApiException.validation('That code is not right or has expired.', { field: 'code' });
    await this.reconcile(userId, sessionId);
    return this.get(userId, sessionId);
  }

  private mapAuthError(message: string, field: string): ApiException {
    if (/already|registered|exists|taken/i.test(message)) {
      return new ApiException(ErrorCode.CONFLICT, 'That cannot be used for this account.', 409, {
        field,
      });
    }
    if (/rate|too many|seconds/i.test(message)) {
      return new ApiException(ErrorCode.RATE_LIMITED, 'Please wait a minute and try again.', 429);
    }
    return ApiException.validation('That does not look right. Check it and try again.', { field });
  }

  /**
   * Completes any pending contact change whose new value is now on the account: marks it done, signs every other device
   * out (a changed contact means the old sessions may not be the owner's) and tells the old contact. Runs when the
   * member reads their account and on a schedule, because an email change is confirmed from the link in an email.
   */
  async reconcile(userId: string, keepSessionId?: string): Promise<number> {
    const open = await this.prisma.contactChangeRequest.findMany({
      where: { userId, completedAt: null },
    });
    if (open.length === 0) return 0;
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { email: true, phone: true },
    });
    let done = 0;
    for (const r of open) {
      const now = r.kind === 'EMAIL' ? user?.email?.toLowerCase() : user?.phone;
      if (now === r.newValue.toLowerCase() || now === r.newValue) {
        await this.prisma.contactChangeRequest.update({
          where: { id: r.id },
          data: { completedAt: new Date() },
        });
        await this.sessions.revokeAllForUser(userId, keepSessionId);
        await this.tell(userId, {
          type: 'account.contact_changed',
          title: r.kind === 'EMAIL' ? 'Your email was changed' : 'Your phone number was changed',
          body: `Your ${r.kind === 'EMAIL' ? 'email' : 'phone number'} is now ${maskContact(r.newValue)}. Other devices were signed out. If this was not you, contact support.`,
        });
        done += 1;
      } else if (Date.now() - r.requestedAt.getTime() > 7 * 86_400_000) {
        // Never confirmed: stop tracking it.
        await this.prisma.contactChangeRequest.update({
          where: { id: r.id },
          data: { completedAt: new Date() },
        });
      }
    }
    return done;
  }

  /** Scheduled: reconcile everyone with an open request (an email link is clicked outside the app). */
  async reconcileAll(): Promise<number> {
    const users = await this.prisma.contactChangeRequest.findMany({
      where: { completedAt: null },
      distinct: ['userId'],
      select: { userId: true },
      take: 500,
    });
    let n = 0;
    for (const u of users) n += await this.reconcile(u.userId);
    return n;
  }

  // ---- password --------------------------------------------------------------------------------------------

  async changePassword(
    userId: string,
    sessionId: string,
    token: string,
    dto: ChangePasswordDto,
  ): Promise<{ sessionsRevoked: number }> {
    await this.limit('password', userId, PASSWORD_LIMIT_PER_HOUR);
    const key = this.config.supabase.publishableKey;
    if (!key) throw ApiException.external('Changing the password is not available right now.');
    const me = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { email: true, phone: true },
    });
    const before = await this.sessions.count(userId);
    const anon = createClient(this.config.supabase.url, key, {
      auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
    });
    const creds = me.email
      ? { email: me.email, password: dto.currentPassword }
      : { phone: me.phone!, password: dto.currentPassword };
    const check = await anon.auth.signInWithPassword(creds);
    if (check.error || !check.data.user) {
      throw ApiException.validation('Your current password is not right.', {
        field: 'currentPassword',
      });
    }
    // Changed with the member's own session: Supabase ends every other session and keeps this one. The credential check
    // above opened a throw-away session that goes with them.
    const res = await this.asMember('PUT', '/user', token, { password: dto.newPassword });
    if (!res.ok) {
      throw ApiException.validation(
        /same|different/i.test(res.message)
          ? 'Choose a password you have not used before.'
          : 'That password is too weak. Use at least 8 characters with letters and numbers.',
        { field: 'newPassword' },
      );
    }
    // Belt and braces: whatever Supabase left open, apart from this session, is closed.
    await this.sessions.revokeAllForUser(userId, sessionId);
    const sessionsRevoked = Math.max(0, before - (await this.sessions.count(userId)));
    await this.audit.record({
      actorType: 'USER',
      actorId: userId,
      action: 'account.password_change',
      entityType: 'user',
      entityId: userId,
    });
    await this.tell(userId, {
      type: 'account.password_changed',
      title: 'Your password was changed',
      body: 'If this was not you, reset your password now and contact support.',
    });
    return { sessionsRevoked };
  }

  /** Security notices ignore push and email preferences: staying silent would be unsafe. */
  private async tell(
    userId: string,
    n: { type: string; title: string; body: string },
  ): Promise<void> {
    try {
      await this.notifications.notify({ userId, category: 'SYSTEM', critical: true, ...n });
    } catch {
      // A notice that cannot be delivered must not undo the change.
    }
  }
}
