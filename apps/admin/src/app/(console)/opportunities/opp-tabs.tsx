'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const TABS = [
  { href: '/opportunities', label: 'Opportunities', exact: true },
  { href: '/opportunities/providers', label: 'Providers' },
  { href: '/opportunities/link-health', label: 'Link health' },
  { href: '/opportunities/import', label: 'Import CSV' },
] as const;

/** Section navigation inside Opportunities. The detail and edit pages keep the first tab selected. */
export function OppTabs() {
  const pathname = usePathname();
  const current = (t: (typeof TABS)[number]) =>
    'exact' in t
      ? pathname === t.href ||
        (pathname.startsWith('/opportunities/') &&
          !TABS.slice(1).some((o) => pathname.startsWith(o.href)))
      : pathname.startsWith(t.href);
  return (
    <nav className="tabs" aria-label="Opportunities sections">
      {TABS.map((t) => (
        <Link key={t.href} href={t.href} aria-current={current(t) ? 'page' : undefined}>
          {t.label}
        </Link>
      ))}
    </nav>
  );
}
