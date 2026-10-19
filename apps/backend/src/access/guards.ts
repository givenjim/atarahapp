import { type CanActivate, type ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { type EntitlementKey } from '@prisma/client';
import type { Request } from 'express';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { PrismaService } from '../prisma/prisma.service';
import { AccessService } from './access.service';
import {
  ALLOW_PENDING,
  ENTITLEMENT,
  IS_PUBLIC,
  OPTIONAL_AUTH,
  PERMISSIONS,
  RECENT_AUTH_MINUTES,
} from './decorators';
import { TokenService } from './token.service';

/** Anything under /api/v1/admin is an admin route. */
export const isAdminPath = (req: Request): boolean => /^\/api\/v1\/admin(\/|$)/.test(req.path);

const ADMIN_TOUCH_INTERVAL_MS = 60_000;

/**
 * Authenticates every request that is not @Public: verifies the access token, checks the session family is
 * still live, applies account-status rules, keeps admin tokens and member tokens on their own routes, and
 * enforces the admin idle timeout. Runs before the permission and entitlement guards.
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly tokens: TokenService,
    private readonly prisma: PrismaService,
    private readonly access: AccessService,
    private readonly settings: PlatformSettingsService,
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
    const claims = this.tokens.verifyAccess(header.slice(7).trim());

    const adminRoute = isAdminPath(req);
    if (claims.adm !== adminRoute) {
      // Admin tokens only work on admin routes and member tokens only on member routes.
      throw ApiException.forbidden(
        adminRoute ? 'This area is for administrators.' : 'Use a member session for this action.',
        { reason: adminRoute ? 'ADMIN_ONLY' : 'MEMBER_ONLY' },
      );
    }

    const now = new Date();
    const head = await this.prisma.session.findFirst({
      where: {
        familyId: claims.fam,
        userId: claims.sub,
        revokedAt: null,
        rotatedAt: null,
        expiresAt: { gt: now },
      },
      select: { id: true, lastActiveAt: true, reauthAt: true },
    });
    if (!head) throw ApiException.unauthenticated('Your session has ended. Please sign in again.');

    const user = await this.prisma.user.findUnique({
      where: { id: claims.sub },
      select: { status: true, deletedAt: true },
    });
    if (!user || user.deletedAt) throw ApiException.unauthenticated();

    if (user.status !== 'ACTIVE') {
      const allowPending = this.reflector.getAllAndOverride<boolean>(ALLOW_PENDING, targets);
      if (!(user.status === 'PENDING_VERIFICATION' && allowPending)) {
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

    if (adminRoute) {
      const access = await this.access.effectiveAccess(claims.sub, user.status);
      if (!access.isStaff)
        throw ApiException.forbidden('This area is for administrators.', { reason: 'ADMIN_ONLY' });

      const idleMinutes = await this.settings.get<number>('auth.admin_idle_timeout_minutes', 30);
      if (now.getTime() - head.lastActiveAt.getTime() > idleMinutes * 60_000) {
        await this.prisma.session.updateMany({
          where: { familyId: claims.fam, revokedAt: null },
          data: { revokedAt: now, revokedReason: 'admin_idle_timeout' },
        });
        throw new ApiException(
          ErrorCode.AUTHENTICATION_REQUIRED,
          'You were signed out after a period of inactivity.',
          401,
          {
            reason: 'SESSION_IDLE',
          },
        );
      }
      if (now.getTime() - head.lastActiveAt.getTime() > ADMIN_TOUCH_INTERVAL_MS) {
        await this.prisma.session.update({ where: { id: head.id }, data: { lastActiveAt: now } });
      }
    }

    req.auth = {
      userId: claims.sub,
      familyId: claims.fam,
      status: user.status,
      isAdminSession: adminRoute,
      reauthAt: head.reauthAt,
    };
    return true;
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

/** Admin sensitive actions need a fresh password + TOTP re-authentication. */
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
        'Confirm your password and authenticator code to continue.',
        401,
        { reason: 'REAUTH_REQUIRED', withinMinutes: minutes },
      );
    }
    return true;
  }
}
