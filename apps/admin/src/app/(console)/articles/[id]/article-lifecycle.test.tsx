import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ArticleLifecycle } from './article-lifecycle';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({ articleLifecycleAction: vi.fn() }));
vi.mock('@/app/articles-actions', () => actions);

const lastButton = (name: string) => screen.getAllByRole('button', { name }).at(-1)!;

beforeEach(() => {
  vi.clearAllMocks();
  actions.articleLifecycleAction.mockResolvedValue({ ok: true });
});

const names = () => screen.getAllByRole('button').map((b) => b.textContent);

describe('ArticleLifecycle', () => {
  it('shows only the buttons that match each status', () => {
    const { rerender } = render(<ArticleLifecycle id="a1" title="T" status="DRAFT" />);
    expect(names()).toEqual(['Submit for review']);
    rerender(<ArticleLifecycle id="a1" title="T" status="IN_REVIEW" />);
    expect(screen.getByRole('button', { name: 'Return to draft' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Schedule…' })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Submit for review' })).not.toBeInTheDocument();
    rerender(<ArticleLifecycle id="a1" title="T" status="PUBLISHED" />);
    expect(screen.getByRole('button', { name: 'Archive' })).toBeInTheDocument();
    rerender(<ArticleLifecycle id="a1" title="T" status="ARCHIVED" />);
    expect(screen.getByRole('button', { name: 'Restore to draft' })).toBeInTheDocument();
    expect(screen.getByText(/archived and cannot be edited/)).toBeInTheDocument();
  });

  it('submits for review straight away and refreshes', async () => {
    const user = userEvent.setup();
    render(<ArticleLifecycle id="a1" title="T" status="DRAFT" />);
    await user.click(screen.getByRole('button', { name: 'Submit for review' }));
    expect(actions.articleLifecycleAction).toHaveBeenCalledWith('a1', 'submit', undefined);
    await vi.waitFor(() => expect(nav.refresh).toHaveBeenCalled());
  });

  it('shows the backend error inline and does not refresh', async () => {
    actions.articleLifecycleAction.mockResolvedValue({ ok: false, error: 'Add a summary first.' });
    const user = userEvent.setup();
    render(<ArticleLifecycle id="a1" title="T" status="DRAFT" />);
    await user.click(screen.getByRole('button', { name: 'Submit for review' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Add a summary first.');
    expect(nav.refresh).not.toHaveBeenCalled();
  });

  it('publishes only after confirmation', async () => {
    const user = userEvent.setup();
    render(<ArticleLifecycle id="a1" title="T" status="IN_REVIEW" />);
    await user.click(screen.getByRole('button', { name: 'Publish now' }));
    expect(actions.articleLifecycleAction).not.toHaveBeenCalled();
    await user.click(lastButton('Publish now'));
    expect(actions.articleLifecycleAction).toHaveBeenCalledWith('a1', 'publish', undefined);
  });

  it('refuses a schedule time in the past without calling the API', async () => {
    const user = userEvent.setup();
    render(<ArticleLifecycle id="a1" title="T" status="IN_REVIEW" />);
    await user.click(screen.getByRole('button', { name: 'Schedule…' }));
    await user.type(screen.getByLabelText('Publish at'), '2020-01-01T09:00');
    await user.click(lastButton('Schedule'));
    expect(await screen.findByRole('alert')).toHaveTextContent(/future/);
    expect(actions.articleLifecycleAction).not.toHaveBeenCalled();
  });

  it('schedules a future time as an ISO string', async () => {
    const user = userEvent.setup();
    render(<ArticleLifecycle id="a1" title="T" status="IN_REVIEW" />);
    await user.click(screen.getByRole('button', { name: 'Schedule…' }));
    await user.type(screen.getByLabelText('Publish at'), '2099-01-01T09:00');
    await user.click(lastButton('Schedule'));
    expect(actions.articleLifecycleAction).toHaveBeenCalledWith(
      'a1',
      'schedule',
      new Date('2099-01-01T09:00').toISOString(),
    );
  });

  it('archives after confirmation', async () => {
    const user = userEvent.setup();
    render(<ArticleLifecycle id="a1" title="T" status="PUBLISHED" />);
    await user.click(screen.getByRole('button', { name: 'Archive' }));
    expect(actions.articleLifecycleAction).not.toHaveBeenCalled();
    await user.click(lastButton('Archive'));
    expect(actions.articleLifecycleAction).toHaveBeenCalledWith('a1', 'archive', undefined);
  });

  it('disables the buttons while there are unsaved changes', () => {
    render(<ArticleLifecycle id="a1" title="T" status="DRAFT" dirty />);
    expect(screen.getByRole('button', { name: 'Submit for review' })).toBeDisabled();
    expect(screen.getByRole('status')).toHaveTextContent(/Save your changes/);
  });
});
