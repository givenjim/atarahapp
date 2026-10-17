import { Injectable } from '@nestjs/common';
import { type CodeChannel, type CodePurpose } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { hmacHex, randomCode, safeEqualHex } from '../common/crypto';
import { ErrorCode } from '../common/error-codes';
import { AppConfigService } from '../config/app-config.service';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { PrismaService } from '../prisma/prisma.service';

const MAX_ATTEMPTS = 5;

export interface IssuedCode {
  code: string;
  expiresAt: Date;
  resendAvailableAt: Date;
  ttlMinutes: number;
}

/**
 * Six-digit one-time codes: stored hashed (HMAC with a server pepper), single-use, expire (10 min; 15 min
 * for recovery), 60 s resend cooldown, at most 5 guesses, and issuing a new code invalidates older ones.
 */
@Injectable()
export class CodeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly settings: PlatformSettingsService,
    private readonly config: AppConfigService,
  ) {}

  private hash(userId: string, purpose: CodePurpose, code: string): string {
    return hmacHex(this.config.peppers.code, `${userId}:${purpose}:${code}`);
  }

  async issue(input: {
    userId: string;
    purpose: CodePurpose;
    channel: CodeChannel;
    destination: string;
  }): Promise<IssuedCode> {
    const now = new Date();
    const cooldown = await this.settings.get<number>('auth.code_resend_cooldown_seconds', 60);
    const ttlMinutes = await this.settings.get<number>(
      input.purpose === 'PASSWORD_RESET'
        ? 'auth.recovery_code_ttl_minutes'
        : 'auth.code_ttl_minutes',
      input.purpose === 'PASSWORD_RESET' ? 15 : 10,
    );

    const last = await this.prisma.verificationCode.findFirst({
      where: { userId: input.userId, purpose: input.purpose },
      orderBy: { createdAt: 'desc' },
      select: { createdAt: true },
    });
    if (last) {
      const waitMs = last.createdAt.getTime() + cooldown * 1000 - now.getTime();
      if (waitMs > 0) {
        throw new ApiException(
          ErrorCode.RATE_LIMITED,
          'Please wait a moment before asking for another code.',
          429,
          { retryAfterSeconds: Math.ceil(waitMs / 1000) },
        );
      }
    }

    const code = randomCode(6);
    const expiresAt = new Date(now.getTime() + ttlMinutes * 60_000);
    await this.prisma.$transaction([
      // Older codes for the same purpose stop working the moment a new one is issued.
      this.prisma.verificationCode.updateMany({
        where: {
          userId: input.userId,
          purpose: input.purpose,
          consumedAt: null,
          expiresAt: { gt: now },
        },
        data: { expiresAt: now },
      }),
      this.prisma.verificationCode.create({
        data: {
          userId: input.userId,
          purpose: input.purpose,
          channel: input.channel,
          destination: input.destination,
          codeHash: this.hash(input.userId, input.purpose, code),
          expiresAt,
        },
      }),
    ]);
    return {
      code,
      expiresAt,
      ttlMinutes,
      resendAvailableAt: new Date(now.getTime() + cooldown * 1000),
    };
  }

  /** Throws a field-level VALIDATION_ERROR on any failure. Consumes the code on success. */
  async verify(input: { userId: string; purpose: CodePurpose; code: string }): Promise<{
    channel: CodeChannel;
    destination: string;
  }> {
    const now = new Date();
    const row = await this.prisma.verificationCode.findFirst({
      where: {
        userId: input.userId,
        purpose: input.purpose,
        consumedAt: null,
        expiresAt: { gt: now },
      },
      orderBy: { createdAt: 'desc' },
    });
    if (!row) throw this.invalid();

    if (row.attempts >= MAX_ATTEMPTS) {
      await this.prisma.verificationCode.update({
        where: { id: row.id },
        data: { expiresAt: now },
      });
      throw this.invalid('Too many wrong attempts. Ask for a new code.');
    }
    await this.prisma.verificationCode.update({
      where: { id: row.id },
      data: { attempts: { increment: 1 } },
    });

    if (!safeEqualHex(row.codeHash, this.hash(input.userId, input.purpose, input.code))) {
      throw this.invalid();
    }
    // Atomic single use: only one concurrent request can flip consumedAt.
    const consumed = await this.prisma.verificationCode.updateMany({
      where: { id: row.id, consumedAt: null },
      data: { consumedAt: now },
    });
    if (consumed.count !== 1) throw this.invalid();
    return { channel: row.channel, destination: row.destination };
  }

  private invalid(message = 'That code is not right or has expired.'): ApiException {
    return ApiException.validation(message, { fields: [{ field: 'code', messages: [message] }] });
  }
}
