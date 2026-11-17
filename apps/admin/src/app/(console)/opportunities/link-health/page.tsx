import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { linkHealth } from '@/lib/opportunities-api';
import { LINK_RESULTS, linkMeta, statusMeta } from '@/lib/opportunities';

export const metadata = { title: 'Link health' };

type SearchParams = Promise<{ result?: string; page?: string }>;

export default async function LinkHealthPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'opportunity.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Opportunities.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const result = LINK_RESULTS.find((r) => r === sp.result) ?? 'BROKEN';
  const { data, error, response } = await linkHealth({ page, limit: 20, result });
  const counts = (
    data?.meta as { counts?: { broken: number; ok: number; unknown: number } } | undefined
  )?.counts;

  return (
    <>
      <div className="page-head">
        <h1>Link health</h1>
        <p>
          Once a week Atarah checks each application link. Broken links are only flagged here:
          nothing is unpublished or removed automatically. Open the listing to fix the address or
          close it.
        </p>
      </div>
      <nav className="tabs" aria-label="Filter by result">
        {LINK_RESULTS.map((r) => (
          <Link
            key={r}
            href={`/opportunities/link-health?result=${r}`}
            aria-current={r === result ? 'page' : undefined}
          >
            {linkMeta(r).label}
            {counts ? ` (${counts[r.toLowerCase() as 'broken' | 'ok' | 'unknown']})` : ''}
          </Link>
        ))}
      </nav>
      <section className="card" aria-label="Link health">
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Link health"
              rows={data.data}
              rowKey={(i) => i.opportunityId}
              empty={
                result === 'BROKEN'
                  ? 'No broken links. Everything checked answers.'
                  : 'Nothing here.'
              }
              columns={[
                {
                  key: 'title',
                  header: 'Opportunity',
                  render: (i) => (
                    <>
                      <Link href={`/opportunities/${i.opportunityId}`}>{i.title}</Link>
                      <div className="muted">{i.provider}</div>
                    </>
                  ),
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (i) => (
                    <span className={`pill ${statusMeta(i.status).tone}`.trim()}>
                      {statusMeta(i.status).label}
                    </span>
                  ),
                },
                {
                  key: 'url',
                  header: 'Link',
                  render: (i) => (
                    <span style={{ overflowWrap: 'anywhere' }}>{i.applicationUrl ?? '—'}</span>
                  ),
                },
                {
                  key: 'result',
                  header: 'Result',
                  render: (i) => (
                    <>
                      <span className={`pill ${linkMeta(i.linkStatus).tone}`.trim()}>
                        {linkMeta(i.linkStatus).label}
                      </span>
                      {i.httpStatus ? <div className="muted">HTTP {i.httpStatus}</div> : null}
                      {i.error ? <div className="muted">{i.error}</div> : null}
                    </>
                  ),
                },
                {
                  key: 'checked',
                  header: 'Checked',
                  render: (i) => (i.checkedAt ? i.checkedAt.slice(0, 10) : '—'),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/opportunities/link-health"
                query={{ result }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
