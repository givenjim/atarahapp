import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listAdminArticles } from '@/lib/articles-api';
import { parseStatus, STATUS_FILTERS, statusPill } from '@/lib/articles';
import { NewArticleForm } from './new-article-form';

export const metadata = { title: 'Articles' };

type SearchParams = Promise<{ status?: string; q?: string; page?: string }>;

export default async function ArticlesPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'article.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Articles.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const status = parseStatus(sp.status);

  const { data, error, response } = await listAdminArticles({ page, limit: 20, q, status });

  const tabHref = (value: string) => {
    const params = new URLSearchParams();
    if (value) params.set('status', value);
    if (q) params.set('q', q);
    const s = params.toString();
    return s ? `/articles?${s}` : '/articles';
  };

  return (
    <>
      <div className="page-head">
        <h1>Articles</h1>
        <p>
          Write, review and publish articles for the Atarah app. Nothing reaches members until you
          publish it. Every change is recorded in the audit log.
        </p>
      </div>
      <section className="card" aria-label="Articles">
        <nav className="tabs" aria-label="Filter by status">
          {STATUS_FILTERS.map((f) => (
            <Link
              key={f.value || 'all'}
              className="tab"
              href={tabHref(f.value)}
              aria-current={(status ?? '') === f.value ? 'page' : undefined}
            >
              {f.label}
            </Link>
          ))}
        </nav>
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            {status ? <input type="hidden" name="status" value={status} /> : null}
            <label className="field">
              Search
              <input
                className="input"
                type="search"
                name="q"
                defaultValue={q ?? ''}
                placeholder="Title or byline"
              />
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {q ? (
              <Link
                className="button secondary"
                href={status ? `/articles?status=${status}` : '/articles'}
              >
                Clear
              </Link>
            ) : null}
          </form>
          <NewArticleForm />
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Articles"
              rows={data.data}
              rowKey={(a) => a.id}
              empty={q || status ? 'No articles match these filters.' : 'No articles yet.'}
              columns={[
                {
                  key: 'title',
                  header: 'Title',
                  render: (a) => (
                    <>
                      <Link href={`/articles/${a.id}`}>{a.title}</Link>
                      {a.featured ? (
                        <>
                          {' '}
                          <span className="pill success">Featured</span>
                        </>
                      ) : null}
                    </>
                  ),
                },
                { key: 'author', header: 'Byline', render: (a) => a.authorName },
                {
                  key: 'status',
                  header: 'Status',
                  render: (a) => {
                    const p = statusPill(a.status, a.scheduled);
                    return <span className={`pill ${p.tone}`.trim()}>{p.label}</span>;
                  },
                },
                { key: 'source', header: 'Source', render: (a) => a.source.toLowerCase() },
                {
                  key: 'published',
                  header: 'Publishes',
                  render: (a) =>
                    a.publishedAt ? new Date(a.publishedAt).toLocaleString('en-KE') : '—',
                },
                {
                  key: 'updated',
                  header: 'Updated',
                  render: (a) => new Date(a.updatedAt).toLocaleDateString('en-KE'),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/articles"
                query={{ q, status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
