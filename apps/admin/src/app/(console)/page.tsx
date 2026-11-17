import Link from 'next/link';
import { PriorityPill } from '@/components/ops/priority-pill';
import { errorOf } from '@/lib/api';
import { currentAdmin } from '@/lib/admin';
import {
  ageLabel,
  COUNT_TILES,
  formatCount,
  formatWhen,
  safeConsolePath,
  sortQueues,
} from '@/lib/ops';
import { getDashboard } from '@/lib/ops-api';

export const metadata = { title: 'Dashboard' };

export default async function DashboardPage() {
  await currentAdmin();
  const { data, error, response } = await getDashboard();
  if (!data) {
    return (
      <>
        <div className="page-head">
          <h1>Dashboard</h1>
        </div>
        <p className="alert" role="alert">
          {errorOf(error, response).message}
        </p>
      </>
    );
  }
  const { counts, generatedAt } = data.data;
  const queues = sortQueues(data.data.queues);

  return (
    <>
      <div className="page-head">
        <h1>Dashboard</h1>
        <p>Updated {formatWhen(generatedAt)}. Reload the page for fresh numbers.</p>
      </div>

      <section aria-labelledby="queues-title" className="card">
        <div style={{ padding: '16px 16px 0' }}>
          <h2 id="queues-title" className="section-title">
            Needs attention
          </h2>
          <p className="muted" style={{ margin: '4px 0 0' }}>
            Only the queues you can act on are shown, most urgent first.
          </p>
        </div>
        {queues.length === 0 ? (
          <p className="empty">No queues for your role.</p>
        ) : (
          <ul className="queues">
            {queues.map((q) => (
              <li key={q.key}>
                <span className="queue-count" aria-label={`${q.count} waiting`}>
                  {formatCount(q.count)}
                </span>
                <div>
                  <Link href={safeConsolePath(q.path)}>{q.label}</Link>
                  <div className="muted">
                    {q.count === 0
                      ? 'Nothing waiting'
                      : q.oldestAt
                        ? `Oldest waiting ${ageLabel(q.oldestAt)}`
                        : 'Waiting'}
                  </div>
                </div>
                <PriorityPill priority={q.priority} />
              </li>
            ))}
          </ul>
        )}
      </section>

      <section aria-labelledby="counts-title">
        <h2 id="counts-title" className="section-title" style={{ marginBottom: 12 }}>
          Key counts
        </h2>
        <ul className="tiles">
          {COUNT_TILES.map((t) => (
            <li key={`${t.key}`} className="card tile">
              <span className="label">{t.label}</span>
              <span className="value">{formatCount(counts[t.key], t.percent)}</span>
              <span className="muted">{t.hint}</span>
            </li>
          ))}
        </ul>
      </section>
    </>
  );
}
