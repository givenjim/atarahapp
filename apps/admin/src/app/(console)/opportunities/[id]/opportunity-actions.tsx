'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import {
  featureOpportunityAction,
  rejectOpportunityAction,
  setTrustAction,
  transitionOpportunityAction,
  verifyOpportunityAction,
} from '@/app/opportunity-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { actionsFor, deadlineToIso, trustMeta } from '@/lib/opportunities';

type Dialog =
  'publish' | 'close' | 'archive' | 'remove' | 'reject' | 'feature' | 'trust' | 'verify' | null;

/**
 * Lifecycle, feature and trust decisions for one listing. Buttons follow the listing's status (the API allows the
 * same moves and checks them again). Remove and Verify need a fresh authenticator code. Verify is offered only to
 * administrators with `opportunity.verify`.
 */
export function OpportunityActions({
  id,
  title,
  status,
  trust,
  featured,
  canVerify,
}: {
  id: string;
  title: string;
  status: string;
  trust: string;
  featured: boolean;
  canVerify: boolean;
}) {
  const router = useRouter();
  const [dialog, setDialog] = useState<Dialog>(null);
  const [until, setUntil] = useState('');
  const [trustChoice, setTrustChoice] = useState(
    trust === 'SOURCE_CONFIRMED' ? 'EXTERNAL_SOURCE' : 'SOURCE_CONFIRMED',
  );
  const [trustReason, setTrustReason] = useState('');
  const { attempt, pending, error, setError, reauth } = useReauth();
  const allowed = actionsFor(status);

  const close = () => {
    setDialog(null);
    setError(null);
  };
  const done = () => {
    close();
    router.refresh();
  };
  const move = (verb: 'publish' | 'close' | 'archive' | 'remove') =>
    attempt(() => transitionOpportunityAction(id, verb), done);

  return (
    <section className="card" aria-label="Actions" style={{ padding: 20 }}>
      <h2>Actions</h2>
      <div className="row-actions" style={{ flexWrap: 'wrap' }}>
        {allowed.includes('publish') ? (
          <button type="button" className="button" onClick={() => setDialog('publish')}>
            Publish
          </button>
        ) : null}
        {allowed.includes('reject') ? (
          <button type="button" className="button secondary" onClick={() => setDialog('reject')}>
            Send back
          </button>
        ) : null}
        {allowed.includes('close') ? (
          <button type="button" className="button secondary" onClick={() => setDialog('close')}>
            Close
          </button>
        ) : null}
        {allowed.includes('feature') ? (
          featured ? (
            <button
              type="button"
              className="button secondary"
              disabled={pending}
              onClick={() => attempt(() => featureOpportunityAction(id, null), done)}
            >
              Remove feature
            </button>
          ) : (
            <button type="button" className="button secondary" onClick={() => setDialog('feature')}>
              Feature
            </button>
          )
        ) : null}
        {allowed.includes('archive') ? (
          <button type="button" className="button secondary" onClick={() => setDialog('archive')}>
            Archive
          </button>
        ) : null}
        {allowed.includes('remove') ? (
          <button type="button" className="button danger" onClick={() => setDialog('remove')}>
            Remove
          </button>
        ) : null}
      </div>

      <h3 style={{ marginTop: 20 }}>Trust badge</h3>
      <p className="muted">
        Now: {trustMeta(trust).label}. “Verified by Atarah” is a decision only people with the
        verify permission can make. It needs a fresh authenticator code and is recorded in the audit
        log.
      </p>
      <div className="row-actions">
        <button type="button" className="button secondary" onClick={() => setDialog('trust')}>
          Set source level
        </button>
        {canVerify && trust !== 'VERIFIED' ? (
          <button type="button" className="button" onClick={() => setDialog('verify')}>
            Verify (Verified by Atarah)
          </button>
        ) : null}
        {!canVerify ? <span className="muted">You cannot give the Verified badge.</span> : null}
      </div>

      {error && !dialog ? (
        <p className="alert" role="alert">
          {error}
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
          Members will see it in Opportunities straight away. It needs a way to apply and a deadline
          that has not passed.
        </p>
      </ConfirmDialog>
      <ConfirmDialog
        open={dialog === 'close'}
        title={`Close “${title}”?`}
        confirmLabel="Close listing"
        pending={pending}
        error={dialog === 'close' ? error : null}
        onCancel={close}
        onConfirm={() => move('close')}
      >
        <p className="muted" style={{ margin: 0 }}>
          It leaves discovery. Members who are tracking it keep it in their list.
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
          Archived listings are hidden from members and cannot be published again.
        </p>
      </ConfirmDialog>
      <ConfirmDialog
        open={dialog === 'remove'}
        title={`Remove “${title}”?`}
        confirmLabel="Remove"
        tone="danger"
        pending={pending}
        error={dialog === 'remove' ? error : null}
        onCancel={close}
        onConfirm={() => move('remove')}
      >
        <p className="muted" style={{ margin: 0 }}>
          The listing disappears for everyone, including members tracking it. This needs a fresh
          authenticator code.
        </p>
      </ConfirmDialog>
      <ConfirmDialog
        open={dialog === 'reject'}
        title="Send back to the provider"
        confirmLabel="Send back"
        reasonLabel="What should the provider change?"
        minReasonLength={3}
        pending={pending}
        error={dialog === 'reject' ? error : null}
        onCancel={close}
        onConfirm={(reason) => attempt(() => rejectOpportunityAction(id, reason), done)}
      >
        <p className="muted" style={{ margin: 0 }}>
          It returns to draft and the provider is told why.
        </p>
      </ConfirmDialog>
      <ConfirmDialog
        open={dialog === 'verify'}
        title={`Verify “${title}”?`}
        confirmLabel="Verify"
        reasonLabel="Why is it verified? (optional, kept in the audit log)"
        minReasonLength={0}
        pending={pending}
        error={dialog === 'verify' ? error : null}
        onCancel={close}
        onConfirm={(reason) => attempt(() => verifyOpportunityAction(id, reason), done)}
      >
        <p className="muted" style={{ margin: 0 }}>
          Members will see “Verified by Atarah” on this listing. Only verify what you have confirmed
          with the organiser.
        </p>
      </ConfirmDialog>

      <FormDialog
        open={dialog === 'feature'}
        title="Feature this listing"
        submitLabel="Feature"
        pending={pending}
        error={dialog === 'feature' ? error : null}
        onCancel={close}
        onSubmit={() => {
          const iso = deadlineToIso(until);
          if (!iso) return setError('Choose when the feature ends.');
          attempt(() => featureOpportunityAction(id, iso), done);
        }}
      >
        <label className="field">
          Featured until (Nairobi time)
          <input
            className="input"
            type="datetime-local"
            value={until}
            onChange={(e) => setUntil(e.target.value)}
          />
        </label>
      </FormDialog>
      <FormDialog
        open={dialog === 'trust'}
        title="Set the source level"
        submitLabel="Save"
        pending={pending}
        error={dialog === 'trust' ? error : null}
        onCancel={close}
        onSubmit={() => attempt(() => setTrustAction(id, trustChoice, trustReason), done)}
      >
        <label className="field">
          Level
          <select
            className="select"
            value={trustChoice}
            onChange={(e) => setTrustChoice(e.target.value)}
          >
            <option value="SOURCE_CONFIRMED">Source confirmed</option>
            <option value="EXTERNAL_SOURCE">External source</option>
          </select>
        </label>
        <label className="field">
          Why? (optional, kept in the audit log)
          <textarea
            className="textarea"
            maxLength={300}
            value={trustReason}
            onChange={(e) => setTrustReason(e.target.value)}
          />
        </label>
      </FormDialog>
      <ReauthDialog {...reauth} />
    </section>
  );
}
