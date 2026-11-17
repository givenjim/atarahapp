'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import {
  addModeratorAction,
  archiveGroupAction,
  pinPostAction,
  removeModeratorAction,
  unpinPostAction,
} from '@/app/community-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';

export interface ModeratorRow {
  id: string;
  name: string;
  handle: string | null;
  role: string;
}

/** Moderators, pinned announcements and archiving for one group. */
export function GroupManager({
  groupId,
  name,
  moderators,
  pinnedPostIds,
}: {
  groupId: string;
  name: string;
  moderators: ModeratorRow[];
  pinnedPostIds: string[];
}) {
  const router = useRouter();
  const [userId, setUserId] = useState('');
  const [role, setRole] = useState('MODERATOR');
  const [postId, setPostId] = useState('');
  const [archiving, setArchiving] = useState(false);
  const { attempt, pending, error, setError, reauth } = useReauth();

  const refresh = () => router.refresh();
  const run = (fn: () => ReturnType<typeof addModeratorAction>, after?: () => void) => {
    setError(null);
    attempt(fn, () => {
      after?.();
      refresh();
    });
  };

  return (
    <>
      <section className="card" aria-label="Moderators" style={{ padding: 20 }}>
        <h2>Moderators ({moderators.length})</h2>
        {moderators.length === 0 ? (
          <p className="empty">No moderators yet.</p>
        ) : (
          <ul className="plain-list">
            {moderators.map((m) => (
              <li key={m.id} className="row-actions" style={{ alignItems: 'center' }}>
                <span>
                  {m.name}
                  {m.handle ? <span className="muted"> @{m.handle}</span> : null}
                  <span className="muted"> · {m.role.toLowerCase()}</span>
                </span>
                <button
                  type="button"
                  className="button secondary small"
                  disabled={pending}
                  aria-label={`Remove ${m.name}`}
                  onClick={() => run(() => removeModeratorAction(groupId, m.id))}
                >
                  Remove
                </button>
              </li>
            ))}
          </ul>
        )}
        <form
          className="filters"
          style={{ padding: '16px 0 0' }}
          onSubmit={(e) => {
            e.preventDefault();
            run(
              () => addModeratorAction(groupId, userId, role),
              () => setUserId(''),
            );
          }}
        >
          <label className="field">
            Member user id
            <input
              className="input"
              value={userId}
              placeholder="Copy from the member's user page"
              onChange={(e) => setUserId(e.target.value)}
            />
          </label>
          <label className="field">
            Role
            <select className="select" value={role} onChange={(e) => setRole(e.target.value)}>
              <option value="MODERATOR">Moderator</option>
              <option value="OWNER">Owner</option>
            </select>
          </label>
          <button className="button" type="submit" disabled={pending || !userId.trim()}>
            Add moderator
          </button>
        </form>
      </section>

      <section className="card" aria-label="Pinned posts" style={{ padding: 20 }}>
        <h2>Pinned posts ({pinnedPostIds.length})</h2>
        {pinnedPostIds.length === 0 ? (
          <p className="empty">Nothing is pinned.</p>
        ) : (
          <ul className="plain-list">
            {pinnedPostIds.map((p) => (
              <li key={p} className="row-actions" style={{ alignItems: 'center' }}>
                <code>{p}</code>
                <button
                  type="button"
                  className="button secondary small"
                  disabled={pending}
                  aria-label={`Unpin ${p}`}
                  onClick={() => run(() => unpinPostAction(groupId, p))}
                >
                  Unpin
                </button>
              </li>
            ))}
          </ul>
        )}
        <form
          className="filters"
          style={{ padding: '16px 0 0' }}
          onSubmit={(e) => {
            e.preventDefault();
            run(
              () => pinPostAction(groupId, postId),
              () => setPostId(''),
            );
          }}
        >
          <label className="field">
            Post id
            <input
              className="input"
              value={postId}
              placeholder="A post in this group"
              onChange={(e) => setPostId(e.target.value)}
            />
          </label>
          <button className="button" type="submit" disabled={pending || !postId.trim()}>
            Pin post
          </button>
        </form>
      </section>

      <section className="card" aria-label="Archive group" style={{ padding: 20 }}>
        <h2>Archive</h2>
        <p className="muted">
          Archiving hides the group and stops new posts. It needs a fresh authenticator code and is
          recorded in the audit log.
        </p>
        <button type="button" className="button danger" onClick={() => setArchiving(true)}>
          Archive group
        </button>
      </section>

      {error && !archiving ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}

      <ConfirmDialog
        open={archiving}
        title={`Archive “${name}”?`}
        confirmLabel="Archive group"
        tone="danger"
        pending={pending}
        error={archiving ? error : null}
        onCancel={() => setArchiving(false)}
        onConfirm={() =>
          attempt(
            () => archiveGroupAction(groupId),
            () => {
              setArchiving(false);
              router.push('/groups');
              router.refresh();
            },
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          Members will no longer see this group.
        </p>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}
