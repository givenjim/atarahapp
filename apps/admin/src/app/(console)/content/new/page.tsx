import Link from 'next/link';
import { can, currentAdmin } from '@/lib/admin';
import { emptyHelpArticleForm } from '@/lib/help';
import { HelpArticleForm } from '../help-article-form';

export const metadata = { title: 'New help article' };

export default async function NewHelpArticlePage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'help.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Help articles.
      </div>
    );
  }
  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/content">← All help articles</Link>
        </p>
        <h1>New help article</h1>
        <p>It is saved as a draft until you tick Published.</p>
      </div>
      <HelpArticleForm id={null} initial={emptyHelpArticleForm()} />
    </>
  );
}
