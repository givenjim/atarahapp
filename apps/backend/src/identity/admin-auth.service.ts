import { Inject, Injectable } from '@nestjs/common';
import { generateSecret, generateURI, verifySync } from 'otplib';
import { Redis } from 'ioredis';
import { AccessService } from '../access/access.service';
import { TokenService } from '../access/token.service';
import { ApiException } from '../common/api.exception';
import {
  decryptSecret,
  encryptSecret,
  hmacHex,
  randomRecoveryCode,
  safeEqualHex,
} from '../common/crypto';
import { ErrorCode } from '../common/error-codes';
import { AppConfigService } from '../config/app-config.service';
import { AuditService } from '../audit/audit.service';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';
import { type AuthSession, AuthService, type RequestMeta } from './auth.service';
import { PasswordService } from './password.service';
import { SessionService } from './session.service';
import { UserViewService } from './user-view.service';

const WRONG = 'That email or password is not right.';
const FAIL_LIMIT = 5;
const FAIL_LOCK_SECONDS = 15 * 60;
const RECOVERY_CODE_COUNT = 8;
const TOTP_TOLERANCE_SECONDS = 30;

export type AdminLoginStep = 'TOTP_ENROLMENT_REQUIRED' | 'TOTP_REQUIRED';

/**
 * Administrator sign-in: password, then TOTP (enrolling on first use), then a short-lived admin session.
 * Admin tokens only work on /api/v1/admin/* and member tokens never do. Sensitive actions need a fresh
 * password + TOTP re-authentication (see @RequiresRecentAuth).
 */
@Injectable()
export class AdminAuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: AppConfigService,
    private readonly passwords: PasswordService,
    private readonly tokens: TokenService,
    private readonly access: AccessService,
    private readonly auth: AuthService,
    private readonly sessions: SessionService,
    private readonly userViews: UserViewService,
    private readonly audit: AuditService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async login(
    email: string,
    password: string,
    meta: RequestMeta,
  ): Promise<{ step: AdminLoginStep; challengeToken: string }> {
    const normalised = email.trim().toLowerCase();
    await this.assertNotLocked(normalised);

    const user = await this.prisma.user.findFirst({
      where: { email: normalised, deletedAt: null },
    });
    const credential = user
      ? await this.prisma.credential.findUnique({ where: { userId: user.id } })
      : null;

    const fail = async (): Promise<never> => {
      await this.recordFailure(normalised);
      await this.audit.record({
        actorType: 'SYSTEM',
        action: 'admin.login_failed',
        entityType: 'User',
        entityId: user?.id ?? null,
        after: { email: normalised },
        ip: meta.ip,
      });
      throw new ApiException(ErrorCode.INVALID_CREDENTIALS, WRONG, 401);
    };

    if (!user || !credential) {
      await this.passwords.burn(password);
      return fail();
    }
    if (!(await this.passwords.verify(credential.passwordHash, password))) return fail();
    // Same answer for "not an admin" and "wrong password": do not reveal which emails are staff.
    const { isStaff } = await this.access.effectiveAccess(user.id, user.status);
    if (user.status !== 'ACTIVE' || !isStaff) return fail();

    const totp = await this.prisma.adminTotp.findUnique({ where: { userId: user.id } });
    const enrol = !totp?.confirmedAt;
    return {
      step: enrol ? 'TOTP_ENROLMENT_REQUIRED' : 'TOTP_REQUIRED',
      challengeToken: this.tokens.signAdminChallenge(user.id, enrol),
    };
  }

  /** First-time enrolment: returns the secret and otpauth URL once, to be scanned into an authenticator app. */
  async totpSetup(challengeToken: string): Promise<{ secret: string; otpauthUrl: string }> {
    const claims = this.tokens.verifyAdminChallenge(challengeToken);
    if (!claims.enrol)
      throw ApiException.forbidden('Authenticator is already set up for this account.');
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: claims.sub } });

    const secret = generateSecret();
    const secretEncrypted = encryptSecret(this.config.peppers.dataKey, secret);
    await this.prisma.adminTotp.upsert({
      where: { userId: user.id },
      create: { userId: user.id, secretEncrypted },
      update: {
        secretEncrypted,
        confirmedAt: null,
        lastUsedTimeStep: null,
        recoveryCodeHashes: [],
      },
    });
    return {
      secret,
      otpauthUrl: generateURI({ issuer: 'Atarah Admin', label: user.email ?? user.id, secret }),
    };
  }

  /** Completes sign-in with an authenticator code (or a one-time recovery code). */
  async totpVerify(
    challengeToken: string,
    input: { code?: string; recoveryCode?: string },
    meta: RequestMeta,
  ): Promise<AuthSession & { recoveryCodes?: string[] }> {
    const claims = this.tokens.verifyAdminChallenge(challengeToken);
    const lockId = `totp:${claims.sub}`;
    await this.assertNotLocked(lockId);

    const totp = await this.prisma.adminTotp.findUnique({ where: { userId: claims.sub } });
    if (!totp) throw ApiException.forbidden('Authenticator is not set up for this account.');
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: claims.sub } });
    const { isStaff } = await this.access.effectiveAccess(user.id, user.status);
    if (user.status !== 'ACTIVE' || !isStaff)
      throw ApiException.forbidden('This account cannot sign in to the admin console.');

    let recoveryCodes: string[] | undefined;
    const enrolling = totp.confirmedAt === null;

    if (input.recoveryCode) {
      if (enrolling) throw ApiException.forbidden('Finish setting up your authenticator first.');
      await this.consumeRecoveryCode(totp.id, totp.recoveryCodeHashes, input.recoveryCode, lockId);
    } else if (input.code) {
      await this.consumeTotpCode(
        totp.id,
        totp.secretEncrypted,
        totp.lastUsedTimeStep,
        input.code,
        lockId,
      );
      if (enrolling) {
        recoveryCodes = Array.from({ length: RECOVERY_CODE_COUNT }, randomRecoveryCode);
        await this.prisma.adminTotp.update({
          where: { id: totp.id },
          data: {
            confirmedAt: new Date(),
            recoveryCodeHashes: recoveryCodes.map((c) => this.hashRecovery(c)),
          },
        });
      }
    } else {
      throw ApiException.validation('Enter the code from your authenticator app.', {
        fields: [{ field: 'code', messages: ['Enter the code from your authenticator app.'] }],
      });
    }
    await this.redis.del(this.failKey(lockId)).catch(() => undefined);

    await this.prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } });
    const session = await this.auth.startSession(user.id, {
      client: 'ADMIN',
      deviceName: 'Admin console',
      ip: meta.ip ?? null,
      userAgent: meta.userAgent ?? null,
    });
    await this.audit.record({
      actorType: 'ADMIN',
      actorId: user.id,
      action: enrolling ? 'admin.totp_enrolled' : 'admin.login',
      entityType: 'User',
      entityId: user.id,
      ip: meta.ip,
    });
    return { ...session, recoveryCodes };
  }

  async refresh(refreshToken: string): Promise<AuthSession> {
    const rotated = await this.sessions.rotate(refreshToken, 'ADMIN');
    const user = await this.prisma.user.findUnique({ where: { id: rotated.userId } });
    const { isStaff } = user
      ? await this.access.effectiveAccess(user.id, user.status)
      : { isStaff: false };
    if (!user || user.status !== 'ACTIVE' || !isStaff) {
      await this.sessions.revokeFamily(rotated.familyId, 'admin_access_lost');
      throw ApiException.forbidden('This account cannot sign in to the admin console.');
    }
    return this.auth.issueTokens(
      rotated.userId,
      rotated.familyId,
      rotated.refreshToken,
      rotated.refreshTokenExpiresAt,
      true,
    );
  }

  /** Re-authenticate for sensitive actions: password and a current authenticator code. */
  async reauth(
    userId: string,
    familyId: string,
    input: { password: string; code: string },
    meta: RequestMeta,
  ): Promise<{ reauthenticatedUntil: Date }> {
    const lockId = `reauth:${userId}`;
    await this.assertNotLocked(lockId);

    const credential = await this.prisma.credential.findUnique({ where: { userId } });
    const totp = await this.prisma.adminTotp.findUnique({ where: { userId } });
    if (
      !credential ||
      !totp?.confirmedAt ||
      !(await this.passwords.verify(credential.passwordHash, input.password))
    ) {
      await this.recordFailure(lockId);
      throw new ApiException(
        ErrorCode.INVALID_CREDENTIALS,
        'Your password or code is not right.',
        401,
      );
    }
    await this.consumeTotpCode(
      totp.id,
      totp.secretEncrypted,
      totp.lastUsedTimeStep,
      input.code,
      lockId,
    );
    await this.redis.del(this.failKey(lockId)).catch(() => undefined);

    const now = new Date();
    await this.prisma.session.updateMany({
      where: { familyId, userId, revokedAt: null, rotatedAt: null },
      data: { reauthAt: now },
    });
    await this.audit.record({
      actorType: 'ADMIN',
      actorId: userId,
      action: 'admin.reauth',
      entityType: 'User',
      entityId: userId,
      ip: meta.ip,
    });
    return { reauthenticatedUntil: new Date(now.getTime() + 5 * 60_000) };
  }

  async profile(userId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    const access = await this.access.effectiveAccess(userId, user.status);
    return {
      ...(await this.userViews.me(userId)),
      permissions: [...access.permissions].sort(),
    };
  }

  async logout(familyId: string): Promise<void> {
    await this.sessions.revokeFamily(familyId, 'admin_logout');
  }

  // ---- internals ----

  private async consumeTotpCode(
    totpId: string,
    secretEncrypted: string,
    lastUsedTimeStep: number | null,
    code: string,
    lockId: string,
  ): Promise<void> {
    const secret = decryptSecret(this.config.peppers.dataKey, secretEncrypted);
    const result = verifySync({
      secret,
      token: code,
      epochTolerance: TOTP_TOLERANCE_SECONDS,
      ...(lastUsedTimeStep !== null ? { afterTimeStep: lastUsedTimeStep } : {}),
    });
    if (!result.valid) {
      await this.recordFailure(lockId);
      throw new ApiException(
        ErrorCode.INVALID_CREDENTIALS,
        'That code is not right. Check your authenticator app.',
        401,
      );
    }
    const timeStep =
      (result as { timeStep?: number }).timeStep ?? Math.floor(Date.now() / 1000 / 30);
    // Replay protection: a time step can be used once. Compare-and-set so two parallel requests cannot both win.
    const updated = await this.prisma.adminTotp.updateMany({
      where: {
        id: totpId,
        OR: [{ lastUsedTimeStep: null }, { lastUsedTimeStep: { lt: timeStep } }],
      },
      data: { lastUsedTimeStep: timeStep },
    });
    if (updated.count !== 1) {
      await this.recordFailure(lockId);
      throw new ApiException(
        ErrorCode.INVALID_CREDENTIALS,
        'That code was already used. Wait for the next one.',
        401,
      );
    }
  }

  private async consumeRecoveryCode(
    totpId: string,
    hashes: string[],
    code: string,
    lockId: string,
  ): Promise<void> {
    const candidate = this.hashRecovery(code);
    const match = hashes.find((h) => safeEqualHex(h, candidate));
    if (!match) {
      await this.recordFailure(lockId);
      throw new ApiException(
        ErrorCode.INVALID_CREDENTIALS,
        'That recovery code is not valid.',
        401,
      );
    }
    // Single use: remove it, guarding against a parallel request using the same code.
    const row = await this.prisma.adminTotp.findUniqueOrThrow({ where: { id: totpId } });
    if (!row.recoveryCodeHashes.includes(match)) {
      throw new ApiException(
        ErrorCode.INVALID_CREDENTIALS,
        'That recovery code is not valid.',
        401,
      );
    }
    const res = await this.prisma.adminTotp.updateMany({
      where: { id: totpId, recoveryCodeHashes: { has: match } },
      data: { recoveryCodeHashes: row.recoveryCodeHashes.filter((h) => h !== match) },
    });
    if (res.count !== 1)
      throw new ApiException(
        ErrorCode.INVALID_CREDENTIALS,
        'That recovery code is not valid.',
        401,
      );
  }

  private hashRecovery(code: string): string {
    return hmacHex(this.config.peppers.code, `admin-recovery:${code.toUpperCase()}`);
  }

  private failKey(id: string): string {
    return `auth:fail:admin:${id}`;
  }

  private async assertNotLocked(id: string): Promise<void> {
    try {
      const count = Number((await this.redis.get(this.failKey(id))) ?? 0);
      if (count >= FAIL_LIMIT) {
        const ttl = await this.redis.ttl(this.failKey(id));
        throw new ApiException(
          ErrorCode.RATE_LIMITED,
          'Too many attempts. Please wait a few minutes.',
          429,
          {
            retryAfterSeconds: ttl > 0 ? ttl : FAIL_LOCK_SECONDS,
          },
        );
      }
    } catch (err) {
      if (err instanceof ApiException) throw err;
    }
  }

  private async recordFailure(id: string): Promise<void> {
    try {
      const n = await this.redis.incr(this.failKey(id));
      if (n === 1) await this.redis.expire(this.failKey(id), FAIL_LOCK_SECONDS);
    } catch {
      // best effort
    }
  }
}
