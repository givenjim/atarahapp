import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listCases } from '@/lib/moderation-api';
import {
  BACKLOG_HOURS,
  CASE_STATUSES,
  PRIORITIES,
  TARGET_LABELS,
  formatAge,
  isBacklog,
  priorityTone,
  reasonLabel,
  statusLabel,
  statusTone,
} from '@/lib/moderation';

export const metadata = { title: 'Community & Reports' };

type SearchParams = Promise<{
  status?: string;
  priority?: string;
  targetType?: string;
  view?: string;
  page?: string;
}>;

const pick = (v: string | undefined, allowed: readonly string[]) =>
  v && allowed.includes(v) ? v : undefined;

export default async function CommunityPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'report.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Community &amp; Reports.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const status = pick(sp.status, CASE_STATUSES);
  const priority = pick(sp.priority, PRIORITIES);
  const targetType = pick(sp.targetType, Object.keys(TARGET_LABELS));
  // view: open (default), backlog (open and older than 48 h), mine (assigned to me), all
  const view = pick(sp.view, ['open', 'backlog', 'mine', 'all']) ?? 'open';

  const { data, error, response } = await listCases({
    page,
    limit: 20,
    status,
    priority,
    targetType,
    open: view === 'all' ? undefined : true,
    olderThanHours: view === 'backlog' ? BACKLOG_HOURS : undefined,
    assigneeId: view === 'mine' ? me.id : undefined,
  });

  const filtered = Boolean(status || priority || targetType || view !== 'open');

  return (
    <>
      <div className="page-head">
        <h1>Community &amp; Reports</h1>
        <p>
          One case per reported post, comment, account or group, most urgent first. Cases waiting
          more than {BACKLOG_HOURS} hours are flagged as backlog. Every decision is recorded in the
          audit log.
        </p>
      </div>
      <section className="card" aria-label="Moderation cases">
        <form className="filters" role="search" method="get">
          <label className="field">
            Show
            <select className="select" name="view" defaultValue={view}>
              <option value="open">Open cases</option>
              <option value="backlog">Backlog (over {BACKLOG_HOURS} h)</option>
              <option value="mine">Assigned to me</option>
              <option value="all">All cases</option>
            </select>
          </label>
          <label className="field">
            Status
            <select className="select" name="status" defaultValue={status ?? ''}>
              <option value="">Any</option>
              {CASE_STATUSES.map((s) => (
                <option key={s} value={s}>
                  {statusLabel(s)}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            Priority
            <select className="select" name="priority" defaultValue={priority ?? ''}>
              <option value="">Any</option>
              {PRIORITIES.map((p) => (
                <option key={p} value={p}>
                  {statusLabel(p)}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            Reported item
            <select className="select" name="targetType" defaultValue={targetType ?? ''}>
              <option value="">Any</option>
              {Object.entries(TARGET_LABELS).map(([k, label]) => (
                <option key={k} value={k}>
                  {label}
                </option>
              ))}
            </select>
          </label>
          <button className="button" type="submit">
            Apply
          </button>
          {filtered ? (
            <Link className="button secondary" href="/community">
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
              caption="Moderation cases"
              rows={data.data}
              rowKey={(c) => c.id}
              empty={filtered ? 'No cases match these filters.' : 'No open cases. All clear.'}
              columns={[
                {
                  key: 'content',
                  header: 'Reported',
                  render: (c) => (
                    <>
                      <Link href={`/community/${c.id}`}>{c.preview?.trim() || 'No preview'}</Link>
                      <div className="muted">{TARGET_LABELS[c.targetType] ?? c.targetType}</div>
                    </>
                  ),
                },
                {
                  key: 'reports',
                  header: 'Reports',
                  render: (c) => c.reportCount,
                },
                {
                  key: 'author',
                  header: 'Author',
                  render: (c) =>
                    c.author ? (
                      <>
                        <Link href={`/users/${c.author.id}`}>{c.author.displayName}</Link>
                        {c.author.handle ? <div className="muted">@{c.author.handle}</div> : null}
                      </>
                    ) : (
                      '—'
                    ),
                },
                { key: 'reason', header: 'Top reason', render: (c) => reasonLabel(c.topReason) },
                {
                  key: 'priority',
                  header: 'Priority',
                  render: (c) => (
                    <span className={`pill ${priorityTone(c.priority)}`.trim()}>
                      {statusLabel(c.priority)}
                    </span>
                  ),
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (c) => (
                    <span className={`pill ${statusTone(c.status)}`.trim()}>
                      {statusLabel(c.status)}
                    </span>
                  ),
                },
                {
                  key: 'assignee',
                  header: 'Assignee',
                  render: (c) => (c.assignee ? c.assignee.displayName : 'Unassigned'),
                },
                {
                  key: 'age',
                  header: 'Age',
                  render: (c) => (
                    <>
                      {formatAge(c.ageHours)}
                      {isBacklog(c.ageHours, c.status) ? (
                        <>
                          {' '}
                          <span className="pill danger">Backlog</span>
                        </>
                      ) : null}
                    </>
                  ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/community"
                query={{ status, priority, targetType, view: view === 'open' ? undefined : view }}
              />
            ) : null}
          </>
        )}
      </section>
      <p className="muted">
        Reporter names are shown on each case. Reporters are only ever told that a report was
        reviewed, never what was decided or who decided it.
      </p>
    </>
  );
}
