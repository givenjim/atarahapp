import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listReports } from '@/lib/marketplace-api';
import { REPORT_STATUSES, statusTone, titleCase } from '@/lib/marketplace';
import { ReportActions } from '../marketplace-actions-ui';

export const metadata = { title: 'Reported listings' };

type SearchParams = Promise<{ status?: string; page?: string }>;

export default async function ReportsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'marketplace.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to reported listings.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const status = (REPORT_STATUSES as readonly string[]).includes(sp.status ?? '')
    ? sp.status
    : 'OPEN';
  const { data, error, response } = await listReports({ page, limit: 20, status });

  return (
    <>
      <div className="page-head">
        <h1>Reported listings</h1>
        <p>
          Members report listings that look wrong. Taking a listing down answers every open report
          on it at once and tells the seller why.
        </p>
      </div>
      <section className="card" aria-label="Reports">
        <div className="toolbar">
          <nav className="filters" aria-label="Report status">
            {REPORT_STATUSES.map((s) => (
              <Link
                key={s}
                className={`button small ${s === status ? '' : 'secondary'}`.trim()}
                href={`/marketplace/reports?status=${s}`}
                aria-current={s === status ? 'page' : undefined}
              >
                {titleCase(s)}
              </Link>
            ))}
          </nav>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Reported listings"
              rows={data.data}
              rowKey={(r) => r.id}
              empty="No reports here."
              columns={[
                {
                  key: 'listing',
                  header: 'Listing',
                  render: (r) => (
                    <>
                      <strong>{r.listingTitle}</strong>
                      <div className="muted">
                        {r.sellerName} · {titleCase(r.listingStatus)}
                      </div>
                    </>
                  ),
                },
                {
                  key: 'report',
                  header: 'Report',
                  render: (r) => (
                    <>
                      {titleCase(r.reason)}
                      {r.note ? <div className="muted">{r.note}</div> : null}
                      <div className="muted">By {r.reporterName}</div>
                    </>
                  ),
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (r) => (
                    <>
                      <span className={`pill ${statusTone(r.status)}`.trim()}>
                        {titleCase(r.status)}
                      </span>
                      {r.resolution ? <div className="muted">{r.resolution}</div> : null}
                    </>
                  ),
                },
                {
                  key: 'actions',
                  header: 'Actions',
                  render: (r) =>
                    r.status === 'OPEN' ? (
                      <ReportActions id={r.id} title={r.listingTitle} />
                    ) : null,
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/marketplace/reports"
                query={{ status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
