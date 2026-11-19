'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import {
  approveApplicationAction,
  featureMentorAction,
  mentorStatusAction,
  rejectApplicationAction,
  sessionTypeDisabledAction,
} from '@/app/mentorship-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';

/** Approve or reject a pending application. Rejecting needs a reason the applicant will read. */
export function ApplicationActions({ id, name }: { id: string; name: string }) {
  const router = useRouter();
  const [mode, setMode] = useState<'approve' | 'reject' | null>(null);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const close = () => {
    setMode(null);
    setError(null);
  };
  const approving = mode === 'approve';
  return (
    <>
      <span className="row-actions">
        <button
          type="button"
          className="button small"
          aria-label={`Approve ${name}`}
          onClick={() => setMode('approve')}
        >
          Approve
        </button>
        <button
          type="button"
          className="button secondary small"
          aria-label={`Reject ${name}`}
          onClick={() => setMode('reject')}
        >
          Reject
        </button>
      </span>
      <ConfirmDialog
        open={mode !== null}
        title={approving ? `Approve ${name} as a mentor` : `Reject ${name}`}
        confirmLabel={approving ? 'Approve' : 'Reject'}
        tone={approving ? 'primary' : 'danger'}
        reasonLabel={
          approving ? 'Note (optional, kept in the audit log)' : 'Reason (the applicant sees this)'
        }
        minReasonLength={approving ? 0 : 3}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={(reason) =>
          mode &&
          attempt(
            () =>
              approving ? approveApplicationAction(id, reason) : rejectApplicationAction(id, reason),
            () => {
              close();
              router.refresh();
            },
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          {approving
            ? 'This grants the Mentor role and publishes their profile with the session types they proposed.'
            : 'The applicant is told why and can apply again after a short wait.'}
        </p>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}

type Verb = 'pause' | 'resume' | 'remove';

const VERBS: Record<Verb, { button: string; effect: string; danger: boolean }> = {
  pause: {
    button: 'Pause',
    effect: 'Hidden from the directory. Their existing bookings are not affected.',
    danger: false,
  },
  resume: { button: 'Resume', effect: 'Visible in the directory again.', danger: false },
  remove: {
    button: 'Remove',
    effect:
      'Hidden everywhere and the Mentor role is revoked. They can apply again. This needs a fresh authenticator code.',
    danger: true,
  },
};

/** Pause, resume, remove and feature a mentor. */
export function MentorActions({
  id,
  name,
  status,
  featured,
}: {
  id: string;
  name: string;
  status: string;
  featured: boolean;
}) {
  const router = useRouter();
  const [verb, setVerb] = useState<Verb | null>(null);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const close = () => {
    setVerb(null);
    setError(null);
  };
  const offered: Verb[] =
    status === 'APPROVED' ? ['pause', 'remove'] : status === 'PAUSED' ? ['resume', 'remove'] : [];
  const copy = verb ? VERBS[verb] : null;
  return (
    <>
      <span className="row-actions">
        {offered.map((v) => (
          <button
            key={v}
            type="button"
            className="button secondary small"
            aria-label={`${VERBS[v].button} ${name}`}
            onClick={() => setVerb(v)}
          >
            {VERBS[v].button}
          </button>
        ))}
        {status === 'APPROVED' ? (
          <button
            type="button"
            className="button secondary small"
            aria-label={`${featured ? 'Unfeature' : 'Feature'} ${name}`}
            disabled={pending}
            onClick={() =>
              attempt(
                () => featureMentorAction(id, !featured),
                () => router.refresh(),
              )
            }
          >
            {featured ? 'Unfeature' : 'Feature'}
          </button>
        ) : null}
      </span>
      <ConfirmDialog
        open={verb !== null}
        title={copy ? `${copy.button} ${name}` : ''}
        confirmLabel={copy?.button ?? ''}
        tone={copy?.danger ? 'danger' : 'primary'}
        reasonLabel="Reason (the mentor sees this; kept in the audit log)"
        minReasonLength={3}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={(reason) =>
          verb &&
          attempt(
            () => mentorStatusAction(id, verb, reason),
            () => {
              close();
              router.refresh();
            },
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          {copy?.effect}
        </p>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}

/** Switch a session type off for members (or allow it again), with a note the mentor sees. */
export function SessionTypeToggle({
  id,
  name,
  disabled,
}: {
  id: string;
  name: string;
  disabled: boolean;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const close = () => {
    setOpen(false);
    setError(null);
  };
  return (
    <>
      <button
        type="button"
        className="button secondary small"
        aria-label={`${disabled ? 'Allow' : 'Switch off'} ${name}`}
        onClick={() => setOpen(true)}
      >
        {disabled ? 'Allow' : 'Switch off'}
      </button>
      <ConfirmDialog
        open={open}
        title={`${disabled ? 'Allow' : 'Switch off'} ${name}`}
        confirmLabel={disabled ? 'Allow' : 'Switch off'}
        tone={disabled ? 'primary' : 'danger'}
        reasonLabel="Note (the mentor sees this)"
        minReasonLength={0}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={(note) =>
          attempt(
            () => sessionTypeDisabledAction(id, !disabled, note),
            () => {
              close();
              router.refresh();
            },
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          {disabled
            ? 'The mentor can switch it on again.'
            : 'Members can no longer see or book it, and the mentor cannot turn it back on.'}
        </p>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}
