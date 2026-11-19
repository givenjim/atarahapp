import { Injectable, Logger } from '@nestjs/common';
import {
  type Payment,
  type PaymentEventKind,
  type PaymentEventSource,
  type PaymentMethod,
  type PaymentPurpose,
  type PaymentStatus,
  Prisma,
  type Refund,
} from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { DomainEventBus } from '../community-core/domain-events';
import { FeatureFlagService } from '../feature-flags/feature-flag.service';
import { PrismaService, type TxClient } from '../prisma/prisma.service';
import { PaymentCrypto } from './payment-crypto';
import { failureMessage } from './payment-messages';
import { isWholeShillings, last4, toMsisdn } from './payment-money';
import { PaymentProviderRegistry } from './payment-provider.registry';
import { PaymentPurposeRegistry } from './payment-purposes';
import {
  isOpen,
  isPaid,
  REFUNDABLE_STATUSES,
  statusAfterRefund,
  statusesBefore,
} from './payment-state';
import type { PaymentDto } from './payments.dto';
import { bodyDigest } from './providers/mpesa-daraja.provider';
import {
  type ParsedWebhook,
  type PaymentProvider,
  ProviderError,
  type StatusResult,
} from './providers/payment-provider';

/** How long the prompt is considered open before the app offers "Try again" and the server starts checking. */
export const PAYMENT_TIMEOUT_SECONDS = 120;
/** After the time limit the server keeps asking the provider this long before failing the payment as TIMEOUT. */
export const PAYMENT_GRACE_SECONDS = 600;
/** A payment failed as TIMEOUT is still re-checked for this long, in case the money was taken after all. */
export const LATE_SUCCESS_WINDOW_SECONDS = 3_600;
/** A poll triggers a status query when the last one is older than this. */
const POLL_QUERY_AFTER_SECONDS = 8;
/** What the app is told to wait between polls. */
export const POLL_AFTER_SECONDS = 3;
const FLAG_FOR_METHOD: Record<PaymentMethod, string> = {
  MPESA: 'payments-mpesa',
  CARD: 'card-payments',
};

const isUnique = (e: unknown) =>
  e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002';

export interface Actor {
  userId?: string | null;
  ip?: string;
  requestId?: string;
}

export interface InitiatePaymentInput {
  payerId: string;
  purpose: PaymentPurpose;
  referenceType: string | null;
  referenceId: string | null;
  /** Minor units. Trusted: comes from a purpose handler, never from a client. */
  amountMinor: number;
  currency?: string;
  method: PaymentMethod;
  /** Any common Kenyan format. Required for MPESA. */
  phone?: string;
  idempotencyKey: string;
  description: string;
  payeeId?: string | null;
  platformFeeMinor?: number;
  accountReference?: string;
}

interface Transition {
  source: PaymentEventSource;
  summary: string;
  kind?: PaymentEventKind;
  failureCode?: string | null;
  failureReason?: string | null;
  receiptNumber?: string | null;
  actorId?: string | null;
  payload?: unknown;
}

/**
 * The payments core (P2-M1). Rules it enforces, in one place:
 *  - a payment becomes SUCCEEDED only after the provider itself confirms it (an STK status query for M-Pesa); a
 *    client, a callback body or a poll can never do that on their own;
 *  - every state change is a compare-and-set inside a transaction that also writes the event, the ledger row and the
 *    audit entry, so a repeated callback or a second worker cannot apply a change twice;
 *  - domain events (`PaymentSucceeded`, `PaymentFailed`, `PaymentRefunded`) are raised after commit.
 *
 * Other modules use `initiateForPurpose` (member-facing) or `initiate` (a module that already priced the purchase),
 * `get`, `refund` and the events.
 */
@Injectable()
export class PaymentsService {
  private readonly log = new Logger(PaymentsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly providers: PaymentProviderRegistry,
    private readonly purposes: PaymentPurposeRegistry,
    private readonly flags: FeatureFlagService,
    private readonly crypto: PaymentCrypto,
    private readonly audit: AuditService,
    private readonly bus: DomainEventBus,
  ) {}

  // ---- what the app may offer ------------------------------------------------------------------

  /** Methods the member can pick: the feature flag is on and the provider has credentials. */
  async availableMethods(): Promise<PaymentMethod[]> {
    const out: PaymentMethod[] = [];
    for (const method of ['MPESA', 'CARD'] as const) {
      const provider = this.providers.forMethod(method);
      if (
        provider?.isConfigured() &&
        this.crypto.isAvailable &&
        (await this.flags.isEnabled(FLAG_FOR_METHOD[method]))
      ) {
        out.push(method);
      }
    }
    return out;
  }

  // ---- starting a payment ----------------------------------------------------------------------

  /** Member-facing start: the purpose handler checks the member may pay for the reference and sets the amount. */
  async initiateForPurpose(input: {
    userId: string;
    purpose: PaymentPurpose;
    referenceId: string | null;
    method: PaymentMethod;
    phone?: string;
    idempotencyKey: string;
    sandboxAmountMinor?: number;
  }): Promise<PaymentDto> {
    // Replaying a request must not re-run the purchase checks (the reference may have moved on since).
    const replay = await this.findByKey(input.userId, input.idempotencyKey);
    if (replay) return this.sameRequestOrConflict(replay, input.purpose, input.referenceId);
    const quote = await this.purposes.quote(input.purpose, {
      userId: input.userId,
      referenceId: input.referenceId,
      requestedAmountMinor: input.sandboxAmountMinor,
    });
    return this.initiate({
      payerId: input.userId,
      purpose: input.purpose,
      referenceType: quote.referenceType,
      referenceId: quote.referenceId,
      amountMinor: quote.amountMinor,
      currency: quote.currency,
      method: input.method,
      phone: input.phone,
      idempotencyKey: input.idempotencyKey,
      description: quote.description,
      payeeId: quote.payeeId,
      platformFeeMinor: quote.platformFeeMinor,
      accountReference: quote.accountReference,
    });
  }

  /**
   * Creates the payment and asks the provider to collect it. Idempotent per (payer, key): a repeat returns the same
   * payment. Throws PAYMENT_ERROR when the provider refuses, after recording the payment as FAILED.
   */
  async initiate(input: InitiatePaymentInput): Promise<PaymentDto> {
    const replay = await this.findByKey(input.payerId, input.idempotencyKey);
    if (replay) return this.sameRequestOrConflict(replay, input.purpose, input.referenceId);

    if (!Number.isInteger(input.amountMinor) || input.amountMinor <= 0) {
      throw ApiException.validation('The payment amount is not valid.');
    }
    const provider = this.providers.forMethod(input.method);
    const flagOn = await this.flags.isEnabled(FLAG_FOR_METHOD[input.method]);
    if (!provider || !flagOn || !provider.isConfigured() || !this.crypto.isAvailable) {
      throw new ApiException(
        ErrorCode.PAYMENT_ERROR,
        input.method === 'CARD'
          ? 'Card payments are not available yet.'
          : 'M-Pesa payments are not available right now. Please try again later.',
        503,
      );
    }

    let msisdn: string | undefined;
    if (input.method === 'MPESA') {
      msisdn = toMsisdn(input.phone ?? '') ?? undefined;
      if (!msisdn) {
        throw ApiException.validation('Enter a Safaricom number like +254712345678.', {
          field: 'phone',
        });
      }
      if (!isWholeShillings(input.amountMinor)) {
        throw ApiException.validation('M-Pesa payments are in whole shillings.');
      }
    }

    // One open payment per purchase: a second prompt on top of a live one would double-charge.
    if (input.referenceId) {
      const open = await this.prisma.payment.findFirst({
        where: {
          payerId: input.payerId,
          purpose: input.purpose,
          referenceId: input.referenceId,
          status: { in: ['INITIATED', 'PENDING'] },
          expiresAt: { gt: new Date() },
        },
        select: { id: true },
      });
      if (open) {
        throw ApiException.conflict(
          'A payment for this is already waiting for your confirmation.',
          {
            paymentId: open.id,
          },
        );
      }
    }

    const platformFeeMinor = input.payeeId ? (input.platformFeeMinor ?? 0) : input.amountMinor;
    if (platformFeeMinor < 0 || platformFeeMinor > input.amountMinor) {
      throw ApiException.validation('The platform fee is not valid.');
    }
    let payment: Payment;
    try {
      payment = await this.prisma.$transaction(async (tx) => {
        const row = await tx.payment.create({
          data: {
            purpose: input.purpose,
            referenceType: input.referenceType,
            referenceId: input.referenceId,
            payerId: input.payerId,
            payeeId: input.payeeId ?? null,
            amountMinor: BigInt(input.amountMinor),
            currency: input.currency ?? 'KES',
            platformFeeMinor: BigInt(platformFeeMinor),
            method: input.method,
            provider: provider.key,
            msisdnLast4: msisdn ? last4(msisdn) : null,
            idempotencyKey: input.idempotencyKey,
            description: input.description,
            expiresAt: new Date(Date.now() + PAYMENT_TIMEOUT_SECONDS * 1000),
          },
        });
        await tx.paymentEvent.create({
          data: {
            paymentId: row.id,
            kind: 'INITIATED',
            source: 'API',
            toStatus: 'INITIATED',
            summary: `Payment started (${input.method}, ${row.currency} ${Number(row.amountMinor) / 100})`,
            actorId: input.payerId,
          },
        });
        return row;
      });
    } catch (e) {
      if (isUnique(e)) {
        const raced = await this.findByKey(input.payerId, input.idempotencyKey);
        if (raced) return this.sameRequestOrConflict(raced, input.purpose, input.referenceId);
      }
      throw e;
    }

    try {
      const started = await provider.initiate({
        paymentId: payment.id,
        amountMinor: input.amountMinor,
        currency: payment.currency,
        msisdn,
        accountReference: input.accountReference ?? 'Atarah',
        description: input.description,
      });
      const { payment: pending } = await this.transition(payment.id, 'PENDING', {
        source: 'API',
        summary: 'Prompt sent to the member. Waiting for confirmation.',
        payload: { providerReference: started.providerReference },
        providerFields: {
          providerReference: started.providerReference,
          merchantReference: started.merchantReference ?? null,
        },
      });
      return { ...this.toDto(pending), action: started.action };
    } catch (e) {
      const retryable = e instanceof ProviderError ? e.retryable : true;
      this.log.warn(
        `Provider refused payment ${payment.id}: ${e instanceof Error ? e.message : String(e)}`,
      );
      const code = retryable ? 'PROVIDER_UNAVAILABLE' : 'PROVIDER_DECLINED';
      await this.transition(payment.id, 'FAILED', {
        source: 'API',
        summary: `The provider did not start the payment: ${e instanceof Error ? e.message : 'unknown error'}`,
        failureCode: code,
        failureReason: failureMessage(code),
      });
      throw new ApiException(ErrorCode.PAYMENT_ERROR, failureMessage(code), 502, {
        paymentId: payment.id,
      });
    }
  }

  // ---- reading ---------------------------------------------------------------------------------

  /**
   * The member's own payment, for the waiting screen. While it is open and the provider has been quiet, this also
   * asks the provider (at most every few seconds) so the screen settles even if the callback never arrives.
   */
  async getForPayer(paymentId: string, payerId: string): Promise<PaymentDto> {
    let payment = await this.prisma.payment.findFirst({ where: { id: paymentId, payerId } });
    if (!payment) throw ApiException.notFound('We could not find that payment.');
    if (payment.status === 'PENDING' && payment.providerReference) {
      const idleFor = Date.now() - (payment.lastQueriedAt ?? payment.initiatedAt).getTime();
      if (idleFor >= POLL_QUERY_AFTER_SECONDS * 1000) {
        await this.verifyWithProvider(payment, 'STATUS_QUERY').catch((e: unknown) =>
          this.log.warn(`Poll query for ${paymentId} failed: ${String(e)}`),
        );
        payment = (await this.prisma.payment.findUnique({ where: { id: paymentId } })) ?? payment;
      }
    }
    return this.toDto(payment);
  }

  /** The member's payments, newest first (receipts). */
  async listForPayer(payerId: string, page: number, limit: number) {
    const where = { payerId };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.payment.count({ where }),
      this.prisma.payment.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        skip: (page - 1) * limit,
        take: limit,
      }),
    ]);
    return { items: rows.map((r) => this.toDto(r)), total };
  }

  /** The newest payment for a purchase (what M2 and M5 read to show state). Null when none exists. */
  async latestForReference(referenceType: string, referenceId: string): Promise<PaymentDto | null> {
    const row = await this.prisma.payment.findFirst({
      where: { referenceType, referenceId },
      orderBy: { createdAt: 'desc' },
    });
    return row ? this.toDto(row) : null;
  }

  // ---- provider callbacks ------------------------------------------------------------------------

  /**
   * Handles a callback the route already authenticated. Safe to call any number of times with the same body.
   * Returns what happened, for logs and tests; the route always answers the provider with success.
   */
  async handleCallback(
    provider: PaymentProvider,
    body: unknown,
    rawBody: string,
  ): Promise<'IGNORED' | 'DUPLICATE' | 'PROCESSED'> {
    const parsed = provider.parseWebhook(body);
    if (!parsed) {
      this.log.warn(`Unrecognised ${provider.key} callback body`);
      return 'IGNORED';
    }
    const payment = await this.prisma.payment.findUnique({
      where: {
        provider_providerReference: {
          provider: provider.key,
          providerReference: parsed.providerReference,
        },
      },
    });
    if (!payment) {
      this.log.warn(
        `${provider.key} callback for an unknown reference ${parsed.providerReference}`,
      );
      return 'IGNORED';
    }
    try {
      await this.prisma.paymentEvent.create({
        data: {
          paymentId: payment.id,
          kind: 'CALLBACK',
          source: 'PROVIDER_CALLBACK',
          summary: `Callback received: provider says ${parsed.claimed}${parsed.code ? ` (${parsed.code})` : ''}`,
          payloadEncrypted: this.crypto.encrypt(rawBody),
          dedupeKey: `cb:${payment.id}:${bodyDigest(rawBody)}`,
        },
      });
    } catch (e) {
      if (isUnique(e)) return 'DUPLICATE';
      throw e;
    }
    await this.applyClaim(provider, payment, parsed);
    return 'PROCESSED';
  }

  private async applyClaim(provider: PaymentProvider, payment: Payment, parsed: ParsedWebhook) {
    const lateSuccess =
      payment.status === 'FAILED' &&
      payment.failureCode === 'TIMEOUT' &&
      parsed.claimed === 'SUCCESS';
    if (!isOpen(payment.status) && !lateSuccess) {
      // Out of order or repeated: the payment already has its answer. Keep a note, change nothing.
      await this.note(
        payment.id,
        'REVIEW',
        'PROVIDER_CALLBACK',
        `Ignored a ${parsed.claimed} callback: the payment is already ${payment.status}.`,
      );
      return;
    }

    if (parsed.claimed === 'SUCCESS') {
      // The callback is only a hint. First the amount has to agree, then the provider has to confirm.
      if (parsed.amountMinor === undefined || parsed.amountMinor !== Number(payment.amountMinor)) {
        if (lateSuccess) {
          await this.note(
            payment.id,
            'REVIEW',
            'PROVIDER_CALLBACK',
            'A late success callback had a different amount. Not accepted; needs a manual check.',
          );
          return;
        }
        await this.transition(payment.id, 'FAILED', {
          source: 'PROVIDER_CALLBACK',
          summary: `Amount mismatch: expected ${Number(payment.amountMinor)}, the callback reported ${parsed.amountMinor ?? 'none'} (minor units). Not accepted; needs a manual check.`,
          failureCode: 'AMOUNT_MISMATCH',
          failureReason: failureMessage('AMOUNT_MISMATCH'),
          receiptNumber: parsed.receiptNumber ?? null,
        });
        return;
      }
      await this.verifyWithProvider(payment, 'PROVIDER_CALLBACK', parsed.receiptNumber);
      return;
    }

    const code = parsed.code ?? 'PROVIDER_DECLINED';
    await this.transition(payment.id, parsed.claimed, {
      source: 'PROVIDER_CALLBACK',
      summary: `Provider reported ${parsed.claimed}${parsed.message ? `: ${parsed.message}` : ''}`,
      failureCode: code,
      failureReason: failureMessage(code),
    });
  }

  // ---- confirming with the provider ----------------------------------------------------------------

  /**
   * Asks the provider for the truth about a payment and applies it. This is the only road to SUCCEEDED.
   * A provider that cannot be reached leaves the payment as it is; the fallback job asks again.
   */
  async verifyWithProvider(
    payment: Payment,
    source: PaymentEventSource,
    receiptFromCallback?: string,
    actor?: Actor,
  ): Promise<{ status: PaymentStatus; settled: boolean }> {
    const provider = this.providers.forKey(payment.provider);
    if (!provider || !payment.providerReference) return { status: payment.status, settled: false };

    let result: StatusResult;
    try {
      result = await provider.queryStatus(payment.providerReference);
    } catch (e) {
      const attempts = payment.queryAttempts + 1;
      await this.prisma.payment.update({
        where: { id: payment.id },
        data: { lastQueriedAt: new Date(), queryAttempts: { increment: 1 } },
      });
      if (attempts === 1 || attempts % 5 === 0) {
        await this.note(
          payment.id,
          'STATUS_QUERY',
          source,
          `Could not confirm with the provider (attempt ${attempts}): ${e instanceof Error ? e.message : 'unknown error'}`,
          actor?.userId,
        );
      }
      return { status: payment.status, settled: false };
    }
    await this.prisma.payment.update({
      where: { id: payment.id },
      data: { lastQueriedAt: new Date(), queryAttempts: { increment: 1 } },
    });

    if (result.outcome === 'SUCCESS') {
      const { changed, payment: after } = await this.transition(payment.id, 'SUCCEEDED', {
        source,
        kind: 'STATUS_CHANGE',
        summary: `Confirmed by the provider status query${result.message ? `: ${result.message}` : ''}`,
        receiptNumber: result.receiptNumber ?? receiptFromCallback ?? null,
        actorId: actor?.userId,
      });
      return { status: after.status, settled: changed || isPaid(after.status) };
    }
    if (result.outcome === 'PENDING') {
      const expiredFor = payment.expiresAt ? Date.now() - payment.expiresAt.getTime() : 0;
      if (isOpen(payment.status) && expiredFor > PAYMENT_GRACE_SECONDS * 1000) {
        const { payment: after } = await this.transition(payment.id, 'FAILED', {
          source,
          summary: 'No confirmation from the provider within the time allowed.',
          failureCode: 'TIMEOUT',
          failureReason: failureMessage('TIMEOUT'),
        });
        return { status: after.status, settled: true };
      }
      return { status: payment.status, settled: false };
    }
    // The provider says it did not go through.
    if (!isOpen(payment.status)) return { status: payment.status, settled: true };
    const code = result.code ?? 'PROVIDER_DECLINED';
    const { payment: after } = await this.transition(payment.id, result.outcome, {
      source,
      summary: `Provider status query: ${result.outcome}${result.message ? ` (${result.message})` : ''}`,
      failureCode: code,
      failureReason: failureMessage(code),
      actorId: actor?.userId,
    });
    return { status: after.status, settled: true };
  }

  /** Manual re-query from the console. Audited by the caller. */
  async requery(paymentId: string, actor: Actor): Promise<Payment> {
    const payment = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    if (!payment) throw ApiException.notFound('We could not find that payment.');
    const requeryable =
      isOpen(payment.status) || (payment.status === 'FAILED' && payment.failureCode === 'TIMEOUT');
    if (!requeryable || !payment.providerReference) {
      throw ApiException.invalidState(
        'This payment has its final answer, so there is nothing to re-query.',
        {
          status: payment.status,
        },
      );
    }
    await this.verifyWithProvider(payment, 'ADMIN', undefined, actor);
    return this.prisma.payment.findUniqueOrThrow({ where: { id: paymentId } });
  }

  /**
   * The fallback job (every minute): open payments past their time limit are asked about; a prompt that never reached the
   * provider is failed; recently timed-out payments are re-checked for a late success.
   */
  async reconcilePending(
    now = new Date(),
  ): Promise<{ checked: number; settled: number; abandoned: number }> {
    const abandonedCutoff = new Date(now.getTime() - 5 * 60_000);
    const abandonedRows = await this.prisma.payment.findMany({
      where: { status: 'INITIATED', providerReference: null, createdAt: { lt: abandonedCutoff } },
      select: { id: true },
      take: 100,
    });
    for (const a of abandonedRows) {
      await this.transition(a.id, 'FAILED', {
        source: 'JOB',
        summary: 'The payment never reached the provider.',
        failureCode: 'INITIATION_INTERRUPTED',
        failureReason: failureMessage('INITIATION_INTERRUPTED'),
      });
    }

    const requeryGap = new Date(now.getTime() - 20_000);
    const lateFrom = new Date(now.getTime() - LATE_SUCCESS_WINDOW_SECONDS * 1000);
    const lateGap = new Date(now.getTime() - 5 * 60_000);
    const due = await this.prisma.payment.findMany({
      where: {
        providerReference: { not: null },
        OR: [
          {
            status: 'PENDING',
            expiresAt: { lte: now },
            OR: [{ lastQueriedAt: null }, { lastQueriedAt: { lt: requeryGap } }],
          },
          {
            status: 'FAILED',
            failureCode: 'TIMEOUT',
            completedAt: { gte: lateFrom },
            OR: [{ lastQueriedAt: null }, { lastQueriedAt: { lt: lateGap } }],
          },
        ],
      },
      orderBy: { expiresAt: 'asc' },
      take: 100,
    });
    let settled = 0;
    for (const p of due) {
      try {
        const r = await this.verifyWithProvider(p, 'JOB');
        if (r.settled && r.status !== p.status) settled += 1;
      } catch (e) {
        this.log.warn(`Reconcile of ${p.id} failed: ${e instanceof Error ? e.message : String(e)}`);
      }
    }
    return { checked: due.length, settled, abandoned: abandonedRows.length };
  }

  // ---- refunds -----------------------------------------------------------------------------------------

  /**
   * Starts a refund. The provider decides whether it can be paid back automatically; M-Pesa today needs finance to pay
   * it out and confirm it (`completeRefund`), in which case the refund waits as PENDING and its amount is held back
   * from further refunds. Used by the console and by modules (mentorship declines with `amountMinor` unset = full).
   */
  async refund(input: {
    paymentId: string;
    amountMinor?: number;
    reason: string;
    actor: Actor;
    idempotencyKey?: string;
  }): Promise<Refund> {
    if (input.idempotencyKey) {
      const existing = await this.prisma.refund.findUnique({
        where: {
          paymentId_idempotencyKey: {
            paymentId: input.paymentId,
            idempotencyKey: input.idempotencyKey,
          },
        },
      });
      if (existing) return existing;
    }
    let refund: Refund;
    let payment: Payment;
    try {
      ({ refund, payment } = await this.prisma.$transaction(async (tx) => {
        await this.lockPayment(tx, input.paymentId);
        const p = await tx.payment.findUnique({ where: { id: input.paymentId } });
        if (!p) throw ApiException.notFound('We could not find that payment.');
        if (!REFUNDABLE_STATUSES.includes(p.status)) {
          throw ApiException.invalidState('Only a payment that has succeeded can be refunded.', {
            status: p.status,
          });
        }
        const remaining = await this.refundable(tx, p);
        const amount = input.amountMinor ?? remaining;
        if (!Number.isInteger(amount) || amount <= 0 || amount > remaining) {
          throw ApiException.validation(
            remaining === 0
              ? 'Everything on this payment has already been refunded or is being refunded.'
              : `The refund must be between 1 and ${remaining} (minor units).`,
            { refundableMinor: remaining },
          );
        }
        const row = await tx.refund.create({
          data: {
            paymentId: p.id,
            amountMinor: BigInt(amount),
            reason: input.reason,
            requestedById: input.actor.userId ?? null,
            idempotencyKey: input.idempotencyKey ?? null,
          },
        });
        await tx.paymentEvent.create({
          data: {
            paymentId: p.id,
            kind: 'REFUND',
            source: input.actor.userId ? 'ADMIN' : 'API',
            summary: `Refund of ${amount} (minor units) requested: ${input.reason}`,
            actorId: input.actor.userId ?? null,
          },
        });
        await this.audit.record(
          {
            actorType: input.actor.userId ? 'ADMIN' : 'SYSTEM',
            actorId: input.actor.userId ?? null,
            action: 'payment.refund.request',
            entityType: 'payment',
            entityId: p.id,
            after: { refundId: row.id, amountMinor: amount, reason: input.reason },
            ip: input.actor.ip ?? null,
            requestId: input.actor.requestId ?? null,
          },
          tx,
        );
        return { refund: row, payment: p };
      }));
    } catch (e) {
      if (isUnique(e) && input.idempotencyKey) {
        const raced = await this.prisma.refund.findUnique({
          where: {
            paymentId_idempotencyKey: {
              paymentId: input.paymentId,
              idempotencyKey: input.idempotencyKey,
            },
          },
        });
        if (raced) return raced;
      }
      throw e;
    }

    const provider = this.providers.forKey(payment.provider);
    if (!provider) throw ApiException.external('The payment provider is not available.');
    let outcome;
    try {
      outcome = await provider.refund({
        paymentId: payment.id,
        providerReference: payment.providerReference ?? '',
        receiptNumber: payment.receiptNumber,
        amountMinor: Number(refund.amountMinor),
        currency: payment.currency,
        reason: input.reason,
      });
    } catch (e) {
      await this.failRefund(
        refund,
        'The provider could not be reached. Nothing was refunded; try again.',
        input.actor,
      );
      throw ApiException.external(
        'The payment provider could not be reached. The refund was not made.',
        {
          refundId: refund.id,
          cause: e instanceof Error ? e.message : String(e),
        },
      );
    }
    if (outcome.outcome === 'COMPLETED') {
      return this.completeRefund(
        refund.id,
        outcome.providerReference ?? null,
        'AUTOMATIC',
        input.actor,
      );
    }
    if (outcome.outcome === 'REJECTED') {
      await this.failRefund(refund, outcome.reason, input.actor);
      throw new ApiException(
        ErrorCode.PAYMENT_ERROR,
        `The provider refused the refund: ${outcome.reason}`,
        502,
        {
          refundId: refund.id,
        },
      );
    }
    await this.note(
      payment.id,
      'REFUND',
      'API',
      `Manual refund needed: ${outcome.note}`,
      input.actor.userId,
    );
    return this.prisma.refund.update({ where: { id: refund.id }, data: { mode: 'MANUAL' } });
  }

  /** Finance confirms a manual refund was paid out. Moves the payment, writes the ledger row, raises `PaymentRefunded`. */
  async confirmManualRefund(
    paymentId: string,
    refundId: string,
    providerReference: string | null,
    actor: Actor,
  ): Promise<Refund> {
    const refund = await this.prisma.refund.findFirst({ where: { id: refundId, paymentId } });
    if (!refund) throw ApiException.notFound('We could not find that refund.');
    if (refund.status !== 'PENDING' || refund.mode !== 'MANUAL') {
      throw ApiException.invalidState(
        'Only a refund that is waiting for a manual payout can be confirmed.',
        {
          status: refund.status,
          mode: refund.mode,
        },
      );
    }
    return this.completeRefund(refundId, providerReference, 'MANUAL', actor);
  }

  /** Finance abandons a manual refund (it will not be paid), freeing its amount. */
  async cancelManualRefund(paymentId: string, refundId: string, actor: Actor): Promise<Refund> {
    const refund = await this.prisma.refund.findFirst({ where: { id: refundId, paymentId } });
    if (!refund) throw ApiException.notFound('We could not find that refund.');
    if (refund.status !== 'PENDING') {
      throw ApiException.invalidState('Only a refund that is still waiting can be cancelled.', {
        status: refund.status,
      });
    }
    return this.failRefund(refund, 'Cancelled by staff.', actor);
  }

  private async failRefund(refund: Refund, reason: string, actor: Actor): Promise<Refund> {
    return this.prisma.$transaction(async (tx) => {
      const res = await tx.refund.updateMany({
        where: { id: refund.id, status: 'PENDING' },
        data: { status: 'FAILED', failureReason: reason, completedAt: new Date() },
      });
      if (res.count === 0) return tx.refund.findUniqueOrThrow({ where: { id: refund.id } });
      await tx.paymentEvent.create({
        data: {
          paymentId: refund.paymentId,
          kind: 'REFUND',
          source: actor.userId ? 'ADMIN' : 'API',
          summary: `Refund not made: ${reason}`,
          actorId: actor.userId ?? null,
        },
      });
      await this.audit.record(
        {
          actorType: actor.userId ? 'ADMIN' : 'SYSTEM',
          actorId: actor.userId ?? null,
          action: 'payment.refund.fail',
          entityType: 'payment',
          entityId: refund.paymentId,
          after: { refundId: refund.id, reason },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
      return tx.refund.findUniqueOrThrow({ where: { id: refund.id } });
    });
  }

  private async completeRefund(
    refundId: string,
    providerReference: string | null,
    mode: 'AUTOMATIC' | 'MANUAL',
    actor: Actor,
  ): Promise<Refund> {
    const outcome = await this.prisma.$transaction(async (tx) => {
      const r = await tx.refund.findUniqueOrThrow({ where: { id: refundId } });
      await this.lockPayment(tx, r.paymentId);
      const claimed = await tx.refund.updateMany({
        where: { id: refundId, status: 'PENDING' },
        data: {
          status: 'SUCCEEDED',
          mode,
          providerReference,
          completedAt: new Date(),
        },
      });
      const p = await tx.payment.findUniqueOrThrow({ where: { id: r.paymentId } });
      if (claimed.count === 0) return { refund: r, payment: p, changed: false };

      const amount = Number(r.amountMinor);
      const before = Number(p.refundedMinor);
      const after = before + amount;
      if (after > Number(p.amountMinor))
        throw ApiException.invalidState('The refund is larger than what is left to refund.');
      const status = statusAfterRefund(Number(p.amountMinor), after);
      const updated = await tx.payment.update({
        where: { id: p.id },
        data: { refundedMinor: BigInt(after), status, version: { increment: 1 } },
      });
      const fee = Number(p.platformFeeMinor);
      const total = Number(p.amountMinor);
      const feeShare = Math.round((fee * after) / total) - Math.round((fee * before) / total);
      await tx.ledgerTransaction.create({
        data: {
          paymentId: p.id,
          refundId: r.id,
          type: 'REFUND',
          payerId: p.payerId,
          payeeId: p.payeeId,
          grossMinor: BigInt(-amount),
          platformFeeMinor: BigInt(-feeShare),
          netMinor: BigInt(-(amount - feeShare)),
          currency: p.currency,
        },
      });
      await tx.paymentEvent.create({
        data: {
          paymentId: p.id,
          kind: 'REFUND',
          source: actor.userId ? 'ADMIN' : 'API',
          fromStatus: p.status,
          toStatus: status,
          summary: `Refund of ${amount} (minor units) completed (${mode.toLowerCase()})`,
          actorId: actor.userId ?? null,
        },
      });
      await this.audit.record(
        {
          actorType: actor.userId ? 'ADMIN' : 'SYSTEM',
          actorId: actor.userId ?? null,
          action: 'payment.refund.complete',
          entityType: 'payment',
          entityId: p.id,
          before: { status: p.status, refundedMinor: before },
          after: { status, refundedMinor: after, refundId: r.id, mode },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
      const refreshed = await tx.refund.findUniqueOrThrow({ where: { id: refundId } });
      return { refund: refreshed, payment: updated, changed: true };
    });
    if (outcome.changed) {
      await this.bus.emit({
        type: 'PaymentRefunded',
        paymentId: outcome.payment.id,
        refundId: outcome.refund.id,
        purpose: outcome.payment.purpose,
        referenceType: outcome.payment.referenceType,
        referenceId: outcome.payment.referenceId,
        payerId: outcome.payment.payerId,
        amountMinor: Number(outcome.refund.amountMinor),
        fullyRefunded: outcome.payment.status === 'REFUNDED',
      });
    }
    return outcome.refund;
  }

  /** Minor units still refundable: the amount less completed refunds and refunds in progress. */
  async refundable(db: TxClient | PrismaService, p: Payment): Promise<number> {
    const pending = await db.refund.aggregate({
      where: { paymentId: p.id, status: 'PENDING' },
      _sum: { amountMinor: true },
    });
    return Math.max(
      0,
      Number(p.amountMinor) -
        Number(p.refundedMinor) -
        Number(pending._sum.amountMinor ?? BigInt(0)),
    );
  }

  private async lockPayment(tx: TxClient, id: string): Promise<void> {
    await tx.$queryRaw`SELECT id FROM payments WHERE id = ${id}::uuid FOR UPDATE`;
  }

  // ---- the one place a status changes --------------------------------------------------------------

  /**
   * Compare-and-set a status. Returns `changed: false` (and the current row) when the payment was not in a state that
   * allows the move, so a repeated callback or a second worker is a quiet no-op. The event, the ledger row (on success)
   * and the audit entry commit with the change; domain events follow the commit.
   */
  private async transition(
    paymentId: string,
    to: PaymentStatus,
    t: Transition & {
      providerFields?: { providerReference: string; merchantReference: string | null };
    },
  ): Promise<{ changed: boolean; payment: Payment }> {
    const where: Prisma.PaymentWhereInput =
      to === 'SUCCEEDED'
        ? {
            id: paymentId,
            OR: [{ status: 'PENDING' }, { status: 'FAILED', failureCode: 'TIMEOUT' }],
          }
        : { id: paymentId, status: { in: statusesBefore(to) } };
    const terminal = to === 'SUCCEEDED' || to === 'FAILED' || to === 'CANCELLED';

    const result = await this.prisma.$transaction(async (tx) => {
      const before = await tx.payment.findUnique({ where: { id: paymentId } });
      if (!before) throw ApiException.notFound('We could not find that payment.');
      const res = await tx.payment.updateMany({
        where,
        data: {
          status: to,
          version: { increment: 1 },
          ...(terminal ? { completedAt: new Date() } : {}),
          ...(to === 'SUCCEEDED'
            ? { failureCode: null, failureReason: null }
            : to === 'FAILED' || to === 'CANCELLED'
              ? { failureCode: t.failureCode ?? null, failureReason: t.failureReason ?? null }
              : {}),
          ...(t.receiptNumber ? { receiptNumber: t.receiptNumber } : {}),
          ...(t.providerFields ?? {}),
        },
      });
      if (res.count === 0) return { changed: false as const, payment: before };

      const payment = await tx.payment.findUniqueOrThrow({ where: { id: paymentId } });
      await tx.paymentEvent.create({
        data: {
          paymentId,
          kind: t.kind ?? 'STATUS_CHANGE',
          source: t.source,
          fromStatus: before.status,
          toStatus: to,
          summary: t.summary,
          payloadEncrypted:
            t.payload !== undefined ? this.crypto.encrypt(JSON.stringify(t.payload)) : null,
          actorId: t.actorId ?? null,
        },
      });
      if (to === 'SUCCEEDED') {
        const gross = Number(payment.amountMinor);
        const fee = Number(payment.platformFeeMinor);
        await tx.ledgerTransaction.create({
          data: {
            paymentId,
            type: 'PAYMENT',
            payerId: payment.payerId,
            payeeId: payment.payeeId,
            grossMinor: BigInt(gross),
            platformFeeMinor: BigInt(fee),
            netMinor: BigInt(gross - fee),
            currency: payment.currency,
          },
        });
      }
      await this.audit.record(
        {
          actorType: t.actorId ? 'ADMIN' : 'SYSTEM',
          actorId: t.actorId ?? null,
          action: 'payment.status_change',
          entityType: 'payment',
          entityId: paymentId,
          before: { status: before.status },
          after: { status: to, source: t.source, failureCode: t.failureCode ?? null },
        },
        tx,
      );
      return { changed: true as const, payment };
    });

    if (result.changed) await this.raise(result.payment, to);
    return result;
  }

  private async raise(p: Payment, to: PaymentStatus): Promise<void> {
    if (to === 'SUCCEEDED') {
      await this.bus.emit({
        type: 'PaymentSucceeded',
        paymentId: p.id,
        purpose: p.purpose,
        referenceType: p.referenceType,
        referenceId: p.referenceId,
        payerId: p.payerId,
        amountMinor: Number(p.amountMinor),
        currency: p.currency,
      });
    } else if (to === 'FAILED' || to === 'CANCELLED') {
      await this.bus.emit({
        type: 'PaymentFailed',
        paymentId: p.id,
        purpose: p.purpose,
        referenceType: p.referenceType,
        referenceId: p.referenceId,
        payerId: p.payerId,
        status: to,
        failureCode: p.failureCode,
        failureReason: p.failureReason,
      });
    }
  }

  // ---- helpers ---------------------------------------------------------------------------------------

  private async note(
    paymentId: string,
    kind: PaymentEventKind,
    source: PaymentEventSource,
    summary: string,
    actorId?: string | null,
  ): Promise<void> {
    await this.prisma.paymentEvent.create({
      data: { paymentId, kind, source, summary, actorId: actorId ?? null },
    });
  }

  private findByKey(payerId: string, idempotencyKey: string) {
    return this.prisma.payment.findUnique({
      where: { payerId_idempotencyKey: { payerId, idempotencyKey } },
    });
  }

  /** A repeated request returns the same payment; the same key for a different purchase is a client bug. */
  private sameRequestOrConflict(
    existing: Payment,
    purpose: PaymentPurpose,
    referenceId: string | null,
  ): PaymentDto {
    if (existing.purpose !== purpose || (referenceId && existing.referenceId !== referenceId)) {
      throw ApiException.conflict('That Idempotency-Key was already used for a different payment.');
    }
    return this.toDto(existing);
  }

  toDto(p: Payment): PaymentDto {
    const timedOut =
      isOpen(p.status) && p.expiresAt !== null && p.expiresAt.getTime() <= Date.now();
    return {
      id: p.id,
      status: p.status,
      purpose: p.purpose,
      method: p.method,
      amountMinor: Number(p.amountMinor),
      currency: p.currency,
      description: p.description,
      referenceType: p.referenceType,
      referenceId: p.referenceId,
      receiptNumber: p.receiptNumber,
      failureCode: p.failureCode,
      failureReason: p.failureReason,
      refundedMinor: Number(p.refundedMinor),
      createdAt: p.createdAt.toISOString(),
      completedAt: p.completedAt?.toISOString() ?? null,
      expiresAt: p.expiresAt?.toISOString() ?? null,
      timedOut,
      pollAfterSeconds: POLL_AFTER_SECONDS,
    };
  }
}
