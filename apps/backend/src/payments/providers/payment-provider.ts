import { type PaymentMethod, type PaymentProviderKey } from '@prisma/client';

/** What the member's app does next after a payment starts. */
export type NextAction =
  { type: 'STK_PROMPT'; message: string } | { type: 'REDIRECT'; url: string };

export interface InitiateInput {
  paymentId: string;
  amountMinor: number;
  currency: string;
  /** Daraja format `2547XXXXXXXX`; present for M-Pesa. Never stored. */
  msisdn?: string;
  /** Short account reference shown on the member's statement. */
  accountReference: string;
  description: string;
}

export interface InitiateResult {
  /** The provider's own id for this attempt (M-Pesa CheckoutRequestID). Callbacks are matched by it. */
  providerReference: string;
  merchantReference?: string;
  action: NextAction;
}

/** What the provider says about an attempt, normalised. PENDING means "still being processed, ask again". */
export interface StatusResult {
  outcome: 'SUCCESS' | 'FAILED' | 'CANCELLED' | 'PENDING';
  /** One of the codes in `payment-messages.ts` when the outcome is FAILED or CANCELLED. */
  code?: string;
  /** The provider's own wording, for the event history. */
  message?: string;
  receiptNumber?: string;
}

export interface WebhookRequest {
  /** The unguessable path token the route was called with. */
  token?: string;
  ip?: string;
  headers: Record<string, string | string[] | undefined>;
  body: unknown;
}

/** A callback after parsing. `claimed` is what the provider says; it is never trusted for success. */
export interface ParsedWebhook {
  providerReference: string;
  claimed: 'SUCCESS' | 'FAILED' | 'CANCELLED';
  code?: string;
  message?: string;
  /** Minor units, as the callback reports it. Success callbacks without one are not accepted. */
  amountMinor?: number;
  receiptNumber?: string;
}

export interface RefundInput {
  paymentId: string;
  providerReference: string;
  receiptNumber: string | null;
  amountMinor: number;
  currency: string;
  reason: string;
}

export type RefundResult =
  | { outcome: 'COMPLETED'; providerReference?: string }
  /** The provider has no automatic route; finance pays it back out of band and confirms it in the console. */
  | { outcome: 'MANUAL_REQUIRED'; note: string }
  | { outcome: 'REJECTED'; reason: string };

/**
 * The seam between Atarah and a payment processor (Master Prompt P2-M1). Adapters translate; the state machine,
 * idempotency, ledger and events live in `PaymentsService` and never in an adapter.
 */
export interface PaymentProvider {
  readonly key: PaymentProviderKey;
  readonly method: PaymentMethod;
  /** Credentials present. A provider that is not configured is never offered to members. */
  isConfigured(): boolean;
  initiate(input: InitiateInput): Promise<InitiateResult>;
  /** Asks the provider for the truth about an attempt. Throws when it cannot be reached. */
  queryStatus(providerReference: string): Promise<StatusResult>;
  refund(input: RefundInput): Promise<RefundResult>;
  /** Authenticates a callback (path token, optional source address). */
  verifyWebhook(req: WebhookRequest): boolean;
  /** Null when the body is not a callback this adapter understands. */
  parseWebhook(body: unknown): ParsedWebhook | null;
}

/** The thrown form of "the provider could not be reached or refused": the service maps it to a member message. */
export class ProviderError extends Error {
  constructor(
    message: string,
    readonly retryable = true,
  ) {
    super(message);
  }
}

export const PAYMENT_PROVIDERS = Symbol('PAYMENT_PROVIDERS');
