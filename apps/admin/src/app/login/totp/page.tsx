import { redirect } from 'next/navigation';
import { anonymousApi } from '@/lib/api';
import { readChallenge } from '@/lib/session';
import { TotpForm } from '../login-form';

export const metadata = { title: 'Verify' };
export const dynamic = 'force-dynamic';

export default async function TotpPage() {
  const challenge = await readChallenge();
  if (!challenge) redirect('/login');
  const enrolment = challenge.step === 'TOTP_ENROLMENT_REQUIRED';

  let setup: { secret: string; otpauthUrl: string } | null = null;
  if (enrolment) {
    const { data } = await anonymousApi().POST('/api/v1/admin/auth/totp/setup', {
      body: { challengeToken: challenge.token },
    });
    if (!data) redirect('/login');
    setup = data.data;
  }

  return (
    <>
      {setup ? (
        <section
          aria-labelledby="enrol-title"
          style={{ display: 'flex', flexDirection: 'column', gap: 10 }}
        >
          <h2 id="enrol-title" style={{ fontSize: '1.0625rem' }}>
            Set up your authenticator
          </h2>
          <p className="muted" style={{ margin: 0 }}>
            Administrators sign in with a code from an authenticator app. Add this account by
            entering the key below (or open the link on a phone that has the app), then enter the
            code it shows.
          </p>
          <p style={{ margin: 0 }}>
            <strong>Key:</strong> <code data-testid="totp-secret">{setup.secret}</code>
          </p>
          <p style={{ margin: 0 }}>
            <a href={setup.otpauthUrl}>Open in authenticator app</a>
          </p>
        </section>
      ) : (
        <p className="muted" style={{ margin: 0 }}>
          Enter the 6-digit code from your authenticator app.
        </p>
      )}
      <TotpForm enrolment={enrolment} />
    </>
  );
}
