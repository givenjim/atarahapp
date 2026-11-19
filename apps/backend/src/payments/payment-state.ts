import { type PaymentStatus } from '@prisma/client';

/**
 * The payment state machine (Master Prompt 6.7, P2-M1):
 *
 *   INITIATED -> PENDING -> SUCCEEDED | FAILED | CANCELLED,  SUCCEEDED -> PARTIALLY_REFUNDED -> REFUNDED
 *
 * Only a verified provider confirmation may move a payment to SUCCEEDED; that rule lives in `PaymentsService`
 * (nothing a client sends reaches this table). One more edge exists on purpose: a payment that was failed because
 * no confirmation arrived in time (`failureCode` TIMEOUT) can still become SUCCEEDED when the provider later
 * confirms that the money was taken. The service allows that edge for TIMEOUT only.
 */
export const TRANSITIONS: Readonly<Record<PaymentStatus, readonly PaymentStatus[]>> = {
  INITIATED: ['PENDING', 'FAILED', 'CANCELLED'],
  PENDING: ['SUCCEEDED', 'FAILED', 'CANCELLED'],
  SUCCEEDED: ['PARTIALLY_REFUNDED', 'REFUNDED'],
  FAILED: ['SUCCEEDED'],
  CANCELLED: [],
  PARTIALLY_REFUNDED: ['PARTIALLY_REFUNDED', 'REFUNDED'],
  REFUNDED: [],
};

export const OPEN_STATUSES: readonly PaymentStatus[] = ['INITIATED', 'PENDING'];
export const REFUNDABLE_STATUSES: readonly PaymentStatus[] = ['SUCCEEDED', 'PARTIALLY_REFUNDED'];
/** The money has been taken (and perhaps partly given back). */
export const PAID_STATUSES: readonly PaymentStatus[] = [
  'SUCCEEDED',
  'PARTIALLY_REFUNDED',
  'REFUNDED',
];

export const canTransition = (from: PaymentStatus, to: PaymentStatus): boolean =>
  TRANSITIONS[from].includes(to);

/** The statuses a payment may currently hold for it to move to `to` (used as a compare-and-set filter). */
export const statusesBefore = (to: PaymentStatus): PaymentStatus[] =>
  (Object.keys(TRANSITIONS) as PaymentStatus[]).filter((from) => canTransition(from, to));

export const isOpen = (s: PaymentStatus): boolean => OPEN_STATUSES.includes(s);
export const isPaid = (s: PaymentStatus): boolean => PAID_STATUSES.includes(s);

/** Status after a completed refund, from the payment amount and the total refunded so far. */
export const statusAfterRefund = (amountMinor: number, refundedMinor: number): PaymentStatus =>
  refundedMinor >= amountMinor ? 'REFUNDED' : 'PARTIALLY_REFUNDED';
