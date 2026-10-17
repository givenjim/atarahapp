import { Injectable } from '@nestjs/common';
import { ApiException } from '../common/api.exception';

export interface GoogleProfile {
  subject: string;
  email: string;
  emailVerified: boolean;
  name: string;
}

/** Auth-provider abstraction for "Continue with Google". */
export interface GoogleAuthProvider {
  verifyIdToken(idToken: string): Promise<GoogleProfile>;
}

export const GOOGLE_AUTH_PROVIDER = Symbol('GOOGLE_AUTH_PROVIDER');

/**
 * Placeholder until OAuth client credentials are supplied (owner decision #4). The `google-sign-in` flag stays
 * off, so clients hide the button; if someone enables the flag without credentials, calls fail clearly.
 */
@Injectable()
export class UnconfiguredGoogleAuthProvider implements GoogleAuthProvider {
  verifyIdToken(): Promise<GoogleProfile> {
    throw ApiException.external('Google sign-in is not configured yet.', {
      reason: 'GOOGLE_NOT_CONFIGURED',
    });
  }
}
