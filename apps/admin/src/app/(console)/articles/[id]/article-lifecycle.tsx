'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { articleLifecycleAction, type ArticleResult } from '@/app/articles-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import {
  lifecycleOptions,
  scheduleToIso,
  type ArticleStatus,
  type LifecycleKind,
} from '@/lib/articles';

const LABEL: Record<LifecycleKind, string> = {
  submit: 'Submit for review',
  return: 'Return to draft',
  publish: 'Publish now',
  schedule: 'Schedule…',
  archive: 'Archive',
  restore: 'Restore to draft',
};

type Dialog = 'publish' | 'schedule' | 'archive' | null;

export function ArticleLifecycle({
  id,
  title,
  status,
  dirty = false,
}: {
  id: string;
  title: string;
  status: ArticleStatus;
  /** Unsaved edits: the buttons wait until they are saved, because the API checks the saved article. */
  dirty?: boolean;
}) {
  const router = useRouter();
  const [dialog, setDialog] = useState<Dialog>(null);
  const [publishAt, setPublishAt] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  const close = () => {
    setDialog(null);
    setPublishAt('');
    setError(null);
  };

  const finish = (result: ArticleResult) => {
    if (result.ok) {
      close();
      router.refresh();
    } else {
      setError(result.error);
    }
  };

  const run = (kind: LifecycleKind, at?: string) =>
    start(async () => finish(await articleLifecycleAction(id, kind, at)));

  const click = (kind: LifecycleKind) => {
    setError(null);
    if (kind === 'publish' || kind === 'schedule' || kind === 'archive') setDialog(kind);
    else run(kind);
  };

  const submitSchedule = () => {
    const r = scheduleToIso(publishAt);
    if (!r.ok) return setError(r.error);
    run('schedule', r.iso);
  };

  return (
    <section className="card" aria-label="Status actions" style={{ padding: 20 }}>
      <div className="row-actions">
        {lifecycleOptions(status).map((kind) => (
          <button
            key={kind}
            type="button"
            className={`button ${kind === 'archive' ? 'danger' : kind === 'return' ? 'secondary' : ''}`.trim()}
            disabled={dirty || pending}
            onClick={() => click(kind)}
          >
            {LABEL[kind]}
          </button>
        ))}
      </div>
      {dirty ? (
        <p className="muted" role="status">
          Save your changes before changing the status.
        </p>
      ) : null}
      {status === 'ARCHIVED' ? (
        <p className="muted">
          This article is archived and cannot be edited. Restore it to a draft to edit it again.
        </p>
      ) : null}
      {dialog === null && error ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}

      <ConfirmDialog
        open={dialog === 'publish'}
        title={`Publish “${title}” now?`}
        confirmLabel="Publish now"
        pending={pending}
        error={dialog === 'publish' ? error : null}
        onCancel={close}
        onConfirm={() => run('publish')}
      >
        <p className="muted" style={{ margin: 0 }}>
          The article becomes visible to members straight away.
        </p>
      </ConfirmDialog>

      <FormDialog
        open={dialog === 'schedule'}
        title={`Schedule “${title}”`}
        submitLabel="Schedule"
        pending={pending}
        error={dialog === 'schedule' ? error : null}
        onSubmit={submitSchedule}
        onCancel={close}
      >
        <label className="field">
          Publish at
          <input
            className="input"
            type="datetime-local"
            value={publishAt}
            onChange={(e) => setPublishAt(e.target.value)}
          />
        </label>
        <p className="muted" style={{ margin: 0 }}>
          Your browser&apos;s local time. The article stays hidden until then.
        </p>
      </FormDialog>

      <ConfirmDialog
        open={dialog === 'archive'}
        title={`Archive “${title}”?`}
        confirmLabel="Archive"
        tone="danger"
        pending={pending}
        error={dialog === 'archive' ? error : null}
        onCancel={close}
        onConfirm={() => run('archive')}
      >
        <p className="muted" style={{ margin: 0 }}>
          Members stop seeing the article. You can restore it to a draft later.
        </p>
      </ConfirmDialog>
    </section>
  );
}
