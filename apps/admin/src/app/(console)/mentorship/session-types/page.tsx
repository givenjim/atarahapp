import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listSessionTypes } from '@/lib/mentorship-api';
import { formatMoney } from '@/lib/mentorship';
import { SessionTypeToggle } from '../mentorship-actions-ui';

export const metadata = { title: 'Mentor session types' };

type SearchParams = Promise<{ mentorId?: string; staffOff?: string; page?: string }>;

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export default async function SessionTypesPage({ searchParams }: { searchParams: SearchParams }) {
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
  const mentorId = sp.mentorId && UUID.test(sp.mentorId) ? sp.mentorId : undefined;
  const staffOff = sp.staffOff === '1';
  const { data, error, response } = await listSessionTypes({
    page,
    limit: 20,
    mentorId,
    disabledByStaff: staffOff ? true : undefined,
  });

  return (
    <>
      <div className="page-head">
        <h1>Session types</h1>
        <p>
          What mentors offer and what they charge. Switch one off if a price or description breaks
          the rules; the mentor cannot turn it back on.
        </p>
      </div>
      <section className="card" aria-label="Session types">
        <div className="toolbar">
          <nav className="filters" aria-label="Session type filters">
            <Link
              className={`button small ${staffOff ? 'secondary' : ''}`.trim()}
              href="/mentorship/session-types"
            >
              All
            </Link>
            <Link
              className={`button small ${staffOff ? '' : 'secondary'}`.trim()}
              href="/mentorship/session-types?staffOff=1"
            >
              Switched off by staff
            </Link>
            {mentorId ? (
              <Link className="button secondary small" href="/mentorship/session-types">
                One mentor only: clear
              </Link>
            ) : null}
          </nav>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Session types"
              rows={data.data}
              rowKey={(t) => t.id}
              empty="No session types."
              columns={[
                {
                  key: 'mentor',
                  header: 'Mentor',
                  render: (t) => t.mentorName,
                },
                {
                  key: 'name',
                  header: 'Session',
                  render: (t) => (
                    <>
                      <strong>{t.name}</strong>
                      <div className="muted">{t.description ?? ''}</div>
                    </>
                  ),
                },
                {
                  key: 'price',
                  header: 'Price',
                  render: (t) => `${formatMoney(t.priceMinor, t.currency)} · ${t.durationMinutes} min`,
                },
                {
                  key: 'state',
                  header: 'State',
                  render: (t) =>
                    t.disabledByStaff ? (
                      <>
                        <span className="pill danger">Switched off by staff</span>
                        {t.staffNote ? <div className="muted">{t.staffNote}</div> : null}
                      </>
                    ) : (
                      <span className={`pill ${t.active ? 'success' : ''}`.trim()}>
                        {t.active ? 'On' : 'Off'}
                      </span>
                    ),
                },
                {
                  key: 'actions',
                  header: 'Actions',
                  render: (t) => (
                    <SessionTypeToggle id={t.id} name={t.name} disabled={t.disabledByStaff} />
                  ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/mentorship/session-types"
                query={{ mentorId, staffOff: staffOff ? '1' : undefined }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
