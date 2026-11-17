'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { transitionContentAction } from '@/app/learning-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { actionsFor } from '@/lib/learning';

type Dialog = 'publish' | 'unpublish' | 'archive' | null;

/**
 * Publish, unpublish and archive one item. Buttons follow its status and learner count (the API allows the same moves
 * and checks them again). Publishing shows what is missing in the API's own words, for example "Add at least one
 * lesson before publishing."
 */
export function ContentActions({
  id,
  title,
  status,
  learners,
}: {
  id: string;
  title: string;
  status: string;
  learners: number;
}) {
  const router = useRouter();
  const [dialog, setDialog] = useState<Dialog>(null);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const allowed = actionsFor(status, learners);

  const close = () => {
    setDialog(null);
    setError(null);
  };
  const move = (verb: 'publish' | 'unpublish' | 'archive') =>
    attempt(
      () => transitionContentAction(id, verb),
      () => {
        close();
        router.refresh();
      },
    );

  return (
    <section className="card" aria-label="Actions" style={{ padding: 20 }}>
      <h2>Publishing</h2>
      <div className="row-actions" style={{ flexWrap: 'wrap' }}>
        {allowed.includes('publish') ? (
          <button type="button" className="button" onClick={() => setDialog('publish')}>
            Publish
          </button>
        ) : null}
        {allowed.includes('unpublish') ? (
          <button type="button" className="button secondary" onClick={() => setDialog('unpublish')}>
            Unpublish
          </button>
        ) : null}
        {allowed.includes('archive') ? (
          <button type="button" className="button secondary" onClick={() => setDialog('archive')}>
            Archive
          </button>
        ) : null}
      </div>
      {status === 'PUBLISHED' && learners > 0 ? (
        <p className="muted">
          {learners} {learners === 1 ? 'member has' : 'members have'} started this, so it can be
          archived but not taken back to draft.
        </p>
      ) : null}

      <ConfirmDialog
        open={dialog === 'publish'}
        title={`Publish “${title}”?`}
        confirmLabel="Publish"
        pending={pending}
        error={dialog === 'publish' ? error : null}
        onCancel={close}
        onConfirm={() => move('publish')}
      >
        <p className="muted" style={{ margin: 0 }}>
          Members will see it in Skill Labs straight away. A course needs at least one lesson with
          something to read or watch; an external item needs its address; an embedded item needs its
          player.
        </p>
      </ConfirmDialog>
      <ConfirmDialog
        open={dialog === 'unpublish'}
        title={`Unpublish “${title}”?`}
        confirmLabel="Unpublish"
        pending={pending}
        error={dialog === 'unpublish' ? error : null}
        onCancel={close}
        onConfirm={() => move('unpublish')}
      >
        <p className="muted" style={{ margin: 0 }}>
          It goes back to draft and leaves the app. Nobody has started it yet.
        </p>
      </ConfirmDialog>
      <ConfirmDialog
        open={dialog === 'archive'}
        title={`Archive “${title}”?`}
        confirmLabel="Archive"
        pending={pending}
        error={dialog === 'archive' ? error : null}
        onCancel={close}
        onConfirm={() => move('archive')}
      >
        <p className="muted" style={{ margin: 0 }}>
          It disappears for new members. Members already learning it keep it, and issued
          certificates stay.
        </p>
      </ConfirmDialog>

      {error && !dialog ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}
      <ReauthDialog {...reauth} />
    </section>
  );
}
