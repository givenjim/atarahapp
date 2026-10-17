'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import {
  reactivateUserAction,
  reauthAction,
  suspendUserAction,
  type ActionResult,
} from '@/app/actions';

type Stage = 'closed' | 'confirm' | 'reauth';

export function UserActions({
  userId,
  name,
  status,
  isSelf,
}: {
  userId: string;
  name: string;
  status: string;
  isSelf: boolean;
}) {
  const router = useRouter();
  const [stage, setStage] = useState<Stage>('closed');
  const [reason, setReason] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  const suspended = status === 'SUSPENDED';
  const canSuspend = status === 'ACTIVE' || status === 'PENDING_VERIFICATION';
  const verb = suspended ? 'Reactivate' : 'Suspend';

  if (isSelf) return <p className="muted">You cannot change the status of your own account.</p>;
  if (!suspended && !canSuspend) return null;

  const run = (why: string) =>
    start(async () => {
      const result: ActionResult = suspended
        ? await reactivateUserAction(userId, why)
        : await suspendUserAction(userId, why);
      if (result.ok) {
        setStage('closed');
        setError(null);
        router.refresh();
      } else if (result.reauth) {
        // The API wants a fresh password + code first; keep the reason and ask for them.
        setError(null);
        setStage('reauth');
      } else {
        setError(result.error);
      }
    });

  return (
    <section className="card" aria-label="Account actions" style={{ padding: 20 }}>
      <button
        type="button"
        className={`button ${suspended ? '' : 'danger'}`}
        onClick={() => {
          setError(null);
          setStage('confirm');
        }}
      >
        {verb} account
      </button>

      <ConfirmDialog
        open={stage === 'confirm'}
        title={`${verb} ${name}?`}
        confirmLabel={`${verb} account`}
        tone={suspended ? 'primary' : 'danger'}
        reasonLabel={suspended ? 'Reason (optional note)' : 'Reason for suspension'}
        minReasonLength={suspended ? 0 : 5}
        pending={pending}
        error={error}
        onCancel={() => setStage('closed')}
        onConfirm={(r) => {
          setReason(r);
          run(r);
        }}
      >
        <p className="muted" style={{ margin: 0 }}>
          {suspended
            ? 'They will be able to sign in again.'
            : 'They are signed out everywhere immediately and cannot sign in until reactivated.'}{' '}
          This is recorded in the audit log with your name.
        </p>
      </ConfirmDialog>

      <ReauthDialog
        open={stage === 'reauth'}
        pending={pending}
        error={error}
        onCancel={() => setStage('closed')}
        onSubmit={(credentials) =>
          start(async () => {
            const res = await reauthAction(credentials);
            if (!res.ok) {
              setError(res.error);
              return;
            }
            setError(null);
            run(reason);
          })
        }
      />
    </section>
  );
}
