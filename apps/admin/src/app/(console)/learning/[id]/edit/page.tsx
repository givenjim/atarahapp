import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { formFromDto } from '@/lib/learning';
import { getContent } from '@/lib/learning-api';
import { loadLearningOptions } from '@/lib/learning-options';
import { ContentFormView } from '../../content-form';

export const metadata = { title: 'Edit Skill Lab' };

export default async function EditContentPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'learning.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Learning.
      </div>
    );
  }
  const [{ data, response }, options] = await Promise.all([getContent(id), loadLearningOptions()]);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the item (${response.status}).`);
  }
  const c = data.data;
  return (
    <>
      <div className="page-head">
        <p>
          <Link href={`/learning/${c.id}`}>← {c.title}</Link>
        </p>
        <h1>Edit Skill Lab</h1>
        {c.status === 'PUBLISHED' ? (
          <p className="muted">This item is live: members see your changes straight away.</p>
        ) : null}
      </div>
      <ContentFormView id={c.id} originalType={c.type} initial={formFromDto(c)} {...options} />
    </>
  );
}
