import Link from 'next/link';
import { notFound } from 'next/navigation';
import { StatusPill } from '@/components/ui/status-pill';
import { can, currentAdmin } from '@/lib/admin';
import {
  assignableRoles,
  canRevokeRole,
  formatWhen,
  historyLabel,
  roleLabel,
  type RoleInfo,
} from '@/lib/ops';
import { getOverview, listRoles } from '@/lib/ops-api';
import { RoleManager } from './role-manager';
import { UserActions } from './user-actions';

export const metadata = { title: 'User' };

export default async function UserPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'user.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Users.
      </div>
    );
  }
  const [{ data, response }, rolesRes] = await Promise.all([getOverview(id), listRoles()]);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the user (${response.status}).`);
  }
  const o = data.data;
  const u = o.user;
  const isSelf = u.id === me.id;
  const allRoles: RoleInfo[] = rolesRes.data?.data ?? [];
  const held = o.roleGrants.map((g) => g.key);
  const assignable = isSelf ? [] : assignableRoles(allRoles, me.permissions, held);

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/users">← All users</Link>
        </p>
        <h1>{u.fullName}</h1>
      </div>

      <section className="card" aria-label="Account">
        <dl className="facts">
          <dt>Status</dt>
          <dd>
            <StatusPill status={u.status} />
            {u.statusReason ? <span className="muted"> · {u.statusReason}</span> : null}
            {o.suspendedUntil ? (
              <span className="muted"> · until {formatWhen(o.suspendedUntil)}</span>
            ) : null}
          </dd>
          <dt>Email</dt>
          <dd>{u.email ?? '—'}</dd>
          <dt>Phone</dt>
          <dd>{u.phone ?? '—'}</dd>
          <dt>Roles</dt>
          <dd>{u.roles.length ? u.roles.map(roleLabel).join(', ').toLowerCase() : 'member'}</dd>
          <dt>Joined</dt>
          <dd>{formatWhen(u.createdAt)}</dd>
          <dt>Last sign-in</dt>
          <dd>{u.lastLoginAt ? formatWhen(u.lastLoginAt) : 'Never'}</dd>
        </dl>
      </section>

      {can(me.permissions, 'user.suspend') ? (
        <UserActions userId={u.id} name={u.fullName} status={u.status} isSelf={isSelf} />
      ) : null}

      <section className="card" aria-label="Profile">
        {o.profile ? (
          <dl className="facts">
            <dt>Profile</dt>
            <dd>
              {o.profile.displayName}
              {o.profile.handle ? <span className="muted"> · @{o.profile.handle}</span> : null}
            </dd>
            <dt>Headline</dt>
            <dd>{o.profile.headline ?? '—'}</dd>
            <dt>Discipline</dt>
            <dd>{o.profile.discipline ?? '—'}</dd>
            <dt>County</dt>
            <dd>{o.profile.county ?? '—'}</dd>
            <dt>Onboarding</dt>
            <dd>{o.profile.onboardingCompleted ? 'Completed' : 'Not finished'}</dd>
            <dt>Profile completion</dt>
            <dd>{o.profile.completionPercent}%</dd>
            <dt>Published projects</dt>
            <dd>{o.profile.publishedProjects}</dd>
          </dl>
        ) : (
          <p className="empty">No creative profile yet.</p>
        )}
      </section>

      <RoleManager
        userId={u.id}
        name={u.fullName}
        canAssign={can(me.permissions, 'role.assign') && !isSelf}
        assignable={assignable.map((r) => ({ key: r.key, name: r.name }))}
        grants={o.roleGrants.map((g) => ({
          ...g,
          revocable: canRevokeRole(g, me.permissions, isSelf),
        }))}
      />

      <section className="card" aria-label="Membership">
        {o.membership ? (
          <dl className="facts">
            <dt>Plan</dt>
            <dd>{o.membership.plan}</dd>
            <dt>Status</dt>
            <dd>{o.membership.status}</dd>
            <dt>Source</dt>
            <dd>{o.membership.source}</dd>
            <dt>Started</dt>
            <dd>{formatWhen(o.membership.startsAt)}</dd>
            <dt>Current period ends</dt>
            <dd>{formatWhen(o.membership.currentPeriodEnd)}</dd>
          </dl>
        ) : (
          <p className="empty">No membership record.</p>
        )}
      </section>

      <section className="card" aria-labelledby="history-title">
        <div style={{ padding: '16px 16px 0' }}>
          <h2 id="history-title" className="section-title">
            Status history
          </h2>
        </div>
        {o.statusHistory.length === 0 ? (
          <p className="empty">No status changes.</p>
        ) : (
          <table className="data">
            <caption className="sr-only-text">Status history</caption>
            <thead>
              <tr>
                <th scope="col">When</th>
                <th scope="col">What</th>
                <th scope="col">By</th>
                <th scope="col">Reason</th>
              </tr>
            </thead>
            <tbody>
              {o.statusHistory.map((h, i) => (
                <tr key={`${h.at}-${i}`}>
                  <td>{formatWhen(h.at)}</td>
                  <td>
                    {historyLabel(h.action)}
                    {h.from || h.to ? (
                      <div className="muted">
                        {h.from ?? '—'} → {h.to ?? '—'}
                      </div>
                    ) : null}
                  </td>
                  <td>{h.actorName ?? 'System'}</td>
                  <td>{h.reason ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      <section className="card" aria-labelledby="sessions-title">
        <div style={{ padding: '16px 16px 0' }}>
          <h2 id="sessions-title" className="section-title">
            Sessions
          </h2>
        </div>
        {o.sessions.length === 0 ? (
          <p className="empty">No active sessions.</p>
        ) : (
          <table className="data">
            <caption className="sr-only-text">Sessions</caption>
            <thead>
              <tr>
                <th scope="col">Device</th>
                <th scope="col">Client</th>
                <th scope="col">Last active</th>
              </tr>
            </thead>
            <tbody>
              {o.sessions.map((s) => (
                <tr key={s.id}>
                  <td>{s.deviceName ?? 'Unknown device'}</td>
                  <td>{s.client}</td>
                  <td>{formatWhen(s.lastActiveAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      <section className="card" aria-labelledby="reports-title">
        <div style={{ padding: '16px 16px 0' }}>
          <h2 id="reports-title" className="section-title">
            Reports
          </h2>
          <p className="muted" style={{ margin: '4px 0 0' }}>
            {o.reports.about} about this member or their content · {o.reports.made} made by them.
            Reporters are never shown.
          </p>
        </div>
        {o.reports.recent.length === 0 ? (
          <p className="empty">No reports about this member.</p>
        ) : (
          <table className="data">
            <caption className="sr-only-text">Recent reports about this member</caption>
            <thead>
              <tr>
                <th scope="col">Case</th>
                <th scope="col">About</th>
                <th scope="col">Reason</th>
                <th scope="col">Status</th>
                <th scope="col">Opened</th>
              </tr>
            </thead>
            <tbody>
              {o.reports.recent.map((r) => (
                <tr key={r.caseId}>
                  <td>
                    {can(me.permissions, 'report.view') ? (
                      <Link href={`/community/${r.caseId}`}>Open case</Link>
                    ) : (
                      'Case'
                    )}
                    <div className="muted">{r.reportCount} reports</div>
                  </td>
                  <td>{r.targetType}</td>
                  <td>{r.topReason}</td>
                  <td>
                    {r.status} · {r.priority.toLowerCase()}
                  </td>
                  <td>{formatWhen(r.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      {can(me.permissions, 'audit.view') ? (
        <p>
          <Link href={`/audit-logs?entityType=user&entityId=${u.id}`}>
            View this account&apos;s audit history
          </Link>
        </p>
      ) : null}
    </>
  );
}
