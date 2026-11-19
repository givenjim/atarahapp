'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const TABS = [
  { href: '/mentorship', label: 'Applications', exact: true },
  { href: '/mentorship/mentors', label: 'Mentors' },
  { href: '/mentorship/session-types', label: 'Session types' },
] as const;

/** Section navigation inside Mentorship. */
export function MentorshipTabs() {
  const pathname = usePathname();
  const current = (t: (typeof TABS)[number]) =>
    'exact' in t ? pathname === t.href : pathname.startsWith(t.href);
  return (
    <nav className="tabs" aria-label="Mentorship sections">
      {TABS.map((t) => (
        <Link key={t.href} href={t.href} aria-current={current(t) ? 'page' : undefined}>
          {t.label}
        </Link>
      ))}
    </nav>
  );
}
