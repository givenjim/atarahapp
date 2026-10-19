import { createParamDecorator, type ExecutionContext, SetMetadata } from '@nestjs/common';
import { type EntitlementKey } from '@prisma/client';
import type { Request } from 'express';
import { ApiException } from '../common/api.exception';
import { type AuthContext } from './access.types';

export const IS_PUBLIC = 'access:public';
export const ALLOW_PENDING = 'access:allow-pending';
export const PERMISSIONS = 'access:permissions';
export const ENTITLEMENT = 'access:entitlement';
export const RECENT_AUTH_MINUTES = 'access:recent-auth';
export const OPTIONAL_AUTH = 'access:optional-auth';

/** No authentication required. Everything else is authenticated by default. */
export const Public = () => SetMetadata(IS_PUBLIC, true);

/**
 * Works signed out and signed in. Without a token the request is anonymous; with one it is authenticated
 * exactly as usual (a bad or expired token is still a 401, so the app can refresh it). Read the caller with
 * `@Viewer()`.
 */
export const OptionalAuth = () => SetMetadata(OPTIONAL_AUTH, true);

/** Permit accounts still in PENDING_VERIFICATION (e.g. resending the code, reading /users/me). */
export const AllowPending = () => SetMetadata(ALLOW_PENDING, true);

/** All listed permissions are required (`resource.action`). Evaluated by the backend on every request. */
export const RequiresPermission = (...keys: string[]) => SetMetadata(PERMISSIONS, keys);

/** The member must hold the entitlement through a live membership, otherwise PREMIUM_REQUIRED. */
export const RequiresEntitlement = (key: EntitlementKey) => SetMetadata(ENTITLEMENT, key);

/** Admin sensitive actions: password + TOTP re-authentication within the last N minutes (default 5). */
export const RequiresRecentAuth = (minutes = 5) => SetMetadata(RECENT_AUTH_MINUTES, minutes);

/** The authenticated caller. Only valid on non-@Public routes. */
export const CurrentAuth = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): AuthContext => {
    const req = ctx.switchToHttp().getRequest<Request>();
    if (!req.auth) throw ApiException.unauthenticated();
    return req.auth;
  },
);

/** The caller on an @OptionalAuth route: undefined when anonymous. */
export const Viewer = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): AuthContext | undefined => {
    return ctx.switchToHttp().getRequest<Request>().auth;
  },
);

/** Client IP for audit records. Trust-proxy configuration decides what `req.ip` means in production. */
export const ClientIp = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): string | undefined => {
    return ctx.switchToHttp().getRequest<Request>().ip ?? undefined;
  },
);

export const RequestIdParam = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): string | undefined => {
    const v = ctx.switchToHttp().getRequest<Request>().headers['x-request-id'];
    return typeof v === 'string' ? v : undefined;
  },
);

/** Raw User-Agent header. A param decorator (not @Headers) so it does not appear as an API parameter. */
export const UserAgent = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): string | undefined => {
    const v = ctx.switchToHttp().getRequest<Request>().headers['user-agent'];
    return typeof v === 'string' ? v : undefined;
  },
);
