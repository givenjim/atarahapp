import Link from 'next/link';
import { DataTable } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listHelpArticles } from '@/lib/help-api';
import { PUBLISHED_META } from '@/lib/help';
import { ArticleRowActions } from './article-row-actions';

export const metadata = { title: 'Help articles' };

type SearchParams = Promise<{ q?: string }>;

export default async function HelpArticlesPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'help.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Help articles.
      </div>
    );
  }
  const q = sp.q?.trim() || undefined;
  const { data, error, response } = await listHelpArticles({ page: 1, limit: 100, q });
  const rows = data?.data ?? [];
  const ordered = [...rows].sort((a, b) => a.sortOrder - b.sortOrder);

  return (
    <>
      <div className="page-head">
        <h1>Help articles</h1>
        <p>
          The articles members read in Help. Only published articles are shown in the app; the order
          here is the order members see.
        </p>
      </div>
      <section className="card" aria-label="Help articles">
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            <label className="field">
              Search
              <input
                className="input"
                type="search"
                name="q"
                defaultValue={q ?? ''}
                placeholder="Title or text"
              />
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {q ? (
              <Link className="button secondary" href="/content">
                Clear
              </Link>
            ) : null}
          </form>
          <Link className="button" href="/content/new">
            New article
          </Link>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <DataTable
            caption="Help articles"
            rows={ordered}
            rowKey={(a) => a.id}
            empty={q ? 'No articles match that search.' : 'No help articles yet.'}
            columns={[
              {
                key: 'title',
                header: 'Article',
                render: (a) => (
                  <>
                    <Link href={`/content/${a.id}`}>{a.title}</Link>
                    <div className="muted">/{a.slug}</div>
                  </>
                ),
              },
              {
                key: 'status',
                header: 'Status',
                render: (a) => (
                  <span className={`pill ${PUBLISHED_META(a.published).tone}`.trim()}>
                    {PUBLISHED_META(a.published).label}
                  </span>
                ),
              },
              { key: 'order', header: 'Order', render: (a) => a.sortOrder },
              {
                key: 'actions',
                header: 'Actions',
                render: (a) => (
                  <ArticleRowActions
                    id={a.id}
                    title={a.title}
                    published={a.published}
                    items={ordered.map((x) => ({ id: x.id, sortOrder: x.sortOrder }))}
                    reorderable={!q}
                  />
                ),
              },
            ]}
          />
        )}
      </section>
    </>
  );
}
