import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { StatusPill } from '@/components/ui/status-pill';
import { api, errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';

export const metadata = { title: 'Users' };

type SearchParams = Promise<{ q?: string; status?: string; page?: string }>;

const STATUSES = ['ACTIVE', 'PENDING_VERIFICATION', 'SUSPENDED', 'DEACTIVATED', 'DELETED'] as const;
type Status = (typeof STATUSES)[number];
const isStatus = (v: string | undefined): v is Status => STATUSES.includes(v as Status);

export default async function UsersPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'user.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Users.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const status = isStatus(sp.status) ? sp.status : undefined;

  const { data, error, response } = await api().GET('/api/v1/admin/users', {
    params: { query: { page, limit: 20, q, status } },
  });

  return (
    <>
      <div className="page-head">
        <h1>Users</h1>
        <p>Search members and manage account status. Every change is recorded in the audit log.</p>
      </div>
      <section className="card" aria-label="Users">
        <form className="filters" role="search" method="get">
          <label className="field">
            Search
            <input
              className="input"
              type="search"
              name="q"
              defaultValue={q ?? ''}
              placeholder="Name, email or phone"
            />
          </label>
          <label className="field">
            Status
            <select className="select" name="status" defaultValue={status ?? ''}>
              <option value="">All statuses</option>
              {STATUSES.map((s) => (
                <option key={s} value={s}>
                  {s.replaceAll('_', ' ').toLowerCase()}
                </option>
              ))}
            </select>
          </label>
          <button className="button" type="submit">
            Apply
          </button>
          {q || status ? (
            <Link className="button secondary" href="/users">
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
              caption="Users"
              rows={data.data}
              rowKey={(u) => u.id}
              empty="No users match these filters."
              columns={[
                {
                  key: 'name',
                  header: 'Name',
                  render: (u) => <Link href={`/users/${u.id}`}>{u.fullName}</Link>,
                },
                { key: 'contact', header: 'Contact', render: (u) => u.email ?? u.phone ?? '—' },
                {
                  key: 'status',
                  header: 'Status',
                  render: (u) => <StatusPill status={u.status} />,
                },
                {
                  key: 'roles',
                  header: 'Roles',
                  render: (u) => (u.roles.length ? u.roles.join(', ').toLowerCase() : 'member'),
                },
                {
                  key: 'joined',
                  header: 'Joined',
                  render: (u) => new Date(u.createdAt).toLocaleDateString('en-KE'),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/users"
                query={{ q, status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
