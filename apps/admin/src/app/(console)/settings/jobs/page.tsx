import Link from 'next/link';
import { DataTable } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { formatWhen, jobKey, shortReason, type FailedJob, type QueueCounts } from '@/lib/ops';
import { listFailedJobs, listQueues } from '@/lib/ops-api';
import { RetryJob } from './retry-job';

export const metadata = { title: 'Background jobs' };

export default async function JobsPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'settings.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Settings.
      </div>
    );
  }
  const queues = await listQueues();
  const counts: QueueCounts[] = queues.data?.data ?? [];
  // Failed jobs for the queues that have any (the API keeps them 14 days as the dead-letter store).
  const failed = await Promise.all(
    counts
      .filter((q) => q.failed > 0)
      .map(async (q) => ({ queue: q.queue, res: await listFailedJobs(q.queue) })),
  );

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/settings">← Settings</Link>
        </p>
        <h1>Background jobs</h1>
        <p>
          Queue sizes and the jobs that ran out of retries. Job contents are never shown. Retrying
          needs a fresh authenticator code.
        </p>
      </div>
      <section className="card" aria-label="Queues">
        {!queues.data ? (
          <p className="alert notice" role="alert">
            {errorOf(queues.error, queues.response).message}
          </p>
        ) : (
          <DataTable
            caption="Queues"
            rows={counts}
            rowKey={(q) => q.queue}
            empty="No queues."
            columns={[
              { key: 'q', header: 'Queue', render: (q) => q.queue },
              { key: 'w', header: 'Waiting', render: (q) => q.waiting },
              { key: 'a', header: 'Active', render: (q) => q.active },
              { key: 'd', header: 'Delayed', render: (q) => q.delayed },
              {
                key: 'f',
                header: 'Failed',
                render: (q) =>
                  q.failed > 0 ? <span className="pill danger">{q.failed}</span> : q.failed,
              },
              { key: 'c', header: 'Completed', render: (q) => q.completed },
            ]}
          />
        )}
      </section>
      {queues.data && failed.length === 0 ? <p className="card empty">No failed jobs.</p> : null}
      {failed.map(({ queue, res }) => (
        <section key={queue} className="card" aria-label={`Failed jobs in ${queue}`}>
          <div style={{ padding: '16px 16px 0' }}>
            <h2 className="section-title">Failed in {queue}</h2>
          </div>
          {!res.data ? (
            <p className="alert notice" role="alert">
              {errorOf(res.error, res.response).message}
            </p>
          ) : (
            <DataTable<FailedJob>
              caption={`Failed jobs in ${queue}`}
              rows={res.data.data}
              rowKey={(j) => jobKey(queue, j.id)}
              empty="No failed jobs."
              columns={[
                {
                  key: 'job',
                  header: 'Job',
                  render: (j) => (
                    <>
                      {j.name}
                      <div className="muted">#{j.id}</div>
                    </>
                  ),
                },
                { key: 'why', header: 'Reason', render: (j) => shortReason(j.failedReason) },
                { key: 'tries', header: 'Attempts', render: (j) => j.attemptsMade },
                { key: 'when', header: 'Failed', render: (j) => formatWhen(j.failedAt) },
                {
                  key: 'act',
                  header: 'Action',
                  render: (j) => <RetryJob queue={queue} jobId={j.id} />,
                },
              ]}
            />
          )}
        </section>
      ))}
    </>
  );
}
