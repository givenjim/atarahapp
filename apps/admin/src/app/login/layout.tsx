import type { ReactNode } from 'react';
import { Logo } from '@/components/logo';

export default function LoginLayout({ children }: { children: ReactNode }) {
  return (
    <main className="auth">
      <div className="card auth-card">
        <Logo width={130} />
        <h1 style={{ fontSize: '1.25rem' }}>Admin console</h1>
        {children}
      </div>
    </main>
  );
}
