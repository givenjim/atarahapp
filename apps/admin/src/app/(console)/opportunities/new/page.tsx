import Link from 'next/link';
import { can, currentAdmin } from '@/lib/admin';
import { emptyForm } from '@/lib/opportunities';
import { loadFormOptions } from '@/lib/opportunity-options';
import { OpportunityForm } from '../opportunity-form';

export const metadata = { title: 'New opportunity' };

export default async function NewOpportunityPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'opportunity.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Opportunities.
      </div>
    );
  }
  const options = await loadFormOptions();
  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/opportunities">← All opportunities</Link>
        </p>
        <h1>New opportunity</h1>
        <p>
          It is saved as a draft. Members see it only after you publish it, and its trust badge
          starts as “External source”.
        </p>
      </div>
      {options.providers.length === 0 ? (
        <p className="alert" role="alert">
          There are no providers yet. <Link href="/opportunities/providers">Add one first</Link>.
        </p>
      ) : null}
      <OpportunityForm initial={emptyForm()} {...options} />
    </>
  );
}
