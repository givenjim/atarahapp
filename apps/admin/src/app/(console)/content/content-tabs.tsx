'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const TABS = [
  { href: '/content', label: 'Help articles', exact: true },
  { href: '/content/faq', label: 'FAQ' },
  { href: '/content/legal', label: 'Legal documents' },
] as const;

/** Section navigation inside Content. The article pages keep the first tab selected. */
export function ContentTabs() {
  const pathname = usePathname();
  const current = (t: (typeof TABS)[number]) =>
    'exact' in t
      ? pathname === t.href ||
        (pathname.startsWith('/content/') &&
          !TABS.slice(1).some((o) => pathname.startsWith(o.href)))
      : pathname.startsWith(t.href);
  return (
    <nav className="tabs" aria-label="Content sections">
      {TABS.map((t) => (
        <Link key={t.href} href={t.href} aria-current={current(t) ? 'page' : undefined}>
          {t.label}
        </Link>
      ))}
    </nav>
  );
}
