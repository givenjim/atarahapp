import { JoinCta } from '@/components/join-cta';
import { Wordmark } from '@/components/wordmark';
import { storeLinks } from '@/lib/site';

export const dynamic = 'force-dynamic';

export default function HoldingPage() {
  return (
    <div className="page">
      <header className="header">
        <Wordmark size={26} />
      </header>
      <main className="main">
        <h1 className="hero-title">One creative identity. Many connected possibilities.</h1>
        <p className="hero-copy">
          Atarah brings Kenyan creatives together: a portfolio that earns trust, opportunities worth
          applying for, mentors who open doors, and a community that grows with you.
        </p>
        <JoinCta links={storeLinks()} />
      </main>
      <footer className="footer">© {new Date().getFullYear()} Luxaion Creatives · Atarah</footer>
    </div>
  );
}
