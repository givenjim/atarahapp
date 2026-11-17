'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { cancelBroadcastAction } from '@/app/broadcast-actions';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';

/** Cancel a scheduled broadcast. Nobody is messaged. */
export function CancelBroadcast({ id }: { id: string }) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const close = () => {
    setOpen(false);
    setError(null);
  };
  return (
    <>
      <button type="button" className="button danger" onClick={() => setOpen(true)}>
        Cancel broadcast
      </button>
      <ConfirmDialog
        open={open}
        title="Cancel this broadcast?"
        confirmLabel="Cancel broadcast"
        tone="danger"
        pending={pending}
        error={error}
        onCancel={close}
        onConfirm={() =>
          start(async () => {
            const res = await cancelBroadcastAction(id);
            if (res.ok) {
              close();
              router.refresh();
            } else setError(res.error);
          })
        }
      >
        <p>It will not be sent and nobody is told. This is recorded in the audit log.</p>
      </ConfirmDialog>
    </>
  );
}
