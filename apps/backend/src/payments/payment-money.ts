/** Money and phone helpers for payments. Amounts are integer minor units (KES cents). */

/** `254712345678` (Daraja's format) from `+254712345678`, `0712345678`, `0112345678` or `254712345678`. Null when invalid. */
export function toMsisdn(input: string): string | null {
  const digits = input.replace(/[\s\-()]/g, '');
  let national: string | null = null;
  if (/^\+254[17]\d{8}$/.test(digits)) national = digits.slice(4);
  else if (/^254[17]\d{8}$/.test(digits)) national = digits.slice(3);
  else if (/^0[17]\d{8}$/.test(digits)) national = digits.slice(1);
  return national ? `254${national}` : null;
}

export const last4 = (msisdn: string): string => msisdn.slice(-4);

/** Whole shillings from minor units. Daraja takes whole shillings only, so the caller checks `isWholeShillings`. */
export const isWholeShillings = (amountMinor: number): boolean => amountMinor % 100 === 0;
export const toShillings = (amountMinor: number): number => amountMinor / 100;
export const toMinor = (shillings: number): number => Math.round(shillings * 100);

/** `KES 1,200` or `KES 1,200.50`. */
export function formatMoney(amountMinor: number, currency = 'KES'): string {
  const whole = Math.trunc(amountMinor / 100);
  const cents = Math.abs(amountMinor % 100);
  const grouped = whole.toLocaleString('en-US');
  return `${currency} ${grouped}${cents ? `.${String(cents).padStart(2, '0')}` : ''}`;
}

/** Nairobi wall-clock time as Daraja wants it: `YYYYMMDDHHmmss`. */
export function darajaTimestamp(now = new Date()): string {
  const eat = new Date(now.getTime() + 3 * 3_600_000);
  const p = (n: number, w = 2) => String(n).padStart(w, '0');
  return (
    `${eat.getUTCFullYear()}${p(eat.getUTCMonth() + 1)}${p(eat.getUTCDate())}` +
    `${p(eat.getUTCHours())}${p(eat.getUTCMinutes())}${p(eat.getUTCSeconds())}`
  );
}
