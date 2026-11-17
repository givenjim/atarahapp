'use client';

import {
  DOCUMENTS,
  emptyRule,
  moveRule,
  RULE_HELP,
  RULE_LABELS,
  RULE_TYPES,
  titleCase,
  type RuleDraft,
  type RuleType,
} from '@/lib/opportunities';

export interface Option {
  id: string;
  name: string;
}

/** Toggles one id in a multi-select list (a plain checkbox group keeps this usable with a keyboard). */
const toggle = (ids: string[], id: string): string[] =>
  ids.includes(id) ? ids.filter((x) => x !== id) : [...ids, id];

function CheckList({
  legend,
  options,
  value,
  onChange,
}: {
  legend: string;
  options: Option[];
  value: string[];
  onChange: (ids: string[]) => void;
}) {
  if (options.length === 0)
    return <p className="muted">No options are available to choose from.</p>;
  return (
    <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
      <legend>{legend}</legend>
      <div
        style={{
          display: 'flex',
          flexWrap: 'wrap',
          gap: '4px 16px',
          maxHeight: 180,
          overflow: 'auto',
        }}
      >
        {options.map((o) => (
          <label key={o.id} style={{ display: 'inline-flex', gap: 6, alignItems: 'center' }}>
            <input
              type="checkbox"
              checked={value.includes(o.id)}
              onChange={() => onChange(toggle(value, o.id))}
            />
            {o.name}
          </label>
        ))}
      </div>
    </fieldset>
  );
}

/**
 * Structured eligibility rules. Each row is one rule with its own parameter editor; the API validates the
 * parameters again and its field error is shown by the form.
 */
export function RulesEditor({
  rules,
  onChange,
  disciplines,
  skills,
}: {
  rules: RuleDraft[];
  onChange: (rules: RuleDraft[]) => void;
  disciplines: Option[];
  skills: Option[];
}) {
  const patch = (key: string, change: Partial<RuleDraft>) =>
    onChange(rules.map((r) => (r.key === key ? { ...r, ...change } : r)));

  return (
    <section aria-label="Eligibility rules">
      <h2>Eligibility rules</h2>
      <p className="muted">
        Members see these as a checklist against their own profile. Rules Atarah cannot check (age,
        documents, custom text) are shown as advice, never as missing.
      </p>
      {rules.length === 0 ? (
        <p className="empty">No rules yet. This listing has no checklist.</p>
      ) : null}
      <ol className="plain-list" style={{ display: 'grid', gap: 12 }}>
        {rules.map((r, i) => (
          <li key={r.key} className="card" style={{ padding: 16 }} aria-label={`Rule ${i + 1}`}>
            <div className="filters">
              <label className="field">
                Type
                <select
                  className="select"
                  value={r.ruleType}
                  onChange={(e) => {
                    const fresh = emptyRule(e.target.value as RuleType);
                    patch(r.key, {
                      ...fresh,
                      key: r.key,
                      label: r.label,
                      isBlocking: r.isBlocking,
                    });
                  }}
                >
                  {RULE_TYPES.map((t) => (
                    <option key={t} value={t}>
                      {RULE_LABELS[t]}
                    </option>
                  ))}
                </select>
              </label>
              <label className="field" style={{ flex: 1 }}>
                Label members read
                <input
                  className="input"
                  value={r.label}
                  maxLength={140}
                  placeholder="At least 3 published projects"
                  onChange={(e) => patch(r.key, { label: e.target.value })}
                />
              </label>
              <label className="field">
                <span>
                  <input
                    type="checkbox"
                    checked={r.isBlocking}
                    onChange={(e) => patch(r.key, { isBlocking: e.target.checked })}
                  />{' '}
                  Required
                </span>
              </label>
            </div>
            <p className="muted" style={{ margin: '4px 0 8px' }}>
              {RULE_HELP[r.ruleType]}
            </p>

            {r.ruleType === 'RESIDENCY' ? (
              <div className="filters">
                <label className="field">
                  Country code
                  <input
                    className="input"
                    value={r.countryCode}
                    maxLength={2}
                    placeholder="KE"
                    onChange={(e) => patch(r.key, { countryCode: e.target.value })}
                  />
                </label>
                <label className="field">
                  County codes (optional)
                  <input
                    className="input"
                    value={r.countyCodes}
                    placeholder="NBI, MSA"
                    onChange={(e) => patch(r.key, { countyCodes: e.target.value })}
                  />
                </label>
              </div>
            ) : null}
            {r.ruleType === 'AGE_RANGE' ? (
              <div className="filters">
                <label className="field">
                  Minimum age
                  <input
                    className="input"
                    inputMode="numeric"
                    value={r.min}
                    onChange={(e) => patch(r.key, { min: e.target.value })}
                  />
                </label>
                <label className="field">
                  Maximum age
                  <input
                    className="input"
                    inputMode="numeric"
                    value={r.max}
                    onChange={(e) => patch(r.key, { max: e.target.value })}
                  />
                </label>
              </div>
            ) : null}
            {r.ruleType === 'DISCIPLINE_IN' ? (
              <CheckList
                legend="Disciplines"
                options={disciplines}
                value={r.disciplineIds}
                onChange={(ids) => patch(r.key, { disciplineIds: ids })}
              />
            ) : null}
            {r.ruleType === 'SKILL_IN' ? (
              <>
                <label className="field">
                  Member needs
                  <select
                    className="select"
                    value={r.mode}
                    onChange={(e) => patch(r.key, { mode: e.target.value as 'any' | 'all' })}
                  >
                    <option value="any">Any of these skills</option>
                    <option value="all">All of these skills</option>
                  </select>
                </label>
                <CheckList
                  legend="Skills"
                  options={skills}
                  value={r.skillIds}
                  onChange={(ids) => patch(r.key, { skillIds: ids })}
                />
              </>
            ) : null}
            {r.ruleType === 'MIN_PROJECTS' ? (
              <label className="field">
                Published projects needed
                <input
                  className="input"
                  inputMode="numeric"
                  value={r.count}
                  onChange={(e) => patch(r.key, { count: e.target.value })}
                />
              </label>
            ) : null}
            {r.ruleType === 'DOCUMENT' ? (
              <label className="field">
                Document
                <select
                  className="select"
                  value={r.document}
                  onChange={(e) => patch(r.key, { document: e.target.value })}
                >
                  {DOCUMENTS.map((d) => (
                    <option key={d} value={d}>
                      {titleCase(d)}
                    </option>
                  ))}
                </select>
              </label>
            ) : null}

            <div className="row-actions" style={{ marginTop: 8 }}>
              <button
                type="button"
                className="button secondary small"
                disabled={i === 0}
                aria-label={`Move rule ${i + 1} up`}
                onClick={() => onChange(moveRule(rules, i, -1))}
              >
                Move up
              </button>
              <button
                type="button"
                className="button secondary small"
                disabled={i === rules.length - 1}
                aria-label={`Move rule ${i + 1} down`}
                onClick={() => onChange(moveRule(rules, i, 1))}
              >
                Move down
              </button>
              <button
                type="button"
                className="button danger small"
                aria-label={`Remove rule ${i + 1}`}
                onClick={() => onChange(rules.filter((x) => x.key !== r.key))}
              >
                Remove
              </button>
            </div>
          </li>
        ))}
      </ol>
      {rules.length < 12 ? (
        <button
          type="button"
          className="button secondary"
          onClick={() => onChange([...rules, emptyRule()])}
        >
          Add a rule
        </button>
      ) : (
        <p className="muted">A listing can have up to 12 rules.</p>
      )}
    </section>
  );
}
