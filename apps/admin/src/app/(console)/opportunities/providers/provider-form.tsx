'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { saveProviderAction } from '@/app/opportunity-actions';
import { FormDialog } from '@/components/ui/form-dialog';
import {
  emptyProviderForm,
  PROVIDER_TYPES,
  titleCase,
  validateProvider,
  type ProviderForm,
} from '@/lib/opportunities';

/** Add a provider, or edit one (`id` and `initial` set). */
export function ProviderFormDialog({ id, initial }: { id?: string; initial?: ProviderForm }) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [f, setF] = useState<ProviderForm>(initial ?? emptyProviderForm());
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const set = <K extends keyof ProviderForm>(k: K, v: ProviderForm[K]) =>
    setF((p) => ({ ...p, [k]: v }));
  const creating = !id;

  const close = () => {
    setOpen(false);
    setError(null);
  };
  const submit = () => {
    const problem = validateProvider(f);
    if (problem) return setError(problem);
    start(async () => {
      const res = await saveProviderAction(id ?? null, f);
      if (res.ok) {
        close();
        if (creating) setF(emptyProviderForm());
        router.refresh();
      } else {
        setError(res.error);
      }
    });
  };

  return (
    <>
      <button
        type="button"
        className={`button ${creating ? '' : 'secondary small'}`.trim()}
        onClick={() => setOpen(true)}
      >
        {creating ? 'New provider' : 'Edit'}
      </button>
      <FormDialog
        open={open}
        title={creating ? 'New provider' : 'Edit provider'}
        submitLabel={creating ? 'Add provider' : 'Save changes'}
        pending={pending}
        error={error}
        onSubmit={submit}
        onCancel={close}
      >
        <label className="field">
          Name
          <input
            className="input"
            value={f.name}
            maxLength={120}
            onChange={(e) => set('name', e.target.value)}
          />
        </label>
        <label className="field">
          Type
          <select className="select" value={f.type} onChange={(e) => set('type', e.target.value)}>
            {PROVIDER_TYPES.map((t) => (
              <option key={t} value={t}>
                {titleCase(t)}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Website
          <input
            className="input"
            type="url"
            value={f.website}
            placeholder="https://"
            onChange={(e) => set('website', e.target.value)}
          />
        </label>
        <label className="field">
          Owner user id (optional)
          <input
            className="input"
            value={f.ownerUserId}
            placeholder="Copy from the member's user page"
            onChange={(e) => set('ownerUserId', e.target.value)}
          />
          <span className="muted">The account that may submit listings for this provider.</span>
        </label>
      </FormDialog>
    </>
  );
}
