'use client';

import { useEffect, useId, useRef, type FormEvent, type ReactNode } from 'react';

/**
 * Modal confirmation built on the native <dialog> (focus trap, Escape and backdrop come from the browser).
 * With `reasonLabel` it collects a mandatory reason, which the caller sends to the API and which is audited.
 */
export function ConfirmDialog({
  open,
  title,
  children,
  confirmLabel,
  tone = 'primary',
  reasonLabel,
  minReasonLength = 5,
  pending = false,
  error,
  onConfirm,
  onCancel,
}: {
  open: boolean;
  title: string;
  children?: ReactNode;
  confirmLabel: string;
  tone?: 'primary' | 'danger';
  reasonLabel?: string;
  minReasonLength?: number;
  pending?: boolean;
  error?: string | null;
  onConfirm: (reason: string) => void;
  onCancel: () => void;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();
  const reasonId = useId();

  useEffect(() => {
    const d = ref.current;
    if (!d) return;
    if (open && !d.open) d.showModal();
    if (!open && d.open) d.close();
  }, [open]);

  function submit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const reason = String(new FormData(e.currentTarget).get('reason') ?? '').trim();
    onConfirm(reason);
  }

  return (
    <dialog
      ref={ref}
      aria-labelledby={titleId}
      onCancel={onCancel}
      onClose={() => open && onCancel()}
    >
      <form onSubmit={submit}>
        <h2 id={titleId}>{title}</h2>
        {children}
        {reasonLabel ? (
          <label className="field" htmlFor={reasonId}>
            {reasonLabel}
            <textarea
              id={reasonId}
              name="reason"
              className="textarea"
              required={minReasonLength > 0}
              minLength={minReasonLength || undefined}
              maxLength={500}
            />
          </label>
        ) : null}
        {error ? (
          <p className="alert" role="alert">
            {error}
          </p>
        ) : null}
        <div className="dialog-actions">
          <button type="button" className="button secondary" onClick={onCancel} disabled={pending}>
            Cancel
          </button>
          <button
            type="submit"
            className={`button ${tone === 'danger' ? 'danger' : ''}`}
            disabled={pending}
          >
            {pending ? 'Working…' : confirmLabel}
          </button>
        </div>
      </form>
    </dialog>
  );
}
