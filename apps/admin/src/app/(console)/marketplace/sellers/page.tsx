import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listSellers } from '@/lib/marketplace-api';
import { SELLER_STATUSES, statusTone, titleCase } from '@/lib/marketplace';
import { SellerActions } from '../marketplace-actions-ui';

export const metadata = { title: 'Sellers' };

type SearchParams = Promise<{ q?: string; status?: string; page?: string }>;

export default async function SellersPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'seller.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to sellers.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const status = (SELLER_STATUSES as readonly string[]).includes(sp.status ?? '')
    ? sp.status
    : undefined;
  const { data, error, response } = await listSellers({ page, limit: 20, q, status });

  return (
    <>
      <div className="page-head">
        <h1>Sellers</h1>
        <p>
          Suspending a seller hides their live listings and stops them replying. Marking a seller
          with a clean history lets their listings go live without review.
        </p>
      </div>
      <section className="card" aria-label="Sellers">
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            <label className="field">
              Search
              <input
                className="input"
                type="search"
                name="q"
                defaultValue={q ?? ''}
                placeholder="Name, handle or email"
              />
            </label>
            <label className="field">
              Status
              <select className="input" name="status" defaultValue={status ?? ''}>
                <option value="">All</option>
                {SELLER_STATUSES.map((s) => (
                  <option key={s} value={s}>
                    {titleCase(s)}
                  </option>
                ))}
              </select>
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {q || status ? (
              <Link className="button secondary" href="/marketplace/sellers">
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
              caption="Sellers"
              rows={data.data}
              rowKey={(s) => s.id}
              empty="No sellers match."
              columns={[
                {
                  key: 'seller',
                  header: 'Seller',
                  render: (s) => (
                    <>
                      <strong>{s.displayName}</strong>
                      <div className="muted">{s.email}</div>
                    </>
                  ),
                },
                {
                  key: 'stats',
                  header: 'Activity',
                  render: (s) => (
                    <>
                      {s.liveListings} live · {s.underReviewListings} in review
                      <div className="muted">
                        {s.ratingAverage === null || s.ratingAverage === undefined
                          ? 'No rating yet'
                          : `${s.ratingAverage} (${s.ratingCount})`}{' '}
                        · {s.completedCount} completed · {s.openReports} open report(s)
                      </div>
                    </>
                  ),
                },
                {
                  key: 'terms',
                  header: 'Terms',
                  render: (s) => (
                    <>
                      {s.termsVersion}
                      <div className="muted">
                        {new Date(s.termsAcceptedAt).toISOString().slice(0, 10)}
                      </div>
                    </>
                  ),
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (s) => (
                    <>
                      <span className={`pill ${statusTone(s.status)}`.trim()}>
                        {titleCase(s.status)}
                      </span>
                      {s.canPublishDirectly ? (
                        <div className="muted">Publishes without review</div>
                      ) : null}
                      {s.suspendedReason ? <div className="muted">{s.suspendedReason}</div> : null}
                    </>
                  ),
                },
                {
                  key: 'actions',
                  header: 'Actions',
                  render: (s) => (
                    <SellerActions
                      id={s.id}
                      name={s.displayName}
                      status={s.status}
                      canPublishDirectly={s.canPublishDirectly}
                    />
                  ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/marketplace/sellers"
                query={{ q, status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
