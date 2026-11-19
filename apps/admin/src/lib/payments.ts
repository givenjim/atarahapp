/** Pure helpers for the Payments screens (no server imports). Amounts are minor units (KES cents). */

export const REASON_MIN = 5;
export const REASON_MAX = 500;

export const PAYMENT_STATUSES = [
  'INITIATED',
  'PENDING',
  'SUCCEEDED',
  'FAILED',
  'CANCELLED',
  'REFUNDED',
  'PARTIALLY_REFUNDED',
] as const;
export const PAYMENT_METHODS = ['MPESA', 'CARD'] as const;
export const PAYMENT_PURPOSES = ['MEMBERSHIP', 'MENTORSHIP', 'VERIFICATION', 'OTHER'] as const;

const STATUS_LABEL: Record<string, string> = {
  INITIATED: 'Started',
  PENDING: 'Waiting for member',
  SUCCEEDED: 'Paid',
  FAILED: 'Failed',
  CANCELLED: 'Cancelled',
  REFUNDED: 'Refunded',
  PARTIALLY_REFUNDED: 'Partly refunded',
};

const STATUS_TONE: Record<string, '' | 'success' | 'warning' | 'danger'> = {
  INITIATED: '',
  PENDING: 'warning',
  SUCCEEDED: 'success',
  FAILED: 'danger',
  CANCELLED: '',
  REFUNDED: '',
  PARTIALLY_REFUNDED: 'warning',
};

export const statusLabel = (s: string): string => STATUS_LABEL[s] ?? s;
export const statusTone = (s: string): '' | 'success' | 'warning' | 'danger' =>
  STATUS_TONE[s] ?? '';

export const METHOD_LABEL: Record<string, string> = { MPESA: 'M-Pesa', CARD: 'Card' };
export const PURPOSE_LABEL: Record<string, string> = {
  MEMBERSHIP: 'Membership',
  MENTORSHIP: 'Mentorship',
  VERIFICATION: 'Verification',
  OTHER: 'Other',
};

export const EVENT_KIND_LABEL: Record<string, string> = {
  INITIATED: 'Started',
  CALLBACK: 'Provider callback',
  STATUS_QUERY: 'Status query',
  STATUS_CHANGE: 'Status change',
  REFUND: 'Refund',
  REVIEW: 'Needs a look',
};

export const SOURCE_LABEL: Record<string, string> = {
  API: 'App',
  PROVIDER_CALLBACK: 'Provider',
  STATUS_QUERY: 'Status query',
  JOB: 'Background job',
  ADMIN: 'Staff',
};

/** `KES 1,200` or `KES 1,200.50`. */
export function formatMoney(amountMinor: number, currency = 'KES'): string {
  const sign = amountMinor < 0 ? '-' : '';
  const abs = Math.abs(amountMinor);
  const whole = Math.trunc(abs / 100).toLocaleString('en-US');
  const cents = abs % 100;
  return `${sign}${currency} ${whole}${cents ? `.${String(cents).padStart(2, '0')}` : ''}`;
}

/** Whole or fractional shillings typed by staff, as minor units. Null when it is not a positive amount with at most 2 decimals. */
export function parseShillings(input: string): number | null {
  const t = input.trim().replace(/,/g, '');
  if (!/^\d+(\.\d{1,2})?$/.test(t)) return null;
  const minor = Math.round(Number(t) * 100);
  return minor > 0 ? minor : null;
}

export interface RefundInput {
  /** Empty means "refund everything still refundable". */
  amount: string;
  reason: string;
  refundableMinor: number;
}

/** A message for the first problem with a refund request, or null when it is fine to send. */
export function validateRefund(i: RefundInput): string | null {
  if (i.refundableMinor <= 0) return 'There is nothing left to refund on this payment.';
  const reason = i.reason.trim();
  if (reason.length < REASON_MIN) return `Give a reason of at least ${REASON_MIN} characters.`;
  if (reason.length > REASON_MAX)
    return `The reason is too long (${REASON_MAX} characters at most).`;
  if (i.amount.trim()) {
    const minor = parseShillings(i.amount);
    if (minor === null) return 'Enter the amount in shillings, like 500 or 500.50.';
    if (minor > i.refundableMinor) {
      return `You can refund at most ${formatMoney(i.refundableMinor)}.`;
    }
  }
  return null;
}

/** What a failed finance call means for staff. */
export function paymentsMessage(status: number | undefined, message: string): string {
  if (status === 403) return 'You do not have permission to manage payments.';
  if (status === 404) return 'That payment no longer exists.';
  return message;
}

export const isUuid = (v: string): boolean =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v.trim());
