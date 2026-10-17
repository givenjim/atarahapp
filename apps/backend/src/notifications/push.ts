import { Injectable, Logger } from '@nestjs/common';
import { AppConfigService } from '../config/app-config.service';
import { DevOutbox } from '../messaging/dev-providers';

export interface PushMessage {
  tokens: string[];
  title: string;
  body: string;
  /** String values only (FCM data payload). Carries the deep link the app opens on tap. */
  data: Record<string, string>;
}

export interface PushResult {
  /** Tokens the push service says are no longer valid; the caller revokes them. */
  invalidTokens: string[];
}

export interface PushProvider {
  send(message: PushMessage): Promise<PushResult>;
}

export const PUSH_PROVIDER = Symbol('PUSH_PROVIDER');

/**
 * Development sink: records the push in the outbox. It exists only outside deployed environments and
 * delivers nothing to a phone; use real FCM credentials to test on a device.
 */
@Injectable()
export class DevPushProvider implements PushProvider {
  private readonly logger = new Logger('DevPush');

  constructor(
    private readonly config: AppConfigService,
    private readonly outbox: DevOutbox,
  ) {}

  async send(message: PushMessage): Promise<PushResult> {
    if (this.config.isDeployed) {
      throw new Error('The development push sink must not be used in staging or production.');
    }
    this.outbox.push.push(message);
    if (this.config.environment === 'dev') {
      this.logger.log(`[DEV PUSH] ${message.tokens.length} device(s): ${message.title}`);
    }
    return { invalidTokens: [] };
  }
}

/** Deployed without credentials: fail loudly so the job is retried and the gap is visible, never silent. */
@Injectable()
export class UnconfiguredPushProvider implements PushProvider {
  async send(): Promise<PushResult> {
    throw new Error('Push is not configured: set ATARAH_FCM_SERVICE_ACCOUNT_JSON.');
  }
}

const INVALID_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/** The slice of firebase-admin's Messaging that we use. Narrow on purpose, so tests can substitute it. */
export interface FcmMessaging {
  sendEachForMulticast(message: {
    tokens: string[];
    notification: { title: string; body: string };
    data: Record<string, string>;
    android: { priority: 'high' };
  }): Promise<{ responses: Array<{ success: boolean; error?: { code?: string } }> }>;
}

/**
 * Firebase Cloud Messaging sender. STATUS: request building and invalid-token handling are tested against a
 * fake messaging client; delivery to Google has NOT been verified because no Firebase project credentials
 * exist yet (owner decision, Master Prompt §12).
 */
export class FcmPushProvider implements PushProvider {
  constructor(private readonly messaging: FcmMessaging) {}

  async send(message: PushMessage): Promise<PushResult> {
    const invalidTokens: string[] = [];
    // FCM accepts at most 500 tokens per multicast request.
    for (let i = 0; i < message.tokens.length; i += 500) {
      const tokens = message.tokens.slice(i, i + 500);
      const res = await this.messaging.sendEachForMulticast({
        tokens,
        notification: { title: message.title, body: message.body },
        data: message.data,
        android: { priority: 'high' },
      });
      res.responses.forEach((r, idx) => {
        if (!r.success && r.error?.code && INVALID_TOKEN_CODES.has(r.error.code)) {
          invalidTokens.push(tokens[idx]!);
        } else if (!r.success) {
          throw new Error(`FCM send failed: ${r.error?.code ?? 'unknown error'}`);
        }
      });
    }
    return { invalidTokens };
  }
}

/** Builds the real firebase-admin messaging client from the service-account JSON. */
export async function firebaseMessaging(serviceAccountJson: string): Promise<FcmMessaging> {
  const { cert, getApps, initializeApp } = await import('firebase-admin/app');
  const { getMessaging } = await import('firebase-admin/messaging');
  const app =
    getApps()[0] ?? initializeApp({ credential: cert(JSON.parse(serviceAccountJson) as object) });
  return getMessaging(app) as unknown as FcmMessaging;
}
