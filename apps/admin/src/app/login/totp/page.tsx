import { redirect } from 'next/navigation';
import { mfaStep, startEnrolment } from '@/lib/mfa';
import { supabaseServer } from '@/lib/supabase/server';
import { TotpForm } from '../login-form';

export const metadata = { title: 'Verify' };
export const dynamic = 'force-dynamic';

export default async function TotpPage() {
  const supabase = await supabaseServer();
  const step = await mfaStep(supabase);
  if (step.step === 'login') redirect('/login');
  if (step.step === 'done') redirect('/');

  if (step.step === 'verify') {
    return (
      <>
        <p className="muted" style={{ margin: 0 }}>
          Enter the 6-digit code from your authenticator app.
        </p>
        <TotpForm factorId={step.factorId} enrolment={false} />
      </>
    );
  }

  // No authenticator yet: administrators must set one up before they can use the console.
  const setup = await startEnrolment(supabase);
  if (!setup) redirect('/login?reason=expired');
  return (
    <>
      <section
        aria-labelledby="enrol-title"
        style={{ display: 'flex', flexDirection: 'column', gap: 10 }}
      >
        <h2 id="enrol-title" style={{ fontSize: '1.0625rem' }}>
          Set up your authenticator
        </h2>
        <p className="muted" style={{ margin: 0 }}>
          Administrators sign in with a code from an authenticator app. Scan the QR code, or enter
          the key below, then enter the code the app shows.
        </p>
        {/* Supabase returns the QR code as an SVG data URI. */}
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={setup.qrCode}
          alt="QR code for your authenticator app"
          width={176}
          height={176}
          style={{
            alignSelf: 'center',
            background: 'var(--at-color-white)',
            padding: 8,
            borderRadius: 8,
          }}
        />
        <p style={{ margin: 0 }}>
          <strong>Key:</strong> <code data-testid="totp-secret">{setup.secret}</code>
        </p>
        <p className="muted" style={{ margin: 0 }}>
          There are no recovery codes. If you lose this authenticator, a super administrator has to
          reset it for you.
        </p>
      </section>
      <TotpForm factorId={setup.factorId} enrolment />
    </>
  );
}
