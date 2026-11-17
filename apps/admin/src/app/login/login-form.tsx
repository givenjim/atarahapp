'use client';

import { useActionState } from 'react';
import { loginAction, totpAction, type FormState } from '../actions';

const initial: FormState = {};

export function LoginForm() {
  const [state, action, pending] = useActionState(loginAction, initial);
  return (
    <form action={action} noValidate>
      <label className="field">
        Email
        <input
          className="input"
          name="email"
          type="email"
          autoComplete="username"
          required
          autoFocus
        />
      </label>
      <label className="field">
        Password
        <input
          className="input"
          name="password"
          type="password"
          autoComplete="current-password"
          required
        />
      </label>
      {state.error ? (
        <p className="alert" role="alert">
          {state.error}
        </p>
      ) : null}
      <button className="button" type="submit" disabled={pending}>
        {pending ? 'Checking…' : 'Continue'}
      </button>
    </form>
  );
}

/** The code step. `factorId` is the authenticator to check (the one just enrolled, or the existing one). */
export function TotpForm({ factorId, enrolment }: { factorId: string; enrolment: boolean }) {
  const [state, action, pending] = useActionState(totpAction, initial);

  return (
    <form action={action} noValidate>
      <input type="hidden" name="factorId" value={factorId} />
      <label className="field">
        {enrolment ? 'Code from your authenticator app' : 'Authenticator code'}
        <input
          className="input"
          name="code"
          inputMode="numeric"
          autoComplete="one-time-code"
          maxLength={6}
          autoFocus
        />
      </label>
      {state.error ? (
        <p className="alert" role="alert">
          {state.error}
        </p>
      ) : null}
      <button className="button" type="submit" disabled={pending}>
        {pending ? 'Verifying…' : enrolment ? 'Verify and finish' : 'Sign in'}
      </button>
    </form>
  );
}
