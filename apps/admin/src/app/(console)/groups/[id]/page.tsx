import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { getGroup } from '@/lib/moderation-api';
import { GroupForm } from '../group-form';
import { GroupManager } from './group-manager';

export const metadata = { title: 'Group' };

export default async function GroupPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'community.group.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Groups.
      </div>
    );
  }
  const { data, response } = await getGroup(id);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the group (${response.status}).`);
  }
  const g = data.data;

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/groups">← All groups</Link>
        </p>
        <h1>{g.name}</h1>
      </div>
      <section className="card" aria-label="Group">
        <dl className="facts">
          <dt>Status</dt>
          <dd>
            <span className={`pill ${g.archivedAt ? 'muted' : 'success'}`}>
              {g.archivedAt ? 'Archived' : 'Active'}
            </span>
          </dd>
          <dt>Address</dt>
          <dd>/{g.slug}</dd>
          <dt>Type</dt>
          <dd>{g.type.toLowerCase()}</dd>
          <dt>Run by</dt>
          <dd>{g.isOfficial ? 'Atarah' : 'Community'}</dd>
          <dt>Visibility</dt>
          <dd>{g.visibility.toLowerCase()}</dd>
          <dt>Members</dt>
          <dd>{g.memberCount}</dd>
          <dt>Description</dt>
          <dd style={{ whiteSpace: 'pre-wrap' }}>{g.description || '—'}</dd>
        </dl>
        {g.archivedAt ? null : (
          <div style={{ padding: '0 20px 20px' }}>
            <GroupForm
              mode="edit"
              initial={{
                id: g.id,
                name: g.name,
                description: g.description,
                visibility: g.visibility,
                isOfficial: g.isOfficial,
              }}
            />
          </div>
        )}
      </section>
      {g.archivedAt ? (
        <p className="muted">Archived groups cannot be changed.</p>
      ) : (
        <GroupManager
          groupId={g.id}
          name={g.name}
          moderators={g.moderators.map((m) => ({
            id: m.person.id,
            name: m.person.displayName,
            handle: m.person.handle,
            role: m.role,
          }))}
          pinnedPostIds={g.pinnedPostIds}
        />
      )}
      {can(me.permissions, 'audit.view') ? (
        <p>
          <Link href={`/audit-logs?entityType=group&entityId=${g.id}`}>
            View this group&apos;s audit history
          </Link>
        </p>
      ) : null}
    </>
  );
}
