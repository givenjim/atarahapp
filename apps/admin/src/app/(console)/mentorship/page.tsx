import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listApplications } from '@/lib/mentorship-api';
import {
  APPLICATION_STATUSES,
  formatMoney,
  statusTone,
  titleCase,
} from '@/lib/mentorship';
import { ApplicationActions } from './mentorship-actions-ui';

export const metadata = { title: 'Mentor applications' };

type SearchParams = Promise<{ status?: string; page?: string }>;

export default async function ApplicationsPage({ searchParams }: { searchParams: SearchParams }) {
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
  const status = (APPLICATION_STATUSES as readonly string[]).includes(sp.status ?? '')
    ? sp.status
    : 'PENDING';
  const { data, error, response } = await listApplications({ page, limit: 20, status });

  return (
    <>
      <div className="page-head">
        <h1>Mentor applications</h1>
        <p>
          Approving grants the Mentor role once and publishes the mentor profile with the session
          types the applicant proposed. Every decision is audited.
        </p>
      </div>
      <section className="card" aria-label="Applications">
        <div className="toolbar">
          <nav className="filters" aria-label="Application status">
            {APPLICATION_STATUSES.map((s) => (
              <Link
                key={s}
                className={`button small ${s === status ? '' : 'secondary'}`.trim()}
                href={`/mentorship?status=${s}`}
                aria-current={s === status ? 'page' : undefined}
              >
                {titleCase(s)}
              </Link>
            ))}
          </nav>
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Mentor applications"
              rows={data.data}
              rowKey={(a) => a.id}
              empty={`No ${titleCase(status ?? 'PENDING').toLowerCase()} applications.`}
              columns={[
                {
                  key: 'applicant',
                  header: 'Applicant',
                  render: (a) => (
                    <>
                      <strong>{a.applicant.displayName}</strong>
                      <div className="muted">{a.applicant.email ?? a.applicant.handle ?? ''}</div>
                    </>
                  ),
                },
                {
                  key: 'application',
                  header: 'Application',
                  render: (a) => (
                    <details>
                      <summary>
                        {a.headline} · {a.yearsExperience} yrs
                      </summary>
                      <p>{a.statement}</p>
                      <p className="muted">
                        Expertise: {a.expertiseTags.join(', ') || 'none given'} · Time zone:{' '}
                        {a.timeZone}
                      </p>
                      <ul>
                        {a.proposedSessionTypes.map((t) => (
                          <li key={t.name}>
                            {t.name}: {t.durationMinutes} min, {formatMoney(t.priceMinor)}
                          </li>
                        ))}
                      </ul>
                      {a.evidenceLinks.length ? (
                        <ul>
                          {a.evidenceLinks.map((l) => (
                            <li key={l}>
                              <a href={l} target="_blank" rel="noopener noreferrer">
                                {l}
                              </a>
                            </li>
                          ))}
                        </ul>
                      ) : null}
                      <p className="muted">
                        Passport: {String(a.passportSnapshot.passportNumber ?? 'no number')} ·{' '}
                        {String(a.passportSnapshot.displayName ?? '')}
                      </p>
                    </details>
                  ),
                },
                {
                  key: 'status',
                  header: 'Status',
                  render: (a) => (
                    <>
                      <span className={`pill ${statusTone(a.status)}`.trim()}>
                        {titleCase(a.status)}
                      </span>
                      {a.reviewerNotes ? <div className="muted">{a.reviewerNotes}</div> : null}
                    </>
                  ),
                },
                {
                  key: 'actions',
                  header: 'Actions',
                  render: (a) =>
                    a.status === 'PENDING' ? (
                      <ApplicationActions id={a.id} name={a.applicant.displayName} />
                    ) : null,
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/mentorship"
                query={{ status }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
