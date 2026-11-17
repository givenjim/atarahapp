import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { getCase } from '@/lib/moderation-api';
import {
  TARGET_LABELS,
  actionMeta,
  formatAge,
  isBacklog,
  priorityTone,
  reasonLabel,
  statusLabel,
  statusTone,
} from '@/lib/moderation';
import { CaseActions } from './case-actions';

export const metadata = { title: 'Moderation case' };

const when = (iso: string) => new Date(iso).toLocaleString('en-KE');

export default async function CasePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'report.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Community &amp; Reports.
      </div>
    );
  }
  const { data, response } = await getCase(id);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the case (${response.status}).`);
  }
  const c = data.data;
  const target = TARGET_LABELS[c.targetType] ?? c.targetType;
  const canResolve = can(me.permissions, 'report.resolve');
  const canAct = canResolve && can(me.permissions, 'moderation.act');
  const ownContent = c.author?.id === me.id;

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/community">← All cases</Link>
        </p>
        <h1>
          {target} report{c.reportCount === 1 ? '' : 's'} ({c.reportCount})
        </h1>
      </div>

      <section className="card" aria-label="Case">
        <dl className="facts">
          <dt>Status</dt>
          <dd>
            <span className={`pill ${statusTone(c.status)}`.trim()}>{statusLabel(c.status)}</span>{' '}
            <span className={`pill ${priorityTone(c.priority)}`.trim()}>
              {statusLabel(c.priority)} priority
            </span>
            {isBacklog(c.ageHours, c.status) ? (
              <>
                {' '}
                <span className="pill danger">Backlog</span>
              </>
            ) : null}
          </dd>
          <dt>Top reason</dt>
          <dd>{reasonLabel(c.topReason)}</dd>
          <dt>Author</dt>
          <dd>
            {c.author ? (
              <>
                <Link href={`/users/${c.author.id}`}>{c.author.displayName}</Link>
                {c.author.handle ? <span className="muted"> · @{c.author.handle}</span> : null}
              </>
            ) : (
              '—'
            )}
          </dd>
          <dt>Assignee</dt>
          <dd>{c.assignee ? c.assignee.displayName : 'Unassigned'}</dd>
          <dt>Opened</dt>
          <dd>
            {when(c.createdAt)} <span className="muted">· {formatAge(c.ageHours)} ago</span>
          </dd>
          {c.resolvedAt ? (
            <>
              <dt>Closed</dt>
              <dd>{when(c.resolvedAt)}</dd>
            </>
          ) : null}
        </dl>
      </section>

      <section className="card" aria-label="Reported content" style={{ padding: 20 }}>
        <h2>Reported {target.toLowerCase()}</h2>
        {!c.content.exists ? (
          <p className="muted">The author has deleted this content.</p>
        ) : (
          <>
            <p>
              {c.content.status ? (
                <span className={`pill ${c.content.status === 'VISIBLE' ? 'success' : 'danger'}`}>
                  {statusLabel(c.content.status)}
                </span>
              ) : null}
              {c.content.createdAt ? (
                <span className="muted"> {when(c.content.createdAt)}</span>
              ) : null}
            </p>
            <blockquote className="quote">{c.content.text ?? 'No text.'}</blockquote>
            {c.content.postId ? (
              <p className="muted">This comment is on post {c.content.postId}.</p>
            ) : null}
          </>
        )}
      </section>

      <section className="card" aria-label="Reports" style={{ padding: 20 }}>
        <h2>Reports ({c.reports.length})</h2>
        {c.reports.length === 0 ? (
          <p className="empty">No reports.</p>
        ) : (
          <ul className="plain-list">
            {c.reports.map((r) => (
              <li key={r.id}>
                <strong>{reasonLabel(r.reason)}</strong>
                <span className="muted">
                  {' '}
                  · {r.reporter ? r.reporter.displayName : 'Reporter removed'} · {when(r.createdAt)}
                </span>
                {r.note ? <div>{r.note}</div> : null}
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className="card" aria-label="History" style={{ padding: 20 }}>
        <h2>History</h2>
        {c.history.length === 0 ? (
          <p className="empty">No decisions yet.</p>
        ) : (
          <ol className="timeline">
            {c.history.map((h) => (
              <li key={h.id}>
                <strong>{actionMeta(h.action).label}</strong>
                <span className="muted">
                  {' '}
                  · {h.actor ? h.actor.displayName : 'System'} · {when(h.createdAt)}
                </span>
                {h.reason ? <div>{h.reason}</div> : null}
              </li>
            ))}
          </ol>
        )}
      </section>

      {canResolve ? (
        <CaseActions
          caseId={c.id}
          meId={me.id}
          assigneeId={c.assignee?.id ?? null}
          allowedActions={canAct ? c.allowedActions : []}
          canSuspend={can(me.permissions, 'user.suspend')}
          ownContent={ownContent}
          targetLabel={target.toLowerCase()}
        />
      ) : (
        <p className="muted">You can view this case but not decide on it.</p>
      )}
      {can(me.permissions, 'audit.view') ? (
        <p>
          <Link href={`/audit-logs?entityType=moderation_case&entityId=${c.id}`}>
            View this case&apos;s audit history
          </Link>
        </p>
      ) : null}
    </>
  );
}
