'use client';

import { useRouter } from 'next/navigation';
import { useReducer, useRef, useState, useTransition } from 'react';
import { saveArticleAction } from '@/app/articles-actions';
import {
  addTags,
  blocksFromApi,
  blocksReducer,
  BLOCK_LABELS,
  BLOCK_TYPES,
  BYLINE_MAX,
  draftsEqual,
  isEditable,
  removeTag,
  SOURCE_OPTIONS,
  sourceNeedsLabel,
  submitGaps,
  TITLE_MAX,
  toUpdateBody,
  validateDraft,
  type ArticleDraft,
  type ArticleSource,
  type ArticleStatus,
  type BlockType,
  type EditorBlock,
} from '@/lib/articles';
import { ArticleLifecycle } from './article-lifecycle';
import { ImageField } from './image-field';

export interface EditableArticle {
  id: string;
  status: ArticleStatus;
  title: string;
  authorName: string;
  summary: string;
  source: ArticleSource;
  sourceLabel: string;
  heroMediaId: string;
  heroUrl: string;
  tags: string[];
  readMinutes: number;
  blocks: Parameters<typeof blocksFromApi>[0];
}

export function ArticleEditor({ article }: { article: EditableArticle }) {
  const router = useRouter();
  const counter = useRef(0);
  const nextKey = () => `b${counter.current++}`;

  const [fields, setFields] = useState(() => ({
    title: article.title,
    authorName: article.authorName,
    summary: article.summary,
    source: article.source,
    sourceLabel: article.sourceLabel,
    heroMediaId: article.heroMediaId,
    tags: article.tags,
  }));
  const [heroUrl, setHeroUrl] = useState(article.heroUrl);
  const [blocks, dispatch] = useReducer(blocksReducer, article.blocks, (b) =>
    blocksFromApi(b, (i) => `init${i}`),
  );
  const [tagInput, setTagInput] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [pending, start] = useTransition();

  const draft: ArticleDraft = { ...fields, blocks };
  // The last saved state, to know whether there is anything unsaved.
  const [baseline, setBaseline] = useState<ArticleDraft>(draft);
  const dirty = !draftsEqual(draft, baseline);
  const editable = isEditable(article.status);
  const disabled = !editable || pending;

  const set = <K extends keyof typeof fields>(k: K, v: (typeof fields)[K]) => {
    setSaved(false);
    setFields((f) => ({ ...f, [k]: v }));
  };
  const edit: typeof dispatch = (a) => {
    setSaved(false);
    dispatch(a);
  };

  const commitTags = (raw: string) => {
    if (raw.trim()) set('tags', addTags(fields.tags, raw));
    setTagInput('');
  };

  const save = () => {
    // A tag typed but not yet committed is part of what the editor sees, so include it.
    const toSave: ArticleDraft = tagInput.trim()
      ? { ...draft, tags: addTags(fields.tags, tagInput) }
      : draft;
    const problem = validateDraft(toSave);
    if (problem) return setError(problem);
    setError(null);
    start(async () => {
      const result = await saveArticleAction(article.id, toUpdateBody(toSave));
      if (result.ok) {
        if (tagInput.trim()) {
          set('tags', toSave.tags);
          setTagInput('');
        }
        setBaseline(toSave);
        setSaved(true);
        router.refresh();
      } else {
        setError(result.error);
      }
    });
  };

  const gaps = submitGaps(draft);

  return (
    <>
      {!editable ? (
        <p className="notice alert" role="status">
          This article is archived, so it is read-only. Restore it to a draft to edit it.
        </p>
      ) : null}

      <section className="card" aria-label="Details" style={{ padding: 20 }}>
        <label className="field">
          Title
          <input
            className="input"
            value={fields.title}
            maxLength={TITLE_MAX}
            disabled={disabled}
            onChange={(e) => set('title', e.target.value)}
          />
        </label>
        <label className="field">
          Byline
          <input
            className="input"
            value={fields.authorName}
            maxLength={BYLINE_MAX}
            disabled={disabled}
            onChange={(e) => set('authorName', e.target.value)}
          />
        </label>
        <label className="field">
          Summary
          <textarea
            className="textarea"
            value={fields.summary}
            disabled={disabled}
            onChange={(e) => set('summary', e.target.value)}
          />
        </label>
        <label className="field">
          Source
          <select
            className="select"
            value={fields.source}
            disabled={disabled}
            onChange={(e) => set('source', e.target.value as ArticleSource)}
          >
            {SOURCE_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Source label{sourceNeedsLabel(fields.source) ? ' (required)' : ' (optional)'}
          <input
            className="input"
            value={fields.sourceLabel}
            disabled={disabled}
            placeholder={sourceNeedsLabel(fields.source) ? 'Who this article came from' : ''}
            onChange={(e) => set('sourceLabel', e.target.value)}
          />
        </label>
        <div className="field">
          <label htmlFor="tag-input">Tags</label>
          <div className="row-actions" aria-label="Current tags">
            {fields.tags.length === 0 ? <span className="muted">No tags.</span> : null}
            {fields.tags.map((t) => (
              <span key={t} className="pill">
                {t}{' '}
                <button
                  type="button"
                  className="button secondary small"
                  aria-label={`Remove tag ${t}`}
                  disabled={disabled}
                  onClick={() => set('tags', removeTag(fields.tags, t))}
                >
                  ×
                </button>
              </span>
            ))}
          </div>
          <input
            id="tag-input"
            className="input"
            value={tagInput}
            disabled={disabled}
            placeholder="Type a tag, then press Enter or comma"
            onChange={(e) => {
              const v = e.target.value;
              if (v.includes(',')) commitTags(v);
              else setTagInput(v);
            }}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                e.preventDefault();
                commitTags(tagInput);
              }
            }}
            onBlur={() => commitTags(tagInput)}
          />
          <span className="muted">Tags are saved in lower case.</span>
        </div>
        <ImageField
          label="Hero image"
          mediaId={fields.heroMediaId}
          previewUrl={heroUrl}
          disabled={disabled}
          onChange={(id, url) => {
            set('heroMediaId', id);
            setHeroUrl(url);
          }}
          onRemove={() => {
            set('heroMediaId', '');
            setHeroUrl('');
          }}
        />
        <p className="muted">
          Estimated read time: {article.readMinutes} min (updates when saved).
        </p>
      </section>

      <section className="card" aria-label="Content blocks" style={{ padding: 20 }}>
        <h2>Content</h2>
        {blocks.length === 0 ? <p className="empty">No content yet. Add a block below.</p> : null}
        <ol style={{ listStyle: 'none', padding: 0, display: 'grid', gap: 12 }}>
          {blocks.map((b, i) => (
            <li key={b.key} className="card" style={{ padding: 12 }}>
              <BlockFields
                block={b}
                index={i}
                last={i === blocks.length - 1}
                disabled={disabled}
                onChange={(patch) => edit({ kind: 'update', key: b.key, patch })}
                onMove={(direction) => edit({ kind: 'move', key: b.key, direction })}
                onRemove={() => edit({ kind: 'remove', key: b.key })}
              />
            </li>
          ))}
        </ol>
        <div className="row-actions" role="group" aria-label="Add a block">
          {BLOCK_TYPES.map((t: BlockType) => (
            <button
              key={t}
              type="button"
              className="button secondary small"
              disabled={disabled}
              onClick={() => edit({ kind: 'add', key: nextKey(), type: t })}
            >
              Add {BLOCK_LABELS[t].toLowerCase()}
            </button>
          ))}
        </div>
      </section>

      <section className="card" aria-label="Save" style={{ padding: 20 }}>
        <button type="button" className="button" disabled={disabled || !dirty} onClick={save}>
          {pending ? 'Saving…' : 'Save changes'}
        </button>
        {dirty ? <span className="muted"> You have unsaved changes.</span> : null}
        {saved && !dirty ? (
          <span className="muted" role="status">
            {' '}
            Saved.
          </span>
        ) : null}
        {error ? (
          <p className="alert" role="alert">
            {error}
          </p>
        ) : null}
        {article.status === 'DRAFT' && gaps.length > 0 ? (
          <p className="muted">To submit for review you still need {gaps.join(', ')}.</p>
        ) : null}
      </section>

      <ArticleLifecycle
        id={article.id}
        title={fields.title}
        status={article.status}
        dirty={dirty}
      />

      <section className="card" aria-label="Preview" style={{ padding: 20 }}>
        <h2>Preview</h2>
        <p className="muted">A simple read-only view of how the content reads.</p>
        <Preview
          title={fields.title}
          byline={fields.authorName}
          heroUrl={heroUrl}
          blocks={blocks}
        />
      </section>
    </>
  );
}

function BlockFields({
  block,
  index,
  last,
  disabled,
  onChange,
  onMove,
  onRemove,
}: {
  block: EditorBlock;
  index: number;
  last: boolean;
  disabled: boolean;
  onChange: (patch: Partial<Omit<EditorBlock, 'key' | 'type'>>) => void;
  onMove: (direction: 'up' | 'down') => void;
  onRemove: () => void;
}) {
  const n = index + 1;
  const name = `${BLOCK_LABELS[block.type]} block ${n}`;
  return (
    <>
      <div className="row-actions" style={{ justifyContent: 'space-between' }}>
        <strong>
          {n}. {BLOCK_LABELS[block.type]}
        </strong>
        <span className="row-actions">
          <button
            type="button"
            className="button secondary small"
            aria-label={`Move ${name} up`}
            disabled={disabled || index === 0}
            onClick={() => onMove('up')}
          >
            Up
          </button>
          <button
            type="button"
            className="button secondary small"
            aria-label={`Move ${name} down`}
            disabled={disabled || last}
            onClick={() => onMove('down')}
          >
            Down
          </button>
          <button
            type="button"
            className="button danger small"
            aria-label={`Remove ${name}`}
            disabled={disabled}
            onClick={onRemove}
          >
            Remove
          </button>
        </span>
      </div>
      {block.type === 'image' ? (
        <>
          <ImageField
            label={`Image for block ${n}`}
            mediaId={block.mediaId}
            previewUrl={block.imageUrl}
            disabled={disabled}
            onChange={(id, url) => onChange({ mediaId: id, imageUrl: url })}
            onRemove={() => onChange({ mediaId: '', imageUrl: '' })}
          />
          <label className="field">
            Caption (block {n})
            <input
              className="input"
              value={block.caption}
              disabled={disabled}
              onChange={(e) => onChange({ caption: e.target.value })}
            />
          </label>
        </>
      ) : (
        <>
          {block.type === 'callout' ? (
            <label className="field">
              Callout title (block {n})
              <input
                className="input"
                value={block.title}
                disabled={disabled}
                placeholder="Rule of thumb"
                onChange={(e) => onChange({ title: e.target.value })}
              />
            </label>
          ) : null}
          <label className="field">
            {BLOCK_LABELS[block.type]} text (block {n})
            {block.type === 'heading' ? (
              <input
                className="input"
                value={block.text}
                disabled={disabled}
                onChange={(e) => onChange({ text: e.target.value })}
              />
            ) : (
              <textarea
                className="textarea"
                value={block.text}
                disabled={disabled}
                onChange={(e) => onChange({ text: e.target.value })}
              />
            )}
          </label>
          {block.type === 'quote' ? (
            <label className="field">
              Attribution (block {n})
              <input
                className="input"
                value={block.attribution}
                disabled={disabled}
                onChange={(e) => onChange({ attribution: e.target.value })}
              />
            </label>
          ) : null}
        </>
      )}
    </>
  );
}

function Preview({
  title,
  byline,
  heroUrl,
  blocks,
}: {
  title: string;
  byline: string;
  heroUrl: string;
  blocks: EditorBlock[];
}) {
  return (
    <article style={{ maxWidth: 640 }}>
      {heroUrl ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img src={heroUrl} alt="" style={{ width: '100%', borderRadius: 8 }} />
      ) : null}
      <h3>{title}</h3>
      <p className="muted">By {byline}</p>
      {blocks.map((b) => {
        switch (b.type) {
          case 'paragraph':
            return (
              <p key={b.key} style={{ whiteSpace: 'pre-wrap' }}>
                {b.text}
              </p>
            );
          case 'heading':
            return <h4 key={b.key}>{b.text}</h4>;
          case 'callout':
            return (
              <aside key={b.key} className="card" style={{ padding: 12 }}>
                {b.title ? <strong>{b.title}</strong> : null}
                <p style={{ whiteSpace: 'pre-wrap', margin: 0 }}>{b.text}</p>
              </aside>
            );
          case 'quote':
            return (
              <blockquote key={b.key}>
                <p style={{ whiteSpace: 'pre-wrap' }}>{b.text}</p>
                {b.attribution ? <footer>— {b.attribution}</footer> : null}
              </blockquote>
            );
          case 'image':
            return (
              <figure key={b.key} style={{ margin: '12px 0' }}>
                {b.imageUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={b.imageUrl} alt={b.caption} style={{ maxWidth: '100%' }} />
                ) : (
                  <span className="muted">(image not uploaded)</span>
                )}
                {b.caption ? <figcaption className="muted">{b.caption}</figcaption> : null}
              </figure>
            );
        }
      })}
    </article>
  );
}
