import type { ReactNode } from 'react';
import { Wordmark } from '@/components/wordmark';

export default function LoginLayout({ children }: { children: ReactNode }) {
  return (
    <main className="auth">
      <div className="card auth-card">
        <Wordmark size={26} />
        <h1 style={{ fontSize: '1.25rem' }}>Admin console</h1>
        {children}
      </div>
    </main>
  );
}
