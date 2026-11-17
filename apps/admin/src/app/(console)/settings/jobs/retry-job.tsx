'use client';

import { useRouter } from 'next/navigation';
import { retryJobAction } from '@/app/ops-actions';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';

/** Puts one failed job back on its queue. Needs a fresh authenticator code; audited as job.retry. */
export function RetryJob({ queue, jobId }: { queue: string; jobId: string }) {
  const router = useRouter();
  const { attempt, pending, error, reauth } = useReauth();
  return (
    <>
      <button
        type="button"
        className="button secondary small"
        disabled={pending}
        aria-label={`Retry job ${jobId} in ${queue}`}
        onClick={() =>
          attempt(
            () => retryJobAction(queue, jobId),
            () => router.refresh(),
          )
        }
      >
        {pending ? 'Retrying…' : 'Retry'}
      </button>
      {error ? (
        <div className="alert" role="alert" style={{ marginTop: 6 }}>
          {error}
        </div>
      ) : null}
      <ReauthDialog {...reauth} />
    </>
  );
}
