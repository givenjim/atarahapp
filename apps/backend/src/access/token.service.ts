import { randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import jwt from 'jsonwebtoken';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { type AccessClaims, type AdminChallengeClaims } from './access.types';

const ISSUER = 'atarah';
const AUDIENCE = 'atarah-api';
const ADMIN_CHALLENGE_TTL_SECONDS = 5 * 60;

@Injectable()
export class TokenService {
  constructor(
    private readonly config: AppConfigService,
    private readonly settings: PlatformSettingsService,
  ) {}

  /** Signs a short-lived access token (default 15 minutes, `auth.access_token_ttl_minutes`). */
  async signAccess(input: { userId: string; familyId: string; admin: boolean }): Promise<{
    token: string;
    expiresAt: Date;
  }> {
    const minutes = await this.settings.get<number>('auth.access_token_ttl_minutes', 15);
    const claims: AccessClaims = {
      sub: input.userId,
      fam: input.familyId,
      adm: input.admin,
      mfa: input.admin,
      typ: 'access',
    };
    const token = jwt.sign(claims, this.config.jwt.accessSecret, {
      algorithm: 'HS256',
      expiresIn: minutes * 60,
      issuer: ISSUER,
      audience: AUDIENCE,
      jwtid: randomUUID(),
    });
    return { token, expiresAt: new Date(Date.now() + minutes * 60_000) };
  }

  verifyAccess(token: string): AccessClaims {
    const claims = this.verify(token);
    if (claims.typ !== 'access') throw ApiException.unauthenticated();
    return claims as unknown as AccessClaims;
  }

  signAdminChallenge(userId: string, enrol: boolean): string {
    const claims: AdminChallengeClaims = { sub: userId, typ: 'admin-challenge', enrol };
    return jwt.sign(claims, this.config.jwt.accessSecret, {
      algorithm: 'HS256',
      expiresIn: ADMIN_CHALLENGE_TTL_SECONDS,
      issuer: ISSUER,
      audience: AUDIENCE,
    });
  }

  verifyAdminChallenge(token: string): AdminChallengeClaims {
    const claims = this.verify(token);
    if (claims.typ !== 'admin-challenge') throw ApiException.unauthenticated();
    return claims as unknown as AdminChallengeClaims;
  }

  private verify(token: string): jwt.JwtPayload & { typ?: string } {
    try {
      const payload = jwt.verify(token, this.config.jwt.accessSecret, {
        algorithms: ['HS256'],
        issuer: ISSUER,
        audience: AUDIENCE,
      });
      if (typeof payload === 'string') throw new Error('unexpected token payload');
      return payload;
    } catch {
      throw ApiException.unauthenticated('Your session has expired. Please sign in again.');
    }
  }
}
