'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import {
  hideProjectAction,
  restoreProjectAction,
  type PortfolioResult,
} from '@/app/portfolio-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import { HIDE_REASON_MAX, validateHideReason } from '@/lib/portfolio';

type Mode = 'hide' | 'restore';

export function ProjectActions({
  id,
  title,
  hidden,
}: {
  id: string;
  title: string;
  hidden: boolean;
}) {
  const router = useRouter();
  const [mode, setMode] = useState<Mode | null>(null);
  const [reason, setReason] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  const close = () => {
    setMode(null);
    setError(null);
    setReason('');
  };

  const finish = (result: PortfolioResult) => {
    if (result.ok) {
      close();
      router.refresh();
    } else {
      setError(result.error);
    }
  };

  const open = (m: Mode) => {
    setError(null);
    setMode(m);
  };

  const submitHide = () => {
    const problem = validateHideReason(reason);
    if (problem) return setError(problem);
    start(async () => finish(await hideProjectAction(id, reason)));
  };

  return (
    <section className="card" aria-label="Moderation actions" style={{ padding: 20 }}>
      {hidden ? (
        <button type="button" className="button" onClick={() => open('restore')}>
          Restore project
        </button>
      ) : (
        <button type="button" className="button danger" onClick={() => open('hide')}>
          Hide project
        </button>
      )}

      <FormDialog
        open={mode === 'hide'}
        title={`Hide “${title}”?`}
        submitLabel="Hide project"
        pending={pending}
        error={mode === 'hide' ? error : null}
        onSubmit={submitHide}
        onCancel={close}
      >
        <p className="muted" style={{ margin: 0 }}>
          The project disappears from the public profile and search straight away. The owner keeps
          their copy. This is recorded in the audit log with your name.
        </p>
        <label className="field">
          Reason for hiding
          <textarea
            className="textarea"
            value={reason}
            maxLength={HIDE_REASON_MAX}
            onChange={(e) => setReason(e.target.value)}
          />
        </label>
      </FormDialog>

      <ConfirmDialog
        open={mode === 'restore'}
        title={`Restore “${title}”?`}
        confirmLabel="Restore project"
        pending={pending}
        error={mode === 'restore' ? error : null}
        onCancel={close}
        onConfirm={() => start(async () => finish(await restoreProjectAction(id)))}
      >
        <p className="muted" style={{ margin: 0 }}>
          The project becomes visible again according to its own visibility setting.
        </p>
      </ConfirmDialog>
    </section>
  );
}
