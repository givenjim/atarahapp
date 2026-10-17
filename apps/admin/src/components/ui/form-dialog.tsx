'use client';

import { useEffect, useId, useRef, type FormEvent, type ReactNode } from 'react';

/**
 * Modal form on the native <dialog>, like ConfirmDialog but for dialogs that collect several fields.
 * The caller owns the field state (children) and receives the submit; errors from the API show inline.
 */
export function FormDialog({
  open,
  title,
  children,
  submitLabel,
  pending = false,
  error,
  onSubmit,
  onCancel,
}: {
  open: boolean;
  title: string;
  children: ReactNode;
  submitLabel: string;
  pending?: boolean;
  error?: string | null;
  onSubmit: () => void;
  onCancel: () => void;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();

  useEffect(() => {
    const d = ref.current;
    if (!d) return;
    if (open && !d.open) d.showModal();
    if (!open && d.open) d.close();
  }, [open]);

  function submit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    onSubmit();
  }

  return (
    <dialog
      ref={ref}
      aria-labelledby={titleId}
      onCancel={onCancel}
      onClose={() => open && onCancel()}
    >
      <form onSubmit={submit} noValidate>
        <h2 id={titleId}>{title}</h2>
        {children}
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
            {pending ? 'Working…' : submitLabel}
          </button>
        </div>
      </form>
    </dialog>
  );
}
