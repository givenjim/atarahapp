'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { createAnnouncementAction } from '@/app/community-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { ANNOUNCEMENT_MAX, validateAnnouncement } from '@/lib/moderation';

export function AnnouncementForm({ groups }: { groups: { id: string; name: string }[] }) {
  const router = useRouter();
  const [body, setBody] = useState('');
  const [groupId, setGroupId] = useState('');
  const [confirming, setConfirming] = useState(false);
  const [sent, setSent] = useState(false);
  const { attempt, pending, error, setError, reauth } = useReauth();

  const audience = groups.find((g) => g.id === groupId)?.name ?? 'every member';

  const review = () => {
    const problem = validateAnnouncement(body, groupId);
    setSent(false);
    if (problem) return setError(problem);
    setError(null);
    setConfirming(true);
  };

  return (
    <section className="card" aria-label="New announcement" style={{ padding: 20 }}>
      <h2>New announcement</h2>
      <form
        className="filters"
        style={{ padding: '12px 0 0', flexDirection: 'column', alignItems: 'stretch' }}
        onSubmit={(e) => {
          e.preventDefault();
          review();
        }}
      >
        <label className="field">
          Announcement
          <textarea
            className="textarea"
            value={body}
            maxLength={ANNOUNCEMENT_MAX}
            onChange={(e) => setBody(e.target.value)}
          />
        </label>
        <label className="field">
          Audience
          <select className="select" value={groupId} onChange={(e) => setGroupId(e.target.value)}>
            <option value="">Every member</option>
            {groups.map((g) => (
              <option key={g.id} value={g.id}>
                {g.name}
              </option>
            ))}
          </select>
        </label>
        {error && !confirming ? (
          <p className="alert" role="alert">
            {error}
          </p>
        ) : null}
        {sent ? (
          <p className="notice" role="status" style={{ margin: 0 }}>
            Announcement posted.
          </p>
        ) : null}
        <div>
          <button className="button" type="submit" disabled={pending}>
            Review and post
          </button>
        </div>
      </form>

      <ConfirmDialog
        open={confirming}
        title="Post this announcement?"
        confirmLabel="Post announcement"
        pending={pending}
        error={confirming ? error : null}
        onCancel={() => {
          setConfirming(false);
          setError(null);
        }}
        onConfirm={() =>
          attempt(
            () => createAnnouncementAction(body, groupId),
            () => {
              setConfirming(false);
              setBody('');
              setSent(true);
              router.refresh();
            },
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          It goes to {audience} straight away and cannot be edited from here. You will be asked for
          your authenticator code.
        </p>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </section>
  );
}
