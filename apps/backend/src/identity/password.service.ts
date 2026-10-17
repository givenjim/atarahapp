import { Injectable } from '@nestjs/common';
import * as argon2 from 'argon2';

/** Minimum 8 characters including a number (the prototype's "Strong — 8+ characters with a number"). */
export const PASSWORD_PATTERN = /^(?=.*\d).{8,128}$/;
export const PASSWORD_RULE_MESSAGE = 'Use at least 8 characters, including a number.';

/** Argon2id parameters follow the OWASP baseline (19 MiB, 2 iterations, 1 lane). */
const OPTIONS = {
  type: argon2.argon2id,
  memoryCost: 19 * 1024,
  timeCost: 2,
  parallelism: 1,
} as const;

@Injectable()
export class PasswordService {
  /** Hash used to spend equal time when the account does not exist (prevents user enumeration by timing). */
  private dummyHash: Promise<string> | undefined;

  hash(password: string): Promise<string> {
    return argon2.hash(password, OPTIONS);
  }

  async verify(hash: string, password: string): Promise<boolean> {
    try {
      return await argon2.verify(hash, password);
    } catch {
      return false;
    }
  }

  /** Verify against a throwaway hash so unknown accounts cost the same as wrong passwords. */
  async burn(password: string): Promise<void> {
    this.dummyHash ??= this.hash('atarah-timing-equaliser-1');
    await this.verify(await this.dummyHash, password);
  }

  needsRehash(hash: string): boolean {
    return argon2.needsRehash(hash, OPTIONS);
  }
}
