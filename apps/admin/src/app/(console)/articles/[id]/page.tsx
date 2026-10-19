import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { getAdminArticle } from '@/lib/articles-api';
import { statusPill } from '@/lib/articles';
import { ArticleEditor } from './article-editor';

export const metadata = { title: 'Article' };

export default async function ArticlePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'article.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Articles.
      </div>
    );
  }
  const { data, response } = await getAdminArticle(id);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the article (${response.status}).`);
  }
  const a = data.data;
  const pill = statusPill(a.status, a.scheduled);

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/articles">← All articles</Link>
        </p>
        <h1>{a.title}</h1>
        <p>
          <span className={`pill ${pill.tone}`.trim()}>{pill.label}</span>
          {a.featured ? (
            <>
              {' '}
              <span className="pill success">Featured on Home</span>
            </>
          ) : null}
          {a.publishedAt ? (
            <span className="muted">
              {' '}
              · {a.scheduled ? 'goes live' : 'published'}{' '}
              {new Date(a.publishedAt).toLocaleString('en-KE')}
            </span>
          ) : null}
          <span className="muted"> · updated {new Date(a.updatedAt).toLocaleString('en-KE')}</span>
        </p>
      </div>
      <ArticleEditor
        // Remount on every save so the editor starts from what the server now holds.
        key={a.updatedAt}
        article={{
          id: a.id,
          status: a.status,
          title: a.title,
          authorName: a.authorName,
          summary: a.summary,
          source: a.source,
          sourceLabel: a.sourceLabel ?? '',
          heroMediaId: a.heroMediaId ?? '',
          heroUrl: a.heroUrl ?? '',
          tags: a.tags,
          readMinutes: a.readMinutes,
          blocks: a.blocks,
        }}
      />
    </>
  );
}
