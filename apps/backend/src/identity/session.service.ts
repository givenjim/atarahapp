import { randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { type SessionClient } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { hmacHex, randomToken } from '../common/crypto';
import { ErrorCode } from '../common/error-codes';
import { AppConfigService } from '../config/app-config.service';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { PrismaService } from '../prisma/prisma.service';

/** A client that retries the same refresh token within this window is not treated as an attack. */
const ROTATION_GRACE_MS = 10_000;

export interface SessionTokens {
  refreshToken: string;
  refreshTokenExpiresAt: Date;
  familyId: string;
}

export interface DeviceInfo {
  client: SessionClient;
  deviceName?: string | null;
  ip?: string | null;
  userAgent?: string | null;
}

export interface SessionView {
  /** The session family id; stable across refresh-token rotations. */
  id: string;
  client: SessionClient;
  deviceName: string | null;
  approxLocation: string | null;
  lastActiveAt: Date;
  current: boolean;
}

/**
 * Sessions are chains ("families") of opaque refresh tokens. Each refresh rotates the token. Presenting a
 * token that was already rotated means it was stolen or replayed, so the whole family is revoked.
 */
@Injectable()
export class SessionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfigService,
    private readonly settings: PlatformSettingsService,
  ) {}

  private hash(token: string): string {
    return hmacHex(this.config.peppers.refresh, token);
  }

  private async refreshTtlMs(client: SessionClient): Promise<number> {
    if (client === 'ADMIN') {
      // Admin sessions are short; the idle timeout (30 min) also applies on every request.
      return 12 * 3600 * 1000;
    }
    const days = await this.settings.get<number>('auth.refresh_token_ttl_days', 30);
    return days * 24 * 3600 * 1000;
  }

  async create(
    userId: string,
    device: DeviceInfo,
    familyId: string = randomUUID(),
  ): Promise<SessionTokens> {
    const token = randomToken();
    const expiresAt = new Date(Date.now() + (await this.refreshTtlMs(device.client)));
    await this.prisma.session.create({
      data: {
        userId,
        familyId,
        refreshTokenHash: this.hash(token),
        client: device.client,
        deviceName: device.deviceName?.slice(0, 80) ?? null,
        ip: device.ip ?? null,
        userAgent: device.userAgent?.slice(0, 200) ?? null,
        expiresAt,
      },
    });
    return { refreshToken: token, refreshTokenExpiresAt: expiresAt, familyId };
  }

  /**
   * Validates and rotates a refresh token. Returns the user id, the (unchanged) family, and a fresh token.
   * Throws AUTHENTICATION_REQUIRED for unknown, expired, revoked or replayed tokens.
   */
  async rotate(
    refreshToken: string,
    expectedClient: 'ADMIN' | 'MEMBER',
  ): Promise<SessionTokens & { userId: string; client: SessionClient }> {
    const now = new Date();
    const session = await this.prisma.session.findUnique({
      where: { refreshTokenHash: this.hash(refreshToken) },
    });
    if (!session) throw this.expired();

    if ((session.client === 'ADMIN') !== (expectedClient === 'ADMIN')) throw this.expired();
    if (session.revokedAt || session.expiresAt <= now) throw this.expired();

    if (session.rotatedAt) {
      if (now.getTime() - session.rotatedAt.getTime() <= ROTATION_GRACE_MS) {
        // Likely a client retry racing its own rotation. Do not revoke; ask it to use the newest token.
        throw new ApiException(ErrorCode.AUTHENTICATION_REQUIRED, 'Please try again.', 401, {
          reason: 'REFRESH_IN_PROGRESS',
        });
      }
      await this.revokeFamily(session.familyId, 'refresh_token_reuse');
      throw new ApiException(
        ErrorCode.AUTHENTICATION_REQUIRED,
        'Your session ended for your security. Please sign in again.',
        401,
        { reason: 'TOKEN_REUSED' },
      );
    }

    if (session.client === 'ADMIN') {
      const idle = await this.settings.get<number>('auth.admin_idle_timeout_minutes', 30);
      if (now.getTime() - session.lastActiveAt.getTime() > idle * 60_000) {
        await this.revokeFamily(session.familyId, 'admin_idle_timeout');
        throw new ApiException(
          ErrorCode.AUTHENTICATION_REQUIRED,
          'You were signed out after a period of inactivity.',
          401,
          {
            reason: 'SESSION_IDLE',
          },
        );
      }
    }

    // Only one concurrent caller can flip rotatedAt from null.
    const flipped = await this.prisma.session.updateMany({
      where: { id: session.id, rotatedAt: null, revokedAt: null },
      data: { rotatedAt: now },
    });
    if (flipped.count !== 1) {
      throw new ApiException(ErrorCode.AUTHENTICATION_REQUIRED, 'Please try again.', 401, {
        reason: 'REFRESH_IN_PROGRESS',
      });
    }

    const next = await this.create(
      session.userId,
      {
        client: session.client,
        deviceName: session.deviceName,
        ip: session.ip,
        userAgent: session.userAgent,
      },
      session.familyId,
    );
    return { ...next, userId: session.userId, client: session.client };
  }

  async revokeFamily(familyId: string, reason: string): Promise<void> {
    await this.prisma.session.updateMany({
      where: { familyId, revokedAt: null },
      data: { revokedAt: new Date(), revokedReason: reason },
    });
  }

  async revokeAllForUser(userId: string, reason: string, exceptFamilyId?: string): Promise<number> {
    const res = await this.prisma.session.updateMany({
      where: {
        userId,
        revokedAt: null,
        ...(exceptFamilyId ? { familyId: { not: exceptFamilyId } } : {}),
      },
      data: { revokedAt: new Date(), revokedReason: reason },
    });
    return res.count;
  }

  /** Revoke one of the user's own sessions (Settings > Security > Active sessions > Sign out). */
  async revokeOwn(userId: string, familyId: string): Promise<void> {
    const exists = await this.prisma.session.findFirst({
      where: { userId, familyId },
      select: { id: true },
    });
    if (!exists) throw ApiException.notFound('That session does not exist.');
    await this.revokeFamily(familyId, 'user_sign_out');
  }

  async list(userId: string, currentFamilyId: string): Promise<SessionView[]> {
    const rows = await this.prisma.session.findMany({
      where: {
        userId,
        revokedAt: null,
        rotatedAt: null,
        expiresAt: { gt: new Date() },
        client: { not: 'ADMIN' },
      },
      orderBy: { lastActiveAt: 'desc' },
    });
    return rows.map((s) => ({
      id: s.familyId,
      client: s.client,
      deviceName: s.deviceName,
      approxLocation: s.approxLocation,
      lastActiveAt: s.lastActiveAt,
      current: s.familyId === currentFamilyId,
    }));
  }

  private expired(): ApiException {
    return ApiException.unauthenticated('Your session has expired. Please sign in again.');
  }
}
