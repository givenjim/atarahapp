import { Injectable, type OnModuleInit } from '@nestjs/common';
import { type PaymentPurpose } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';

/** What a purpose handler decides about one purchase. The amount always comes from the server, never from a client. */
export interface PaymentQuote {
  amountMinor: number;
  currency?: string;
  description: string;
  referenceType: string | null;
  referenceId: string | null;
  /** The member who is paid (a mentor). Omit when the platform is the payee. */
  payeeId?: string | null;
  /** The platform's share. Ignored (the platform keeps everything) when there is no payee. */
  platformFeeMinor?: number;
  /** Shown on the member's M-Pesa statement, at most 12 characters. */
  accountReference?: string;
}

export interface QuoteContext {
  userId: string;
  referenceId: string | null;
  /** Only the sandbox purpose reads this; real purposes ignore anything a client sends. */
  requestedAmountMinor?: number;
}

/**
 * A module that sells something (membership, mentorship, verification) registers one of these. `quote` verifies that
 * the member may pay for the reference (it exists, belongs to them, is awaiting payment) and says how much. M2 and M5
 * call `PaymentPurposeRegistry.register` from `onModuleInit`.
 */
export interface PaymentPurposeHandler {
  readonly purpose: PaymentPurpose;
  quote(ctx: QuoteContext): Promise<PaymentQuote>;
}

@Injectable()
export class PaymentPurposeRegistry {
  private readonly handlers = new Map<PaymentPurpose, PaymentPurposeHandler>();

  register(handler: PaymentPurposeHandler): void {
    this.handlers.set(handler.purpose, handler);
  }

  has(purpose: PaymentPurpose): boolean {
    return this.handlers.has(purpose);
  }

  async quote(purpose: PaymentPurpose, ctx: QuoteContext): Promise<PaymentQuote> {
    const handler = this.handlers.get(purpose);
    if (!handler) {
      throw ApiException.validation('Payments for this are not available yet.', { soon: 'P2' });
    }
    return handler.quote(ctx);
  }
}

/** The most the sandbox purpose will collect: KES 100. */
export const SANDBOX_MAX_MINOR = 10_000;

/**
 * A development tool, not a product: lets the payment flow be exercised end to end against the Daraja sandbox before any
 * real purchase exists. Registered only outside production and only while M-Pesa points at the sandbox; the amount is the
 * one thing a client may choose, capped at KES 100.
 */
@Injectable()
export class SandboxPurposeHandler implements PaymentPurposeHandler, OnModuleInit {
  readonly purpose = 'OTHER' as const;

  constructor(
    private readonly registry: PaymentPurposeRegistry,
    private readonly config: AppConfigService,
  ) {}

  onModuleInit(): void {
    if (!this.config.isProduction && this.config.payments.mpesa.env === 'sandbox') {
      this.registry.register(this);
    }
  }

  quote(ctx: QuoteContext): Promise<PaymentQuote> {
    const amount = ctx.requestedAmountMinor ?? 0;
    if (!Number.isInteger(amount) || amount < 100 || amount > SANDBOX_MAX_MINOR) {
      return Promise.reject(
        ApiException.validation('The sandbox payment must be between KES 1 and KES 100.'),
      );
    }
    return Promise.resolve({
      amountMinor: amount,
      description: 'Sandbox check',
      referenceType: null,
      referenceId: null,
      accountReference: 'Atarah',
    });
  }
}
