import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listAnnouncements, listGroups } from '@/lib/moderation-api';
import { AnnouncementForm } from './announcement-form';

export const metadata = { title: 'Announcements' };

type SearchParams = Promise<{ page?: string }>;

export default async function AnnouncementsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'community.announce')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Announcements.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const [list, groups] = await Promise.all([
    listAnnouncements({ page, limit: 20 }),
    // Group names for the audience picker; groups need their own permission, so this may be empty.
    can(me.permissions, 'community.group.manage')
      ? listGroups({ page: 1, limit: 100 })
      : Promise.resolve(null),
  ]);

  return (
    <>
      <div className="page-head">
        <h1>Announcements</h1>
        <p>
          Staff announcements appear in the Community feed of every member, or only in one group.
          Posting needs a fresh authenticator code and is recorded in the audit log.
        </p>
      </div>
      <AnnouncementForm
        groups={(groups?.data?.data ?? [])
          .filter((g) => !g.archivedAt)
          .map((g) => ({ id: g.id, name: g.name }))}
      />
      <section className="card" aria-label="Past announcements">
        {!list.data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(list.error, list.response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Past announcements"
              rows={list.data.data}
              rowKey={(a) => a.id}
              empty="No announcements yet."
              columns={[
                {
                  key: 'body',
                  header: 'Announcement',
                  render: (a) => <span style={{ whiteSpace: 'pre-wrap' }}>{a.body}</span>,
                },
                {
                  key: 'audience',
                  header: 'Sent to',
                  render: (a) => (a.group ? a.group.name : 'Every member'),
                },
                { key: 'author', header: 'By', render: (a) => a.author.displayName },
                {
                  key: 'when',
                  header: 'Posted',
                  render: (a) => new Date(a.createdAt).toLocaleString('en-KE'),
                },
              ]}
            />
            {list.data.meta ? (
              <Pagination
                meta={list.data.meta as { page: number; limit: number; total: number }}
                basePath="/announcements"
                query={{}}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
