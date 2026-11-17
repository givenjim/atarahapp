'use client';

import { useRouter } from 'next/navigation';
import { useRef, useState, useTransition } from 'react';
import { createBroadcastAction, previewAudienceAction } from '@/app/broadcast-actions';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import {
  BODY_MAX,
  BROADCAST_TARGETS,
  CATEGORY_OPTIONS,
  ROLE_OPTIONS,
  TARGET_LABELS,
  TITLE_MAX,
  validateBroadcastForm,
  type BroadcastForm as Form,
} from '@/lib/broadcasts';

interface Choice {
  id: string;
  name: string;
}

/** Compose a broadcast: message, audience (with a live count) and when to send it. */
export function BroadcastForm({
  initial,
  disciplines,
  counties,
}: {
  initial: Form;
  disciplines: Choice[];
  counties: Choice[];
}) {
  const router = useRouter();
  const [f, setF] = useState<Form>(initial);
  const [audience, setAudience] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [counting, startCount] = useTransition();
  const { attempt, pending, error: sendError, setError: setSendError, reauth } = useReauth();
  const created = useRef<string | undefined>(undefined);
  const set = <K extends keyof Form>(k: K, v: Form[K]) => {
    setF((p) => ({ ...p, [k]: v }));
    if (k === 'target' || k === 'targetValue') setAudience(null);
  };

  const options: Choice[] =
    f.target === 'ROLE'
      ? ROLE_OPTIONS.map((r) => ({ id: r.key, name: r.label }))
      : f.target === 'DISCIPLINE'
        ? disciplines
        : f.target === 'COUNTY'
          ? counties
          : [];

  const count = () => {
    setError(null);
    startCount(async () => {
      const res = await previewAudienceAction(f.target, f.targetValue);
      if (res.ok) {
        setAudience(
          `${res.recipients} ${res.recipients === 1 ? 'member' : 'members'} would receive this.`,
        );
      } else {
        setAudience(null);
        setError(res.error);
      }
    });
  };

  const submit = () => {
    const problem = validateBroadcastForm(f);
    if (problem) return setError(problem);
    setError(null);
    setSendError(null);
    attempt(
      async () => {
        const res = await createBroadcastAction(f);
        if (res.ok) created.current = res.id;
        return res;
      },
      () => router.push(created.current ? `/notifications/${created.current}` : '/notifications'),
    );
  };

  const shown = error ?? sendError;
  return (
    <>
      <form
        className="card"
        style={{ padding: 20, display: 'grid', gap: 16, maxWidth: 720 }}
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
            maxLength={TITLE_MAX}
            onChange={(e) => set('title', e.target.value)}
          />
          <span className="muted">
            {f.title.length}/{TITLE_MAX}
          </span>
        </label>
        <label className="field">
          Message
          <textarea
            className="input"
            rows={4}
            value={f.body}
            maxLength={BODY_MAX}
            onChange={(e) => set('body', e.target.value)}
          />
          <span className="muted">
            {f.body.length}/{BODY_MAX}
          </span>
        </label>
        <div className="filters">
          <label className="field">
            Category
            <select
              className="select"
              value={f.category}
              onChange={(e) => set('category', e.target.value)}
            >
              {CATEGORY_OPTIONS.map((c) => (
                <option key={c.value} value={c.value}>
                  {c.label}
                </option>
              ))}
            </select>
            <span className="muted">Members can switch push and email off per category.</span>
          </label>
          <label className="field" style={{ flex: 1 }}>
            Opens in the app (optional)
            <input
              className="input"
              value={f.deepLink}
              placeholder="/opportunities"
              onChange={(e) => set('deepLink', e.target.value)}
            />
          </label>
        </div>

        <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
          <legend>Who gets it</legend>
          <div className="filters">
            <label className="field">
              Audience
              <select
                className="select"
                value={f.target}
                onChange={(e) => {
                  set('target', e.target.value as Form['target']);
                  set('targetValue', '');
                }}
              >
                {BROADCAST_TARGETS.map((t) => (
                  <option key={t} value={t}>
                    {TARGET_LABELS[t]}
                  </option>
                ))}
              </select>
            </label>
            {f.target !== 'ALL' ? (
              <label className="field">
                {f.target === 'ROLE' ? 'Role' : f.target === 'DISCIPLINE' ? 'Discipline' : 'County'}
                <select
                  className="select"
                  value={f.targetValue}
                  onChange={(e) => set('targetValue', e.target.value)}
                >
                  <option value="">Choose…</option>
                  {options.map((o) => (
                    <option key={o.id} value={o.id}>
                      {o.name}
                    </option>
                  ))}
                </select>
                {options.length === 0 ? (
                  <span className="muted">This list is empty for your account.</span>
                ) : null}
              </label>
            ) : null}
            <button type="button" className="button secondary" disabled={counting} onClick={count}>
              {counting ? 'Counting…' : 'Count recipients'}
            </button>
          </div>
          <p role="status" className="muted" style={{ margin: 0 }}>
            {audience}
          </p>
        </fieldset>

        <fieldset className="field" style={{ border: 0, padding: 0, margin: 0 }}>
          <legend>When</legend>
          <div className="row-actions">
            <label>
              <input
                type="radio"
                name="when"
                checked={f.when === 'now'}
                onChange={() => set('when', 'now')}
              />{' '}
              Send now
            </label>
            <label>
              <input
                type="radio"
                name="when"
                checked={f.when === 'later'}
                onChange={() => set('when', 'later')}
              />{' '}
              Schedule
            </label>
            {f.when === 'later' ? (
              <label className="field">
                Send at (Nairobi time)
                <input
                  className="input"
                  type="datetime-local"
                  value={f.scheduledLocal}
                  onChange={(e) => set('scheduledLocal', e.target.value)}
                />
              </label>
            ) : null}
          </div>
        </fieldset>

        {shown ? (
          <p className="alert" role="alert">
            {shown}
          </p>
        ) : null}
        <div className="row-actions">
          <button className="button" type="submit" disabled={pending}>
            {pending ? 'Working…' : f.when === 'later' ? 'Schedule broadcast' : 'Send broadcast'}
          </button>
        </div>
      </form>
      <ReauthDialog {...reauth} />
    </>
  );
}
