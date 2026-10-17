import Link from 'next/link';
import { notFound } from 'next/navigation';
import { StatusPill } from '@/components/ui/status-pill';
import { can, currentAdmin } from '@/lib/admin';
import { api } from '@/lib/api';
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
  const { data, response } = await api().GET('/api/v1/admin/users/{id}', {
    params: { path: { id } },
  });
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the user (${response.status}).`);
  }
  const u = data.data;
  const isSelf = u.id === me.id;

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
          </dd>
          <dt>Email</dt>
          <dd>{u.email ?? '—'}</dd>
          <dt>Phone</dt>
          <dd>{u.phone ?? '—'}</dd>
          <dt>Roles</dt>
          <dd>{u.roles.length ? u.roles.join(', ').toLowerCase() : 'member'}</dd>
          <dt>Joined</dt>
          <dd>{new Date(u.createdAt).toLocaleString('en-KE')}</dd>
          <dt>Last sign-in</dt>
          <dd>{u.lastLoginAt ? new Date(u.lastLoginAt).toLocaleString('en-KE') : 'Never'}</dd>
        </dl>
      </section>
      {can(me.permissions, 'user.suspend') ? (
        <UserActions userId={u.id} name={u.fullName} status={u.status} isSelf={isSelf} />
      ) : null}
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
