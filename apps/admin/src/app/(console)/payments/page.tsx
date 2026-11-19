import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listPayments } from '@/lib/payments-api';
import {
  METHOD_LABEL,
  PAYMENT_METHODS,
  PAYMENT_PURPOSES,
  PAYMENT_STATUSES,
  PURPOSE_LABEL,
  formatMoney,
  statusLabel,
  statusTone,
} from '@/lib/payments';

export const metadata = { title: 'Payments' };

type SearchParams = Promise<{
  status?: string;
  method?: string;
  purpose?: string;
  q?: string;
  page?: string;
}>;

const pick = (v: string | undefined, allowed: readonly string[]) =>
  v && allowed.includes(v) ? v : undefined;

const when = (iso: string) => new Date(iso).toLocaleString('en-KE');

export default async function PaymentsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'payment.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Payments.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const status = pick(sp.status, PAYMENT_STATUSES);
  const method = pick(sp.method, PAYMENT_METHODS);
  const purpose = pick(sp.purpose, PAYMENT_PURPOSES);
  const q = sp.q?.trim() || undefined;

  const { data, error, response } = await listPayments({
    page,
    limit: 20,
    status,
    paymentMethod: method,
    purpose,
    q,
  });
  const filtered = Boolean(status || method || purpose || q);

  return (
    <>
      <div className="page-head">
        <h1>Payments</h1>
        <p>
          Payment records, newest first. Only metadata is shown: never card data, never the raw
          provider messages, and the paying number only as its last four digits. Refunding needs the
          separate payment permission and a fresh authenticator code, and every change is in the
          audit log.
        </p>
      </div>
      <section className="card" aria-label="Payments">
        <form className="filters" role="search" method="get">
          <label className="field">
            Search
            <input
              className="input"
              type="search"
              name="q"
              defaultValue={q ?? ''}
              placeholder="Payment id, M-Pesa receipt or payer name"
            />
          </label>
          <label className="field">
            Status
            <select className="select" name="status" defaultValue={status ?? ''}>
              <option value="">Any</option>
              {PAYMENT_STATUSES.map((s) => (
                <option key={s} value={s}>
                  {statusLabel(s)}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            Method
            <select className="select" name="method" defaultValue={method ?? ''}>
              <option value="">Any</option>
              {PAYMENT_METHODS.map((m) => (
                <option key={m} value={m}>
                  {METHOD_LABEL[m]}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            For
            <select className="select" name="purpose" defaultValue={purpose ?? ''}>
              <option value="">Any</option>
              {PAYMENT_PURPOSES.map((p) => (
                <option key={p} value={p}>
                  {PURPOSE_LABEL[p]}
                </option>
              ))}
            </select>
          </label>
          <button className="button" type="submit">
            Apply
          </button>
          {filtered ? (
            <Link className="button secondary" href="/payments">
              Clear
            </Link>
          ) : null}
        </form>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Payments"
              rows={data.data}
              rowKey={(p) => p.id}
              empty={filtered ? 'No payments match these filters.' : 'No payments yet.'}
              columns={[
                {
                  key: 'when',
                  header: 'Started',
                  render: (p) => <Link href={`/payments/${p.id}`}>{when(p.createdAt)}</Link>,
                },
                {
                  key: 'payer',
                  header: 'Payer',
                  render: (p) => <Link href={`/users/${p.payer.id}`}>{p.payer.fullName}</Link>,
                },
                {
                  key: 'amount',
                  header: 'Amount',
                  render: (p) => (
                    <>
                      {formatMoney(p.amountMinor, p.currency)}
                      {p.refundedMinor > 0 ? (
                        <div className="muted">
                          {formatMoney(p.refundedMinor, p.currency)} refunded
                        </div>
                      ) : null}
                    </>
                  ),
                },
                {
                  key: 'for',
                  header: 'For',
                  render: (p) => PURPOSE_LABEL[p.purpose] ?? p.purpose,
                },
                {
                  key: 'method',
                  header: 'Method',
                  render: (p) => METHOD_LABEL[p.method] ?? p.method,
                },
                {
                  key: 'receipt',
                  header: 'Receipt',
                  render: (p) => p.receiptNumber ?? '—',
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (p) => (
                    <span className={`pill ${statusTone(p.status)}`.trim()}>
                      {statusLabel(p.status)}
                    </span>
                  ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/payments"
                query={{ status, method, purpose, q }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
