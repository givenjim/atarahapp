import { redirect } from 'next/navigation';
import { readRecoveryCodes } from '@/lib/session';
import { recoveryAcknowledgedAction } from '../../actions';

export const metadata = { title: 'Recovery codes' };
export const dynamic = 'force-dynamic';

export default async function RecoveryPage() {
  const codes = await readRecoveryCodes();
  if (codes.length === 0) redirect('/');
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      <h2>Save your recovery codes</h2>
      <p className="muted" style={{ margin: 0 }}>
        Each code works once if you lose your authenticator. They are shown only now. Store them
        somewhere safe, then continue.
      </p>
      <ul className="codes" aria-label="Recovery codes" style={{ listStyle: 'none', margin: 0 }}>
        {codes.map((c) => (
          <li key={c}>{c}</li>
        ))}
      </ul>
      <form action={recoveryAcknowledgedAction}>
        <button className="button" type="submit" style={{ width: '100%' }}>
          I have saved them
        </button>
      </form>
    </div>
  );
}
