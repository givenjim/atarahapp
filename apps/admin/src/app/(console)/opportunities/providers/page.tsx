import Link from 'next/link';
import { DataTable, Pagination } from '@/components/ui/data-table';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listProviders } from '@/lib/opportunities-api';
import { canVerify, titleCase, verificationMeta } from '@/lib/opportunities';
import { ProviderFormDialog } from './provider-form';
import { ProviderVerify } from './provider-verify';

export const metadata = { title: 'Opportunity providers' };

type SearchParams = Promise<{ q?: string; page?: string }>;

export default async function ProvidersPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'opportunity.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Opportunities.
      </div>
    );
  }
  const page = Math.max(1, Number.parseInt(sp.page ?? '1', 10) || 1);
  const q = sp.q?.trim() || undefined;
  const { data, error, response } = await listProviders({ page, limit: 20, q });
  const verifier = canVerify(me.permissions);

  return (
    <>
      <div className="page-head">
        <h1>Providers</h1>
        <p>
          Organisations that offer opportunities. Verifying a provider shows a tick on its listings;
          it is separate from a listing’s own trust badge.
        </p>
      </div>
      <section className="card" aria-label="Providers">
        <div className="toolbar">
          <form className="filters" role="search" method="get">
            <label className="field">
              Search
              <input
                className="input"
                type="search"
                name="q"
                defaultValue={q ?? ''}
                placeholder="Provider name"
              />
            </label>
            <button className="button" type="submit">
              Apply
            </button>
            {q ? (
              <Link className="button secondary" href="/opportunities/providers">
                Clear
              </Link>
            ) : null}
          </form>
          <ProviderFormDialog />
        </div>
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <>
            <DataTable
              caption="Providers"
              rows={data.data}
              rowKey={(p) => p.id}
              empty={q ? 'No providers match that name.' : 'No providers yet.'}
              columns={[
                {
                  key: 'name',
                  header: 'Provider',
                  render: (p) => (
                    <>
                      <Link href={`/opportunities?providerId=${p.id}`}>{p.name}</Link>
                      <div className="muted">{p.website ?? 'No website'}</div>
                    </>
                  ),
                },
                { key: 'type', header: 'Type', render: (p) => titleCase(p.type) },
                {
                  key: 'status',
                  header: 'Verification',
                  render: (p) => (
                    <span className={`pill ${verificationMeta(p.verificationStatus).tone}`.trim()}>
                      {verificationMeta(p.verificationStatus).label}
                    </span>
                  ),
                },
                { key: 'count', header: 'Published', render: (p) => p.opportunitiesCount },
                {
                  key: 'owner',
                  header: 'Account',
                  render: (p) => (p.ownerUserId ? 'Has an account' : 'Entered by staff'),
                },
                {
                  key: 'actions',
                  header: 'Actions',
                  render: (p) => (
                    <span className="row-actions">
                      <ProviderFormDialog
                        id={p.id}
                        initial={{
                          name: p.name,
                          type: p.type,
                          website: p.website ?? '',
                          ownerUserId: p.ownerUserId ?? '',
                        }}
                      />
                      {verifier ? (
                        <ProviderVerify id={p.id} name={p.name} status={p.verificationStatus} />
                      ) : null}
                    </span>
                  ),
                },
              ]}
            />
            {data.meta ? (
              <Pagination
                meta={data.meta as { page: number; limit: number; total: number }}
                basePath="/opportunities/providers"
                query={{ q }}
              />
            ) : null}
          </>
        )}
      </section>
    </>
  );
}
