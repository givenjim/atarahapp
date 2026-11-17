'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const TABS = [
  { href: '/learning', label: 'Content', exact: true },
  { href: '/learning/categories', label: 'Categories' },
  { href: '/learning/analytics', label: 'Analytics' },
] as const;

/** Section navigation inside Learning. The detail, edit and new pages keep the first tab selected. */
export function LearnTabs() {
  const pathname = usePathname();
  const current = (t: (typeof TABS)[number]) =>
    'exact' in t
      ? pathname === t.href ||
        (pathname.startsWith('/learning/') &&
          !TABS.slice(1).some((o) => pathname.startsWith(o.href)))
      : pathname.startsWith(t.href);
  return (
    <nav className="tabs" aria-label="Learning sections">
      {TABS.map((t) => (
        <Link key={t.href} href={t.href} aria-current={current(t) ? 'page' : undefined}>
          {t.label}
        </Link>
      ))}
    </nav>
  );
}
