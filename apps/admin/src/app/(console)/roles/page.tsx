import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listRoles } from '@/lib/ops-api';

export const metadata = { title: 'Roles & Permissions' };

export default async function RolesPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'role.manage') || !can(me.permissions, 'user.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Roles &amp; Permissions.
      </div>
    );
  }
  const { data, error, response } = await listRoles();
  return (
    <>
      <div className="page-head">
        <h1>Roles &amp; Permissions</h1>
        <p>
          What each role can do. Roles are given and taken away on a member’s page, with a reason
          and a fresh authenticator code.
        </p>
      </div>
      {!data ? (
        <p className="alert" role="alert">
          {errorOf(error, response).message}
        </p>
      ) : (
        data.data.map((r) => (
          <section key={r.key} className="card" aria-label={r.name}>
            <div className="stack">
              <h2 className="section-title">
                {r.name} {r.isStaff ? <span className="pill warning">Staff</span> : null}
              </h2>
              <p className="muted" style={{ margin: 0 }}>
                {r.description}
              </p>
              <p style={{ margin: 0 }}>
                {r.permissions.length ? r.permissions.join(', ') : 'No permissions.'}
              </p>
            </div>
          </section>
        ))
      )}
    </>
  );
}
