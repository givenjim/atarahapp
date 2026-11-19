import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listListings } from '@/lib/marketplace-api';
import { LISTING_STATUSES, statusTone, titleCase } from '@/lib/marketplace';
import { ListingActions } from './marketplace-actions-ui';

export const metadata = { title: 'Marketplace review queue' };

type SearchParams = Promise<{ status?: string; q?: string; page?: string }>;

export default async function ListingQueuePage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'marketplace.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to the marketplace review queue.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const status = (LISTING_STATUSES as readonly string[]).includes(sp.status ?? '')
    ? sp.status
    : 'UNDER_REVIEW';
  const { data, error, response } = await listListings({ page, limit: 20, status, q });

  return (
    <>
      <div className="page-head">
        <h1>Listing review queue</h1>
        <p>
          Approve a listing to put it on the marketplace, or reject it with a reason the seller can
          act on. Suspending hides a live listing at once. Every decision is audited.
        </p>
      </div>
      <section className="card" aria-label="Listings">
        <div className="toolbar">
          <nav className="filters" aria-label="Listing status">
            {LISTING_STATUSES.map((s) => (
              <Link
                key={s}
                className={`button small ${s === status ? '' : 'secondary'}`.trim()}
                href={`/marketplace?status=${s}`}
                aria-current={s === status ? 'page' : undefined}
              >
                {titleCase(s)}
              </Link>
            ))}
          </nav>
          <form className="filters" role="search" method="get">
            <input type="hidden" name="status" value={status} />
            <label className="field">
              Search
              <input
                className="input"
                type="search"
                name="q"
                defaultValue={q ?? ''}
                placeholder="Title, seller or email"
              />
            </label>
            <button className="button" type="submit">
              Apply
            </button>
          </form>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Listings"
              rows={data.data}
              rowKey={(l) => l.id}
              empty={`No ${titleCase(status ?? 'UNDER_REVIEW').toLowerCase()} listings.`}
              columns={[
                {
                  key: 'listing',
                  header: 'Listing',
                  render: (l) => (
                    <details>
                      <summary>
                        <strong>{l.title}</strong> · {l.type === 'PRODUCT' ? 'Product' : 'Service'} ·{' '}
                        {l.categoryName}
                      </summary>
                      <p>{l.description}</p>
                      {l.includedItems.length ? (
                        <ul>
                          {l.includedItems.map((i) => (
                            <li key={i}>{i}</li>
                          ))}
                        </ul>
                      ) : null}
                      <p className="muted">
                        {l.priceLabel} · {l.media.length} picture{l.media.length === 1 ? '' : 's'}
                      </p>
                      {l.media.length ? (
                        <p>
                          {l.media.map((m) =>
                            m.url ? (
                              <a key={m.id} href={m.url} target="_blank" rel="noopener noreferrer">
                                Picture{' '}
                              </a>
                            ) : null,
                          )}
                        </p>
                      ) : null}
                      {l.rejectionReason ? (
                        <p className="muted">Rejected: {l.rejectionReason}</p>
                      ) : null}
                      {l.suspendedReason ? (
                        <p className="muted">Suspended: {l.suspendedReason}</p>
                      ) : null}
                    </details>
                  ),
                },
                {
                  key: 'seller',
                  header: 'Seller',
                  render: (l) => (
                    <>
                      {l.seller.displayName}
                      <div className="muted">
                        {l.sellerApprovedBefore} approved before
                        {l.sellerStatus === 'SUSPENDED' ? ' · suspended' : ''}
                      </div>
                    </>
                  ),
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (l) => (
                    <>
                      <span className={`pill ${statusTone(l.status)}`.trim()}>
                        {titleCase(l.status)}
                      </span>
                      {l.openReports > 0 ? (
                        <div className="muted">{l.openReports} open report(s)</div>
                      ) : null}
                      {l.featured ? <div className="muted">Featured</div> : null}
                    </>
                  ),
                },
                {
                  key: 'actions',
                  header: 'Actions',
                  render: (l) => (
                    <ListingActions
                      id={l.id}
                      title={l.title}
                      status={l.status}
                      featured={l.featured}
                    />
                  ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/marketplace"
                query={{ status, q }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
