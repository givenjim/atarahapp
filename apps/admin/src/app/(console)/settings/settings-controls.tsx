'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { setFlagAction, setSettingAction } from '@/app/ops-actions';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { displaySetting, settingKind, type FeatureFlag, type PlatformSetting } from '@/lib/ops';

/** A feature switch. Changing it needs a fresh authenticator code and is audited. */
export function FlagSwitch({ flag }: { flag: FeatureFlag }) {
  const router = useRouter();
  const { attempt, pending, error, reauth } = useReauth();
  const next = !flag.enabled;
  return (
    <div className="switch-row">
      <div>
        <strong id={`flag-${flag.key}`}>{flag.key}</strong>
        <div className="muted">
          {flag.description} · Phase {flag.phase}
        </div>
        {error ? (
          <p className="alert" role="alert" style={{ margin: '8px 0 0' }}>
            {error}
          </p>
        ) : null}
      </div>
      <div className="row-actions">
        <span className={`pill ${flag.enabled ? 'success' : 'muted'}`}>
          {flag.enabled ? 'On' : 'Off'}
        </span>
        <button
          type="button"
          className="button secondary small"
          aria-describedby={`flag-${flag.key}`}
          disabled={pending}
          onClick={() =>
            attempt(
              () => setFlagAction(flag.key, next),
              () => router.refresh(),
            )
          }
        >
          {next ? 'Turn on' : 'Turn off'}
        </button>
      </div>
      <ReauthDialog {...reauth} />
    </div>
  );
}

/** One tunable value. It can only be saved as the same kind (text, number or true/false) it already holds. */
export function SettingRow({ setting }: { setting: PlatformSetting }) {
  const router = useRouter();
  const kind = settingKind(setting.value);
  const [text, setText] = useState(displaySetting(setting.value));
  const { attempt, pending, error, setError, reauth } = useReauth();
  const dirty = text !== displaySetting(setting.value);
  const id = `setting-${setting.key}`;

  return (
    <form
      className="switch-row"
      onSubmit={(e) => {
        e.preventDefault();
        setError(null);
        attempt(
          () => setSettingAction(setting.key, setting.value, text),
          () => router.refresh(),
        );
      }}
    >
      <div>
        <label htmlFor={id}>
          <strong>{setting.key}</strong>
        </label>
        <div className="muted">
          {setting.description ? `${setting.description} · ` : ''}
          {kind === 'number' ? 'Number' : kind === 'boolean' ? 'True or false' : 'Text'}
        </div>
        {error ? (
          <p className="alert" role="alert" style={{ margin: '8px 0 0' }}>
            {error}
          </p>
        ) : null}
      </div>
      <div className="inline-form">
        {kind === 'boolean' ? (
          <select id={id} className="select" value={text} onChange={(e) => setText(e.target.value)}>
            <option value="true">true</option>
            <option value="false">false</option>
          </select>
        ) : (
          <input
            id={id}
            className="input"
            type={kind === 'number' ? 'number' : 'text'}
            step={kind === 'number' ? 'any' : undefined}
            value={text}
            onChange={(e) => setText(e.target.value)}
          />
        )}
        <button type="submit" className="button small" disabled={!dirty || pending}>
          {pending ? 'Saving…' : 'Save'}
        </button>
      </div>
      <ReauthDialog {...reauth} />
    </form>
  );
}
