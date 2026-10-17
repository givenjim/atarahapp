import type { ReactNode } from 'react';
import { can, currentAdmin } from '@/lib/admin';
import { TaxonomyTabs } from './taxonomy-tabs';

export const metadata = { title: 'Taxonomy' };

export default async function TaxonomyLayout({ children }: { children: ReactNode }) {
  const me = await currentAdmin();
  if (!can(me.permissions, 'taxonomy.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Taxonomy.
      </div>
    );
  }
  return (
    <>
      <div className="page-head">
        <h1>Taxonomy</h1>
        <p>
          The lists members choose from when they build a profile. Archiving hides an entry from new
          choices and keeps it on profiles that already use it.
        </p>
      </div>
      <section className="card" aria-label="Taxonomy">
        <TaxonomyTabs />
        {children}
      </section>
    </>
  );
}
