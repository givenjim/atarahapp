import { Inject, Injectable, Logger } from '@nestjs/common';
import { type CodePurpose, type SessionClient, type User } from '@prisma/client';
import { Redis } from 'ioredis';
import { TokenService } from '../access/token.service';
import { ApiException } from '../common/api.exception';
import { type Identifier, maskIdentifier, parseIdentifier } from '../common/contact';
import { ErrorCode } from '../common/error-codes';
import { FeatureFlagService } from '../feature-flags/feature-flag.service';
import {
  EMAIL_PROVIDER,
  type EmailProvider,
  SMS_PROVIDER,
  type SmsProvider,
} from '../messaging/messaging';
import { type CodeMessageKind, emailFor, renderCodeMessage } from '../messaging/templates';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';
import { CodeService, type IssuedCode } from './code.service';
import {
  type LoginDto,
  type MemberClient,
  type RegisterDto,
  type ResetPasswordDto,
  type VerifyDto,
} from './identity.dto';
import { GOOGLE_AUTH_PROVIDER, type GoogleAuthProvider } from './google.provider';
import { PasswordService } from './password.service';
import { type DeviceInfo, SessionService } from './session.service';
import { type MeView, UserViewService } from './user-view.service';

export interface AuthSession {
  accessToken: string;
  accessTokenExpiresAt: Date;
  refreshToken: string;
  refreshTokenExpiresAt: Date;
  user: MeView;
}

export interface RequestMeta {
  ip?: string;
  userAgent?: string;
}

const LOGIN_FAILURE_LIMIT = 5;
const LOGIN_LOCK_SECONDS = 15 * 60;

const WRONG_PASSWORD =
  "That password doesn't match this account. Check it and try again, or reset it.";

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly passwords: PasswordService,
    private readonly codes: CodeService,
    private readonly sessions: SessionService,
    private readonly tokens: TokenService,
    private readonly userViews: UserViewService,
    private readonly flags: FeatureFlagService,
    @Inject(REDIS) private readonly redis: Redis,
    @Inject(EMAIL_PROVIDER) private readonly email: EmailProvider,
    @Inject(SMS_PROVIDER) private readonly sms: SmsProvider,
    @Inject(GOOGLE_AUTH_PROVIDER) private readonly google: GoogleAuthProvider,
  ) {}

  // ---------------------------------------------------------------------------------------------
  // Registration and verification
  // ---------------------------------------------------------------------------------------------

  async register(dto: RegisterDto): Promise<{
    verification: {
      channel: 'EMAIL' | 'SMS';
      destination: string;
      expiresAt: Date;
      resendAvailableAt: Date;
    };
  }> {
    const id = parseIdentifier(dto.identifier);
    const existing = await this.findByIdentifier(id);
    if (existing) {
      const label = id.kind === 'email' ? 'email' : 'phone number';
      throw ApiException.conflict(
        `An account with this ${label} already exists. Sign in instead?`,
        {
          fields: [
            { field: 'identifier', messages: [`An account with this ${label} already exists.`] },
          ],
          reason: 'ACCOUNT_EXISTS',
        },
      );
    }

    const [terms, privacy] = await Promise.all([
      this.latestLegalVersion('TERMS'),
      this.latestLegalVersion('PRIVACY'),
    ]);
    const passwordHash = await this.passwords.hash(dto.password);

    const user = await this.prisma.user.create({
      data: {
        fullName: dto.fullName.trim(),
        email: id.kind === 'email' ? id.value : null,
        phone: id.kind === 'phone' ? id.value : null,
        status: 'PENDING_VERIFICATION',
        credential: { create: { passwordHash } },
        consents: {
          create: [
            { documentType: 'TERMS', version: terms },
            { documentType: 'PRIVACY', version: privacy },
          ],
        },
      },
    });

    const issued = await this.sendCode(user, id, 'REGISTRATION', 'verify');
    return {
      verification: {
        channel: id.kind === 'email' ? 'EMAIL' : 'SMS',
        destination: maskIdentifier(id),
        expiresAt: issued.expiresAt,
        resendAvailableAt: issued.resendAvailableAt,
      },
    };
  }

  async verify(dto: VerifyDto, meta: RequestMeta): Promise<AuthSession> {
    const id = parseIdentifier(dto.identifier);
    const user = await this.findByIdentifier(id);
    // Unknown identifier looks exactly like a wrong code.
    if (!user)
      throw ApiException.validation('That code is not right or has expired.', {
        fields: [{ field: 'code', messages: ['That code is not right or has expired.'] }],
      });

    await this.codes.verify({ userId: user.id, purpose: 'REGISTRATION', code: dto.code });

    const now = new Date();
    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        ...(id.kind === 'email' ? { emailVerifiedAt: now } : { phoneVerifiedAt: now }),
        ...(user.status === 'PENDING_VERIFICATION'
          ? { status: 'ACTIVE', statusChangedAt: now }
          : {}),
      },
    });
    return this.startSession(user.id, this.device(dto.client ?? 'ANDROID', dto.deviceName, meta));
  }

  /** Always succeeds from the caller's point of view (no account enumeration). */
  async resendVerification(identifier: string): Promise<{ resendAvailableAt: Date | null }> {
    const id = parseIdentifier(identifier);
    const user = await this.findByIdentifier(id);
    if (!user || user.status !== 'PENDING_VERIFICATION') return { resendAvailableAt: null };
    const issued = await this.sendCode(user, id, 'REGISTRATION', 'verify');
    return { resendAvailableAt: issued.resendAvailableAt };
  }

  // ---------------------------------------------------------------------------------------------
  // Sign in, refresh, sign out
  // ---------------------------------------------------------------------------------------------

  async login(dto: LoginDto, meta: RequestMeta): Promise<AuthSession> {
    const id = parseIdentifier(dto.identifier);
    const lockKey = `auth:fail:member:${id.value}`;
    await this.assertNotLocked(lockKey);

    const user = await this.findByIdentifier(id);
    const credential = user
      ? await this.prisma.credential.findUnique({ where: { userId: user.id } })
      : null;

    if (!user || !credential) {
      await this.passwords.burn(dto.password);
      await this.recordFailure(lockKey);
      throw new ApiException(ErrorCode.INVALID_CREDENTIALS, WRONG_PASSWORD, 401);
    }
    if (!(await this.passwords.verify(credential.passwordHash, dto.password))) {
      await this.recordFailure(lockKey);
      throw new ApiException(ErrorCode.INVALID_CREDENTIALS, WRONG_PASSWORD, 401);
    }
    await this.redis.del(lockKey).catch(() => undefined);

    switch (user.status) {
      case 'ACTIVE':
        break;
      case 'PENDING_VERIFICATION': {
        // Right password, unverified account: send a fresh code and tell the app to open the verify screen.
        try {
          await this.sendCode(user, id, 'REGISTRATION', 'verify');
        } catch (err) {
          if (!(err instanceof ApiException)) throw err; // cooldown: a recent code is still valid
        }
        throw new ApiException(
          ErrorCode.VERIFICATION_REQUIRED,
          'Verify your account to continue.',
          403,
          {
            reason: 'ACCOUNT_NOT_VERIFIED',
            destination: maskIdentifier(id),
          },
        );
      }
      case 'SUSPENDED':
        throw ApiException.forbidden(
          'This account is suspended. Contact support if you think this is a mistake.',
          {
            reason: 'ACCOUNT_SUSPENDED',
          },
        );
      case 'DEACTIVATED':
        throw ApiException.forbidden('This account is deactivated.', {
          reason: 'ACCOUNT_DEACTIVATED',
        });
      case 'DELETED':
        throw new ApiException(ErrorCode.INVALID_CREDENTIALS, WRONG_PASSWORD, 401);
    }

    if (this.passwords.needsRehash(credential.passwordHash)) {
      await this.prisma.credential.update({
        where: { userId: user.id },
        data: { passwordHash: await this.passwords.hash(dto.password) },
      });
    }
    await this.prisma.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } });
    return this.startSession(user.id, this.device(dto.client, dto.deviceName, meta));
  }

  async refresh(refreshToken: string): Promise<AuthSession> {
    const rotated = await this.sessions.rotate(refreshToken, 'MEMBER');
    const user = await this.prisma.user.findUnique({ where: { id: rotated.userId } });
    if (!user || user.deletedAt || user.status !== 'ACTIVE') {
      await this.sessions.revokeFamily(rotated.familyId, 'account_not_active');
      throw ApiException.forbidden('This account cannot be used right now.', {
        reason: `ACCOUNT_${user?.status ?? 'MISSING'}`,
      });
    }
    return this.issueTokens(
      rotated.userId,
      rotated.familyId,
      rotated.refreshToken,
      rotated.refreshTokenExpiresAt,
      false,
    );
  }

  async logout(familyId: string): Promise<void> {
    await this.sessions.revokeFamily(familyId, 'user_logout');
  }

  async logoutAll(userId: string): Promise<number> {
    return this.sessions.revokeAllForUser(userId, 'user_logout_all');
  }

  // ---------------------------------------------------------------------------------------------
  // Password recovery
  // ---------------------------------------------------------------------------------------------

  /** Same answer whether or not the account exists. */
  async forgotPassword(identifier: string): Promise<{ sent: true }> {
    const id = parseIdentifier(identifier);
    const user = await this.findByIdentifier(id);
    if (user && (user.status === 'ACTIVE' || user.status === 'PENDING_VERIFICATION')) {
      try {
        await this.sendCode(user, id, 'PASSWORD_RESET', 'reset');
      } catch (err) {
        // Cooldown or provider failure must not reveal whether the account exists.
        this.logger.warn(`Password recovery code not sent: ${(err as Error).message}`);
      }
    }
    return { sent: true };
  }

  async resetPassword(dto: ResetPasswordDto): Promise<{ reset: true }> {
    const id = parseIdentifier(dto.identifier);
    const user = await this.findByIdentifier(id);
    if (!user)
      throw ApiException.validation('That code is not right or has expired.', {
        fields: [{ field: 'code', messages: ['That code is not right or has expired.'] }],
      });

    await this.codes.verify({ userId: user.id, purpose: 'PASSWORD_RESET', code: dto.code });

    const now = new Date();
    const passwordHash = await this.passwords.hash(dto.newPassword);
    await this.prisma.$transaction([
      this.prisma.credential.upsert({
        where: { userId: user.id },
        create: { userId: user.id, passwordHash },
        update: { passwordHash, passwordChangedAt: now },
      }),
      // Receiving the recovery code proves control of that channel.
      this.prisma.user.update({
        where: { id: user.id },
        data:
          id.kind === 'email'
            ? { emailVerifiedAt: user.emailVerifiedAt ?? now }
            : { phoneVerifiedAt: user.phoneVerifiedAt ?? now },
      }),
    ]);
    // "You'll be signed out of other devices."
    await this.sessions.revokeAllForUser(user.id, 'password_reset');
    await this.redis.del(`auth:fail:member:${id.value}`).catch(() => undefined);
    return { reset: true };
  }

  // ---------------------------------------------------------------------------------------------
  // Google (behind the `google-sign-in` flag)
  // ---------------------------------------------------------------------------------------------

  async googleSignIn(
    idToken: string,
    client: MemberClient,
    meta: RequestMeta,
  ): Promise<AuthSession> {
    // Hidden, not dead: with the flag off the route does not exist as far as callers can tell.
    if (!(await this.flags.isEnabled('google-sign-in'))) throw ApiException.notFound();
    const profile = await this.google.verifyIdToken(idToken);
    if (!profile.emailVerified)
      throw ApiException.forbidden('Google has not verified this email address.');

    let user = await this.prisma.user.findUnique({ where: { email: profile.email.toLowerCase() } });
    if (!user) {
      user = await this.prisma.user.create({
        data: {
          fullName: profile.name,
          email: profile.email.toLowerCase(),
          emailVerifiedAt: new Date(),
          status: 'ACTIVE',
        },
      });
    }
    if (user.status !== 'ACTIVE')
      throw ApiException.forbidden('This account cannot be used right now.', {
        reason: `ACCOUNT_${user.status}`,
      });
    return this.startSession(user.id, this.device(client, undefined, meta));
  }

  // ---------------------------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------------------------

  async startSession(userId: string, device: DeviceInfo): Promise<AuthSession> {
    const session = await this.sessions.create(userId, device);
    return this.issueTokens(
      userId,
      session.familyId,
      session.refreshToken,
      session.refreshTokenExpiresAt,
      device.client === 'ADMIN',
    );
  }

  async issueTokens(
    userId: string,
    familyId: string,
    refreshToken: string,
    refreshTokenExpiresAt: Date,
    admin: boolean,
  ): Promise<AuthSession> {
    const access = await this.tokens.signAccess({ userId, familyId, admin });
    return {
      accessToken: access.token,
      accessTokenExpiresAt: access.expiresAt,
      refreshToken,
      refreshTokenExpiresAt,
      user: await this.userViews.me(userId),
    };
  }

  private device(
    client: SessionClient,
    deviceName: string | undefined,
    meta: RequestMeta,
  ): DeviceInfo {
    return {
      client,
      deviceName: deviceName ?? null,
      ip: meta.ip ?? null,
      userAgent: meta.userAgent ?? null,
    };
  }

  async findByIdentifier(id: Identifier): Promise<User | null> {
    return this.prisma.user.findFirst({
      where: {
        deletedAt: null,
        ...(id.kind === 'email' ? { email: id.value } : { phone: id.value }),
      },
    });
  }

  private async latestLegalVersion(type: 'TERMS' | 'PRIVACY'): Promise<string> {
    const doc = await this.prisma.legalDocument.findFirst({
      where: { type },
      orderBy: { createdAt: 'desc' },
      select: { version: true },
    });
    return doc?.version ?? 'unversioned';
  }

  /** Issues a code and delivers it by email or SMS. Delivery failure surfaces as EXTERNAL_SERVICE_ERROR. */
  private async sendCode(
    user: User,
    id: Identifier,
    purpose: CodePurpose,
    kind: CodeMessageKind,
  ): Promise<IssuedCode> {
    const issued = await this.codes.issue({
      userId: user.id,
      purpose,
      channel: id.kind === 'email' ? 'EMAIL' : 'SMS',
      destination: id.value,
    });
    try {
      if (id.kind === 'email') {
        await this.email.send(
          emailFor(id.value, renderCodeMessage(kind, issued.code, issued.ttlMinutes)),
        );
      } else {
        await this.sms.send({
          to: id.value,
          text: `Your Atarah code is ${issued.code}. It expires in ${issued.ttlMinutes} minutes.`,
        });
      }
    } catch (err) {
      this.logger.error(
        `Could not deliver ${purpose} code to ${maskIdentifier(id)}: ${(err as Error).message}`,
      );
      throw ApiException.external('We could not send your code. Please tap resend in a moment.', {
        reason: 'CODE_DELIVERY_FAILED',
        accountCreated: purpose === 'REGISTRATION',
      });
    }
    return issued;
  }

  private async assertNotLocked(key: string): Promise<void> {
    try {
      const count = Number((await this.redis.get(key)) ?? 0);
      if (count >= LOGIN_FAILURE_LIMIT) {
        const ttl = await this.redis.ttl(key);
        throw new ApiException(
          ErrorCode.RATE_LIMITED,
          'Too many sign-in attempts. Please wait a few minutes or reset your password.',
          429,
          { retryAfterSeconds: ttl > 0 ? ttl : LOGIN_LOCK_SECONDS, reason: 'SIGN_IN_LOCKED' },
        );
      }
    } catch (err) {
      if (err instanceof ApiException) throw err; // Redis trouble must not block sign-in
    }
  }

  private async recordFailure(key: string): Promise<void> {
    try {
      const n = await this.redis.incr(key);
      if (n === 1) await this.redis.expire(key, LOGIN_LOCK_SECONDS);
    } catch {
      // best effort
    }
  }
}
