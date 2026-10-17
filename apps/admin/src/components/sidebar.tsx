'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { phaseLabel, type NavSection } from '@/lib/nav';
import { Wordmark } from './wordmark';

const isActive = (pathname: string, href: string) =>
  href === '/' ? pathname === '/' : pathname === href || pathname.startsWith(`${href}/`);

/** Receives only the sections the administrator may see (filtered on the server). */
export function Sidebar({ sections }: { sections: NavSection[] }) {
  const pathname = usePathname();
  return (
    <aside className="sidebar">
      <Wordmark size={22} />
      <nav aria-label="Admin sections">
        <ul>
          {sections.map((s) => (
            <li key={s.slug}>
              <Link
                className="nav-link"
                href={s.href}
                aria-current={isActive(pathname, s.href) ? 'page' : undefined}
              >
                <span>{s.label}</span>
                {s.phase !== 'live' ? (
                  <span className="nav-soon">{phaseLabel(s.phase)}</span>
                ) : null}
              </Link>
            </li>
          ))}
        </ul>
      </nav>
    </aside>
  );
}
