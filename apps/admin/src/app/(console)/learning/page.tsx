import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listContents } from '@/lib/learning-api';
import { loadLearningOptions } from '@/lib/learning-options';
import {
  accessLabel,
  CONTENT_TYPES,
  deliveryLabel,
  linkMeta,
  sourceLabel,
  STATUSES,
  statusMeta,
  typeLabel,
} from '@/lib/learning';

export const metadata = { title: 'Learning' };

type SearchParams = Promise<{
  q?: string;
  status?: string;
  type?: string;
  categoryId?: string;
  broken?: string;
  page?: string;
}>;

export default async function LearningPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'learning.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Learning.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const status = STATUSES.find((s) => s === sp.status);
  const type = CONTENT_TYPES.find((t) => t === sp.type);
  const categoryId = sp.categoryId || undefined;
  const broken = sp.broken === 'true';

  const [{ data, error, response }, options] = await Promise.all([
    listContents({ page, limit: 20, q, status, type, categoryId, brokenLink: broken || undefined }),
    loadLearningOptions(),
  ]);
  const filtered = Boolean(q || status || type || categoryId || broken);

  return (
    <>
      <div className="page-head">
        <h1>Learning</h1>
        <p>
          Skill Labs: courses with lessons, and tutorials, toolkits, webinars, masterclasses and
          articles that open in the app, in an embedded player or on another site. Every change is
          recorded in the audit log.
        </p>
      </div>
      <section className="card" aria-label="Learning content">
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
                {STATUSES.map((s) => (
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
                {CONTENT_TYPES.map((t) => (
                  <option key={t} value={t}>
                    {typeLabel(t)}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              Category
              <select className="select" name="categoryId" defaultValue={categoryId ?? ''}>
                <option value="">Any</option>
                {options.categories.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
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
              <Link className="button secondary" href="/learning">
                Clear
              </Link>
            ) : null}
          </form>
          <span className="row-actions">
            <Link className="button" href="/learning/new">
              New item
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
              caption="Learning content"
              rows={data.data}
              rowKey={(c) => c.id}
              empty={filtered ? 'Nothing matches these filters.' : 'No Skill Labs yet.'}
              columns={[
                {
                  key: 'title',
                  header: 'Item',
                  render: (c) => (
                    <>
                      <Link href={`/learning/${c.id}`}>{c.title}</Link>
                      <div className="muted">
                        {typeLabel(c.type)} · {c.category.name}
                      </div>
                    </>
                  ),
                },
                { key: 'source', header: 'Source', render: (c) => sourceLabel(c.source) },
                { key: 'delivery', header: 'Delivery', render: (c) => deliveryLabel(c.delivery) },
                { key: 'access', header: 'Access', render: (c) => accessLabel(c.access) },
                {
                  key: 'status',
                  header: 'Status',
                  render: (c) => (
                    <span className={`pill ${statusMeta(c.status).tone}`.trim()}>
                      {statusMeta(c.status).label}
                    </span>
                  ),
                },
                { key: 'learners', header: 'Learners', render: (c) => c.enrolmentCount },
                {
                  key: 'link',
                  header: 'Link',
                  render: (c) =>
                    c.linkStatus === 'BROKEN' ? (
                      <span className={`pill ${linkMeta(c.linkStatus).tone}`}>Broken</span>
                    ) : (
                      '—'
                    ),
                },
                { key: 'updated', header: 'Updated', render: (c) => c.updatedAt.slice(0, 10) },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/learning"
                query={{ q, status, type, categoryId, broken: broken ? 'true' : undefined }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
