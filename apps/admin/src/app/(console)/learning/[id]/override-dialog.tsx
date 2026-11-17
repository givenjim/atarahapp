'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { progressOverrideAction } from '@/app/learning-actions';
import { FormDialog } from '@/components/ui/form-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import {
  emptyOverride,
  OVERRIDE_ACTIONS,
  OVERRIDE_LABELS,
  validateOverride,
  type OverrideForm,
} from '@/lib/learning';

/**
 * An explicit, reasoned correction to one member's progress in a course. It needs a fresh authenticator code, and it is
 * recorded with its reason in the audit log. It never edits what a member watched, and a certificate that was already
 * issued stays.
 */
export function OverrideDialog({
  courseId,
  lessons,
}: {
  courseId: string;
  lessons: Array<{ id: string; sequence: number; title: string }>;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [f, setF] = useState<OverrideForm>(emptyOverride());
  const { attempt, pending, error, setError, reauth } = useReauth();
  const set = <K extends keyof OverrideForm>(k: K, v: OverrideForm[K]) =>
    setF((p) => ({ ...p, [k]: v }));

  const close = () => {
    setOpen(false);
    setError(null);
  };
  const submit = () => {
    const problem = validateOverride(f);
    if (problem) return setError(problem);
    attempt(
      () => progressOverrideAction(courseId, f),
      () => {
        close();
        setF(emptyOverride());
        router.refresh();
      },
    );
  };

  return (
    <>
      <button type="button" className="button secondary" onClick={() => setOpen(true)}>
        Progress override
      </button>
      <FormDialog
        open={open}
        title="Progress override"
        submitLabel="Apply override"
        pending={pending}
        error={open ? error : null}
        onSubmit={submit}
        onCancel={close}
      >
        <p className="muted" style={{ marginTop: 0 }}>
          Use this to fix a member’s progress, for example after a workshop held offline. It needs a
          fresh authenticator code and is recorded with your reason in the audit log. A certificate
          that was already issued stays.
        </p>
        <label className="field">
          Member (user id)
          <input
            className="input"
            value={f.userId}
            placeholder="Copy the id from the member’s page"
            onChange={(e) => set('userId', e.target.value)}
          />
        </label>
        <label className="field">
          What to do
          <select
            className="select"
            value={f.action}
            onChange={(e) => set('action', e.target.value as OverrideForm['action'])}
          >
            {OVERRIDE_ACTIONS.map((a) => (
              <option key={a} value={a}>
                {OVERRIDE_LABELS[a]}
              </option>
            ))}
          </select>
        </label>
        {f.action !== 'RESET_COURSE' ? (
          <label className="field">
            Lesson
            <select
              className="select"
              value={f.lessonId}
              onChange={(e) => set('lessonId', e.target.value)}
            >
              <option value="">Choose a lesson</option>
              {lessons.map((l) => (
                <option key={l.id} value={l.id}>
                  {l.sequence}. {l.title}
                </option>
              ))}
            </select>
          </label>
        ) : null}
        <label className="field">
          Reason (kept in the audit log)
          <textarea
            className="textarea"
            rows={3}
            maxLength={400}
            value={f.reason}
            onChange={(e) => set('reason', e.target.value)}
          />
        </label>
      </FormDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}
