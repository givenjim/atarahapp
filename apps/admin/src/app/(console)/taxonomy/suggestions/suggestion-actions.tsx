'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import {
  approveSuggestionAction,
  listSpecialisationsAction,
  mergeSuggestionAction,
  rejectSuggestionAction,
  type SpecialisationOption,
  type TaxonomyResult,
} from '@/app/taxonomy-actions';
import { FormDialog } from '@/components/ui/form-dialog';
import { validateName } from '@/lib/taxonomy';

type Mode = 'approve' | 'merge' | 'reject';

export function SuggestionActions({
  id,
  name,
  disciplineId,
  disciplineName,
}: {
  id: string;
  name: string;
  disciplineId: string;
  disciplineName: string;
}) {
  const router = useRouter();
  const [mode, setMode] = useState<Mode | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  // Approve: optional corrected name. Merge: the existing entry. Reject: optional note.
  const [corrected, setCorrected] = useState('');
  const [note, setNote] = useState('');
  const [target, setTarget] = useState('');
  const [options, setOptions] = useState<SpecialisationOption[] | null>(null);

  const close = () => {
    setMode(null);
    setError(null);
  };

  const finish = (result: TaxonomyResult) => {
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
    if (m === 'merge' && options === null) {
      start(async () => {
        const res = await listSpecialisationsAction(disciplineId);
        if (res.ok) setOptions(res.items);
        else setError(res.error);
      });
    }
  };

  const submit = () => {
    if (mode === 'approve') {
      if (corrected.trim()) {
        const problem = validateName(corrected);
        if (problem) return setError(problem);
      }
      start(async () => finish(await approveSuggestionAction(id, corrected)));
    } else if (mode === 'merge') {
      if (!target) return setError('Choose the specialisation to merge into.');
      start(async () => finish(await mergeSuggestionAction(id, target)));
    } else if (mode === 'reject') {
      start(async () => finish(await rejectSuggestionAction(id, note)));
    }
  };

  return (
    <>
      <div className="row-actions">
        <button
          type="button"
          className="button small"
          aria-label={`Approve ${name}`}
          onClick={() => open('approve')}
        >
          Approve
        </button>
        <button
          type="button"
          className="button secondary small"
          aria-label={`Merge ${name}`}
          onClick={() => open('merge')}
        >
          Merge
        </button>
        <button
          type="button"
          className="button danger small"
          aria-label={`Reject ${name}`}
          onClick={() => open('reject')}
        >
          Reject
        </button>
      </div>

      <FormDialog
        open={mode === 'approve'}
        title={`Approve “${name}”`}
        submitLabel="Approve"
        pending={pending}
        error={mode === 'approve' ? error : null}
        onSubmit={submit}
        onCancel={close}
      >
        <p className="muted" style={{ margin: 0 }}>
          It is added to {disciplineName} and to the suggester&apos;s profile if it is their main
          discipline.
        </p>
        <label className="field">
          Corrected name (optional)
          <input
            className="input"
            value={corrected}
            maxLength={60}
            placeholder={name}
            onChange={(e) => setCorrected(e.target.value)}
          />
        </label>
      </FormDialog>

      <FormDialog
        open={mode === 'merge'}
        title={`Merge “${name}”`}
        submitLabel="Merge"
        pending={pending}
        error={mode === 'merge' ? error : null}
        onSubmit={submit}
        onCancel={close}
      >
        <p className="muted" style={{ margin: 0 }}>
          Use this when {disciplineName} already has an entry for the same thing.
        </p>
        <label className="field">
          Existing specialisation
          <select
            className="select"
            value={target}
            disabled={options === null}
            onChange={(e) => setTarget(e.target.value)}
          >
            <option value="">{options === null ? 'Loading…' : 'Choose one'}</option>
            {(options ?? []).map((o) => (
              <option key={o.id} value={o.id}>
                {o.name}
              </option>
            ))}
          </select>
        </label>
        {options !== null && options.length === 0 ? (
          <p className="muted" style={{ margin: 0 }}>
            {disciplineName} has no other specialisations to merge into.
          </p>
        ) : null}
      </FormDialog>

      <FormDialog
        open={mode === 'reject'}
        title={`Reject “${name}”`}
        submitLabel="Reject"
        pending={pending}
        error={mode === 'reject' ? error : null}
        onSubmit={submit}
        onCancel={close}
      >
        <label className="field">
          Note (optional)
          <textarea
            className="textarea"
            value={note}
            maxLength={500}
            onChange={(e) => setNote(e.target.value)}
          />
        </label>
      </FormDialog>
    </>
  );
}
