import { Injectable } from '@nestjs/common';
import {
  type InitiateInput,
  type InitiateResult,
  type ParsedWebhook,
  type PaymentProvider,
  ProviderError,
  type RefundInput,
  type RefundResult,
  type StatusResult,
  type WebhookRequest,
} from './payment-provider';

/**
 * Card adapter (Visa and Mastercard). The interface and the app's path exist, but the card provider used by Luxaion is an
 * owner decision (Master Prompt section 12, item 6) and no credentials exist, so this adapter reports itself as not
 * configured and the Card option stays hidden behind the `card-payments` flag. Wiring the chosen provider means filling
 * in these methods (a hosted-checkout redirect returns `{ type: 'REDIRECT', url }`) and `isConfigured`; nothing else in
 * the payment flow changes.
 */
@Injectable()
export class CardProvider implements PaymentProvider {
  readonly key = 'CARD' as const;
  readonly method = 'CARD' as const;

  isConfigured(): boolean {
    return false;
  }

  initiate(_input: InitiateInput): Promise<InitiateResult> {
    return Promise.reject(new ProviderError('Card payments are not set up yet.', false));
  }

  queryStatus(_providerReference: string): Promise<StatusResult> {
    return Promise.reject(new ProviderError('Card payments are not set up yet.', false));
  }

  refund(_input: RefundInput): Promise<RefundResult> {
    return Promise.resolve({
      outcome: 'MANUAL_REQUIRED',
      note: 'The card provider is not connected yet; refund the card payment with the provider and confirm it here.',
    });
  }

  verifyWebhook(_req: WebhookRequest): boolean {
    return false;
  }

  parseWebhook(_body: unknown): ParsedWebhook | null {
    return null;
  }
}
