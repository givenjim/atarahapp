'use client';

import { useEffect, useId, useRef, type FormEvent } from 'react';

/**
 * Sensitive actions need a fresh authenticator code (Master Prompt §7.4, Supabase MFA). The dialog only
 * collects it; the server action verifies it with Supabase and the API checks the verification time.
 */
export function ReauthDialog({
  open,
  pending = false,
  error,
  onSubmit,
  onCancel,
}: {
  open: boolean;
  pending?: boolean;
  error?: string | null;
  onSubmit: (credentials: { code: string }) => void;
  onCancel: () => void;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();
  const codeId = useId();

  useEffect(() => {
    const d = ref.current;
    if (!d) return;
    if (open && !d.open) d.showModal();
    if (!open && d.open) d.close();
  }, [open]);

  function submit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    onSubmit({ code: String(f.get('code') ?? '').trim() });
  }

  return (
    <dialog
      ref={ref}
      aria-labelledby={titleId}
      onCancel={onCancel}
      onClose={() => open && onCancel()}
    >
      <form onSubmit={submit}>
        <h2 id={titleId}>Confirm it&apos;s you</h2>
        <p className="muted" style={{ margin: 0 }}>
          This action needs a current code from your authenticator app.
        </p>
        <label className="field" htmlFor={codeId}>
          Authenticator code
          <input
            id={codeId}
            name="code"
            className="input"
            inputMode="numeric"
            autoComplete="one-time-code"
            pattern="[0-9]{6}"
            maxLength={6}
            required
          />
        </label>
        {error ? (
          <p className="alert" role="alert">
            {error}
          </p>
        ) : null}
        <div className="dialog-actions">
          <button type="button" className="button secondary" onClick={onCancel} disabled={pending}>
            Cancel
          </button>
          <button type="submit" className="button" disabled={pending}>
            {pending ? 'Checking…' : 'Confirm'}
          </button>
        </div>
      </form>
    </dialog>
  );
}
