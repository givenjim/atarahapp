'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import {
  cancelRefundAction,
  completeRefundAction,
  refundPaymentAction,
  requeryPaymentAction,
} from '@/app/payment-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { formatMoney, REASON_MAX, validateRefund } from '@/lib/payments';

interface RefundRow {
  id: string;
  amountMinor: number;
  status: string;
  mode: string;
  reason: string;
}

type Dialog = 'refund' | 'requery' | { complete: string } | { cancel: string } | null;

/**
 * Finance actions on one payment: re-query the provider, refund, confirm a manual refund was paid out, or abandon it.
 * Each needs a fresh authenticator code (the API answers REAUTH_REQUIRED and the dialog asks) and is audited.
 */
export function PaymentActions({
  paymentId,
  status,
  currency,
  refundableMinor,
  canRequery,
  refunds,
}: {
  paymentId: string;
  status: string;
  currency: string;
  refundableMinor: number;
  canRequery: boolean;
  refunds: RefundRow[];
}) {
  const router = useRouter();
  const [dialog, setDialog] = useState<Dialog>(null);
  const [amount, setAmount] = useState('');
  const [reason, setReason] = useState('');
  const [reference, setReference] = useState('');
  // One key per opened refund dialog: a double click or a retry after re-authentication creates one refund.
  const [key, setKey] = useState('');
  const { attempt, pending, error, setError, reauth } = useReauth();

  const refundable = status === 'SUCCEEDED' || status === 'PARTIALLY_REFUNDED';
  const waiting = refunds.filter((r) => r.status === 'PENDING' && r.mode === 'MANUAL');

  const close = () => {
    setDialog(null);
    setError(null);
    setAmount('');
    setReason('');
    setReference('');
  };
  const done = () => {
    close();
    router.refresh();
  };

  const openRefund = () => {
    setError(null);
    setKey(globalThis.crypto.randomUUID());
    setDialog('refund');
  };

  const sendRefund = () => {
    const problem = validateRefund({ amount, reason, refundableMinor });
    if (problem) return setError(problem);
    attempt(() => refundPaymentAction(paymentId, { amount, reason, refundableMinor, key }), done);
  };

  const completing = typeof dialog === 'object' && dialog !== null && 'complete' in dialog;
  const cancelling = typeof dialog === 'object' && dialog !== null && 'cancel' in dialog;

  return (
    <section className="card" aria-label="Finance actions" style={{ padding: 20 }}>
      <h2>Finance actions</h2>
      <div className="row-actions">
        {canRequery ? (
          <button
            type="button"
            className="button secondary"
            disabled={pending}
            onClick={() => {
              setError(null);
              setDialog('requery');
            }}
          >
            Re-check with provider
          </button>
        ) : null}
        {refundable && refundableMinor > 0 ? (
          <button type="button" className="button danger" disabled={pending} onClick={openRefund}>
            Refund
          </button>
        ) : null}
      </div>
      {!canRequery && !(refundable && refundableMinor > 0) && waiting.length === 0 ? (
        <p className="muted">There is nothing to do on this payment.</p>
      ) : null}

      {waiting.length > 0 ? (
        <>
          <h3>Refunds waiting for a payout</h3>
          <p className="muted">
            M-Pesa refunds are paid back by finance. Pay the amount to the member, then confirm it
            here. The payment and the ledger only change when you confirm.
          </p>
          <ul className="plain-list">
            {waiting.map((r) => (
              <li key={r.id} style={{ marginBottom: 8 }}>
                {formatMoney(r.amountMinor, currency)} · {r.reason}{' '}
                <span className="row-actions" style={{ display: 'inline-flex' }}>
                  <button
                    type="button"
                    className="button"
                    disabled={pending}
                    onClick={() => {
                      setError(null);
                      setDialog({ complete: r.id });
                    }}
                  >
                    Confirm paid out
                  </button>
                  <button
                    type="button"
                    className="button secondary"
                    disabled={pending}
                    onClick={() => {
                      setError(null);
                      setDialog({ cancel: r.id });
                    }}
                  >
                    Cancel refund
                  </button>
                </span>
              </li>
            ))}
          </ul>
        </>
      ) : null}
      {error && dialog === null ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}

      <ConfirmDialog
        open={dialog === 'requery'}
        title="Re-check with the provider?"
        confirmLabel="Re-check"
        pending={pending}
        error={dialog === 'requery' ? error : null}
        onCancel={close}
        onConfirm={() => attempt(() => requeryPaymentAction(paymentId), done)}
      >
        <p className="muted" style={{ margin: 0 }}>
          Asks M-Pesa what happened to this payment. If it confirms the money was taken, the payment
          is marked paid. Nothing else changes. This is recorded in the audit log.
        </p>
      </ConfirmDialog>

      <FormDialog
        open={dialog === 'refund'}
        title="Refund this payment"
        submitLabel="Refund"
        pending={pending}
        error={dialog === 'refund' ? error : null}
        onCancel={close}
        onSubmit={sendRefund}
      >
        <p className="muted" style={{ margin: 0 }}>
          Up to {formatMoney(refundableMinor, currency)} can still be refunded. M-Pesa refunds are
          paid out by finance afterwards and confirmed here. The reason is recorded in the audit log
          with your name.
        </p>
        <label className="field">
          Amount in shillings (leave empty to refund {formatMoney(refundableMinor, currency)})
          <input
            className="input"
            inputMode="decimal"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
        </label>
        <label className="field">
          Reason
          <textarea
            className="textarea"
            value={reason}
            maxLength={REASON_MAX}
            onChange={(e) => setReason(e.target.value)}
          />
        </label>
      </FormDialog>

      <FormDialog
        open={completing}
        title="Confirm the refund was paid out"
        submitLabel="Confirm paid out"
        pending={pending}
        error={completing ? error : null}
        onCancel={close}
        onSubmit={() =>
          completing &&
          attempt(
            () =>
              completeRefundAction(paymentId, (dialog as { complete: string }).complete, reference),
            done,
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          Only confirm once the money has left. This marks the refund done, updates the payment and
          the ledger, and tells the member.
        </p>
        <label className="field">
          Payout reference (M-Pesa receipt or bank reference, optional)
          <input
            className="input"
            value={reference}
            maxLength={100}
            onChange={(e) => setReference(e.target.value)}
          />
        </label>
      </FormDialog>

      <ConfirmDialog
        open={cancelling}
        title="Cancel this refund?"
        confirmLabel="Cancel refund"
        tone="danger"
        pending={pending}
        error={cancelling ? error : null}
        onCancel={close}
        onConfirm={() =>
          cancelling &&
          attempt(() => cancelRefundAction(paymentId, (dialog as { cancel: string }).cancel), done)
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          The refund will not be paid and its amount becomes refundable again.
        </p>
      </ConfirmDialog>

      <ReauthDialog {...reauth} />
    </section>
  );
}
