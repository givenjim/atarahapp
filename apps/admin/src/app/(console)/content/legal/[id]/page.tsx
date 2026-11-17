import Link from 'next/link';
import { notFound } from 'next/navigation';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { formatWhen } from '@/lib/broadcasts';
import { listLegalDocuments } from '@/lib/help-api';
import { canEditLegal, DRAFT_LABEL, legalLabel, legalStatusMeta } from '@/lib/help';
import { LegalEditor } from './legal-editor';

export const metadata = { title: 'Legal document' };

export default async function LegalVersionPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'legal.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Legal documents.
      </div>
    );
  }
  // There is no "get one" endpoint: the list carries every version with its text.
  const { data, error, response } = await listLegalDocuments();
  if (!data) {
    return (
      <p className="alert" role="alert">
        {errorOf(error, response).message}
      </p>
    );
  }
  const doc = data.data.find((d) => d.id === id);
  if (!doc) notFound();
  const meta = legalStatusMeta(doc.status);
  const editable = canEditLegal(doc.status);

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/content/legal">← All legal documents</Link>
        </p>
        <h1>
          {legalLabel(doc.type)} · version {doc.version}
        </h1>
        <p>
          <span className={`pill ${meta.tone}`.trim()}>{meta.label}</span>{' '}
          {doc.isDraft ? DRAFT_LABEL : `Effective ${formatWhen(doc.effectiveAt)}`}
        </p>
      </div>
      {editable ? null : (
        <p className="card" style={{ padding: 16, maxWidth: 800 }}>
          This version is {doc.status === 'PUBLISHED' ? 'published' : 'archived'}, so it is a record
          of what members agreed to and cannot be edited. To change the wording, add a new version
          from the list.
        </p>
      )}
      <LegalEditor
        id={doc.id}
        editable={editable}
        initial={{ type: doc.type, version: doc.version, title: doc.title, body: doc.body }}
      />
    </>
  );
}
