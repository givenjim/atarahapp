import Link from 'next/link';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { getHomeConfig, listAdminArticles } from '@/lib/articles-api';
import { HomePin } from './home-pin';

export const metadata = { title: 'Home curation' };

export default async function HomeCurationPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'article.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Home curation.
      </div>
    );
  }
  const [config, published] = await Promise.all([
    getHomeConfig(),
    listAdminArticles({ status: 'PUBLISHED', page: 1, limit: 100 }),
  ]);

  return (
    <>
      <div className="page-head">
        <h1>Home curation</h1>
        <p>
          Choose the article pinned at the top of the Home screen. Only published articles can be
          pinned. The featured-opportunity pin arrives with Opportunities.
        </p>
      </div>
      {!config.data ? (
        <p className="alert" role="alert">
          {errorOf(config.error, config.response).message}
        </p>
      ) : !published.data ? (
        <p className="alert" role="alert">
          {errorOf(published.error, published.response).message}
        </p>
      ) : (
        <HomePin
          current={{
            id: config.data.data.featuredArticleId ?? null,
            title: config.data.data.featuredArticleTitle ?? null,
          }}
          options={published.data.data
            .filter((a) => !a.scheduled)
            .map((a) => ({ id: a.id, title: a.title, authorName: a.authorName }))}
        />
      )}
      <p>
        <Link href="/articles?status=PUBLISHED">Manage published articles</Link>
      </p>
    </>
  );
}
