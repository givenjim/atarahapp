import Link from 'next/link';
import { can, currentAdmin } from '@/lib/admin';
import { emptyContentForm } from '@/lib/learning';
import { loadLearningOptions } from '@/lib/learning-options';
import { ContentFormView } from '../content-form';

export const metadata = { title: 'New Skill Lab' };

export default async function NewContentPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'learning.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Learning.
      </div>
    );
  }
  const options = await loadLearningOptions();
  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/learning">← All Skill Labs</Link>
        </p>
        <h1>New Skill Lab</h1>
        <p>
          It is saved as a draft. Members see it only after you publish it. Courses get their
          lessons on the next page.
        </p>
      </div>
      {options.categories.length === 0 ? (
        <p className="alert" role="alert">
          There are no categories yet. <Link href="/learning/categories">Add one first</Link>.
        </p>
      ) : null}
      <ContentFormView initial={emptyContentForm()} {...options} />
    </>
  );
}
