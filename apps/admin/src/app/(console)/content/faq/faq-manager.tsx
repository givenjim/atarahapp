'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import {
  deleteFaqAction,
  reorderFaqAction,
  saveFaqAction,
  setFaqPublishedAction,
} from '@/app/help-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import {
  ANSWER_MAX,
  emptyFaqForm,
  nextSortOrder,
  PUBLISHED_META,
  QUESTION_MAX,
  swapOrders,
  validateFaq,
  type FaqForm,
} from '@/lib/help';

export interface FaqEntry {
  id: string;
  question: string;
  answer: string;
  sortOrder: number;
  published: boolean;
}

/** The FAQ list: add, edit, publish, move up or down, and delete. */
export function FaqManager({ entries }: { entries: FaqEntry[] }) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [editing, setEditing] = useState<{ id: string | null; form: FaqForm } | null>(null);
  const [dialogError, setDialogError] = useState<string | null>(null);
  const [deleting, setDeleting] = useState<FaqEntry | null>(null);

  const run = (fn: () => Promise<{ ok: boolean; error?: string }>, after?: () => void) =>
    start(async () => {
      const res = await fn();
      if (res.ok) {
        setError(null);
        after?.();
        router.refresh();
      } else setError(res.error ?? 'Something went wrong.');
    });

  const move = (id: string, direction: 'up' | 'down') => {
    const updates = swapOrders(entries, id, direction);
    if (updates.length > 0) run(() => reorderFaqAction(updates));
  };

  const save = () => {
    if (!editing) return;
    const problem = validateFaq(editing.form);
    if (problem) return setDialogError(problem);
    start(async () => {
      const res = await saveFaqAction(editing.id, editing.form, nextSortOrder(entries));
      if (res.ok) {
        setEditing(null);
        setDialogError(null);
        router.refresh();
      } else setDialogError(res.error);
    });
  };

  const set = <K extends keyof FaqForm>(k: K, v: FaqForm[K]) =>
    setEditing((e) => (e ? { ...e, form: { ...e.form, [k]: v } } : e));

  return (
    <section className="card" aria-label="FAQ entries">
      <div className="toolbar">
        <span className="muted">{entries.length} entries</span>
        <button
          type="button"
          className="button"
          onClick={() => {
            setDialogError(null);
            setEditing({ id: null, form: emptyFaqForm() });
          }}
        >
          New question
        </button>
      </div>
      {error ? (
        <p className="alert" role="alert" style={{ margin: 16 }}>
          {error}
        </p>
      ) : null}
      {entries.length === 0 ? (
        <p className="empty">No questions yet.</p>
      ) : (
        <ol style={{ listStyle: 'none', padding: 16, margin: 0, display: 'grid', gap: 12 }}>
          {entries.map((e, i) => (
            <li key={e.id} className="card" style={{ padding: 14 }}>
              <div className="row-actions" style={{ justifyContent: 'space-between' }}>
                <strong>{e.question}</strong>
                <span className={`pill ${PUBLISHED_META(e.published).tone}`.trim()}>
                  {PUBLISHED_META(e.published).label}
                </span>
              </div>
              <p className="muted" style={{ margin: '6px 0 10px', whiteSpace: 'pre-wrap' }}>
                {e.answer}
              </p>
              <span className="row-actions">
                <button
                  type="button"
                  className="button secondary small"
                  onClick={() => {
                    setDialogError(null);
                    setEditing({
                      id: e.id,
                      form: { question: e.question, answer: e.answer, published: e.published },
                    });
                  }}
                >
                  Edit
                </button>
                <button
                  type="button"
                  className="button secondary small"
                  disabled={pending}
                  onClick={() => run(() => setFaqPublishedAction(e.id, !e.published))}
                >
                  {e.published ? 'Unpublish' : 'Publish'}
                </button>
                <button
                  type="button"
                  className="button secondary small"
                  aria-label={`Move “${e.question}” up`}
                  disabled={pending || i === 0}
                  onClick={() => move(e.id, 'up')}
                >
                  Up
                </button>
                <button
                  type="button"
                  className="button secondary small"
                  aria-label={`Move “${e.question}” down`}
                  disabled={pending || i === entries.length - 1}
                  onClick={() => move(e.id, 'down')}
                >
                  Down
                </button>
                <button
                  type="button"
                  className="button danger small"
                  aria-label={`Delete “${e.question}”`}
                  disabled={pending}
                  onClick={() => setDeleting(e)}
                >
                  Delete
                </button>
              </span>
            </li>
          ))}
        </ol>
      )}

      <FormDialog
        open={editing !== null}
        title={editing?.id ? 'Edit question' : 'New question'}
        submitLabel={editing?.id ? 'Save changes' : 'Add question'}
        pending={pending}
        error={dialogError}
        onSubmit={save}
        onCancel={() => {
          setEditing(null);
          setDialogError(null);
        }}
      >
        <label className="field">
          Question
          <input
            className="input"
            value={editing?.form.question ?? ''}
            maxLength={QUESTION_MAX}
            onChange={(e) => set('question', e.target.value)}
          />
        </label>
        <label className="field">
          Answer
          <textarea
            className="input"
            rows={5}
            value={editing?.form.answer ?? ''}
            maxLength={ANSWER_MAX}
            onChange={(e) => set('answer', e.target.value)}
          />
        </label>
        <label className="row-actions">
          <input
            type="checkbox"
            checked={editing?.form.published ?? true}
            onChange={(e) => set('published', e.target.checked)}
          />
          Published (visible to members)
        </label>
      </FormDialog>

      <ConfirmDialog
        open={deleting !== null}
        title="Delete this question?"
        confirmLabel="Delete question"
        tone="danger"
        pending={pending}
        error={error}
        onCancel={() => setDeleting(null)}
        onConfirm={() =>
          deleting &&
          run(
            () => deleteFaqAction(deleting.id),
            () => setDeleting(null),
          )
        }
      >
        <p>Members will no longer see “{deleting?.question}”. To hide it for now, unpublish it.</p>
      </ConfirmDialog>
    </section>
  );
}
