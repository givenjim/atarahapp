import { Injectable } from '@nestjs/common';
import { createRemoteJWKSet, decodeProtectedHeader, jwtVerify, type JWTPayload } from 'jose';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';

/** Claims Supabase Auth puts in an access token that Atarah relies on. Never `user_metadata` or `app_metadata`. */
export interface SupabaseClaims {
  sub: string;
  sessionId: string;
  role: string;
  /** `aal1` after a password or code; `aal2` once an MFA factor was verified. */
  aal: 'aal1' | 'aal2';
  /** Authentication methods with the time each was last used (seconds since epoch). */
  amr: Array<{ method: string; timestamp: number }>;
  isAnonymous: boolean;
}

/**
 * Verifies Supabase-issued JWTs: signature through the project's JWKS endpoint (asymmetric signing keys),
 * or the legacy HS256 secret on projects that still have one, plus issuer, audience and expiry.
 */
@Injectable()
export class SupabaseJwtService {
  private readonly jwks;

  constructor(private readonly config: AppConfigService) {
    this.jwks = createRemoteJWKSet(new URL(config.supabase.jwksUrl), {
      cooldownDuration: 10_000,
      cacheMaxAge: 10 * 60_000,
    });
  }

  async verify(token: string): Promise<SupabaseClaims> {
    const { jwtSecret, issuer, audience } = this.config.supabase;
    let payload: JWTPayload;
    try {
      const alg = decodeProtectedHeader(token).alg;
      const options = { issuer, audience };
      if (alg === 'HS256') {
        if (!jwtSecret) throw new Error('HS256 token but no legacy secret configured');
        ({ payload } = await jwtVerify(token, new TextEncoder().encode(jwtSecret), {
          ...options,
          algorithms: ['HS256'],
        }));
      } else {
        ({ payload } = await jwtVerify(token, this.jwks, {
          ...options,
          algorithms: ['ES256', 'RS256', 'EdDSA'],
        }));
      }
    } catch {
      throw ApiException.unauthenticated('Your session has ended. Please sign in again.');
    }
    const p = payload as JWTPayload & {
      session_id?: string;
      role?: string;
      aal?: string;
      amr?: Array<{ method: string; timestamp: number }>;
      is_anonymous?: boolean;
    };
    if (!p.sub || !p.session_id) throw ApiException.unauthenticated();
    return {
      sub: p.sub,
      sessionId: p.session_id,
      role: p.role ?? '',
      aal: p.aal === 'aal2' ? 'aal2' : 'aal1',
      amr: Array.isArray(p.amr) ? p.amr : [],
      isAnonymous: p.is_anonymous === true,
    };
  }
}
