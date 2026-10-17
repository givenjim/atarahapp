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

export function TotpForm({ enrolment }: { enrolment: boolean }) {
  const [state, action, pending] = useActionState(totpAction, initial);

  return (
    <form action={action} noValidate>
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
      {!enrolment ? (
        <details>
          <summary className="muted" style={{ cursor: 'pointer' }}>
            Use a recovery code instead
          </summary>
          <label className="field" style={{ marginTop: 10 }}>
            Recovery code
            <input
              className="input"
              name="recoveryCode"
              placeholder="XXXX-XXXX-XXXX"
              maxLength={14}
            />
          </label>
        </details>
      ) : null}
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
