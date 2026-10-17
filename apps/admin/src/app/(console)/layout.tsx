import type { ReactNode } from 'react';
import { Sidebar } from '@/components/sidebar';
import { currentAdmin } from '@/lib/admin';
import { visibleNav } from '@/lib/nav';
import { logoutAction } from '../actions';

export default async function ConsoleLayout({ children }: { children: ReactNode }) {
  const me = await currentAdmin();
  return (
    <div className="shell">
      <Sidebar sections={visibleNav(me.permissions)} />
      <div className="content">
        <header className="topbar">
          <span>
            {me.fullName} · <span className="muted">{me.roles.join(', ')}</span>
          </span>
          <form action={logoutAction}>
            <button className="button secondary" type="submit">
              Sign out
            </button>
          </form>
        </header>
        <main className="page">{children}</main>
      </div>
    </div>
  );
}
