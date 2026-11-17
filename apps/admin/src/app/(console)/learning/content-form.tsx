'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition, type FormEvent } from 'react';
import { saveContentAction } from '@/app/learning-actions';
import {
  ACCESS,
  accessLabel,
  CONTENT_TYPES,
  deliveriesFor,
  deliveryLabel,
  embedPreview,
  groupCategories,
  groupLabel,
  LEVELS,
  SOURCES,
  sourceLabel,
  titleCase,
  typeLabel,
  validateContentForm,
  withType,
  type ContentForm,
} from '@/lib/learning';
import { ImageField } from '../articles/[id]/image-field';

interface Option {
  id: string;
  name: string;
}
interface CategoryOption extends Option {
  group: string;
  isActive: boolean;
}

/** A repeatable list of short strings ("What you'll learn"). */
function ListField({
  label,
  items,
  onChange,
}: {
  label: string;
  items: string[];
  onChange: (items: string[]) => void;
}) {
  const set = (i: number, v: string) => onChange(items.map((x, j) => (j === i ? v : x)));
  return (
    <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
      <legend>{label}</legend>
      {items.map((v, i) => (
        <div key={i} className="row-actions" style={{ marginBottom: 6 }}>
          <input
            className="input"
            style={{ flex: 1 }}
            value={v}
            maxLength={160}
            aria-label={`${label} ${i + 1}`}
            onChange={(e) => set(i, e.target.value)}
          />
          <button
            type="button"
            className="button secondary small"
            aria-label={`Remove ${label.toLowerCase()} ${i + 1}`}
            onClick={() => onChange(items.length > 1 ? items.filter((_, j) => j !== i) : [''])}
          >
            Remove
          </button>
        </div>
      ))}
      {items.length < 10 ? (
        <button
          type="button"
          className="button secondary small"
          onClick={() => onChange([...items, ''])}
        >
          Add another
        </button>
      ) : null}
    </fieldset>
  );
}

function Checks({
  legend,
  options,
  selected,
  onChange,
}: {
  legend: string;
  options: Option[];
  selected: string[];
  onChange: (ids: string[]) => void;
}) {
  return (
    <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
      <legend>{legend}</legend>
      {options.length === 0 ? (
        <span className="muted">
          None to choose from (managing the taxonomy needs the taxonomy permission).
        </span>
      ) : (
        <div
          style={{
            display: 'flex',
            flexWrap: 'wrap',
            gap: '4px 16px',
            maxHeight: 180,
            overflowY: 'auto',
          }}
        >
          {options.map((o) => (
            <label key={o.id} style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
              <input
                type="checkbox"
                checked={selected.includes(o.id)}
                onChange={() =>
                  onChange(
                    selected.includes(o.id)
                      ? selected.filter((x) => x !== o.id)
                      : [...selected, o.id],
                  )
                }
              />
              {o.name}
            </label>
          ))}
        </div>
      )}
    </fieldset>
  );
}

/** Create or edit a Skill Labs item of any type. One form for both: `id` set means editing. */
export function ContentFormView({
  id,
  originalType,
  initial,
  categories,
  disciplines,
  skills,
  hosts,
}: {
  id?: string;
  originalType?: string;
  initial: ContentForm;
  categories: CategoryOption[];
  disciplines: Option[];
  skills: Option[];
  hosts: string[];
}) {
  const router = useRouter();
  const [f, setF] = useState<ContentForm>(initial);
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const mode = id ? 'edit' : 'create';
  const course = f.type === 'COURSE';
  const set = <K extends keyof ContentForm>(key: K, value: ContentForm[K]) =>
    setF((prev) => ({ ...prev, [key]: value }));
  // A course cannot be turned into another type (or back); the API refuses it, so the form does not offer it.
  const typeLocked = Boolean(id);
  const typeChoices = typeLocked
    ? CONTENT_TYPES.filter((t) => (t === 'COURSE') === (originalType === 'COURSE'))
    : CONTENT_TYPES;
  const embed =
    f.delivery === 'EMBEDDED' && !course && f.embedUrl.trim()
      ? embedPreview(f.embedUrl, hosts)
      : null;

  const submit = (e: FormEvent) => {
    e.preventDefault();
    const problem = validateContentForm(f, mode, hosts);
    if (problem) return setError(problem);
    setError(null);
    start(async () => {
      const res = await saveContentAction(id ?? null, f, hosts, originalType);
      if (res.ok) {
        router.push(`/learning/${res.id ?? id}`);
        router.refresh();
      } else {
        setError(res.error);
      }
    });
  };

  return (
    <form
      className="card"
      style={{ padding: 20, display: 'grid', gap: 16 }}
      onSubmit={submit}
      noValidate
    >
      <label className="field">
        Title
        <input
          className="input"
          value={f.title}
          maxLength={140}
          onChange={(e) => set('title', e.target.value)}
        />
      </label>
      <div className="filters">
        <label className="field">
          Type
          <select
            className="select"
            value={f.type}
            onChange={(e) => setF((p) => withType(p, e.target.value))}
          >
            {typeChoices.map((t) => (
              <option key={t} value={t}>
                {typeLabel(t)}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Category
          <select
            className="select"
            value={f.categoryId}
            onChange={(e) => set('categoryId', e.target.value)}
          >
            <option value="">Choose a category</option>
            {groupCategories(categories.map((c, i) => ({ ...c, sortOrder: i }))).map((g) => (
              <optgroup key={g.group} label={groupLabel(g.group)}>
                {g.items.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                    {c.isActive ? '' : ' (off)'}
                  </option>
                ))}
              </optgroup>
            ))}
          </select>
        </label>
        <label className="field">
          Level
          <select className="select" value={f.level} onChange={(e) => set('level', e.target.value)}>
            {LEVELS.map((l) => (
              <option key={l} value={l}>
                {titleCase(l)}
              </option>
            ))}
          </select>
        </label>
        {course ? null : (
          <label className="field">
            Duration (minutes)
            <input
              className="input"
              inputMode="numeric"
              style={{ width: 120 }}
              value={f.durationMinutes}
              onChange={(e) => set('durationMinutes', e.target.value)}
            />
          </label>
        )}
      </div>
      <label className="field">
        Summary (shown on the card)
        <textarea
          className="textarea"
          rows={2}
          value={f.summary}
          maxLength={300}
          onChange={(e) => set('summary', e.target.value)}
        />
      </label>

      <div className="filters">
        <label className="field">
          Source
          <select
            className="select"
            value={f.source}
            onChange={(e) => set('source', e.target.value)}
          >
            {SOURCES.map((s) => (
              <option key={s} value={s}>
                {sourceLabel(s)}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Delivery
          <select
            className="select"
            value={f.delivery}
            disabled={course}
            onChange={(e) => set('delivery', e.target.value)}
          >
            {deliveriesFor(f.type).map((d) => (
              <option key={d} value={d}>
                {deliveryLabel(d)}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Access
          <select
            className="select"
            value={f.access}
            onChange={(e) => set('access', e.target.value)}
          >
            {ACCESS.map((a) => (
              <option key={a} value={a}>
                {accessLabel(a)}
              </option>
            ))}
          </select>
        </label>
        <label className="field" style={{ flex: 1 }}>
          Provider name
          <input
            className="input"
            value={f.providerName}
            maxLength={80}
            placeholder="Atarah Studio"
            onChange={(e) => set('providerName', e.target.value)}
          />
        </label>
      </div>

      {f.delivery === 'EXTERNAL_LINK' ? (
        <label className="field">
          Address it opens (https)
          <input
            className="input"
            type="url"
            value={f.externalUrl}
            placeholder="https://"
            onChange={(e) => set('externalUrl', e.target.value)}
          />
          <span className="muted">
            Members see the site’s name in the “Leaving Atarah” sheet. Needed before publishing.
          </span>
        </label>
      ) : null}
      {f.delivery === 'EMBEDDED' && !course ? (
        <label className="field">
          Embedded player address
          <input
            className="input"
            type="url"
            value={f.embedUrl}
            placeholder="https://www.youtube.com/watch?v=…"
            onChange={(e) => set('embedUrl', e.target.value)}
          />
          <span className="muted">
            Allowed hosts: {hosts.length > 0 ? hosts.join(', ') : 'not loaded'}. Pasted YouTube and
            Vimeo links become player addresses.
          </span>
          {embed?.ok ? (
            <span role="status">
              Members will see: <code>{embed.url}</code>
            </span>
          ) : embed ? (
            <span className="alert" role="alert">
              {embed.error}
            </span>
          ) : null}
        </label>
      ) : null}
      {course ? (
        <label style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
          <input
            type="checkbox"
            checked={f.sequential}
            onChange={(e) => set('sequential', e.target.checked)}
          />
          Lessons unlock one after another
        </label>
      ) : null}

      <ImageField
        label="Cover image"
        mediaId={f.coverMediaId}
        previewUrl={f.coverUrl}
        disabled={pending}
        onChange={(mediaId, coverUrl) => setF((p) => ({ ...p, coverMediaId: mediaId, coverUrl }))}
        onRemove={() => setF((p) => ({ ...p, coverMediaId: '', coverUrl: '' }))}
      />

      <ListField
        label="What you’ll learn"
        items={f.whatYouLearn}
        onChange={(v) => set('whatYouLearn', v)}
      />
      <label className="field">
        Who it’s for
        <textarea
          className="textarea"
          rows={2}
          value={f.whoItsFor}
          maxLength={300}
          onChange={(e) => set('whoItsFor', e.target.value)}
        />
      </label>

      <Checks
        legend="Disciplines (recommendations use these)"
        options={disciplines}
        selected={f.disciplineIds}
        onChange={(ids) => set('disciplineIds', ids)}
      />
      <Checks
        legend="Skills it teaches (completing a course adds them to the member’s profile as learned)"
        options={skills}
        selected={f.skillIds}
        onChange={(ids) => set('skillIds', ids)}
      />

      <label className="field">
        Instructor (user id, optional)
        <input
          className="input"
          value={f.instructorUserId}
          placeholder="Copy the id from the member’s page"
          onChange={(e) => set('instructorUserId', e.target.value)}
        />
      </label>
      <label style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
        <input
          type="checkbox"
          checked={f.featured}
          onChange={(e) => set('featured', e.target.checked)}
        />
        Featured in the Skill Labs hub
      </label>

      {error ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}
      <div className="row-actions">
        <button className="button" type="submit" disabled={pending}>
          {pending ? 'Saving…' : id ? 'Save changes' : 'Create draft'}
        </button>
        <button
          type="button"
          className="button secondary"
          disabled={pending}
          onClick={() => router.back()}
        >
          Cancel
        </button>
      </div>
    </form>
  );
}
