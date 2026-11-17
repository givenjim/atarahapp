import Link from 'next/link';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listLegalDocuments } from '@/lib/help-api';
import { DRAFT_LABEL, groupLegal, legalLabel, legalStatusMeta } from '@/lib/help';
import { formatWhen } from '@/lib/broadcasts';
import { NewLegalVersion } from './new-legal-version';

export const metadata = { title: 'Legal documents' };

export default async function LegalPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'legal.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Legal documents.
      </div>
    );
  }
  const { data, error, response } = await listLegalDocuments();
  const groups = data ? groupLegal(data.data) : [];

  return (
    <>
      <div className="page-head">
        <h1>Legal documents</h1>
        <p>
          Each document has versions. A published version is what members agree to; it is never
          edited. To change a document, add a new version, review it, then publish it: the version
          it replaces is archived, and members who accepted it are unaffected.
        </p>
      </div>
      <div className="toolbar" style={{ marginBottom: 12 }}>
        <span className="muted">
          Drafts are labelled “{DRAFT_LABEL}” for members until published.
        </span>
        <NewLegalVersion />
      </div>
      {!data ? (
        <p className="alert" role="alert">
          {errorOf(error, response).message}
        </p>
      ) : groups.length === 0 ? (
        <p className="card empty">No legal documents yet.</p>
      ) : (
        groups.map((g) => (
          <section
            key={g.type}
            className="card"
            aria-label={legalLabel(g.type)}
            style={{ marginBottom: 16 }}
          >
            <h2 style={{ padding: '16px 16px 0', margin: 0 }}>{legalLabel(g.type)}</h2>
            <div className="table-wrap">
              <table className="data">
                <caption className="sr-only" style={{ position: 'absolute', left: -9999 }}>
                  Versions of {legalLabel(g.type)}
                </caption>
                <thead>
                  <tr>
                    <th scope="col">Version</th>
                    <th scope="col">Status</th>
                    <th scope="col">Effective</th>
                    <th scope="col">Last changed</th>
                    <th scope="col">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {g.versions.map((v) => {
                    const meta = legalStatusMeta(v.status);
                    return (
                      <tr key={v.id}>
                        <td>
                          <Link href={`/content/legal/${v.id}`}>{v.version}</Link>
                          <div className="muted">{v.title}</div>
                        </td>
                        <td>
                          <span className={`pill ${meta.tone}`.trim()}>{meta.label}</span>
                          {v.isDraft ? <div className="muted">{DRAFT_LABEL}</div> : null}
                        </td>
                        <td>
                          {v.status === 'PUBLISHED' || v.status === 'ARCHIVED'
                            ? formatWhen(v.effectiveAt)
                            : '—'}
                        </td>
                        <td>{formatWhen(v.updatedAt)}</td>
                        <td>
                          <Link className="button secondary small" href={`/content/legal/${v.id}`}>
                            {v.status === 'DRAFT' || v.status === 'IN_REVIEW' ? 'Edit' : 'View'}
                          </Link>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </section>
        ))
      )}
    </>
  );
}
