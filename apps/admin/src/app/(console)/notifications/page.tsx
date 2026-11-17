import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  BROADCAST_FILTERS,
  broadcastStatusMeta,
  formatWhen,
  parseBroadcastStatus,
  targetSummary,
} from '@/lib/broadcasts';
import { listBroadcasts } from '@/lib/broadcasts-api';

export const metadata = { title: 'Notification broadcasts' };

type SearchParams = Promise<{ status?: string; page?: string }>;

export default async function BroadcastsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'notification.broadcast')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Notifications.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const status = parseBroadcastStatus(sp.status);
  const { data, error, response } = await listBroadcasts({ page, limit: 20, status });

  return (
    <>
      <div className="page-head">
        <h1>Notifications</h1>
        <p>
          Platform announcements to members. A broadcast appears in each member’s notifications, and
          as a push or email to those who have those channels on for its category.
        </p>
      </div>
      <section className="card" aria-label="Broadcasts">
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            <label className="field">
              Status
              <select className="select" name="status" defaultValue={status ?? ''}>
                {BROADCAST_FILTERS.map((s) => (
                  <option key={s.value} value={s.value}>
                    {s.label}
                  </option>
                ))}
              </select>
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {status ? (
              <Link className="button secondary" href="/notifications">
                Clear
              </Link>
            ) : null}
          </form>
          <Link className="button" href="/notifications/new">
            New broadcast
          </Link>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Broadcasts"
              rows={data.data}
              rowKey={(b) => b.id}
              empty={status ? 'No broadcasts with that status.' : 'No broadcasts yet.'}
              columns={[
                {
                  key: 'title',
                  header: 'Notification',
                  render: (b) => (
                    <>
                      <Link href={`/notifications/${b.id}`}>{b.title}</Link>
                      <div className="muted">
                        {b.body.length > 90 ? `${b.body.slice(0, 89)}…` : b.body}
                      </div>
                    </>
                  ),
                },
                { key: 'target', header: 'Audience', render: (b) => targetSummary(b) },
                {
                  key: 'status',
                  header: 'Status',
                  render: (b) => (
                    <span className={`pill ${broadcastStatusMeta(b.status).tone}`.trim()}>
                      {broadcastStatusMeta(b.status).label}
                    </span>
                  ),
                },
                { key: 'count', header: 'Recipients', render: (b) => b.recipientCount },
                {
                  key: 'when',
                  header: 'When',
                  render: (b) =>
                    b.status === 'SENT'
                      ? formatWhen(b.sentAt)
                      : formatWhen(b.scheduledAt ?? b.createdAt),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/notifications"
                query={{ status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
