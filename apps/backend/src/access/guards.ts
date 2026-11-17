import { type CanActivate, type ExecutionContext, Inject, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { type EntitlementKey } from '@prisma/client';
import type { Request } from 'express';
import type { Redis } from 'ioredis';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';
import { SupabaseJwtService } from '../supabase/supabase-jwt.service';
import { AccessService } from './access.service';
import { twoStepVerdict } from './two-step.policy';
import {
  ALLOW_DEACTIVATED,
  ALLOW_PENDING,
  ALLOW_TWO_STEP_PENDING,
  ENTITLEMENT,
  IS_PUBLIC,
  OPTIONAL_AUTH,
  PERMISSIONS,
  RECENT_AUTH_MINUTES,
} from './decorators';

/** Anything under /api/v1/admin is an admin route. */
export const isAdminPath = (req: Request): boolean => /^\/api\/v1\/admin(\/|$)/.test(req.path);

const ADMIN_ACTIVITY_PREFIX = 'auth:admin-activity:';

/**
 * Authenticates every request that is not @Public. The bearer token is a Supabase Auth JWT: it is verified
 * (signature, issuer, audience, expiry), the Supabase session must still exist, and the account is loaded from
 * `public.users` by `sub`. Suspended, deactivated and deleted accounts are refused. Admin routes also need an
 * AAL2 token (a verified MFA factor), staff access, and are signed out after an idle period. Runs before the
 * permission and entitlement guards. Authorisation never reads Supabase `user_metadata`.
 */
@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly jwt: SupabaseJwtService,
    private readonly prisma: PrismaService,
    private readonly access: AccessService,
    private readonly settings: PlatformSettingsService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const targets = [ctx.getHandler(), ctx.getClass()];
    if (this.reflector.getAllAndOverride<boolean>(IS_PUBLIC, targets)) return true;

    const req = ctx.switchToHttp().getRequest<Request>();
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      if (this.reflector.getAllAndOverride<boolean>(OPTIONAL_AUTH, targets)) return true;
      throw ApiException.unauthenticated();
    }
    const claims = await this.jwt.verify(header.slice(7).trim());
    if (claims.role !== 'authenticated' || claims.isAnonymous) throw ApiException.unauthenticated();

    // A revoked or signed-out session must stop working immediately, not when the 1-hour token expires.
    const [live] = await this.prisma.$queryRaw<Array<{ ok: boolean }>>`
      SELECT public.atarah_auth_session_exists(${claims.sessionId}::uuid, ${claims.sub}::uuid) AS ok`;
    if (!live?.ok)
      throw ApiException.unauthenticated('Your session has ended. Please sign in again.');

    const user = await this.prisma.user.findUnique({
      where: { id: claims.sub },
      select: { status: true, deletedAt: true },
    });
    if (!user || user.deletedAt) throw ApiException.unauthenticated();

    if (user.status !== 'ACTIVE') {
      const allowPending = this.reflector.getAllAndOverride<boolean>(ALLOW_PENDING, targets);
      // A member who asked to delete their account may still sign in during the grace period to restore it.
      const allowDeactivated =
        user.status === 'DEACTIVATED' &&
        this.reflector.getAllAndOverride<boolean>(ALLOW_DEACTIVATED, targets) &&
        (await this.hasPendingDeletion(claims.sub));
      if (!(user.status === 'PENDING_VERIFICATION' && allowPending) && !allowDeactivated) {
        throw new ApiException(
          user.status === 'PENDING_VERIFICATION'
            ? ErrorCode.VERIFICATION_REQUIRED
            : ErrorCode.FORBIDDEN,
          user.status === 'PENDING_VERIFICATION'
            ? 'Verify your account to continue.'
            : 'This account cannot be used right now.',
          403,
          { reason: `ACCOUNT_${user.status}` },
        );
      }
    }

    if (
      user.status === 'ACTIVE' &&
      !this.reflector.getAllAndOverride<boolean>(ALLOW_TWO_STEP_PENDING, targets)
    ) {
      await this.enforceTwoStep(claims.sub, claims.sessionId, claims.aal);
    }

    const adminRoute = isAdminPath(req);
    if (adminRoute) {
      const access = await this.access.effectiveAccess(claims.sub, user.status);
      if (!access.isStaff)
        throw ApiException.forbidden('This area is for administrators.', { reason: 'ADMIN_ONLY' });
      if (claims.aal !== 'aal2') {
        throw ApiException.forbidden('Confirm your authenticator code to continue.', {
          reason: 'MFA_REQUIRED',
        });
      }
      await this.enforceAdminIdleTimeout(claims.sessionId, claims.sub);
    }

    const totp = claims.amr
      .filter((m) => m.method === 'totp')
      .reduce((latest, m) => Math.max(latest, m.timestamp), 0);
    req.auth = {
      userId: claims.sub,
      sessionId: claims.sessionId,
      status: user.status,
      isAdminSession: adminRoute,
      aal: claims.aal,
      reauthAt: totp > 0 ? new Date(totp * 1000) : null,
    };
    return true;
  }

  private async hasPendingDeletion(userId: string): Promise<boolean> {
    return (
      (await this.prisma.accountDeletionRequest.count({ where: { userId, status: 'PENDING' } })) > 0
    );
  }

  /** Whether the member turned two-step on. Cached briefly; the toggle clears the entry. */
  private async twoStepOn(userId: string): Promise<boolean> {
    const key = `2fa:on:${userId}`;
    const hit = await this.redis.get(key).catch(() => null);
    if (hit !== null) return hit === '1';
    const row = await this.prisma.twoStepSetting.findUnique({
      where: { userId },
      select: { enabled: true },
    });
    const on = row?.enabled === true;
    await this.redis.set(key, on ? '1' : '0', 'EX', 60).catch(() => undefined);
    return on;
  }

  /** New device plus two-step on means the second-factor challenge comes first (see two-step.policy.ts). */
  private async enforceTwoStep(userId: string, sessionId: string, aal: 'aal1' | 'aal2'): Promise<void> {
    if (!(await this.twoStepOn(userId))) return;
    const enforced = await this.settings.get<boolean>('auth.two_step_enforced', true);
    const device = await this.prisma.userDevice.findFirst({
      where: { userId, lastSessionId: sessionId },
      select: { id: true, verifiedAt: true },
    });
    const verdict = twoStepVerdict({ enabled: true, enforced, aal, device });
    if (verdict === 'CHALLENGE') {
      throw ApiException.forbidden('Confirm it is you with your second step to continue.', {
        reason: 'TWO_STEP_REQUIRED',
      });
    }
    if (verdict === 'MARK_VERIFIED' && device) {
      await this.prisma.userDevice.update({
        where: { id: device.id },
        data: { verifiedAt: new Date() },
      });
    }
  }

  /** Staff are signed out after `auth.admin_idle_timeout_minutes` without a request (default 30). */
  private async enforceAdminIdleTimeout(sessionId: string, userId: string): Promise<void> {
    const idleMinutes = await this.settings.get<number>('auth.admin_idle_timeout_minutes', 30);
    const key = `${ADMIN_ACTIVITY_PREFIX}${sessionId}`;
    const now = Date.now();
    const last = Number(await this.redis.get(key).catch(() => null));
    if (last && now - last > idleMinutes * 60_000) {
      await this.prisma.$queryRaw`
        SELECT public.atarah_auth_delete_session(${sessionId}::uuid, ${userId}::uuid)`;
      await this.redis.del(key).catch(() => undefined);
      throw new ApiException(
        ErrorCode.AUTHENTICATION_REQUIRED,
        'You were signed out after a period of inactivity.',
        401,
        { reason: 'SESSION_IDLE' },
      );
    }
    await this.redis.set(key, String(now), 'EX', 24 * 3600).catch(() => undefined);
  }
}

/** Requires every permission named by @RequiresPermission (plus `admin.access` on admin routes). */
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly access: AccessService,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const targets = [ctx.getHandler(), ctx.getClass()];
    const req = ctx.switchToHttp().getRequest<Request>();
    const required =
      this.reflector.getAllAndOverride<string[] | undefined>(PERMISSIONS, targets) ?? [];
    if (!req.auth) return true; // @Public route

    const needed = isAdminPath(req) ? ['admin.access', ...required] : required;
    if (needed.length === 0) return true;

    const { permissions } = await this.access.effectiveAccess(req.auth.userId, req.auth.status);
    const missing = needed.filter((k) => !permissions.has(k));
    if (missing.length > 0) {
      throw ApiException.forbidden('You do not have permission to do that.', { missing });
    }
    return true;
  }
}

/** PREMIUM_REQUIRED unless the caller's live membership grants the entitlement. */
@Injectable()
export class EntitlementsGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly access: AccessService,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const key = this.reflector.getAllAndOverride<EntitlementKey | undefined>(ENTITLEMENT, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    if (!key) return true;
    const req = ctx.switchToHttp().getRequest<Request>();
    if (!req.auth) return true;
    if (!(await this.access.hasEntitlement(req.auth.userId, key))) {
      throw new ApiException(ErrorCode.PREMIUM_REQUIRED, 'This is part of Atarah Pro.', 403, {
        entitlement: key,
      });
    }
    return true;
  }
}

/** Admin sensitive actions need a fresh authenticator-code (TOTP) verification on the session. */
@Injectable()
export class RecentAuthGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const minutes = this.reflector.getAllAndOverride<number | undefined>(RECENT_AUTH_MINUTES, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    if (minutes === undefined) return true;
    const req = ctx.switchToHttp().getRequest<Request>();
    const reauthAt = req.auth?.reauthAt;
    if (!reauthAt || Date.now() - reauthAt.getTime() > minutes * 60_000) {
      throw new ApiException(
        ErrorCode.AUTHENTICATION_REQUIRED,
        'Confirm your authenticator code to continue.',
        401,
        { reason: 'REAUTH_REQUIRED', withinMinutes: minutes },
      );
    }
    return true;
  }
}
