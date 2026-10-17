import Link from 'next/link';
import type { ReactNode } from 'react';

export interface Column<T> {
  key: string;
  header: string;
  render: (row: T) => ReactNode;
}

export interface PageMeta {
  page: number;
  limit: number;
  total: number;
}

/** Table for server-paginated data. It never slices rows itself: the API returns one page at a time. */
export function DataTable<T>({
  columns,
  rows,
  rowKey,
  empty = 'Nothing to show.',
  caption,
}: {
  columns: Column<T>[];
  rows: T[];
  rowKey: (row: T) => string;
  empty?: string;
  caption: string;
}) {
  if (rows.length === 0) return <p className="empty">{empty}</p>;
  return (
    <div className="table-wrap">
      <table className="data">
        <caption className="sr-only" style={{ position: 'absolute', left: -9999 }}>
          {caption}
        </caption>
        <thead>
          <tr>
            {columns.map((c) => (
              <th key={c.key} scope="col">
                {c.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={rowKey(r)}>
              {columns.map((c) => (
                <td key={c.key}>{c.render(r)}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export const pageCount = (m: PageMeta): number => Math.max(1, Math.ceil(m.total / m.limit));

/** Previous / next links that keep every other query parameter (filters) intact. */
export function Pagination({
  meta,
  basePath,
  query,
}: {
  meta: PageMeta;
  basePath: string;
  query: Record<string, string | undefined>;
}) {
  const pages = pageCount(meta);
  const href = (page: number) => {
    const params = new URLSearchParams();
    for (const [k, v] of Object.entries(query)) if (v) params.set(k, v);
    params.set('page', String(page));
    return `${basePath}?${params.toString()}`;
  };
  const from = meta.total === 0 ? 0 : (meta.page - 1) * meta.limit + 1;
  const to = Math.min(meta.total, meta.page * meta.limit);
  return (
    <nav className="pagination" aria-label="Pagination">
      <span>
        {from}–{to} of {meta.total}
      </span>
      <span className="links">
        {meta.page > 1 ? (
          <Link className="button secondary" href={href(meta.page - 1)} rel="prev">
            Previous
          </Link>
        ) : null}
        {meta.page < pages ? (
          <Link className="button secondary" href={href(meta.page + 1)} rel="next">
            Next
          </Link>
        ) : null}
      </span>
    </nav>
  );
}
