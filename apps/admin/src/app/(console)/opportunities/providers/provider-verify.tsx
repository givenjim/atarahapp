'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { verifyProviderAction } from '@/app/opportunity-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';

type Decision = 'VERIFIED' | 'REJECTED' | 'REVOKED';

const COPY: Record<Decision, { button: string; title: string; effect: string; danger: boolean }> = {
  VERIFIED: {
    button: 'Verify',
    title: 'Verify this provider',
    effect:
      'Members see a verified tick next to this provider. Only verify organisations you have confirmed.',
    danger: false,
  },
  REJECTED: {
    button: 'Reject',
    title: 'Reject this provider',
    effect: 'The provider is marked rejected. Nothing is removed from members.',
    danger: true,
  },
  REVOKED: {
    button: 'Revoke',
    title: 'Revoke verification',
    effect: 'The verified tick is removed from this provider’s listings.',
    danger: true,
  },
};

/** Provider verification. Only shown to administrators with `opportunity.verify`; needs a fresh authenticator code. */
export function ProviderVerify({ id, name, status }: { id: string; name: string; status: string }) {
  const router = useRouter();
  const [decision, setDecision] = useState<Decision | null>(null);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const offered: Decision[] =
    status === 'VERIFIED'
      ? ['REVOKED']
      : status === 'REJECTED'
        ? ['VERIFIED']
        : ['VERIFIED', 'REJECTED'];
  const close = () => {
    setDecision(null);
    setError(null);
  };
  const copy = decision ? COPY[decision] : null;

  return (
    <>
      {offered.map((d) => (
        <button
          key={d}
          type="button"
          className="button secondary small"
          aria-label={`${COPY[d].button} ${name}`}
          onClick={() => setDecision(d)}
        >
          {COPY[d].button}
        </button>
      ))}
      <ConfirmDialog
        open={decision !== null}
        title={copy ? `${copy.title}: ${name}` : ''}
        confirmLabel={copy?.button ?? ''}
        tone={copy?.danger ? 'danger' : 'primary'}
        reasonLabel="Reason (optional, kept in the audit log)"
        minReasonLength={0}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={(reason) =>
          decision &&
          attempt(
            () => verifyProviderAction(id, decision, reason),
            () => {
              close();
              router.refresh();
            },
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          {copy?.effect} This needs a fresh authenticator code.
        </p>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}
