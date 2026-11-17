import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listGroups } from '@/lib/moderation-api';
import { GROUP_TYPES } from '@/lib/moderation';
import { GroupForm } from './group-form';

export const metadata = { title: 'Groups' };

type SearchParams = Promise<{ q?: string; type?: string; archived?: string; page?: string }>;

export default async function GroupsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'community.group.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Groups.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const type = GROUP_TYPES.find((t) => t === sp.type);
  const archived = sp.archived === 'true';

  const { data, error, response } = await listGroups({
    page,
    limit: 20,
    q,
    type,
    includeArchived: archived || undefined,
  });

  return (
    <>
      <div className="page-head">
        <h1>Groups</h1>
        <p>
          Official and community groups. Manage their details, moderators and pinned announcements.
          Every change is recorded in the audit log.
        </p>
      </div>
      <section className="card" aria-label="Groups">
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            <label className="field">
              Search
              <input
                className="input"
                type="search"
                name="q"
                defaultValue={q ?? ''}
                placeholder="Group name"
              />
            </label>
            <label className="field">
              Type
              <select className="select" name="type" defaultValue={type ?? ''}>
                <option value="">Any</option>
                {GROUP_TYPES.map((t) => (
                  <option key={t} value={t}>
                    {t.charAt(0) + t.slice(1).toLowerCase()}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              <span>
                <input type="checkbox" name="archived" value="true" defaultChecked={archived} />{' '}
                Include archived
              </span>
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {q || type || archived ? (
              <Link className="button secondary" href="/groups">
                Clear
              </Link>
            ) : null}
          </form>
          <GroupForm mode="create" />
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Groups"
              rows={data.data}
              rowKey={(g) => g.id}
              empty={q || type || archived ? 'No groups match these filters.' : 'No groups yet.'}
              columns={[
                {
                  key: 'name',
                  header: 'Group',
                  render: (g) => (
                    <>
                      <Link href={`/groups/${g.id}`}>{g.name}</Link>
                      <div className="muted">/{g.slug}</div>
                    </>
                  ),
                },
                { key: 'type', header: 'Type', render: (g) => g.type.toLowerCase() },
                { key: 'members', header: 'Members', render: (g) => g.memberCount },
                {
                  key: 'official',
                  header: 'Run by',
                  render: (g) => (g.isOfficial ? 'Atarah' : 'Community'),
                },
                {
                  key: 'visibility',
                  header: 'Visibility',
                  render: (g) => g.visibility.toLowerCase(),
                },
                { key: 'mods', header: 'Moderators', render: (g) => g.moderators.length },
                {
                  key: 'status',
                  header: 'Status',
                  render: (g) => (
                    <span className={`pill ${g.archivedAt ? 'muted' : 'success'}`}>
                      {g.archivedAt ? 'Archived' : 'Active'}
                    </span>
                  ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/groups"
                query={{ q, type, archived: archived ? 'true' : undefined }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
