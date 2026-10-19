import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listAdminProjects } from '@/lib/portfolio-api';

export const metadata = { title: 'Portfolio' };

type SearchParams = Promise<{ q?: string; hiddenOnly?: string; page?: string }>;

export default async function PortfolioPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'moderation.act')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Portfolio.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const hiddenOnly = sp.hiddenOnly === 'true';

  const { data, error, response } = await listAdminProjects({
    page,
    limit: 20,
    q,
    hiddenOnly: hiddenOnly || undefined,
  });

  return (
    <>
      <div className="page-head">
        <h1>Portfolio</h1>
        <p>
          Published portfolio projects. Hide a project that breaks the rules and restore it if that
          was a mistake. Every change is recorded in the audit log.
        </p>
      </div>
      <section className="card" aria-label="Portfolio projects">
        <form className="filters" role="search" method="get">
          <label className="field">
            Search
            <input
              className="input"
              type="search"
              name="q"
              defaultValue={q ?? ''}
              placeholder="Project title or owner"
            />
          </label>
          <label className="field">
            <span>
              <input type="checkbox" name="hiddenOnly" value="true" defaultChecked={hiddenOnly} />{' '}
              Hidden only
            </span>
          </label>
          <button className="button" type="submit">
            Apply
          </button>
          {q || hiddenOnly ? (
            <Link className="button secondary" href="/portfolio">
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
              caption="Portfolio projects"
              rows={data.data}
              rowKey={(p) => p.id}
              empty={
                q || hiddenOnly ? 'No projects match these filters.' : 'No published projects yet.'
              }
              columns={[
                {
                  key: 'title',
                  header: 'Project',
                  render: (p) => <Link href={`/portfolio/${p.id}`}>{p.title}</Link>,
                },
                {
                  key: 'owner',
                  header: 'Owner',
                  render: (p) => (
                    <>
                      <Link href={`/users/${p.ownerUserId}`}>{p.ownerName}</Link>
                      {p.ownerHandle ? <div className="muted">@{p.ownerHandle}</div> : null}
                    </>
                  ),
                },
                { key: 'category', header: 'Category', render: (p) => p.category.toLowerCase() },
                { key: 'media', header: 'Media', render: (p) => p.mediaCount },
                {
                  key: 'status',
                  header: 'Status',
                  render: (p) => (
                    <span className={`pill ${p.hidden ? 'danger' : 'success'}`}>
                      {p.hidden ? 'Hidden' : 'Visible'}
                    </span>
                  ),
                },
                {
                  key: 'updated',
                  header: 'Updated',
                  render: (p) => new Date(p.updatedAt).toLocaleDateString('en-KE'),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/portfolio"
                query={{ q, hiddenOnly: hiddenOnly ? 'true' : undefined }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
