import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { TaxonomyManager, type TaxonomyItem } from './taxonomy-manager';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  createTaxonomyItemAction: vi.fn(),
  updateTaxonomyItemAction: vi.fn(),
  reorderTaxonomyAction: vi.fn(),
}));
vi.mock('@/app/taxonomy-actions', () => actions);

const item = (over: Partial<TaxonomyItem> & { id: string; name: string }): TaxonomyItem => ({
  slug: over.name.toLowerCase(),
  icon: null,
  disciplineId: 'd1',
  disciplineName: 'Music',
  sortOrder: 1,
  isActive: true,
  usage: 0,
  ...over,
});

const ROWS = [
  item({ id: 's1', name: 'Alpha', usage: 3 }),
  item({ id: 's2', name: 'Beta', isActive: false }),
  item({ id: 's3', name: 'Gamma' }),
];
const DISCIPLINES = [{ id: 'd1', name: 'Music', isActive: true }];

const scoped = () => (
  <TaxonomyManager
    kind="specialisations"
    items={ROWS}
    disciplines={DISCIPLINES}
    disciplineId="d1"
  />
);

beforeEach(() => {
  vi.clearAllMocks();
  actions.reorderTaxonomyAction.mockResolvedValue({ ok: true });
  actions.updateTaxonomyItemAction.mockResolvedValue({ ok: true });
});

describe('TaxonomyManager', () => {
  it('shows usage and Active / Archived status, and mutes archived rows', () => {
    render(scoped());
    const beta = screen.getByRole('row', { name: /Beta/ });
    expect(beta).toHaveClass('archived');
    expect(within(beta).getByText('Archived')).toBeInTheDocument();
    const alpha = screen.getByRole('row', { name: /Alpha/ });
    expect(within(alpha).getByText('Active')).toBeInTheDocument();
    expect(within(alpha).getByText('3')).toBeInTheDocument();
  });

  it('sends the whole visible list in the new order when moving down', async () => {
    render(scoped());
    await userEvent.click(screen.getByRole('button', { name: 'Move Alpha down' }));
    expect(actions.reorderTaxonomyAction).toHaveBeenCalledWith('specialisations', [
      's2',
      's1',
      's3',
    ]);
    expect(nav.refresh).toHaveBeenCalled();
  });

  it('disables the ends of the list', () => {
    render(scoped());
    expect(screen.getByRole('button', { name: 'Move Alpha up' })).toBeDisabled();
    expect(screen.getByRole('button', { name: 'Move Gamma down' })).toBeDisabled();
  });

  it('blocks reordering until a discipline is chosen for a scoped list', () => {
    render(<TaxonomyManager kind="skills" items={ROWS} disciplines={DISCIPLINES} />);
    expect(screen.getByText(/Choose a discipline to change the order/)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Move Beta up' })).toBeDisabled();
  });

  it('shows the API message inline when a rename is refused', async () => {
    actions.updateTaxonomyItemAction.mockResolvedValue({
      ok: false,
      error: 'Gamma is already in the Music list.',
    });
    render(scoped());
    await userEvent.click(screen.getByRole('button', { name: 'Edit Alpha' }));
    const dialog = screen.getByRole('dialog');
    const name = within(dialog).getByLabelText('Name');
    await userEvent.clear(name);
    await userEvent.type(name, 'Gamma');
    await userEvent.click(within(dialog).getByRole('button', { name: 'Save' }));
    expect(await within(dialog).findByRole('alert')).toHaveTextContent('already in the Music list');
    expect(nav.refresh).not.toHaveBeenCalled();
  });

  it('validates a new discipline locally and sends nothing when the icon is missing', async () => {
    render(
      <TaxonomyManager
        kind="disciplines"
        items={[
          item({
            id: 'd9',
            name: 'Dance',
            icon: 'drama',
            disciplineId: null,
            disciplineName: null,
          }),
        ]}
        disciplines={[]}
      />,
    );
    await userEvent.click(screen.getByRole('button', { name: 'Add discipline' }));
    const dialog = screen.getByRole('dialog');
    await userEvent.type(within(dialog).getByLabelText('Name'), 'Puppetry');
    await userEvent.click(within(dialog).getByRole('button', { name: 'Add' }));
    expect(within(dialog).getByRole('alert')).toHaveTextContent(/icon/i);
    expect(actions.createTaxonomyItemAction).not.toHaveBeenCalled();
  });

  it('archives only after confirmation and restores an archived row', async () => {
    render(scoped());
    await userEvent.click(screen.getByRole('button', { name: 'Archive Alpha' }));
    expect(actions.updateTaxonomyItemAction).not.toHaveBeenCalled();
    await userEvent.click(
      within(screen.getByRole('dialog')).getByRole('button', { name: 'Archive' }),
    );
    expect(actions.updateTaxonomyItemAction).toHaveBeenCalledWith('specialisations', 's1', {
      isActive: false,
    });

    await userEvent.click(screen.getByRole('button', { name: 'Restore Beta' }));
    await userEvent.click(
      within(screen.getByRole('dialog')).getByRole('button', { name: 'Restore' }),
    );
    expect(actions.updateTaxonomyItemAction).toHaveBeenLastCalledWith('specialisations', 's2', {
      isActive: true,
    });
  });
});
