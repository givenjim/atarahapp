import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listFaq } from '@/lib/help-api';
import { FaqManager } from './faq-manager';

export const metadata = { title: 'FAQ' };

export default async function FaqPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'help.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to the FAQ.
      </div>
    );
  }
  const { data, error, response } = await listFaq({ page: 1, limit: 100 });
  return (
    <>
      <div className="page-head">
        <h1>FAQ</h1>
        <p>
          Questions members see in Help, in this order. Only published entries are shown in the app.
        </p>
      </div>
      {!data ? (
        <p className="alert" role="alert">
          {errorOf(error, response).message}
        </p>
      ) : (
        <FaqManager
          entries={[...data.data]
            .sort((a, b) => a.sortOrder - b.sortOrder)
            .map((e) => ({
              id: e.id,
              question: e.question,
              answer: e.answer,
              sortOrder: e.sortOrder,
              published: e.published,
            }))}
        />
      )}
    </>
  );
}
