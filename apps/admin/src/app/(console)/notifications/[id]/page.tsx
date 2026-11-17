import Link from 'next/link';
import { notFound } from 'next/navigation';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  broadcastStatusMeta,
  canCancelBroadcast,
  formatWhen,
  targetSummary,
  timingLine,
} from '@/lib/broadcasts';
import { getBroadcast } from '@/lib/broadcasts-api';
import { CancelBroadcast } from './cancel-broadcast';

export const metadata = { title: 'Broadcast' };

export default async function BroadcastPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'notification.broadcast')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Notifications.
      </div>
    );
  }
  const { data, error, response } = await getBroadcast(id);
  if (response.status === 404) notFound();
  if (!data) {
    return (
      <p className="alert" role="alert">
        {errorOf(error, response).message}
      </p>
    );
  }
  const b = data.data;
  const meta = broadcastStatusMeta(b.status);
  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/notifications">← All broadcasts</Link>
        </p>
        <h1>{b.title}</h1>
        <p>
          <span className={`pill ${meta.tone}`.trim()}>{meta.label}</span> {timingLine(b)}
        </p>
      </div>
      <section className="card" style={{ padding: 20, display: 'grid', gap: 12, maxWidth: 720 }}>
        <p style={{ margin: 0, whiteSpace: 'pre-wrap' }}>{b.body}</p>
        <dl className="facts">
          <dt>Audience</dt>
          <dd>{targetSummary(b)}</dd>
          <dt>Recipients</dt>
          <dd>{b.recipientCount}</dd>
          <dt>Category</dt>
          <dd>{b.category}</dd>
          <dt>Opens</dt>
          <dd>{b.deepLink ?? 'Just the notification'}</dd>
          <dt>Created</dt>
          <dd>{formatWhen(b.createdAt)}</dd>
        </dl>
        <p className="muted" style={{ margin: 0 }}>
          The recipient count is the number of members the notification was written for. Whether it
          arrived as a push or an email depends on each member’s settings and devices.{' '}
          <Link href="/audit-logs">See the audit log</Link>.
        </p>
        {canCancelBroadcast(b.status) ? (
          <div className="row-actions">
            <CancelBroadcast id={b.id} />
          </div>
        ) : null}
      </section>
    </>
  );
}
