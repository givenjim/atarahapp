'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const TABS = [
  { href: '/marketplace', label: 'Review queue', exact: true },
  { href: '/marketplace/sellers', label: 'Sellers' },
  { href: '/marketplace/reports', label: 'Reported listings' },
  { href: '/marketplace/categories', label: 'Categories' },
  { href: '/marketplace/reviews', label: 'Reviews' },
] as const;

/** Section navigation inside Marketplace. */
export function MarketplaceTabs() {
  const pathname = usePathname();
  const current = (t: (typeof TABS)[number]) =>
    'exact' in t ? pathname === t.href : pathname.startsWith(t.href);
  return (
    <nav className="tabs" aria-label="Marketplace sections">
      {TABS.map((t) => (
        <Link key={t.href} href={t.href} aria-current={current(t) ? 'page' : undefined}>
          {t.label}
        </Link>
      ))}
    </nav>
  );
}
