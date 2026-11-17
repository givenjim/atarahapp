'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import {
  deleteHelpArticleAction,
  reorderHelpArticlesAction,
  setHelpArticlePublishedAction,
} from '@/app/help-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { swapOrders, type Orderable } from '@/lib/help';

/** Publish, move and delete one help article. Moving is only offered on the full list (not a search). */
export function ArticleRowActions({
  id,
  title,
  published,
  items,
  reorderable,
}: {
  id: string;
  title: string;
  published: boolean;
  items: Orderable[];
  reorderable: boolean;
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [confirming, setConfirming] = useState(false);

  const run = (fn: () => Promise<{ ok: boolean; error?: string }>, after?: () => void) =>
    start(async () => {
      const res = await fn();
      if (res.ok) {
        setError(null);
        after?.();
        router.refresh();
      } else setError(res.error ?? 'Something went wrong.');
    });

  const move = (direction: 'up' | 'down') => {
    const updates = swapOrders(items, id, direction);
    if (updates.length === 0) return;
    run(() => reorderHelpArticlesAction(updates));
  };

  return (
    <>
      <span className="row-actions">
        <Link className="button secondary small" href={`/content/${id}`}>
          Edit
        </Link>
        <button
          type="button"
          className="button secondary small"
          disabled={pending}
          onClick={() => run(() => setHelpArticlePublishedAction(id, !published))}
        >
          {published ? 'Unpublish' : 'Publish'}
        </button>
        {reorderable ? (
          <>
            <button
              type="button"
              className="button secondary small"
              aria-label={`Move ${title} up`}
              disabled={pending}
              onClick={() => move('up')}
            >
              Up
            </button>
            <button
              type="button"
              className="button secondary small"
              aria-label={`Move ${title} down`}
              disabled={pending}
              onClick={() => move('down')}
            >
              Down
            </button>
          </>
        ) : null}
        <button
          type="button"
          className="button danger small"
          aria-label={`Delete ${title}`}
          disabled={pending}
          onClick={() => setConfirming(true)}
        >
          Delete
        </button>
      </span>
      {error ? (
        <p className="alert" role="alert" style={{ margin: '6px 0 0' }}>
          {error}
        </p>
      ) : null}
      <ConfirmDialog
        open={confirming}
        title={`Delete “${title}”?`}
        confirmLabel="Delete article"
        tone="danger"
        pending={pending}
        error={error}
        onCancel={() => setConfirming(false)}
        onConfirm={() =>
          run(
            () => deleteHelpArticleAction(id),
            () => setConfirming(false),
          )
        }
      >
        <p>
          Members will no longer find it in Help, and links to it stop working. To hide it for now,
          unpublish it instead.
        </p>
      </ConfirmDialog>
    </>
  );
}
