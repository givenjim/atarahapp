import Link from 'next/link';
import { DataTable } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { learningAnalytics } from '@/lib/learning-api';
import { formatRate, typeLabel } from '@/lib/learning';

export const metadata = { title: 'Learning analytics' };

export default async function LearningAnalyticsPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'learning.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Learning.
      </div>
    );
  }
  const { data, error, response } = await learningAnalytics();
  if (!data) {
    return (
      <p className="alert" role="alert">
        {errorOf(error, response).message}
      </p>
    );
  }
  const a = data.data;
  const overall = a.totalStarts === 0 ? 0 : (a.totalCompletions / a.totalStarts) * 100;

  return (
    <>
      <div className="page-head">
        <h1>Learning analytics</h1>
        <p>
          How members use Skill Labs. A start is an enrolment in a course, or opening any other
          item; a completion is a finished course or an item a member marked complete.
        </p>
      </div>
      <section className="card" aria-label="Totals" style={{ padding: 20 }}>
        <dl className="facts">
          <dt>Published items</dt>
          <dd>{a.publishedItems}</dd>
          <dt>Starts</dt>
          <dd>{a.totalStarts}</dd>
          <dt>Completions</dt>
          <dd>
            {a.totalCompletions} <span className="muted">({formatRate(overall)} of starts)</span>
          </dd>
          <dt>Certificates issued</dt>
          <dd>{a.certificatesIssued}</dd>
        </dl>
      </section>
      <section className="card" aria-label="Items" style={{ marginTop: 16 }}>
        <DataTable
          caption="Starts and completions per item"
          rows={a.items}
          rowKey={(r) => r.contentId}
          empty="Nobody has started anything yet."
          columns={[
            {
              key: 'title',
              header: 'Item',
              render: (r) => (
                <>
                  <Link href={`/learning/${r.contentId}`}>{r.title}</Link>
                  <div className="muted">{typeLabel(r.type)}</div>
                </>
              ),
            },
            { key: 'starts', header: 'Starts', render: (r) => r.starts },
            { key: 'completions', header: 'Completions', render: (r) => r.completions },
            {
              key: 'rate',
              header: 'Completion rate',
              render: (r) => formatRate(r.completionRate),
            },
          ]}
        />
      </section>
    </>
  );
}
