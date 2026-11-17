import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { ConfirmDialog } from './confirm-dialog';
import { DataTable, Pagination, pageCount } from './data-table';
import { ReauthDialog } from './reauth-dialog';
import { SoonPanel } from './soon-panel';
import { StatusPill } from './status-pill';
import { NAV, sectionBySlug, visibleNav } from '@/lib/nav';

vi.mock('next/link', () => ({
  default: ({ href, children, ...rest }: { href: string; children: React.ReactNode }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

describe('StatusPill', () => {
  it('labels known statuses in plain words and passes unknown ones through', () => {
    const { rerender } = render(<StatusPill status="SUSPENDED" />);
    expect(screen.getByText('Suspended')).toHaveClass('danger');
    rerender(<StatusPill status="PENDING_VERIFICATION" />);
    expect(screen.getByText('Pending verification')).toBeInTheDocument();
    rerender(<StatusPill status="MYSTERY" />);
    expect(screen.getByText('MYSTERY')).toBeInTheDocument();
  });
});

describe('DataTable', () => {
  const cols = [{ key: 'n', header: 'Name', render: (r: { n: string }) => r.n }];

  it('renders one row per item with column headers', () => {
    render(
      <DataTable
        caption="People"
        columns={cols}
        rows={[{ n: 'Nia' }, { n: 'Amani' }]}
        rowKey={(r) => r.n}
      />,
    );
    expect(screen.getByRole('columnheader', { name: 'Name' })).toBeInTheDocument();
    expect(screen.getAllByRole('row')).toHaveLength(3);
  });

  it('shows the empty message instead of an empty table', () => {
    render(
      <DataTable
        caption="People"
        columns={cols}
        rows={[]}
        rowKey={(r: { n: string }) => r.n}
        empty="No people."
      />,
    );
    expect(screen.getByText('No people.')).toBeInTheDocument();
    expect(screen.queryByRole('table')).toBeNull();
  });
});

describe('Pagination', () => {
  it('counts pages from the server total', () => {
    expect(pageCount({ page: 1, limit: 20, total: 0 })).toBe(1);
    expect(pageCount({ page: 1, limit: 20, total: 41 })).toBe(3);
  });

  it('links to neighbouring pages and keeps the active filters', () => {
    render(
      <Pagination
        meta={{ page: 2, limit: 20, total: 70 }}
        basePath="/users"
        query={{ q: 'nia', status: undefined }}
      />,
    );
    expect(screen.getByText('21–40 of 70')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Previous' })).toHaveAttribute(
      'href',
      '/users?q=nia&page=1',
    );
    expect(screen.getByRole('link', { name: 'Next' })).toHaveAttribute(
      'href',
      '/users?q=nia&page=3',
    );
  });

  it('hides Previous on the first page and Next on the last', () => {
    const { rerender } = render(
      <Pagination meta={{ page: 1, limit: 20, total: 30 }} basePath="/x" query={{}} />,
    );
    expect(screen.queryByRole('link', { name: 'Previous' })).toBeNull();
    rerender(<Pagination meta={{ page: 2, limit: 20, total: 30 }} basePath="/x" query={{}} />);
    expect(screen.queryByRole('link', { name: 'Next' })).toBeNull();
  });
});

describe('ConfirmDialog', () => {
  it('requires a reason and hands the trimmed reason to onConfirm', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    render(
      <ConfirmDialog
        open
        title="Suspend Nia?"
        confirmLabel="Suspend account"
        reasonLabel="Reason for suspension"
        onConfirm={onConfirm}
        onCancel={() => undefined}
      />,
    );
    const reason = screen.getByLabelText('Reason for suspension');
    expect(reason).toBeRequired();
    await user.type(reason, '  Repeated harassment  ');
    await user.click(screen.getByRole('button', { name: 'Suspend account' }));
    expect(onConfirm).toHaveBeenCalledWith('Repeated harassment');
  });

  it('shows an API error in an alert and locks the buttons while pending', () => {
    render(
      <ConfirmDialog
        open
        title="t"
        confirmLabel="Go"
        pending
        error="Only a super admin can change an administrator account."
        onConfirm={() => undefined}
        onCancel={() => undefined}
      />,
    );
    expect(screen.getByRole('alert')).toHaveTextContent('Only a super admin');
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeDisabled();
    expect(screen.getByRole('button', { name: 'Working…' })).toBeDisabled();
  });

  it('calls onCancel from the Cancel button', async () => {
    const onCancel = vi.fn();
    render(
      <ConfirmDialog
        open
        title="t"
        confirmLabel="Go"
        onConfirm={() => undefined}
        onCancel={onCancel}
      />,
    );
    await userEvent.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(onCancel).toHaveBeenCalled();
  });
});

describe('ReauthDialog', () => {
  it('collects a 6-digit authenticator code and no password', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();
    render(<ReauthDialog open onSubmit={onSubmit} onCancel={() => undefined} />);
    const code = screen.getByLabelText('Authenticator code');
    expect(code).toHaveAttribute('autocomplete', 'one-time-code');
    expect(screen.queryByLabelText('Password')).toBeNull();
    await user.type(code, '123456');
    await user.click(screen.getByRole('button', { name: 'Confirm' }));
    expect(onSubmit).toHaveBeenCalledWith({ code: '123456' });
  });
});

describe('navigation and Soon panels', () => {
  it('lists every section of the Admin Platform spec', () => {
    expect(NAV.map((s) => s.label)).toEqual([
      'Dashboard',
      'Users',
      'Privacy requests',
      'Memberships',
      'Roles & Permissions',
      'Verification',
      'Content',
      'Articles',
      'Home curation',
      'Taxonomy',
      'Learning',
      'Opportunities',
      'Mentorship',
      'Marketplace',
      'Community & Reports',
      'Groups',
      'Announcements',
      'Portfolio',
      'Creative Economy',
      'Payments',
      'Notifications',
      'AI',
      'Analytics',
      'Audit Logs',
      'Settings',
    ]);
  });

  it('shows only the sections the administrator has permission for', () => {
    const moderator = visibleNav(['admin.access', 'report.view']).map((s) => s.slug);
    expect(moderator).toEqual(['dashboard', 'community']);
    expect(visibleNav(['admin.access', 'moderation.act']).map((s) => s.slug)).toEqual([
      'dashboard',
      'portfolio',
    ]);
    expect(visibleNav([])).toEqual([]);
    expect(visibleNav(['admin.access', 'article.manage']).map((s) => s.slug)).toEqual([
      'dashboard',
      'articles',
      'home-curation',
    ]);
    // Help articles, the FAQ and legal documents have their own permissions (P1-M11).
    expect(visibleNav(['admin.access', 'help.manage']).map((s) => s.slug)).toEqual([
      'dashboard',
      'content',
    ]);
    expect(visibleNav(['admin.access', 'notification.broadcast']).map((s) => s.slug)).toEqual([
      'dashboard',
      'notifications',
    ]);
    expect(visibleNav(['admin.access', 'user.view']).map((s) => s.slug)).toEqual([
      'dashboard',
      'users',
      'privacy-requests',
    ]);
    expect(visibleNav(['admin.access', 'moderation.act']).map((s) => s.slug)).not.toContain(
      'articles',
    );
    expect(visibleNav(['admin.access', 'taxonomy.manage']).map((s) => s.slug)).toEqual([
      'dashboard',
      'taxonomy',
    ]);
    expect(visibleNav(['admin.access', 'opportunity.manage']).map((s) => s.slug)).toEqual([
      'dashboard',
      'opportunities',
    ]);
    expect(sectionBySlug('opportunities')?.phase).toBe('live');
    expect(visibleNav(['admin.access', 'learning.manage']).map((s) => s.slug)).toEqual([
      'dashboard',
      'learning',
    ]);
    expect(sectionBySlug('learning')?.phase).toBe('live');
    // Operations (P1-M12): analytics, settings and roles each have their own permission.
    expect(visibleNav(['admin.access', 'analytics.view']).map((s) => s.slug)).toEqual([
      'dashboard',
      'analytics',
    ]);
    expect(visibleNav(['admin.access', 'settings.manage']).map((s) => s.slug)).toEqual([
      'dashboard',
      'settings',
    ]);
    expect(visibleNav(['admin.access', 'role.manage']).map((s) => s.slug)).toEqual([
      'dashboard',
      'roles',
    ]);
  });

  it('only the built sections are live; everything else names its phase', () => {
    expect(NAV.filter((s) => s.phase === 'live').map((s) => s.slug)).toEqual([
      'dashboard',
      'users',
      'privacy-requests',
      'roles',
      'content',
      'articles',
      'home-curation',
      'taxonomy',
      'learning',
      'opportunities',
      'community',
      'groups',
      'announcements',
      'portfolio',
      'notifications',
      'analytics',
      'audit-logs',
      'settings',
    ]);
    render(<SoonPanel section={sectionBySlug('payments')!} />);
    expect(screen.getByText('Soon · P2')).toBeInTheDocument();
  });
});
