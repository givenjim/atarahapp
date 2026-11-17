'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { assignCaseAction, decideCaseAction } from '@/app/community-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { actionMeta, actionNeedsReason, REASON_MAX, validateDecision } from '@/lib/moderation';

export function CaseActions({
  caseId,
  meId,
  assigneeId,
  allowedActions,
  canSuspend,
  ownContent,
  targetLabel,
}: {
  caseId: string;
  meId: string;
  assigneeId: string | null;
  allowedActions: readonly string[];
  canSuspend: boolean;
  /** Staff cannot decide on their own account or content. */
  ownContent: boolean;
  targetLabel: string;
}) {
  const router = useRouter();
  const [action, setAction] = useState<string | null>(null);
  const [days, setDays] = useState('');
  const [reason, setReason] = useState('');
  const { attempt, pending, error, setError, reauth } = useReauth();

  const actions = ownContent
    ? []
    : allowedActions.filter((a) => a !== 'SUSPEND_ACCOUNT' || canSuspend);
  const mine = assigneeId === meId;

  const close = () => {
    setAction(null);
    setError(null);
    setReason('');
    setDays('');
  };
  const done = () => {
    close();
    router.refresh();
  };

  const decide = (a: string, why: string, restrictDays?: number) => {
    const problem = validateDecision({ action: a, reason: why, restrictDays });
    if (problem) return setError(problem);
    attempt(() => decideCaseAction(caseId, a, why, restrictDays), done);
  };

  const assign = (to: string | null) => {
    setError(null);
    attempt(
      () => assignCaseAction(caseId, to),
      () => router.refresh(),
    );
  };

  const meta = action ? actionMeta(action) : null;

  return (
    <section className="card" aria-label="Moderation actions" style={{ padding: 20 }}>
      <h2>Decide</h2>
      <div className="row-actions" style={{ marginBottom: 12 }}>
        {mine ? (
          <button
            type="button"
            className="button secondary"
            disabled={pending}
            onClick={() => assign(null)}
          >
            Unassign
          </button>
        ) : (
          <button
            type="button"
            className="button secondary"
            disabled={pending}
            onClick={() => assign(meId)}
          >
            {assigneeId ? 'Take over' : 'Assign to me'}
          </button>
        )}
      </div>
      {ownContent ? (
        <p className="muted">
          This {targetLabel} is yours, so you cannot decide on it. Ask another moderator.
        </p>
      ) : actions.length === 0 ? (
        <p className="muted">No decisions are available for this case.</p>
      ) : (
        <div className="row-actions">
          {actions.map((a) => (
            <button
              key={a}
              type="button"
              className={`button ${actionMeta(a).tone === 'danger' ? 'danger' : ''}`.trim()}
              disabled={pending}
              onClick={() => {
                setError(null);
                setAction(a);
              }}
            >
              {actionMeta(a).label}
            </button>
          ))}
        </div>
      )}
      {error && action === null ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}

      <FormDialog
        open={action === 'RESTRICT_ACCOUNT'}
        title="Restrict account?"
        submitLabel="Restrict account"
        pending={pending}
        error={action === 'RESTRICT_ACCOUNT' ? error : null}
        onCancel={close}
        onSubmit={() => decide('RESTRICT_ACCOUNT', reason, days.trim() ? Number(days) : undefined)}
      >
        <p className="muted" style={{ margin: 0 }}>
          {actionMeta('RESTRICT_ACCOUNT').effect} Leave the days empty for a restriction that stays
          until a moderator restores the account. This is recorded in the audit log.
        </p>
        <label className="field">
          Days (1 to 365, optional)
          <input
            className="input"
            inputMode="numeric"
            value={days}
            onChange={(e) => setDays(e.target.value)}
          />
        </label>
        <label className="field">
          Reason for restriction (internal)
          <textarea
            className="textarea"
            value={reason}
            maxLength={REASON_MAX}
            onChange={(e) => setReason(e.target.value)}
          />
        </label>
      </FormDialog>

      <ConfirmDialog
        open={action !== null && action !== 'RESTRICT_ACCOUNT'}
        title={meta?.verb ?? ''}
        confirmLabel={meta?.verb ?? 'Confirm'}
        tone={meta?.tone ?? 'primary'}
        reasonLabel={
          action && actionNeedsReason(action) ? 'Reason (internal)' : 'Note (optional, internal)'
        }
        minReasonLength={action && actionNeedsReason(action) ? 5 : 0}
        pending={pending}
        error={action !== 'RESTRICT_ACCOUNT' ? error : null}
        onCancel={close}
        onConfirm={(why) => action && decide(action, why)}
      >
        <p className="muted" style={{ margin: 0 }}>
          {meta?.effect} The reason is never shown to reporters and is recorded in the audit log
          with your name.
        </p>
      </ConfirmDialog>

      <ReauthDialog {...reauth} />
    </section>
  );
}
