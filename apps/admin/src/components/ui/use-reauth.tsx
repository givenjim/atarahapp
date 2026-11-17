'use client';

import { useRef, useState, useTransition } from 'react';
import { reauthAction, type ActionResult } from '@/app/actions';

/**
 * Runs a server action that may answer "needs a fresh authenticator code". When it does, the reauth dialog
 * opens (spread `reauth` onto <ReauthDialog>); after a good code the same action is retried.
 */
export function useReauth() {
  const [reauthOpen, setReauthOpen] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const retry = useRef<(() => void) | null>(null);

  const attempt = (run: () => Promise<ActionResult>, onOk: () => void) => {
    retry.current = () => attempt(run, onOk);
    start(async () => {
      const result = await run();
      if (result.ok) {
        setReauthOpen(false);
        setError(null);
        onOk();
      } else if (result.reauth) {
        setError(null);
        setReauthOpen(true);
      } else {
        setReauthOpen(false);
        setError(result.error);
      }
    });
  };

  const reauth = {
    open: reauthOpen,
    pending,
    error: reauthOpen ? error : null,
    onCancel: () => setReauthOpen(false),
    onSubmit: (credentials: { code: string }) =>
      start(async () => {
        const res = await reauthAction(credentials);
        if (!res.ok) {
          setError(res.error);
          return;
        }
        setError(null);
        retry.current?.();
      }),
  };

  return { attempt, pending, error, setError, reauth };
}
