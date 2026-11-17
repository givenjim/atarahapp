'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { saveLegalAction } from '@/app/help-actions';
import { FormDialog } from '@/components/ui/form-dialog';
import {
  emptyLegalForm,
  LEGAL_BODY_MAX,
  LEGAL_LABELS,
  LEGAL_TITLE_MAX,
  LEGAL_TYPES,
  validateLegalForm,
  VERSION_MAX,
  type LegalForm,
} from '@/lib/help';

/** Start a new version of a legal document as a draft. It is not shown to members until it is published. */
export function NewLegalVersion() {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [f, setF] = useState<LegalForm>(emptyLegalForm());
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const set = <K extends keyof LegalForm>(k: K, v: LegalForm[K]) => setF((p) => ({ ...p, [k]: v }));
  const close = () => {
    setOpen(false);
    setError(null);
  };
  const submit = () => {
    const problem = validateLegalForm(f, 'create');
    if (problem) return setError(problem);
    start(async () => {
      const res = await saveLegalAction(null, f);
      if (res.ok) {
        close();
        setF(emptyLegalForm());
        if (res.id) router.push(`/content/legal/${res.id}`);
        else router.refresh();
      } else setError(res.error);
    });
  };

  return (
    <>
      <button type="button" className="button" onClick={() => setOpen(true)}>
        New version
      </button>
      <FormDialog
        open={open}
        title="New version"
        submitLabel="Create draft"
        pending={pending}
        error={error}
        onSubmit={submit}
        onCancel={close}
      >
        <label className="field">
          Document
          <select className="select" value={f.type} onChange={(e) => set('type', e.target.value)}>
            {LEGAL_TYPES.map((t) => (
              <option key={t} value={t}>
                {LEGAL_LABELS[t]}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Version
          <input
            className="input"
            value={f.version}
            maxLength={VERSION_MAX}
            placeholder="2026.2"
            onChange={(e) => set('version', e.target.value)}
          />
        </label>
        <label className="field">
          Title
          <input
            className="input"
            value={f.title}
            maxLength={LEGAL_TITLE_MAX}
            onChange={(e) => set('title', e.target.value)}
          />
        </label>
        <label className="field">
          Text
          <textarea
            className="input"
            rows={10}
            value={f.body}
            maxLength={LEGAL_BODY_MAX}
            onChange={(e) => set('body', e.target.value)}
          />
        </label>
      </FormDialog>
    </>
  );
}
