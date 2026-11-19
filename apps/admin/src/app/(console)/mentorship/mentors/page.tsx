import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listMentors } from '@/lib/mentorship-api';
import { MENTOR_STATUSES, statusTone, titleCase } from '@/lib/mentorship';
import { MentorActions } from '../mentorship-actions-ui';

export const metadata = { title: 'Mentors' };

type SearchParams = Promise<{ q?: string; status?: string; page?: string }>;

export default async function MentorsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'mentor.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Mentorship.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const status = (MENTOR_STATUSES as readonly string[]).includes(sp.status ?? '')
    ? sp.status
    : undefined;
  const { data, error, response } = await listMentors({ page, limit: 20, q, status });

  return (
    <>
      <div className="page-head">
        <h1>Mentors</h1>
        <p>
          Pause hides a mentor from the directory; remove also revokes the Mentor role. Featured
          mentors lead the hub and the directory.
        </p>
      </div>
      <section className="card" aria-label="Mentors">
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            <label className="field">
              Search
              <input
                className="input"
                type="search"
                name="q"
                defaultValue={q ?? ''}
                placeholder="Name, email or headline"
              />
            </label>
            <label className="field">
              Status
              <select className="input" name="status" defaultValue={status ?? ''}>
                <option value="">All</option>
                {MENTOR_STATUSES.map((s) => (
                  <option key={s} value={s}>
                    {titleCase(s)}
                  </option>
                ))}
              </select>
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {q || status ? (
              <Link className="button secondary" href="/mentorship/mentors">
                Clear
              </Link>
            ) : null}
          </form>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Mentors"
              rows={data.data}
              rowKey={(m) => m.id}
              empty="No mentors match."
              columns={[
                {
                  key: 'mentor',
                  header: 'Mentor',
                  render: (m) => (
                    <>
                      <strong>{m.mentor.displayName}</strong>
                      <div className="muted">{m.headline}</div>
                    </>
                  ),
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (m) => (
                    <>
                      <span className={`pill ${statusTone(m.status)}`.trim()}>
                        {titleCase(m.status)}
                      </span>
                      {m.featured ? <span className="pill success">Featured</span> : null}
                      {m.statusReason ? <div className="muted">{m.statusReason}</div> : null}
                    </>
                  ),
                },
                {
                  key: 'types',
                  header: 'Session types',
                  render: (m) => (
                    <Link href={`/mentorship/session-types?mentorId=${m.id}`}>
                      {m.sessionTypeCount}
                    </Link>
                  ),
                },
                {
                  key: 'stats',
                  header: 'Rating',
                  render: (m) =>
                    m.ratingCount > 0
                      ? `${m.ratingAverage.toFixed(1)} (${m.ratingCount}) · ${m.sessionsCount} sessions`
                      : 'No reviews yet',
                },
                {
                  key: 'actions',
                  header: 'Actions',
                  render: (m) => (
                    <MentorActions
                      id={m.id}
                      name={m.mentor.displayName}
                      status={m.status}
                      featured={m.featured}
                    />
                  ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/mentorship/mentors"
                query={{ q, status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
