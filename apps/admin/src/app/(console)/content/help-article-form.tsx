'use client';

import { useRouter } from 'next/navigation';
import { useReducer, useRef, useState, useTransition } from 'react';
import { saveHelpArticleAction } from '@/app/help-actions';
import {
  BLOCK_LABELS,
  blocksReducer,
  type BlockAction,
  type BlockType,
  type EditorBlock,
} from '@/lib/articles';
import {
  ARTICLE_SUMMARY_MAX,
  ARTICLE_TITLE_MAX,
  HELP_BLOCK_TYPES,
  slugFromTitle,
  validateHelpArticle,
  type HelpArticleForm as Form,
} from '@/lib/help';
import { BlockFields } from '../articles/[id]/article-editor';

/** Create or edit a help article. The address (slug) is chosen at creation and then fixed. `id` null means a new one. */
export function HelpArticleForm({ id, initial }: { id: string | null; initial: Form }) {
  const router = useRouter();
  const [f, setF] = useState<Form>(initial);
  const [slugTouched, setSlugTouched] = useState(Boolean(id));
  const [blocks, dispatch] = useReducer(
    (state: EditorBlock[], action: BlockAction) => blocksReducer(state, action),
    initial.blocks,
  );
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [pending, start] = useTransition();
  const counter = useRef(0);
  const nextKey = () => `help-block-${(counter.current += 1)}`;
  const mode = id ? 'edit' : 'create';
  const form: Form = { ...f, blocks };
  const set = <K extends keyof Form>(k: K, v: Form[K]) => {
    setSaved(false);
    setF((p) => ({ ...p, [k]: v }));
  };

  const submit = () => {
    const problem = validateHelpArticle(form, mode);
    if (problem) return setError(problem);
    setError(null);
    start(async () => {
      const res = await saveHelpArticleAction(id, form);
      if (res.ok) {
        if (!id && res.id) router.push(`/content/${res.id}`);
        else {
          setSaved(true);
          router.refresh();
        }
      } else setError(res.error);
    });
  };

  return (
    <form
      className="card"
      style={{ padding: 20, display: 'grid', gap: 16, maxWidth: 800 }}
      onSubmit={(e) => {
        e.preventDefault();
        submit();
      }}
      noValidate
    >
      <label className="field">
        Title
        <input
          className="input"
          value={f.title}
          maxLength={ARTICLE_TITLE_MAX}
          onChange={(e) => {
            set('title', e.target.value);
            if (!slugTouched) setF((p) => ({ ...p, slug: slugFromTitle(e.target.value) }));
          }}
        />
      </label>
      <label className="field">
        Address
        <input
          className="input"
          value={f.slug}
          disabled={Boolean(id)}
          onChange={(e) => {
            setSlugTouched(true);
            set('slug', e.target.value);
          }}
        />
        <span className="muted">
          {id
            ? 'The address never changes, so links keep working.'
            : 'Lower-case words separated by dashes. It cannot be changed after saving.'}
        </span>
      </label>
      <label className="field">
        Summary
        <textarea
          className="input"
          rows={2}
          value={f.summary}
          maxLength={ARTICLE_SUMMARY_MAX}
          onChange={(e) => set('summary', e.target.value)}
        />
        <span className="muted">
          {f.summary.length}/{ARTICLE_SUMMARY_MAX}. Shown under the title in search results.
        </span>
      </label>

      <div className="field">
        <strong>Text</strong>
        {blocks.length === 0 ? <p className="muted">No text yet. Add a block below.</p> : null}
        <ol style={{ listStyle: 'none', padding: 0, margin: 0, display: 'grid', gap: 12 }}>
          {blocks.map((b, i) => (
            <li key={b.key} className="card" style={{ padding: 12 }}>
              <BlockFields
                block={b}
                index={i}
                last={i === blocks.length - 1}
                disabled={pending}
                onChange={(patch) => dispatch({ kind: 'update', key: b.key, patch })}
                onMove={(direction) => dispatch({ kind: 'move', key: b.key, direction })}
                onRemove={() => dispatch({ kind: 'remove', key: b.key })}
              />
            </li>
          ))}
        </ol>
        <div className="row-actions" role="group" aria-label="Add a block">
          {HELP_BLOCK_TYPES.map((t: BlockType) => (
            <button
              key={t}
              type="button"
              className="button secondary small"
              disabled={pending}
              onClick={() => dispatch({ kind: 'add', key: nextKey(), type: t })}
            >
              Add {BLOCK_LABELS[t].toLowerCase()}
            </button>
          ))}
        </div>
      </div>

      <div className="filters">
        <label className="field">
          Order
          <input
            className="input"
            inputMode="numeric"
            style={{ width: 110 }}
            value={f.sortOrder}
            placeholder="Last"
            onChange={(e) => set('sortOrder', e.target.value)}
          />
          <span className="muted">Lower numbers come first.</span>
        </label>
        <label className="row-actions" style={{ alignSelf: 'end' }}>
          <input
            type="checkbox"
            checked={f.published}
            onChange={(e) => set('published', e.target.checked)}
          />
          Published (visible to members)
        </label>
      </div>

      {error ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}
      {saved ? <p role="status">Saved.</p> : null}
      <div className="row-actions">
        <button className="button" type="submit" disabled={pending}>
          {pending ? 'Saving…' : id ? 'Save changes' : 'Create article'}
        </button>
      </div>
    </form>
  );
}
