import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { api, errorOf } from '@/lib/api';
import { parseSuggestionFilter, SUGGESTION_STATUSES } from '@/lib/taxonomy';
import { SuggestionActions } from './suggestion-actions';

export const metadata = { title: 'Suggestions' };

type SearchParams = Promise<{ status?: string; page?: string }>;

const LABEL: Record<string, string> = {
  PENDING: 'Pending',
  APPROVED: 'Approved',
  MERGED: 'Merged',
  REJECTED: 'Rejected',
};
const TONE: Record<string, string> = {
  PENDING: 'warning',
  APPROVED: 'success',
  MERGED: '',
  REJECTED: 'danger',
};

const when = (iso: string) => new Date(iso).toLocaleString('en-KE');

export default async function SuggestionsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const filter = parseSuggestionFilter(sp.status);
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);

  const { data, error, response } = await api().GET('/api/v1/admin/specialisation-suggestions', {
    params: { query: { page, limit: 20, status: filter === 'ALL' ? undefined : filter } },
  });

  return (
    <>
      <form className="filters" role="search" method="get">
        <label className="field">
          Status
          <select className="select" name="status" defaultValue={filter}>
            {SUGGESTION_STATUSES.map((s) => (
              <option key={s} value={s}>
                {LABEL[s]}
              </option>
            ))}
            <option value="ALL">All statuses</option>
          </select>
        </label>
        <button className="button" type="submit">
          Apply
        </button>
        {filter !== 'PENDING' ? (
          <Link className="button secondary" href="/taxonomy/suggestions">
            Clear
          </Link>
        ) : null}
      </form>
      {!data ? (
        <p className="alert" role="alert" style={{ margin: 16 }}>
          {errorOf(error, response).message}
        </p>
      ) : (
        <>
          <DataTable
            caption="Specialisation suggestions"
            rows={data.data}
            rowKey={(s) => s.id}
            empty={
              filter === 'PENDING' ? 'No suggestions waiting.' : 'No suggestions match this filter.'
            }
            columns={[
              { key: 'name', header: 'Suggestion', render: (s) => s.name },
              { key: 'discipline', header: 'Discipline', render: (s) => s.disciplineName },
              {
                key: 'by',
                header: 'Suggested by',
                render: (s) => (
                  <>
                    {s.suggestedByName}
                    <div className="muted">{when(s.createdAt)}</div>
                  </>
                ),
              },
              {
                key: 'status',
                header: 'Outcome',
                render: (s) =>
                  s.status === 'PENDING' ? (
                    <SuggestionActions
                      id={s.id}
                      name={s.name}
                      disciplineId={s.disciplineId}
                      disciplineName={s.disciplineName}
                    />
                  ) : (
                    <>
                      <span className={`pill ${TONE[s.status] ?? ''}`.trim()}>
                        {LABEL[s.status] ?? s.status}
                      </span>
                      {s.resolvedAt ? <div className="muted">{when(s.resolvedAt)}</div> : null}
                      {s.resolutionNote ? <div className="muted">{s.resolutionNote}</div> : null}
                    </>
                  ),
              },
            ]}
          />
          {data.meta ? (
            <Pagination
              meta={data.meta as { page: number; limit: number; total: number }}
              basePath="/taxonomy/suggestions"
              query={{ status: filter === 'PENDING' ? undefined : filter }}
            />
          ) : null}
        </>
      )}
    </>
  );
}
