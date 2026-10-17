import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { can, currentAdmin } from '@/lib/admin';
import { api, errorOf } from '@/lib/api';

export const metadata = { title: 'Audit Logs' };

type SearchParams = Promise<{
  action?: string;
  entityType?: string;
  entityId?: string;
  actorId?: string;
  page?: string;
}>;

const clean = (v: string | undefined) => v?.trim() || undefined;

export default async function AuditLogsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'audit.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Audit Logs.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const filters = {
    action: clean(sp.action),
    entityType: clean(sp.entityType),
    entityId: clean(sp.entityId),
    actorId: clean(sp.actorId),
  };
  const { data, error, response } = await api().GET('/api/v1/admin/audit-logs', {
    params: { query: { page, limit: 20, ...filters } },
  });
  const filtered = Object.values(filters).some(Boolean);

  return (
    <>
      <div className="page-head">
        <h1>Audit Logs</h1>
        <p>A read-only record of sensitive actions. Entries cannot be edited or deleted.</p>
      </div>
      <section className="card" aria-label="Audit log">
        <form className="filters" role="search" method="get">
          <label className="field">
            Action
            <input
              className="input"
              name="action"
              defaultValue={filters.action ?? ''}
              placeholder="user.suspend"
            />
          </label>
          <label className="field">
            Entity type
            <input
              className="input"
              name="entityType"
              defaultValue={filters.entityType ?? ''}
              placeholder="user"
            />
          </label>
          <label className="field">
            Entity ID
            <input className="input" name="entityId" defaultValue={filters.entityId ?? ''} />
          </label>
          <label className="field">
            Actor ID
            <input className="input" name="actorId" defaultValue={filters.actorId ?? ''} />
          </label>
          <button className="button" type="submit">
            Apply
          </button>
          {filtered ? (
            <Link className="button secondary" href="/audit-logs">
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
              caption="Audit log entries"
              rows={data.data}
              rowKey={(e) => e.id}
              empty="No audit entries match these filters."
              columns={[
                {
                  key: 'when',
                  header: 'When',
                  render: (e) => new Date(e.createdAt).toLocaleString('en-KE'),
                },
                {
                  key: 'actor',
                  header: 'Actor',
                  render: (e) =>
                    e.actorName ?? (e.actorType === 'SYSTEM' ? 'System' : (e.actorId ?? '—')),
                },
                { key: 'action', header: 'Action', render: (e) => <code>{e.action}</code> },
                {
                  key: 'entity',
                  header: 'Entity',
                  render: (e) => (
                    <>
                      {e.entityType}
                      {e.entityId ? <div className="muted">{e.entityId}</div> : null}
                    </>
                  ),
                },
                {
                  key: 'change',
                  header: 'Change',
                  render: (e) =>
                    e.before || e.after ? (
                      <pre className="json">
                        {JSON.stringify({ before: e.before, after: e.after }, null, 1)}
                      </pre>
                    ) : (
                      '—'
                    ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/audit-logs"
                query={filters}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
