'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import {
  createTaxonomyItemAction,
  reorderTaxonomyAction,
  updateTaxonomyItemAction,
  type TaxonomyResult,
} from '@/app/taxonomy-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import { canReorder, KIND_INFO, moveId, validateItemForm, type TaxonomyKind } from '@/lib/taxonomy';

export interface TaxonomyItem {
  id: string;
  slug: string;
  name: string;
  icon: string | null;
  disciplineId: string | null;
  disciplineName: string | null;
  sortOrder: number;
  isActive: boolean;
  usage: number;
}

export interface DisciplineOption {
  id: string;
  name: string;
  isActive: boolean;
}

type Dialog =
  | { type: 'create' }
  | { type: 'edit'; item: TaxonomyItem }
  | { type: 'archive'; item: TaxonomyItem };

export function TaxonomyManager({
  kind,
  items,
  disciplines,
  disciplineId,
}: {
  kind: TaxonomyKind;
  items: TaxonomyItem[];
  disciplines: DisciplineOption[];
  disciplineId?: string;
}) {
  const info = KIND_INFO[kind];
  const router = useRouter();
  const [dialog, setDialog] = useState<Dialog | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [pageError, setPageError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  const reorderable = canReorder(info, disciplineId);
  const ids = items.map((i) => i.id);

  const close = () => {
    setDialog(null);
    setError(null);
  };

  /** Runs a server action; closes the dialog and refreshes on success, shows the message otherwise. */
  const run = (action: () => Promise<TaxonomyResult>, onError: (m: string) => void) =>
    start(async () => {
      const result = await action();
      if (result.ok) {
        close();
        setPageError(null);
        router.refresh();
      } else {
        onError(result.error);
      }
    });

  const move = (index: number, direction: 'up' | 'down') => {
    const next = moveId(ids, index, direction);
    if (!next) return;
    run(() => reorderTaxonomyAction(kind, next), setPageError);
  };

  const filterBy = (id: string) =>
    router.push(id ? `/taxonomy/${kind}?disciplineId=${id}` : `/taxonomy/${kind}`);

  return (
    <>
      <div className="toolbar">
        {info.scoped ? (
          <div className="filters">
            <label className="field">
              Discipline
              <select
                className="select"
                value={disciplineId ?? ''}
                onChange={(e) => filterBy(e.target.value)}
              >
                <option value="">All disciplines</option>
                {disciplines.map((d) => (
                  <option key={d.id} value={d.id}>
                    {d.name}
                    {d.isActive ? '' : ' (archived)'}
                  </option>
                ))}
              </select>
            </label>
          </div>
        ) : (
          <span />
        )}
        <button
          type="button"
          className="button"
          onClick={() => {
            setError(null);
            setDialog({ type: 'create' });
          }}
        >
          Add {info.noun}
        </button>
      </div>

      {info.scoped && !reorderable ? (
        <p className="muted notice">Choose a discipline to change the order of its entries.</p>
      ) : null}
      {pageError ? (
        <p className="alert notice" role="alert">
          {pageError}
        </p>
      ) : null}

      {items.length === 0 ? (
        <p className="empty">
          {disciplineId
            ? `No ${info.label.toLowerCase()} in this discipline yet.`
            : `No ${info.label.toLowerCase()} yet.`}
        </p>
      ) : (
        <div className="table-wrap">
          <table className="data">
            <caption className="sr-only" style={{ position: 'absolute', left: -9999 }}>
              {info.label}
            </caption>
            <thead>
              <tr>
                <th scope="col">Name</th>
                {info.hasIcon ? <th scope="col">Icon</th> : null}
                {info.scoped ? <th scope="col">Discipline</th> : null}
                <th scope="col">In use</th>
                <th scope="col">Status</th>
                <th scope="col">Actions</th>
              </tr>
            </thead>
            <tbody>
              {items.map((item, index) => (
                <tr key={item.id} className={item.isActive ? undefined : 'archived'}>
                  <td>{item.name}</td>
                  {info.hasIcon ? (
                    <td>
                      <code>{item.icon ?? '—'}</code>
                    </td>
                  ) : null}
                  {info.scoped ? <td>{item.disciplineName ?? 'General'}</td> : null}
                  <td>{item.usage}</td>
                  <td>
                    <span className={`pill ${item.isActive ? 'success' : 'muted'}`}>
                      {item.isActive ? 'Active' : 'Archived'}
                    </span>
                  </td>
                  <td>
                    <div className="row-actions">
                      <button
                        type="button"
                        className="button secondary small"
                        aria-label={`Move ${item.name} up`}
                        disabled={pending || !reorderable || index === 0}
                        onClick={() => move(index, 'up')}
                      >
                        Up
                      </button>
                      <button
                        type="button"
                        className="button secondary small"
                        aria-label={`Move ${item.name} down`}
                        disabled={pending || !reorderable || index === items.length - 1}
                        onClick={() => move(index, 'down')}
                      >
                        Down
                      </button>
                      <button
                        type="button"
                        className="button secondary small"
                        aria-label={`Edit ${item.name}`}
                        onClick={() => {
                          setError(null);
                          setDialog({ type: 'edit', item });
                        }}
                      >
                        Edit
                      </button>
                      <button
                        type="button"
                        className={`button small ${item.isActive ? 'danger' : ''}`}
                        aria-label={`${item.isActive ? 'Archive' : 'Restore'} ${item.name}`}
                        onClick={() => {
                          setError(null);
                          setDialog({ type: 'archive', item });
                        }}
                      >
                        {item.isActive ? 'Archive' : 'Restore'}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {dialog && dialog.type !== 'archive' ? (
        <ItemFormDialog
          key={dialog.type === 'edit' ? dialog.item.id : 'create'}
          kind={kind}
          mode={dialog.type}
          item={dialog.type === 'edit' ? dialog.item : undefined}
          disciplines={disciplines}
          defaultDisciplineId={disciplineId}
          pending={pending}
          error={error}
          onCancel={close}
          onSubmit={(input) =>
            run(
              () =>
                dialog.type === 'edit'
                  ? updateTaxonomyItemAction(kind, dialog.item.id, {
                      name: input.name,
                      ...(info.hasIcon ? { icon: input.icon } : {}),
                    })
                  : createTaxonomyItemAction(kind, input),
              setError,
            )
          }
        />
      ) : null}

      <ConfirmDialog
        open={dialog?.type === 'archive'}
        title={
          dialog?.type === 'archive'
            ? `${dialog.item.isActive ? 'Archive' : 'Restore'} ${dialog.item.name}?`
            : ''
        }
        confirmLabel={dialog?.type === 'archive' && !dialog.item.isActive ? 'Restore' : 'Archive'}
        tone={dialog?.type === 'archive' && !dialog.item.isActive ? 'primary' : 'danger'}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={() => {
          if (dialog?.type !== 'archive') return;
          const item = dialog.item;
          run(
            () => updateTaxonomyItemAction(kind, item.id, { isActive: !item.isActive }),
            setError,
          );
        }}
      >
        <p className="muted" style={{ margin: 0 }}>
          {dialog?.type === 'archive' && !dialog.item.isActive
            ? 'It will appear in the lists members choose from again.'
            : 'It disappears from the lists members choose from. Profiles that already use it keep it. You can restore it later.'}
        </p>
      </ConfirmDialog>
    </>
  );
}

function ItemFormDialog({
  kind,
  mode,
  item,
  disciplines,
  defaultDisciplineId,
  pending,
  error,
  onSubmit,
  onCancel,
}: {
  kind: TaxonomyKind;
  mode: 'create' | 'edit';
  item?: TaxonomyItem;
  disciplines: DisciplineOption[];
  defaultDisciplineId?: string;
  pending: boolean;
  error: string | null;
  onSubmit: (input: { name: string; icon: string; disciplineId: string }) => void;
  onCancel: () => void;
}) {
  const info = KIND_INFO[kind];
  const [name, setName] = useState(item?.name ?? '');
  const [icon, setIcon] = useState(item?.icon ?? '');
  const [disciplineId, setDisciplineId] = useState(defaultDisciplineId ?? '');
  const [localError, setLocalError] = useState<string | null>(null);

  const submit = () => {
    const input = { name, icon, disciplineId };
    const problem = validateItemForm(info, input, mode);
    setLocalError(problem);
    if (!problem) onSubmit(input);
  };

  return (
    <FormDialog
      open
      title={mode === 'create' ? `Add ${info.noun}` : `Edit ${item?.name ?? info.noun}`}
      submitLabel={mode === 'create' ? 'Add' : 'Save'}
      pending={pending}
      error={localError ?? error}
      onSubmit={submit}
      onCancel={onCancel}
    >
      <label className="field">
        Name
        <input
          className="input"
          name="name"
          value={name}
          maxLength={60}
          onChange={(e) => setName(e.target.value)}
        />
      </label>
      {info.hasIcon ? (
        <label className="field">
          Icon (Lucide name)
          <input
            className="input"
            name="icon"
            value={icon}
            maxLength={40}
            placeholder="palette"
            onChange={(e) => setIcon(e.target.value)}
          />
        </label>
      ) : null}
      {info.scoped && mode === 'create' ? (
        <label className="field">
          Discipline{info.disciplineRequired ? '' : ' (optional)'}
          <select
            className="select"
            name="disciplineId"
            value={disciplineId}
            onChange={(e) => setDisciplineId(e.target.value)}
          >
            <option value="">{info.disciplineRequired ? 'Choose a discipline' : 'General'}</option>
            {disciplines
              .filter((d) => d.isActive)
              .map((d) => (
                <option key={d.id} value={d.id}>
                  {d.name}
                </option>
              ))}
          </select>
        </label>
      ) : null}
    </FormDialog>
  );
}
