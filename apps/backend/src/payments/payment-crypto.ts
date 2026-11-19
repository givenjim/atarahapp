import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { AppConfigService } from '../config/app-config.service';

/**
 * AES-256-GCM for the raw provider payloads kept in `payment_events` (Master Prompt P2-M1: stored encrypted).
 * Format: `v1.<iv>.<tag>.<ciphertext>` in base64url. The key comes from `ATARAH_PAYMENTS_ENCRYPTION_KEY`; development
 * and test derive a stand-in so nothing secret is committed, and a deployed environment without a key refuses to store
 * a payload at all (payments report themselves unavailable first).
 */
@Injectable()
export class PaymentCrypto {
  constructor(private readonly config: AppConfigService) {}

  /** True when a real key is set, or the environment is a development stand-in one. */
  get isAvailable(): boolean {
    return this.keyOrNull() !== null;
  }

  encrypt(plaintext: string): string {
    const key = this.requireKey();
    const iv = randomBytes(12);
    const cipher = createCipheriv('aes-256-gcm', key, iv);
    const body = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
    const tag = cipher.getAuthTag();
    return [
      'v1',
      iv.toString('base64url'),
      tag.toString('base64url'),
      body.toString('base64url'),
    ].join('.');
  }

  decrypt(token: string): string {
    const key = this.requireKey();
    const [version, iv, tag, body] = token.split('.');
    if (version !== 'v1' || !iv || !tag || !body) throw new Error('Unrecognised payload format.');
    const decipher = createDecipheriv('aes-256-gcm', key, Buffer.from(iv, 'base64url'));
    decipher.setAuthTag(Buffer.from(tag, 'base64url'));
    return Buffer.concat([
      decipher.update(Buffer.from(body, 'base64url')),
      decipher.final(),
    ]).toString('utf8');
  }

  private keyOrNull(): Buffer | null {
    const configured = this.config.payments.encryptionKey;
    if (configured) return Buffer.from(configured, 'base64');
    if (this.config.isDeployed) return null;
    // Development and test stand-in. Not a secret; never used where `isDeployed`.
    return createHash('sha256').update('atarah-dev-payments-key').digest();
  }

  private requireKey(): Buffer {
    const key = this.keyOrNull();
    if (!key) throw new Error('ATARAH_PAYMENTS_ENCRYPTION_KEY is not set.');
    return key;
  }
}
