'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { createArticleAction } from '@/app/articles-actions';
import { FormDialog } from '@/components/ui/form-dialog';
import { BYLINE_MAX, TITLE_MAX, validateNewArticle } from '@/lib/articles';

export function NewArticleForm() {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState('');
  const [authorName, setAuthorName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  const close = () => {
    setOpen(false);
    setError(null);
    setTitle('');
    setAuthorName('');
  };

  const submit = () => {
    const problem = validateNewArticle(title, authorName);
    if (problem) return setError(problem);
    start(async () => {
      const result = await createArticleAction(title, authorName);
      if (result.ok) {
        close();
        router.push(`/articles/${result.id}`);
      } else {
        setError(result.error);
      }
    });
  };

  return (
    <>
      <button type="button" className="button" onClick={() => setOpen(true)}>
        New article
      </button>
      <FormDialog
        open={open}
        title="New article"
        submitLabel="Create draft"
        pending={pending}
        error={error}
        onSubmit={submit}
        onCancel={close}
      >
        <label className="field">
          Title
          <input
            className="input"
            value={title}
            maxLength={TITLE_MAX}
            onChange={(e) => setTitle(e.target.value)}
          />
        </label>
        <label className="field">
          Byline
          <input
            className="input"
            value={authorName}
            maxLength={BYLINE_MAX}
            onChange={(e) => setAuthorName(e.target.value)}
          />
        </label>
        <p className="muted" style={{ margin: 0 }}>
          The article starts as a draft. You add the summary, image and content next.
        </p>
      </FormDialog>
    </>
  );
}
