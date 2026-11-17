import Link from 'next/link';
import { can, currentAdmin } from '@/lib/admin';
import { loadAudienceOptions } from '@/lib/broadcast-options';
import { emptyBroadcastForm } from '@/lib/broadcasts';
import { BroadcastForm } from '../broadcast-form';

export const metadata = { title: 'New broadcast' };

export default async function NewBroadcastPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'notification.broadcast')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Notifications.
      </div>
    );
  }
  const options = await loadAudienceOptions();
  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/notifications">← All broadcasts</Link>
        </p>
        <h1>New broadcast</h1>
        <p>
          Members read this in their notifications. Once sent it cannot be taken back, so sending
          asks for a code from your authenticator app. A scheduled broadcast can be cancelled until
          it starts.
        </p>
      </div>
      <BroadcastForm initial={emptyBroadcastForm()} {...options} />
    </>
  );
}
