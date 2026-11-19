/**
 * What a member reads when a payment does not go through. Every message says what to do next (Master Prompt P2-M1).
 * The codes are stable and stored on the payment (`failureCode`).
 */
export const FAILURE_MESSAGES: Readonly<Record<string, string>> = {
  CANCELLED_BY_USER: 'You cancelled the M-Pesa prompt. Try again when you are ready.',
  INSUFFICIENT_FUNDS: 'Your M-Pesa balance was too low. Top up, then try again.',
  WRONG_PIN: 'M-Pesa did not accept the PIN. Try again and enter your PIN carefully.',
  TIMEOUT:
    'We did not receive your M-Pesa confirmation. If money left your account it will show here automatically within a few minutes; otherwise try again.',
  AMOUNT_MISMATCH:
    'The amount M-Pesa received did not match this payment, so we did not accept it. Contact Atarah support and we will refund it.',
  PROVIDER_UNAVAILABLE:
    'We could not reach M-Pesa just now and you have not been charged. Wait a moment, then try again.',
  INITIATION_INTERRUPTED:
    'The payment did not start properly and you have not been charged. Please try again.',
  PROVIDER_DECLINED:
    'M-Pesa could not complete the payment. Check your number and balance, then try again.',
};

export const failureMessage = (code: string | null | undefined): string =>
  (code && FAILURE_MESSAGES[code]) || FAILURE_MESSAGES.PROVIDER_DECLINED!;
