'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { KIND_INFO, TAXONOMY_KINDS } from '@/lib/taxonomy';

const TABS = [
  ...TAXONOMY_KINDS.map((k) => ({ href: `/taxonomy/${k}`, label: KIND_INFO[k].label })),
  { href: '/taxonomy/suggestions', label: 'Suggestions' },
];

export function TaxonomyTabs() {
  const pathname = usePathname();
  return (
    <nav className="tabs" aria-label="Taxonomy lists">
      {TABS.map((t) => (
        <Link
          key={t.href}
          className="tab"
          href={t.href}
          aria-current={pathname === t.href ? 'page' : undefined}
        >
          {t.label}
        </Link>
      ))}
    </nav>
  );
}
