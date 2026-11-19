import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { PaymentActions } from './[id]/payment-actions';

const nav = vi.hoisted(() => ({ refresh: vi.fn(), push: vi.fn() }));
vi.mock('next/navigation', () => ({ useRouter: () => nav }));

const actions = vi.hoisted(() => ({
  requeryPaymentAction: vi.fn(),
  refundPaymentAction: vi.fn(),
  completeRefundAction: vi.fn(),
  cancelRefundAction: vi.fn(),
}));
vi.mock('@/app/payment-actions', () => actions);
const auth = vi.hoisted(() => ({ reauthAction: vi.fn() }));
vi.mock('@/app/actions', () => auth);

const lastButton = (name: string) => screen.getAllByRole('button', { name }).at(-1)!;

const props = {
  paymentId: 'p1',
  status: 'SUCCEEDED',
  currency: 'KES',
  refundableMinor: 100_000,
  canRequery: false,
  refunds: [],
};

beforeEach(() => {
  vi.clearAllMocks();
  for (const fn of Object.values(actions)) fn.mockResolvedValue({ ok: true });
  auth.reauthAction.mockResolvedValue({ ok: true });
});

describe('PaymentActions', () => {
  it('offers Refund on a paid payment and Re-check only when it is open', () => {
    const { rerender } = render(<PaymentActions {...props} />);
    expect(screen.getByRole('button', { name: 'Refund' })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Re-check with provider' })).toBeNull();
    rerender(<PaymentActions {...props} status="PENDING" canRequery />);
    expect(screen.getByRole('button', { name: 'Re-check with provider' })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Refund' })).toBeNull();
  });

  it('has nothing to offer on a finished, fully refunded payment', () => {
    render(<PaymentActions {...props} status="REFUNDED" refundableMinor={0} />);
    expect(screen.queryByRole('button', { name: 'Refund' })).toBeNull();
    expect(screen.getByText(/nothing to do/i)).toBeInTheDocument();
  });

  it('does not send a refund without a reason or above the refundable amount', async () => {
    const user = userEvent.setup();
    render(<PaymentActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Refund' }));
    await user.type(screen.getByLabelText(/Reason/), 'no');
    await user.click(lastButton('Refund'));
    expect(actions.refundPaymentAction).not.toHaveBeenCalled();
    await user.clear(screen.getByLabelText(/Reason/));
    await user.type(screen.getByLabelText(/Reason/), 'Duplicate charge');
    await user.type(screen.getByLabelText(/Amount in shillings/), '5000');
    await user.click(lastButton('Refund'));
    expect(actions.refundPaymentAction).not.toHaveBeenCalled();
    expect(screen.getByText(/at most KES 1,000/)).toBeInTheDocument();
  });

  it('refunds with an idempotency key, then refreshes', async () => {
    const user = userEvent.setup();
    render(<PaymentActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Refund' }));
    await user.type(screen.getByLabelText(/Reason/), 'Duplicate charge');
    await user.type(screen.getByLabelText(/Amount in shillings/), '400');
    await user.click(lastButton('Refund'));
    expect(actions.refundPaymentAction).toHaveBeenCalledWith('p1', {
      amount: '400',
      reason: 'Duplicate charge',
      refundableMinor: 100_000,
      key: expect.stringMatching(/^[0-9a-f-]{36}$/),
    });
    expect(nav.refresh).toHaveBeenCalled();
  });

  it('asks for the authenticator code when the API wants a fresh one, then retries with the same key', async () => {
    const user = userEvent.setup();
    actions.refundPaymentAction.mockResolvedValueOnce({
      ok: false,
      reauth: true,
      error: 'Confirm with your authenticator',
    });
    render(<PaymentActions {...props} />);
    await user.click(screen.getByRole('button', { name: 'Refund' }));
    await user.type(screen.getByLabelText(/Reason/), 'Duplicate charge');
    await user.click(lastButton('Refund'));
    expect(await screen.findByLabelText(/code/i)).toBeInTheDocument();
    await user.type(screen.getByLabelText(/code/i), '123456');
    await user.click(lastButton('Confirm'));
    expect(auth.reauthAction).toHaveBeenCalledWith({ code: '123456' });
    expect(actions.refundPaymentAction).toHaveBeenCalledTimes(2);
    const [first, second] = actions.refundPaymentAction.mock.calls;
    expect(second![1].key).toBe(first![1].key);
  });

  it('confirms and cancels refunds waiting for a payout', async () => {
    const user = userEvent.setup();
    render(
      <PaymentActions
        {...props}
        refunds={[
          { id: 'r1', amountMinor: 60_000, status: 'PENDING', mode: 'MANUAL', reason: 'Duplicate' },
        ]}
      />,
    );
    expect(screen.getByText(/KES 600 · Duplicate/)).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Confirm paid out' }));
    await user.type(screen.getByLabelText(/Payout reference/), 'QGH-REFUND-1');
    await user.click(lastButton('Confirm paid out'));
    expect(actions.completeRefundAction).toHaveBeenCalledWith('p1', 'r1', 'QGH-REFUND-1');
    await user.click(screen.getByRole('button', { name: 'Cancel refund' }));
    await user.click(lastButton('Cancel refund'));
    expect(actions.cancelRefundAction).toHaveBeenCalledWith('p1', 'r1');
  });

  it('re-checks with the provider', async () => {
    const user = userEvent.setup();
    render(<PaymentActions {...props} status="PENDING" canRequery />);
    await user.click(screen.getByRole('button', { name: 'Re-check with provider' }));
    await user.click(lastButton('Re-check'));
    expect(actions.requeryPaymentAction).toHaveBeenCalledWith('p1');
  });
});
