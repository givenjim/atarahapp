'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { errorOf, needsReauth, sessionRedirectFor } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { cancelRefund, completeRefund, refundPayment, requeryPayment } from '@/lib/payments-api';
import { paymentsMessage, validateRefund, parseShillings } from '@/lib/payments';
import type { ActionResult } from '@/app/actions';

const DENIED = 'You do not have permission to manage payments.';

/** The backend enforces `payment.manage` on every call; checking here only gives a clearer answer sooner. */
async function mayManage(): Promise<boolean> {
  const me = await currentAdmin();
  return can(me.permissions, 'payment.manage');
}

/** Turns an API response into an action result: a stale authenticator check asks for the code again. */
function settle(error: unknown, response: Response, id: string): ActionResult {
  if (response.ok) {
    revalidatePath('/payments', 'layout');
    revalidatePath(`/payments/${id}`);
    revalidatePath('/audit-logs');
    return { ok: true };
  }
  const e = errorOf(error, response);
  if (needsReauth(e)) return { ok: false, reauth: true, error: e.message };
  const gone = sessionRedirectFor(e);
  if (gone) redirect(gone);
  return { ok: false, error: paymentsMessage(e.status, e.message) };
}

/** Asks the provider again about a stuck payment. Needs a fresh authenticator check. */
export async function requeryPaymentAction(id: string): Promise<ActionResult> {
  if (!(await mayManage())) return { ok: false, error: DENIED };
  const { error, response } = await requeryPayment(id);
  return settle(error, response, id);
}

/**
 * Refunds a payment. `amount` is in shillings (empty = everything still refundable); `key` is generated when the dialog
 * opens so a double click or a retry after re-authentication never creates a second refund.
 */
export async function refundPaymentAction(
  id: string,
  input: { amount: string; reason: string; refundableMinor: number; key: string },
): Promise<ActionResult> {
  if (!(await mayManage())) return { ok: false, error: DENIED };
  const problem = validateRefund(input);
  if (problem) return { ok: false, error: problem };
  const amountMinor = input.amount.trim() ? (parseShillings(input.amount) ?? undefined) : undefined;
  const { error, response } = await refundPayment(
    id,
    { ...(amountMinor ? { amountMinor } : {}), reason: input.reason.trim() },
    input.key,
  );
  return settle(error, response, id);
}

/** Finance confirms it paid a manual refund out. */
export async function completeRefundAction(
  id: string,
  refundId: string,
  providerReference: string,
): Promise<ActionResult> {
  if (!(await mayManage())) return { ok: false, error: DENIED };
  const { error, response } = await completeRefund(
    id,
    refundId,
    providerReference.trim() || undefined,
  );
  return settle(error, response, id);
}

/** Abandons a manual refund that will not be paid. */
export async function cancelRefundAction(id: string, refundId: string): Promise<ActionResult> {
  if (!(await mayManage())) return { ok: false, error: DENIED };
  const { error, response } = await cancelRefund(id, refundId);
  return settle(error, response, id);
}
