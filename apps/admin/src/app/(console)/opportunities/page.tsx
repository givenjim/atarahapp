import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listOpportunities } from '@/lib/opportunities-api';
import {
  formatDeadline,
  OPP_STATUSES,
  OPP_TYPES,
  statusMeta,
  titleCase,
  trustMeta,
} from '@/lib/opportunities';
import { loadFormOptions } from '@/lib/opportunity-options';

export const metadata = { title: 'Opportunities' };

type SearchParams = Promise<{
  q?: string;
  status?: string;
  type?: string;
  providerId?: string;
  broken?: string;
  page?: string;
}>;

export default async function OpportunitiesPage({ searchParams }: { searchParams: SearchParams }) {
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
  const q = sp.q?.trim() || undefined;
  const status = OPP_STATUSES.find((s) => s === sp.status);
  const type = OPP_TYPES.find((t) => t === sp.type);
  const providerId = sp.providerId || undefined;
  const broken = sp.broken === 'true';

  const [{ data, error, response }, options] = await Promise.all([
    listOpportunities({
      page,
      limit: 20,
      q,
      status,
      type,
      providerId,
      brokenLink: broken || undefined,
    }),
    loadFormOptions(),
  ]);
  const filtered = Boolean(q || status || type || providerId || broken);

  return (
    <>
      <div className="page-head">
        <h1>Opportunities</h1>
        <p>
          Listings members discover, save and track. Providers’ submissions wait in the review
          queue. Every change is recorded in the audit log.
        </p>
      </div>
      <section className="card" aria-label="Opportunities">
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            <label className="field">
              Search
              <input
                className="input"
                type="search"
                name="q"
                defaultValue={q ?? ''}
                placeholder="Title or provider"
              />
            </label>
            <label className="field">
              Status
              <select className="select" name="status" defaultValue={status ?? ''}>
                <option value="">Any</option>
                {OPP_STATUSES.map((s) => (
                  <option key={s} value={s}>
                    {statusMeta(s).label}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              Type
              <select className="select" name="type" defaultValue={type ?? ''}>
                <option value="">Any</option>
                {OPP_TYPES.map((t) => (
                  <option key={t} value={t}>
                    {titleCase(t)}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              Provider
              <select className="select" name="providerId" defaultValue={providerId ?? ''}>
                <option value="">Any</option>
                {options.providers.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              <span>
                <input type="checkbox" name="broken" value="true" defaultChecked={broken} /> Broken
                link
              </span>
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {filtered ? (
              <Link className="button secondary" href="/opportunities">
                Clear
              </Link>
            ) : null}
          </form>
          <span className="row-actions">
            <Link
              className={`button ${status === 'PENDING_REVIEW' ? '' : 'secondary'}`.trim()}
              href="/opportunities?status=PENDING_REVIEW"
            >
              Review queue
            </Link>
            <Link className="button" href="/opportunities/new">
              New opportunity
            </Link>
          </span>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Opportunities"
              rows={data.data}
              rowKey={(o) => o.id}
              empty={
                status === 'PENDING_REVIEW'
                  ? 'Nothing is waiting for review.'
                  : filtered
                    ? 'No opportunities match these filters.'
                    : 'No opportunities yet.'
              }
              columns={[
                {
                  key: 'title',
                  header: 'Opportunity',
                  render: (o) => (
                    <>
                      <Link href={`/opportunities/${o.id}`}>{o.title}</Link>
                      <div className="muted">{titleCase(o.type)}</div>
                    </>
                  ),
                },
                { key: 'provider', header: 'Provider', render: (o) => o.provider.name },
                {
                  key: 'status',
                  header: 'Status',
                  render: (o) => (
                    <span className={`pill ${statusMeta(o.status).tone}`.trim()}>
                      {statusMeta(o.status).label}
                    </span>
                  ),
                },
                {
                  key: 'trust',
                  header: 'Trust',
                  render: (o) => (
                    <span className={`pill ${trustMeta(o.trust).tone}`.trim()}>
                      {trustMeta(o.trust).label}
                    </span>
                  ),
                },
                {
                  key: 'deadline',
                  header: 'Deadline',
                  render: (o) => formatDeadline(o.deadlineAt),
                },
                { key: 'trackers', header: 'Tracking', render: (o) => o.trackerCount },
                {
                  key: 'link',
                  header: 'Link',
                  render: (o) =>
                    o.linkStatus === 'BROKEN' ? <span className="pill danger">Broken</span> : '—',
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/opportunities"
                query={{
                  q,
                  status,
                  type,
                  providerId,
                  broken: broken ? 'true' : undefined,
                }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
