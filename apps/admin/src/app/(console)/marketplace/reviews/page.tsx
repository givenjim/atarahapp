import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listReviews } from '@/lib/marketplace-api';
import { REVIEW_STATUSES, statusTone, titleCase } from '@/lib/marketplace';
import { ReviewActions } from '../marketplace-actions-ui';

export const metadata = { title: 'Review moderation' };

type SearchParams = Promise<{ status?: string; page?: string }>;

export default async function ReviewsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'marketplace.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to review moderation.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const status = (REVIEW_STATUSES as readonly string[]).includes(sp.status ?? '')
    ? sp.status
    : undefined;
  const { data, error, response } = await listReviews({ page, limit: 20, status });

  return (
    <>
      <div className="page-head">
        <h1>Review moderation</h1>
        <p>
          Reviews come only from members with a closed request on that listing. Hide one that
          breaks the rules; it stops counting towards the seller&apos;s rating.
        </p>
      </div>
      <section className="card" aria-label="Reviews">
        <div className="toolbar">
          <nav className="filters" aria-label="Review status">
            <Link
              className={`button small ${status ? 'secondary' : ''}`.trim()}
              href="/marketplace/reviews"
            >
              All
            </Link>
            {REVIEW_STATUSES.map((s) => (
              <Link
                key={s}
                className={`button small ${s === status ? '' : 'secondary'}`.trim()}
                href={`/marketplace/reviews?status=${s}`}
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
              caption="Reviews"
              rows={data.data}
              rowKey={(r) => r.id}
              empty="No reviews yet."
              columns={[
                {
                  key: 'review',
                  header: 'Review',
                  render: (r) => (
                    <>
                      {'★'.repeat(r.rating)}
                      {'☆'.repeat(5 - r.rating)} · {r.reviewerName}
                      {r.body ? <p style={{ margin: '4px 0 0' }}>{r.body}</p> : null}
                    </>
                  ),
                },
                { key: 'listing', header: 'Listing', render: (r) => r.listingTitle },
                {
                  key: 'status',
                  header: 'Status',
                  render: (r) => (
                    <>
                      <span className={`pill ${statusTone(r.status)}`.trim()}>
                        {titleCase(r.status)}
                      </span>
                      {r.hiddenReason ? <div className="muted">{r.hiddenReason}</div> : null}
                    </>
                  ),
                },
                {
                  key: 'actions',
                  header: 'Actions',
                  render: (r) => <ReviewActions id={r.id} status={r.status} />,
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/marketplace/reviews"
                query={{ status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
