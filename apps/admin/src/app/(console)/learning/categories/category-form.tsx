'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { saveCategoryAction } from '@/app/learning-actions';
import { FormDialog } from '@/components/ui/form-dialog';
import {
  emptyCategoryForm,
  GROUPS,
  groupLabel,
  validateCategory,
  type CategoryForm,
} from '@/lib/learning';

/** Add a category, or edit one (`id` and `initial` set). */
export function CategoryFormDialog({ id, initial }: { id?: string; initial?: CategoryForm }) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [f, setF] = useState<CategoryForm>(initial ?? emptyCategoryForm());
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const set = <K extends keyof CategoryForm>(k: K, v: CategoryForm[K]) =>
    setF((p) => ({ ...p, [k]: v }));
  const creating = !id;

  const close = () => {
    setOpen(false);
    setError(null);
  };
  const submit = () => {
    const problem = validateCategory(f);
    if (problem) return setError(problem);
    start(async () => {
      const res = await saveCategoryAction(id ?? null, f);
      if (res.ok) {
        close();
        if (creating) setF(emptyCategoryForm());
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
        {creating ? 'New category' : 'Edit'}
      </button>
      <FormDialog
        open={open}
        title={creating ? 'New category' : 'Edit category'}
        submitLabel={creating ? 'Add category' : 'Save changes'}
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
            maxLength={60}
            onChange={(e) => set('name', e.target.value)}
          />
        </label>
        <label className="field">
          Group
          <select className="select" value={f.group} onChange={(e) => set('group', e.target.value)}>
            {GROUPS.map((g) => (
              <option key={g} value={g}>
                {groupLabel(g)}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Order in its group
          <input
            className="input"
            inputMode="numeric"
            value={f.sortOrder}
            placeholder="Last"
            onChange={(e) => set('sortOrder', e.target.value)}
          />
        </label>
        <label style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
          <input
            type="checkbox"
            checked={f.isActive}
            onChange={(e) => set('isActive', e.target.checked)}
          />
          Active (shown to members)
        </label>
      </FormDialog>
    </>
  );
}
