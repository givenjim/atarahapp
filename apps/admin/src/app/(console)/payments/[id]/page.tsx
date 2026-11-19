import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { getPayment } from '@/lib/payments-api';
import {
  EVENT_KIND_LABEL,
  METHOD_LABEL,
  PURPOSE_LABEL,
  SOURCE_LABEL,
  formatMoney,
  statusLabel,
  statusTone,
} from '@/lib/payments';
import { PaymentActions } from './payment-actions';

export const metadata = { title: 'Payment' };

const when = (iso: string | null) => (iso ? new Date(iso).toLocaleString('en-KE') : '—');

export default async function PaymentPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'payment.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Payments.
      </div>
    );
  }
  const { data, response } = await getPayment(id);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the payment (${response.status}).`);
  }
  const p = data.data;
  const money = (n: number) => formatMoney(n, p.currency);
  const manage = can(me.permissions, 'payment.manage');
  const open = p.status === 'PENDING' || p.status === 'INITIATED';
  const lateCheck = p.status === 'FAILED' && p.failureCode === 'TIMEOUT';

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/payments">← All payments</Link>
        </p>
        <h1>
          {money(p.amountMinor)} · {PURPOSE_LABEL[p.purpose] ?? p.purpose}
        </h1>
      </div>

      <section className="card" aria-label="Payment">
        <dl className="facts">
          <dt>Status</dt>
          <dd>
            <span className={`pill ${statusTone(p.status)}`.trim()}>{statusLabel(p.status)}</span>
          </dd>
          <dt>Payer</dt>
          <dd>
            <Link href={`/users/${p.payer.id}`}>{p.payer.fullName}</Link>
            {p.msisdnLast4 ? <span className="muted"> · number ending {p.msisdnLast4}</span> : null}
          </dd>
          <dt>Method</dt>
          <dd>{METHOD_LABEL[p.method] ?? p.method}</dd>
          <dt>Receipt</dt>
          <dd>{p.receiptNumber ?? '—'}</dd>
          <dt>Provider reference</dt>
          <dd>{p.providerReference ?? '—'}</dd>
          <dt>Started</dt>
          <dd>{when(p.createdAt)}</dd>
          <dt>Finished</dt>
          <dd>{when(p.completedAt)}</dd>
          <dt>Refunded</dt>
          <dd>{money(p.refundedMinor)}</dd>
          <dt>Platform fee</dt>
          <dd>{money(p.platformFeeMinor)}</dd>
          {p.failureReason ? (
            <>
              <dt>Why it failed</dt>
              <dd>
                {p.failureReason}
                {p.failureCode ? <span className="muted"> ({p.failureCode})</span> : null}
              </dd>
            </>
          ) : null}
          <dt>Provider checks</dt>
          <dd>
            {p.queryAttempts} · last {when(p.lastQueriedAt)}
          </dd>
        </dl>
      </section>

      {manage ? (
        <PaymentActions
          paymentId={p.id}
          status={p.status}
          currency={p.currency}
          refundableMinor={p.refundableMinor}
          canRequery={open || lateCheck}
          refunds={p.refunds.map((r) => ({
            id: r.id,
            amountMinor: r.amountMinor,
            status: r.status,
            mode: r.mode,
            reason: r.reason,
          }))}
        />
      ) : (
        <p className="muted">
          Refunds and re-checks need the payment management permission, which your role does not
          have.
        </p>
      )}

      <section className="card" aria-label="Refunds" style={{ padding: 20 }}>
        <h2>Refunds</h2>
        {p.refunds.length === 0 ? (
          <p className="muted">No refunds.</p>
        ) : (
          <div className="table-wrap">
            <table className="data">
              <caption className="sr-only-text">Refunds</caption>
              <thead>
                <tr>
                  <th scope="col">Requested</th>
                  <th scope="col">Amount</th>
                  <th scope="col">How</th>
                  <th scope="col">Status</th>
                  <th scope="col">Reason</th>
                </tr>
              </thead>
              <tbody>
                {p.refunds.map((r) => (
                  <tr key={r.id}>
                    <td>{when(r.createdAt)}</td>
                    <td>{money(r.amountMinor)}</td>
                    <td>{r.mode === 'MANUAL' ? 'Paid out by finance' : 'Through the provider'}</td>
                    <td>
                      {r.status === 'PENDING'
                        ? 'Waiting for payout'
                        : r.status === 'SUCCEEDED'
                          ? 'Done'
                          : 'Not made'}
                      {r.failureReason ? <div className="muted">{r.failureReason}</div> : null}
                    </td>
                    <td>{r.reason}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className="card" aria-label="Ledger" style={{ padding: 20 }}>
        <h2>Ledger</h2>
        {p.ledger.length === 0 ? (
          <p className="muted">Nothing recorded: the payment has not succeeded.</p>
        ) : (
          <div className="table-wrap">
            <table className="data">
              <caption className="sr-only-text">Ledger entries</caption>
              <thead>
                <tr>
                  <th scope="col">When</th>
                  <th scope="col">Type</th>
                  <th scope="col">Gross</th>
                  <th scope="col">Platform fee</th>
                  <th scope="col">Net to payee</th>
                </tr>
              </thead>
              <tbody>
                {p.ledger.map((l) => (
                  <tr key={l.id}>
                    <td>{when(l.createdAt)}</td>
                    <td>{l.type === 'PAYMENT' ? 'Payment' : 'Refund'}</td>
                    <td>{money(l.grossMinor)}</td>
                    <td>{money(l.platformFeeMinor)}</td>
                    <td>{money(l.netMinor)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className="card" aria-label="Event history" style={{ padding: 20 }}>
        <h2>Event history</h2>
        <div className="table-wrap">
          <table className="data">
            <caption className="sr-only-text">Every callback, check and status change</caption>
            <thead>
              <tr>
                <th scope="col">When</th>
                <th scope="col">Event</th>
                <th scope="col">From</th>
                <th scope="col">What happened</th>
              </tr>
            </thead>
            <tbody>
              {p.events.map((e) => (
                <tr key={e.id}>
                  <td>{when(e.createdAt)}</td>
                  <td>{EVENT_KIND_LABEL[e.kind] ?? e.kind}</td>
                  <td>{SOURCE_LABEL[e.source] ?? e.source}</td>
                  <td>
                    {e.fromStatus || e.toStatus ? (
                      <span className="muted">
                        {e.fromStatus ? statusLabel(e.fromStatus) : 'New'} →{' '}
                        {e.toStatus ? statusLabel(e.toStatus) : '—'}.{' '}
                      </span>
                    ) : null}
                    {e.summary}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </>
  );
}
