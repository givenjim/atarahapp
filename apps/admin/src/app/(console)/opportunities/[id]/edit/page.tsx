import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { formFromDto } from '@/lib/opportunities';
import { getOpportunity } from '@/lib/opportunities-api';
import { loadFormOptions } from '@/lib/opportunity-options';
import { OpportunityForm } from '../../opportunity-form';

export const metadata = { title: 'Edit opportunity' };

export default async function EditOpportunityPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'opportunity.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Opportunities.
      </div>
    );
  }
  const [{ data, response }, options] = await Promise.all([getOpportunity(id), loadFormOptions()]);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the opportunity (${response.status}).`);
  }
  const o = data.data;
  return (
    <>
      <div className="page-head">
        <p>
          <Link href={`/opportunities/${o.id}`}>← {o.title}</Link>
        </p>
        <h1>Edit opportunity</h1>
        {o.status === 'PUBLISHED' ? (
          <p className="muted">This listing is live: members see your changes straight away.</p>
        ) : null}
      </div>
      <OpportunityForm id={o.id} initial={formFromDto(o)} {...options} />
    </>
  );
}
