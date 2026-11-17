import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { formatWhen } from '@/lib/broadcasts';
import { listPrivacyRequests } from '@/lib/broadcasts-api';
import {
  dueLabel,
  parsePrivacyKind,
  PRIVACY_KIND_LABEL,
  PRIVACY_KINDS,
  privacyStatusMeta,
} from '@/lib/help';

export const metadata = { title: 'Privacy requests' };

type SearchParams = Promise<{ kind?: string; status?: string; page?: string }>;

export default async function PrivacyRequestsPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'user.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Privacy requests.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const kind = parsePrivacyKind(sp.kind);
  const status = sp.status?.trim().toUpperCase().slice(0, 20) || undefined;
  const { data, error, response } = await listPrivacyRequests({ page, limit: 20, kind, status });

  return (
    <>
      <div className="page-head">
        <h1>Privacy requests</h1>
        <p>
          Data exports and account deletions that members asked for. A deleted account shows only
          its id: the name is removed when the account is purged after the 30-day grace period.
        </p>
      </div>
      <section className="card" aria-label="Privacy requests">
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            <label className="field">
              Type
              <select className="select" name="kind" defaultValue={kind ?? ''}>
                {PRIVACY_KINDS.map((k) => (
                  <option key={k.value} value={k.value}>
                    {k.label}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              Status
              <input
                className="input"
                name="status"
                defaultValue={status ?? ''}
                placeholder="e.g. READY, PURGED"
                maxLength={20}
              />
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {kind || status ? (
              <Link className="button secondary" href="/privacy-requests">
                Clear
              </Link>
            ) : null}
          </form>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Privacy requests"
              rows={data.data}
              rowKey={(r) => `${r.kind}-${r.id}`}
              empty={
                kind || status ? 'No requests match those filters.' : 'No privacy requests yet.'
              }
              columns={[
                {
                  key: 'kind',
                  header: 'Type',
                  render: (r) => PRIVACY_KIND_LABEL[r.kind] ?? r.kind,
                },
                {
                  key: 'member',
                  header: 'Member',
                  render: (r) => (
                    <>
                      {r.memberName ?? <span className="muted">Removed</span>}
                      <div className="muted">
                        <Link href={`/users/${r.userId}`}>{r.userId.slice(0, 8)}…</Link>
                      </div>
                    </>
                  ),
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (r) => (
                    <span className={`pill ${privacyStatusMeta(r.status).tone}`.trim()}>
                      {privacyStatusMeta(r.status).label}
                    </span>
                  ),
                },
                { key: 'requested', header: 'Requested', render: (r) => formatWhen(r.requestedAt) },
                {
                  key: 'due',
                  header: 'Due',
                  render: (r) =>
                    r.dueAt ? (
                      <>
                        {formatWhen(r.dueAt)}
                        <div className="muted">{dueLabel(r.kind)}</div>
                      </>
                    ) : (
                      '—'
                    ),
                },
                { key: 'done', header: 'Finished', render: (r) => formatWhen(r.completedAt) },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/privacy-requests"
                query={{ kind, status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
