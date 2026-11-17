import Link from 'next/link';
import { notFound } from 'next/navigation';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { blocksFromApi } from '@/lib/articles';
import { getHelpArticle } from '@/lib/help-api';
import { HelpArticleForm } from '../help-article-form';

export const metadata = { title: 'Edit help article' };

export default async function EditHelpArticlePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'help.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Help articles.
      </div>
    );
  }
  const { data, error, response } = await getHelpArticle(id);
  if (response.status === 404) notFound();
  if (!data) {
    return (
      <p className="alert" role="alert">
        {errorOf(error, response).message}
      </p>
    );
  }
  const a = data.data;
  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/content">← All help articles</Link>
        </p>
        <h1>{a.title}</h1>
      </div>
      <HelpArticleForm
        id={a.id}
        initial={{
          slug: a.slug,
          title: a.title,
          summary: a.summary,
          blocks: blocksFromApi(
            a.blocks.map((b) => ({
              ...b,
              type: b.type as 'paragraph' | 'heading' | 'callout' | 'quote',
            })),
            (i) => `loaded-${i}`,
          ),
          sortOrder: String(a.sortOrder),
          published: a.published,
        }}
      />
    </>
  );
}
