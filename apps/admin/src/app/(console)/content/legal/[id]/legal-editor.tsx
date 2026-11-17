'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { publishLegalAction, saveLegalAction } from '@/app/help-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { LEGAL_BODY_MAX, LEGAL_TITLE_MAX, validateLegalForm, type LegalForm } from '@/lib/help';

/**
 * Edit a draft (title and text) and publish it. A published or archived version is shown read-only. Publishing asks
 * for a fresh authenticator code because it changes what every member agrees to.
 */
export function LegalEditor({
  id,
  editable,
  initial,
}: {
  id: string;
  editable: boolean;
  initial: LegalForm;
}) {
  const router = useRouter();
  const [f, setF] = useState<LegalForm>(initial);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [pending, start] = useTransition();
  const [publishing, setPublishing] = useState(false);
  const [effective, setEffective] = useState('');
  const {
    attempt,
    pending: publishPending,
    error: publishError,
    setError: setPublishError,
    reauth,
  } = useReauth();
  const set = <K extends keyof LegalForm>(k: K, v: LegalForm[K]) => {
    setSaved(false);
    setF((p) => ({ ...p, [k]: v }));
  };

  const save = () => {
    const problem = validateLegalForm(f, 'edit');
    if (problem) return setError(problem);
    setError(null);
    start(async () => {
      const res = await saveLegalAction(id, f);
      if (res.ok) {
        setSaved(true);
        router.refresh();
      } else setError(res.error);
    });
  };

  const closePublish = () => {
    setPublishing(false);
    setPublishError(null);
  };

  const dirty = f.title !== initial.title || f.body !== initial.body;

  return (
    <>
      <form
        className="card"
        style={{ padding: 20, display: 'grid', gap: 16, maxWidth: 800 }}
        onSubmit={(e) => {
          e.preventDefault();
          if (editable) save();
        }}
        noValidate
      >
        <label className="field">
          Title
          <input
            className="input"
            value={f.title}
            maxLength={LEGAL_TITLE_MAX}
            readOnly={!editable}
            onChange={(e) => set('title', e.target.value)}
          />
        </label>
        <label className="field">
          Text
          <textarea
            className="input"
            rows={18}
            value={f.body}
            maxLength={LEGAL_BODY_MAX}
            readOnly={!editable}
            onChange={(e) => set('body', e.target.value)}
          />
        </label>
        {error ? (
          <p className="alert" role="alert">
            {error}
          </p>
        ) : null}
        {saved ? <p role="status">Saved.</p> : null}
        {editable ? (
          <div className="row-actions">
            <button className="button" type="submit" disabled={pending}>
              {pending ? 'Saving…' : 'Save draft'}
            </button>
            <button
              type="button"
              className="button secondary"
              disabled={pending || dirty}
              title={dirty ? 'Save your changes first' : undefined}
              onClick={() => setPublishing(true)}
            >
              Publish this version
            </button>
            {dirty ? <span className="muted">Save before publishing.</span> : null}
          </div>
        ) : null}
      </form>

      <ConfirmDialog
        open={publishing}
        title={`Publish version ${initial.version}?`}
        confirmLabel="Publish"
        pending={publishPending}
        error={publishError}
        onCancel={closePublish}
        onConfirm={() =>
          attempt(
            () => publishLegalAction(id, effective),
            () => {
              closePublish();
              router.refresh();
            },
          )
        }
      >
        <p>
          Members will see this version as the current one. The version it replaces is archived;
          members who already accepted it are unaffected, and the record of what they accepted
          stays. This cannot be undone: to change the wording afterwards you add another version.
        </p>
        <label className="field">
          Effective from (Nairobi time, optional)
          <input
            className="input"
            type="datetime-local"
            value={effective}
            onChange={(e) => setEffective(e.target.value)}
          />
          <span className="muted">Leave blank for now.</span>
        </label>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}
