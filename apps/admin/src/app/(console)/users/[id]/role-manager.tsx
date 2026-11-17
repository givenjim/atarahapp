'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { assignRoleAction, revokeRoleAction } from '@/app/ops-actions';
import { FormDialog } from '@/components/ui/form-dialog';
import { ReauthDialog } from '@/components/ui/reauth-dialog';
import { useReauth } from '@/components/ui/use-reauth';
import { formatWhen, ROLE_REASON_MAX, roleLabel } from '@/lib/ops';

export interface GrantRow {
  key: string;
  name: string;
  isStaff: boolean;
  grantedAt: string;
  grantedBy: string | null;
  /** Show Revoke (the caller may change this role on this account). */
  revocable: boolean;
}

type Dialog = { kind: 'assign' } | { kind: 'revoke'; role: GrantRow } | null;

/**
 * Role grants with who gave them and when, plus assign and revoke. Both need a reason the audit log keeps and a fresh
 * authenticator code. Which roles are offered, and which can be revoked, was decided on the server from the caller's
 * permissions; the API enforces the same rules.
 */
export function RoleManager({
  userId,
  name,
  grants,
  assignable,
  canAssign,
}: {
  userId: string;
  name: string;
  grants: GrantRow[];
  assignable: Array<{ key: string; name: string }>;
  canAssign: boolean;
}) {
  const router = useRouter();
  const [dialog, setDialog] = useState<Dialog>(null);
  const [role, setRole] = useState('');
  const [reason, setReason] = useState('');
  const { attempt, pending, error, setError, reauth } = useReauth();

  const close = () => {
    setDialog(null);
    setError(null);
  };
  const done = () => {
    close();
    setRole('');
    setReason('');
    router.refresh();
  };

  return (
    <section className="card" aria-labelledby="roles-title">
      <div className="toolbar">
        <h2 id="roles-title" className="section-title">
          Roles
        </h2>
        {canAssign && assignable.length > 0 ? (
          <button
            type="button"
            className="button small"
            onClick={() => {
              setRole(assignable[0]!.key);
              setReason('');
              setError(null);
              setDialog({ kind: 'assign' });
            }}
          >
            Assign a role
          </button>
        ) : null}
      </div>
      {grants.length === 0 ? (
        <p className="empty">Member only. No extra roles.</p>
      ) : (
        <table className="data">
          <caption className="sr-only-text">Role grants</caption>
          <thead>
            <tr>
              <th scope="col">Role</th>
              <th scope="col">Granted by</th>
              <th scope="col">When</th>
              <th scope="col">
                <span className="sr-only-text">Action</span>
              </th>
            </tr>
          </thead>
          <tbody>
            {grants.map((g) => (
              <tr key={g.key}>
                <td>
                  {g.name} {g.isStaff ? <span className="pill warning">Staff</span> : null}
                </td>
                <td>{g.grantedBy ?? 'System'}</td>
                <td>{formatWhen(g.grantedAt)}</td>
                <td>
                  {g.revocable ? (
                    <button
                      type="button"
                      className="button secondary small"
                      aria-label={`Revoke ${g.name}`}
                      onClick={() => {
                        setReason('');
                        setError(null);
                        setDialog({ kind: 'revoke', role: g });
                      }}
                    >
                      Revoke
                    </button>
                  ) : null}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <FormDialog
        open={dialog?.kind === 'assign'}
        title={`Assign a role to ${name}`}
        submitLabel="Assign role"
        pending={pending}
        error={dialog?.kind === 'assign' ? error : null}
        onCancel={close}
        onSubmit={() => {
          if (!role) return setError('Choose a role.');
          attempt(() => assignRoleAction(userId, role, reason), done);
        }}
      >
        <label className="field">
          Role
          <select className="select" value={role} onChange={(e) => setRole(e.target.value)}>
            {assignable.map((r) => (
              <option key={r.key} value={r.key}>
                {r.name || roleLabel(r.key)}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          Reason (kept in the audit log)
          <textarea
            className="textarea"
            rows={3}
            maxLength={ROLE_REASON_MAX}
            value={reason}
            onChange={(e) => setReason(e.target.value)}
          />
        </label>
      </FormDialog>

      <FormDialog
        open={dialog?.kind === 'revoke'}
        title={
          dialog?.kind === 'revoke' ? `Revoke ${dialog.role.name} from ${name}?` : 'Revoke role'
        }
        submitLabel="Revoke role"
        pending={pending}
        error={dialog?.kind === 'revoke' ? error : null}
        onCancel={close}
        onSubmit={() => {
          if (dialog?.kind !== 'revoke') return;
          const key = dialog.role.key;
          attempt(() => revokeRoleAction(userId, key, reason), done);
        }}
      >
        <label className="field">
          Reason (kept in the audit log)
          <textarea
            className="textarea"
            rows={3}
            maxLength={ROLE_REASON_MAX}
            value={reason}
            onChange={(e) => setReason(e.target.value)}
          />
        </label>
      </FormDialog>

      <ReauthDialog {...reauth} />
    </section>
  );
}
