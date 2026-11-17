'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition, type FormEvent } from 'react';
import { saveOpportunityAction } from '@/app/opportunity-actions';
import {
  OPP_TYPES,
  titleCase,
  validateOppForm,
  WORK_MODES,
  type OppForm,
} from '@/lib/opportunities';
import { RulesEditor, type Option } from './rules-editor';

/** A repeatable list of short strings (requirements, benefits). */
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
            maxLength={200}
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
      {items.length < 20 ? (
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

/** Create or edit an opportunity. One form for both: `id` set means editing. */
export function OpportunityForm({
  id,
  initial,
  providers,
  counties,
  disciplines,
  skills,
}: {
  id?: string;
  initial: OppForm;
  providers: Option[];
  counties: Option[];
  disciplines: Option[];
  skills: Option[];
}) {
  const router = useRouter();
  const [f, setF] = useState<OppForm>(initial);
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const mode = id ? 'edit' : 'create';
  const set = <K extends keyof OppForm>(key: K, value: OppForm[K]) =>
    setF((prev) => ({ ...prev, [key]: value }));

  const submit = (e: FormEvent) => {
    e.preventDefault();
    const problem = validateOppForm(f, mode);
    if (problem) return setError(problem);
    setError(null);
    start(async () => {
      const res = await saveOpportunityAction(id ?? null, f);
      if (res.ok) {
        router.push(`/opportunities/${res.id ?? id}`);
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
          Provider
          <select
            className="select"
            value={f.providerId}
            onChange={(e) => set('providerId', e.target.value)}
          >
            <option value="">Choose a provider</option>
            {providers.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Type
          <select className="select" value={f.type} onChange={(e) => set('type', e.target.value)}>
            {OPP_TYPES.map((t) => (
              <option key={t} value={t}>
                {titleCase(t)}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Work mode
          <select
            className="select"
            value={f.workMode}
            onChange={(e) => set('workMode', e.target.value)}
          >
            {WORK_MODES.map((m) => (
              <option key={m} value={m}>
                {titleCase(m)}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          County
          <select
            className="select"
            value={f.countyId}
            onChange={(e) => set('countyId', e.target.value)}
          >
            <option value="">Anywhere / not set</option>
            {counties.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </label>
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
      <label className="field">
        About
        <textarea
          className="textarea"
          rows={6}
          value={f.about}
          maxLength={8000}
          onChange={(e) => set('about', e.target.value)}
        />
      </label>
      <ListField
        label="Requirements"
        items={f.requirements}
        onChange={(v) => set('requirements', v)}
      />
      <ListField label="Benefits" items={f.benefits} onChange={(v) => set('benefits', v)} />

      <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
        <legend>Value</legend>
        <div className="filters">
          <label className="field">
            Smallest amount
            <input
              className="input"
              inputMode="decimal"
              value={f.valueMin}
              placeholder="100000"
              onChange={(e) => set('valueMin', e.target.value)}
            />
          </label>
          <label className="field">
            Largest amount
            <input
              className="input"
              inputMode="decimal"
              value={f.valueMax}
              placeholder="500000"
              onChange={(e) => set('valueMax', e.target.value)}
            />
          </label>
          <label className="field">
            Currency
            <input
              className="input"
              value={f.valueCurrency}
              maxLength={3}
              style={{ width: 80 }}
              onChange={(e) => set('valueCurrency', e.target.value)}
            />
          </label>
          <label className="field">
            Or describe it
            <input
              className="input"
              value={f.valueText}
              maxLength={80}
              placeholder="Paid stipend"
              onChange={(e) => set('valueText', e.target.value)}
            />
          </label>
        </div>
        <span className="muted">
          Amounts are in whole shillings (or the currency chosen), not cents.
        </span>
      </fieldset>

      <label className="field">
        Deadline (Nairobi time)
        <input
          className="input"
          type="datetime-local"
          value={f.deadline}
          onChange={(e) => set('deadline', e.target.value)}
        />
        <span className="muted">Leave empty for a rolling deadline.</span>
      </label>

      <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
        <legend>How members apply</legend>
        <div className="filters">
          <label className="field">
            Method
            <select
              className="select"
              value={f.applicationMethod}
              onChange={(e) =>
                set('applicationMethod', e.target.value as OppForm['applicationMethod'])
              }
            >
              <option value="EXTERNAL_WEBSITE">On the provider’s website</option>
              <option value="EMAIL">By email</option>
            </select>
          </label>
          {f.applicationMethod === 'EXTERNAL_WEBSITE' ? (
            <label className="field" style={{ flex: 1 }}>
              Application link
              <input
                className="input"
                type="url"
                value={f.applicationUrl}
                placeholder="https://"
                onChange={(e) => set('applicationUrl', e.target.value)}
              />
            </label>
          ) : (
            <label className="field" style={{ flex: 1 }}>
              Application email
              <input
                className="input"
                type="email"
                value={f.applicationEmail}
                onChange={(e) => set('applicationEmail', e.target.value)}
              />
            </label>
          )}
        </div>
      </fieldset>
      <label className="field">
        Source link (where you found it, optional)
        <input
          className="input"
          type="url"
          value={f.sourceUrl}
          placeholder="https://"
          onChange={(e) => set('sourceUrl', e.target.value)}
        />
      </label>

      <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
        <legend>Disciplines (leave empty if open to everyone)</legend>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px 16px' }}>
          {disciplines.map((d) => (
            <label key={d.id} style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
              <input
                type="checkbox"
                checked={f.disciplineIds.includes(d.id)}
                onChange={() =>
                  set(
                    'disciplineIds',
                    f.disciplineIds.includes(d.id)
                      ? f.disciplineIds.filter((x) => x !== d.id)
                      : [...f.disciplineIds, d.id],
                  )
                }
              />
              {d.name}
            </label>
          ))}
        </div>
      </fieldset>

      <RulesEditor
        rules={f.rules}
        onChange={(rules) => set('rules', rules)}
        disciplines={disciplines}
        skills={skills}
      />

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
