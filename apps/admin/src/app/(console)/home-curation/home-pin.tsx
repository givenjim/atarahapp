'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { setFeaturedArticleAction } from '@/app/articles-actions';

export interface PinOption {
  id: string;
  title: string;
  authorName: string;
}

export function HomePin({
  current,
  options,
}: {
  current: { id: string | null; title: string | null };
  options: PinOption[];
}) {
  const router = useRouter();
  const [selected, setSelected] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  const change = (id: string | null) => {
    setError(null);
    start(async () => {
      const result = await setFeaturedArticleAction(id);
      if (result.ok) {
        setSelected('');
        router.refresh();
      } else {
        setError(result.error);
      }
    });
  };

  return (
    <section className="card" aria-label="Featured article" style={{ padding: 20 }}>
      <h2>Featured article</h2>
      {current.id ? (
        <p>
          Pinned now: <strong>{current.title ?? 'Untitled article'}</strong>{' '}
          <button
            type="button"
            className="button secondary small"
            disabled={pending}
            onClick={() => change(null)}
          >
            Un-pin
          </button>
        </p>
      ) : (
        <p className="muted">No article is pinned. Home shows its default order.</p>
      )}
      {options.length === 0 ? (
        <p className="empty">There are no published articles to pin yet.</p>
      ) : (
        <div className="filters">
          <label className="field">
            Published article
            <select
              className="select"
              value={selected}
              disabled={pending}
              onChange={(e) => setSelected(e.target.value)}
            >
              <option value="">Choose an article…</option>
              {options.map((o) => (
                <option key={o.id} value={o.id}>
                  {o.title} — {o.authorName}
                  {o.id === current.id ? ' (pinned)' : ''}
                </option>
              ))}
            </select>
          </label>
          <button
            type="button"
            className="button"
            disabled={pending || !selected}
            onClick={() => change(selected)}
          >
            Pin
          </button>
        </div>
      )}
      {error ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}
