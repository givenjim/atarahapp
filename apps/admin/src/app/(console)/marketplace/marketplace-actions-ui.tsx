'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import {
  createCategoryAction,
  directPublishAction,
  featureListingAction,
  listingDecisionAction,
  resolveReportAction,
  reviewModerationAction,
  sellerStatusAction,
  updateCategoryAction,
} from '@/app/marketplace-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { FormDialog } from '@/components/ui/form-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { CATEGORY_TONES, listingVerbs } from '@/lib/marketplace';

type ListingVerb = 'approve' | 'reject' | 'suspend' | 'reinstate';

const LISTING_COPY: Record<
  ListingVerb,
  { button: string; reason: string | null; effect: string; danger: boolean }
> = {
  approve: {
    button: 'Approve',
    reason: null,
    effect: 'The listing goes live and the seller is told.',
    danger: false,
  },
  reject: {
    button: 'Reject',
    reason: 'Reason (the seller reads this and can fix and resubmit)',
    effect: 'The listing is sent back to the seller with your reason.',
    danger: true,
  },
  suspend: {
    button: 'Suspend',
    reason: 'Reason (the seller sees this; kept in the audit log)',
    effect: 'The listing is hidden from the marketplace at once.',
    danger: true,
  },
  reinstate: {
    button: 'Reinstate',
    reason: 'Reason (kept in the audit log)',
    effect: 'The listing is live again.',
    danger: false,
  },
};

/** The review-queue actions for one listing, plus featuring a live one. */
export function ListingActions({
  id,
  title,
  status,
  featured,
}: {
  id: string;
  title: string;
  status: string;
  featured: boolean;
}) {
  const router = useRouter();
  const [verb, setVerb] = useState<ListingVerb | null>(null);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const close = () => {
    setVerb(null);
    setError(null);
  };
  const copy = verb ? LISTING_COPY[verb] : null;
  return (
    <>
      <span className="row-actions">
        {listingVerbs(status).map((v) => (
          <button
            key={v}
            type="button"
            className={`button small ${v === 'approve' ? '' : 'secondary'}`.trim()}
            aria-label={`${LISTING_COPY[v].button} ${title}`}
            onClick={() => setVerb(v)}
          >
            {LISTING_COPY[v].button}
          </button>
        ))}
        {status === 'PUBLISHED' ? (
          <button
            type="button"
            className="button secondary small"
            aria-label={`${featured ? 'Unfeature' : 'Feature'} ${title}`}
            disabled={pending}
            onClick={() =>
              attempt(
                () =>
                  featureListingAction(
                    id,
                    featured ? null : new Date(Date.now() + 14 * 86_400_000).toISOString(),
                  ),
                () => router.refresh(),
              )
            }
          >
            {featured ? 'Unfeature' : 'Feature 14 days'}
          </button>
        ) : null}
      </span>
      <ConfirmDialog
        open={verb !== null}
        title={copy ? `${copy.button}: ${title}` : ''}
        confirmLabel={copy?.button ?? ''}
        tone={copy?.danger ? 'danger' : 'primary'}
        {...(copy?.reason ? { reasonLabel: copy.reason, minReasonLength: 5 } : {})}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={(reason) =>
          verb &&
          attempt(
            () => listingDecisionAction(id, verb, reason),
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

/** Suspend or reinstate a seller, and mark one who may publish without review. */
export function SellerActions({
  id,
  name,
  status,
  canPublishDirectly,
}: {
  id: string;
  name: string;
  status: string;
  canPublishDirectly: boolean;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const suspended = status === 'SUSPENDED';
  const verb = suspended ? 'reinstate' : 'suspend';
  const close = () => {
    setOpen(false);
    setError(null);
  };
  return (
    <>
      <span className="row-actions">
        <button
          type="button"
          className="button secondary small"
          aria-label={`${suspended ? 'Reinstate' : 'Suspend'} ${name}`}
          onClick={() => setOpen(true)}
        >
          {suspended ? 'Reinstate' : 'Suspend'}
        </button>
        <button
          type="button"
          className="button secondary small"
          aria-label={`${canPublishDirectly ? 'Require review for' : 'Let publish directly:'} ${name}`}
          disabled={pending}
          onClick={() =>
            attempt(
              () => directPublishAction(id, !canPublishDirectly),
              () => router.refresh(),
            )
          }
        >
          {canPublishDirectly ? 'Require review' : 'Publish directly'}
        </button>
      </span>
      <ConfirmDialog
        open={open}
        title={`${suspended ? 'Reinstate' : 'Suspend'} ${name}`}
        confirmLabel={suspended ? 'Reinstate' : 'Suspend'}
        tone={suspended ? 'primary' : 'danger'}
        reasonLabel="Reason (kept in the audit log)"
        minReasonLength={5}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={(reason) =>
          attempt(
            () => sellerStatusAction(id, verb, reason),
            () => {
              close();
              router.refresh();
            },
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          {suspended
            ? 'Their live listings that were suspended with them come back. This needs a fresh authenticator code.'
            : 'They cannot create, submit or reply, and their live listings are hidden. This needs a fresh authenticator code.'}
        </p>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}

/** Decide a report: dismiss it or take the listing down. */
export function ReportActions({ id, title }: { id: string; title: string }) {
  const router = useRouter();
  const [action, setAction] = useState<'DISMISS' | 'SUSPEND_LISTING' | null>(null);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const close = () => {
    setAction(null);
    setError(null);
  };
  const suspend = action === 'SUSPEND_LISTING';
  return (
    <>
      <span className="row-actions">
        <button
          type="button"
          className="button secondary small"
          aria-label={`Dismiss report on ${title}`}
          onClick={() => setAction('DISMISS')}
        >
          Dismiss
        </button>
        <button
          type="button"
          className="button small"
          aria-label={`Take down ${title}`}
          onClick={() => setAction('SUSPEND_LISTING')}
        >
          Take down listing
        </button>
      </span>
      <ConfirmDialog
        open={action !== null}
        title={suspend ? `Take down ${title}` : `Dismiss the report on ${title}`}
        confirmLabel={suspend ? 'Take down' : 'Dismiss'}
        tone={suspend ? 'danger' : 'primary'}
        reasonLabel={suspend ? 'Reason (the seller sees this)' : 'Note (kept in the audit log)'}
        minReasonLength={5}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={(note) =>
          action &&
          attempt(
            () => resolveReportAction(id, action, note),
            () => {
              close();
              router.refresh();
            },
          )
        }
      />
      <ReauthDialog {...reauth} />
    </>
  );
}

/** Hide a review that breaks the rules, or bring it back. */
export function ReviewActions({ id, status }: { id: string; status: string }) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const { attempt, pending, error, setError, reauth } = useReauth();
  const hidden = status === 'HIDDEN';
  const close = () => {
    setOpen(false);
    setError(null);
  };
  return (
    <>
      <button
        type="button"
        className="button secondary small"
        aria-label={`${hidden ? 'Restore' : 'Hide'} review`}
        onClick={() => setOpen(true)}
      >
        {hidden ? 'Restore' : 'Hide'}
      </button>
      <ConfirmDialog
        open={open}
        title={hidden ? 'Restore this review' : 'Hide this review'}
        confirmLabel={hidden ? 'Restore' : 'Hide'}
        tone={hidden ? 'primary' : 'danger'}
        reasonLabel="Reason (kept in the audit log)"
        minReasonLength={5}
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={(reason) =>
          attempt(
            () => reviewModerationAction(id, hidden ? 'restore' : 'hide', reason),
            () => {
              close();
              router.refresh();
            },
          )
        }
      >
        <p className="muted" style={{ margin: 0 }}>
          {hidden
            ? 'The review counts towards the rating again.'
            : 'The review leaves the listing and no longer counts towards the rating.'}
        </p>
      </ConfirmDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}

interface CategoryRow {
  id: string;
  name: string;
  icon: string;
  tone: string;
  sortOrder: number;
  isActive: boolean;
  count: number;
}

/** Add a category, rename it, re-order it, or hide it from sellers and the marketplace home. */
export function CategoryManager({ categories }: { categories: CategoryRow[] }) {
  const router = useRouter();
  const [editing, setEditing] = useState<CategoryRow | 'new' | null>(null);
  const [name, setName] = useState('');
  const [icon, setIcon] = useState('tag');
  const [tone, setTone] = useState<string>('violet');
  const [order, setOrder] = useState('');
  const { attempt, pending, error, setError, reauth } = useReauth();

  const open = (c: CategoryRow | 'new') => {
    setEditing(c);
    setError(null);
    setName(c === 'new' ? '' : c.name);
    setIcon(c === 'new' ? 'tag' : c.icon);
    setTone(c === 'new' ? 'violet' : c.tone);
    setOrder(c === 'new' ? '' : String(c.sortOrder));
  };
  const close = () => {
    setEditing(null);
    setError(null);
  };
  const sortOrder = order.trim() === '' ? undefined : Number.parseInt(order, 10);

  return (
    <>
      <div className="toolbar">
        <span />
        <button type="button" className="button" onClick={() => open('new')}>
          Add category
        </button>
      </div>
      <div className="table-wrap">
        <table className="data">
          <caption className="sr-only">Marketplace categories</caption>
          <thead>
            <tr>
              <th scope="col">Name</th>
              <th scope="col">Icon</th>
              <th scope="col">Tone</th>
              <th scope="col">Order</th>
              <th scope="col">Live listings</th>
              <th scope="col">Status</th>
              <th scope="col">Actions</th>
            </tr>
          </thead>
          <tbody>
            {categories.map((c) => (
              <tr key={c.id}>
                <td>
                  <strong>{c.name}</strong>
                </td>
                <td>{c.icon}</td>
                <td>{c.tone}</td>
                <td>{c.sortOrder}</td>
                <td>{c.count}</td>
                <td>
                  <span className={`pill ${c.isActive ? 'success' : ''}`.trim()}>
                    {c.isActive ? 'Active' : 'Hidden'}
                  </span>
                </td>
                <td>
                  <span className="row-actions">
                    <button
                      type="button"
                      className="button secondary small"
                      aria-label={`Edit ${c.name}`}
                      onClick={() => open(c)}
                    >
                      Edit
                    </button>
                    <button
                      type="button"
                      className="button secondary small"
                      aria-label={`${c.isActive ? 'Hide' : 'Show'} ${c.name}`}
                      disabled={pending}
                      onClick={() =>
                        attempt(
                          () => updateCategoryAction(c.id, { isActive: !c.isActive }),
                          () => router.refresh(),
                        )
                      }
                    >
                      {c.isActive ? 'Hide' : 'Show'}
                    </button>
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {error && editing === null ? (
        <p className="alert notice" role="alert">
          {error}
        </p>
      ) : null}
      <FormDialog
        open={editing !== null}
        title={editing === 'new' ? 'Add category' : 'Edit category'}
        submitLabel="Save"
        pending={pending}
        error={error}
        onCancel={close}
        onSubmit={() =>
          attempt(
            () =>
              editing === 'new'
                ? createCategoryAction({ name, icon, tone, sortOrder })
                : updateCategoryAction((editing as CategoryRow).id, {
                    name,
                    icon,
                    tone,
                    sortOrder,
                  }),
            () => {
              close();
              router.refresh();
            },
          )
        }
      >
        <label className="field">
          Name
          <input
            className="input"
            value={name}
            maxLength={60}
            onChange={(e) => setName(e.target.value)}
          />
        </label>
        <label className="field">
          Icon (a Lucide icon name)
          <input
            className="input"
            value={icon}
            maxLength={40}
            onChange={(e) => setIcon(e.target.value)}
          />
        </label>
        <label className="field">
          Tone
          <select className="input" value={tone} onChange={(e) => setTone(e.target.value)}>
            {CATEGORY_TONES.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Order (optional)
          <input
            className="input"
            inputMode="numeric"
            value={order}
            onChange={(e) => setOrder(e.target.value.replace(/\D/g, ''))}
          />
        </label>
      </FormDialog>
      <ReauthDialog {...reauth} />
    </>
  );
}
