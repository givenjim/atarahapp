'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { reactivateUserAction } from '@/app/actions';
import { suspendTimedAction } from '@/app/ops-actions';
import { SUSPEND_MAX_DAYS, SUSPEND_REASON_MAX, validateSuspend, type SuspendForm } from '@/lib/ops';

type Stage = 'closed' | 'suspend' | 'reactivate';

/** Suspend (with a reason and an optional number of days) or reactivate. Both need a fresh authenticator code. */
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
  const [form, setForm] = useState<SuspendForm>({ reason: '', days: '' });
  const { attempt, pending, error, setError, reauth } = useReauth();

  const suspended = status === 'SUSPENDED';
  const canSuspend = status === 'ACTIVE' || status === 'PENDING_VERIFICATION';

  if (isSelf) return <p className="muted">You cannot change the status of your own account.</p>;
  if (!suspended && !canSuspend) return null;

  const close = () => {
    setStage('closed');
    setError(null);
  };
  const done = () => {
    close();
    setForm({ reason: '', days: '' });
    router.refresh();
  };

  return (
    <section className="card stack" aria-label="Account actions">
      <div>
        {suspended ? (
          <button
            type="button"
            className="button"
            onClick={() => {
              setError(null);
              setStage('reactivate');
            }}
          >
            Reactivate account
          </button>
        ) : (
          <button
            type="button"
            className="button danger"
            onClick={() => {
              setError(null);
              setStage('suspend');
            }}
          >
            Suspend account
          </button>
        )}
      </div>

      <FormDialog
        open={stage === 'suspend'}
        title={`Suspend ${name}?`}
        submitLabel="Suspend account"
        pending={pending}
        error={stage === 'suspend' ? error : null}
        onCancel={close}
        onSubmit={() => {
          const problem = validateSuspend(form);
          if (problem) return setError(problem);
          attempt(() => suspendTimedAction(userId, form), done);
        }}
      >
        <p className="muted" style={{ margin: 0 }}>
          They are signed out everywhere immediately and cannot sign in until the suspension ends or
          staff lift it. This is recorded in the audit log with your name.
        </p>
        <label className="field">
          Reason for suspension
          <textarea
            className="textarea"
            rows={3}
            maxLength={SUSPEND_REASON_MAX}
            value={form.reason}
            onChange={(e) => setForm((p) => ({ ...p, reason: e.target.value }))}
          />
        </label>
        <label className="field">
          Number of days (optional)
          <input
            className="input"
            inputMode="numeric"
            placeholder={`1 to ${SUSPEND_MAX_DAYS}; blank until staff lift it`}
            value={form.days}
            onChange={(e) => setForm((p) => ({ ...p, days: e.target.value }))}
          />
        </label>
      </FormDialog>

      <ConfirmDialog
        open={stage === 'reactivate'}
        title={`Reactivate ${name}?`}
        confirmLabel="Reactivate account"
        reasonLabel="Reason (optional note)"
        minReasonLength={0}
        pending={pending}
        error={stage === 'reactivate' ? error : null}
        onCancel={close}
        onConfirm={(reason) => attempt(() => reactivateUserAction(userId, reason), done)}
      >
        <p className="muted" style={{ margin: 0 }}>
          They will be able to sign in again. This is recorded in the audit log with your name.
        </p>
      </ConfirmDialog>

      <ReauthDialog {...reauth} />
    </section>
  );
}
