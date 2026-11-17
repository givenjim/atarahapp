'use client';

import Link from 'next/link';
import { useState, useTransition, type ChangeEvent } from 'react';
import { commitImportAction, previewImportAction } from '@/app/opportunity-actions';
import { csvTemplate, IMPORT_MAX_BYTES, titleCase } from '@/lib/opportunities';

interface Report {
  totalCount: number;
  validCount: number;
  issues: Array<{ line: number; column?: string | null; message: string }>;
  preview: Array<{
    line: number;
    title: string;
    provider: string;
    type: string;
    deadlineAt?: string | null;
    providerExists: boolean;
  }>;
}

interface Done {
  created: number;
  skipped: number;
}

/**
 * Check a CSV, read the report, then import the valid rows as drafts. Importing never publishes anything, and the
 * file is checked again on the server when you import.
 */
export function ImportForm() {
  const [csv, setCsv] = useState('');
  const [report, setReport] = useState<Report | null>(null);
  const [done, setDone] = useState<Done | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();

  const reset = () => {
    setReport(null);
    setDone(null);
    setError(null);
  };

  const onFile = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    reset();
    if (!file) return;
    if (file.size > IMPORT_MAX_BYTES) return setError('That file is too large (1 MB at most).');
    setCsv(await file.text());
  };

  const check = () => {
    reset();
    start(async () => {
      const res = await previewImportAction(csv);
      if (res.ok) setReport(res.report);
      else setError(res.error);
    });
  };

  const commit = () => {
    setError(null);
    start(async () => {
      const res = await commitImportAction(csv);
      if (res.ok) {
        setDone({ created: res.result.created, skipped: res.result.skipped });
        setReport(null);
        setCsv('');
      } else setError(res.error);
    });
  };

  const downloadHref = `data:text/csv;charset=utf-8,${encodeURIComponent(csvTemplate())}`;

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <section
        className="card"
        aria-label="CSV file"
        style={{ padding: 20, display: 'grid', gap: 12 }}
      >
        <p className="muted" style={{ margin: 0 }}>
          Imported rows are always saved as <strong>drafts</strong>, with the “External source”
          badge. Nothing is published until you open each listing and publish it. Separate list
          values (like requirements) with <code>|</code>. Dates look like 2027-03-31 and mean the
          end of that day in Nairobi.
        </p>
        <p style={{ margin: 0 }}>
          <a href={downloadHref} download="opportunities-template.csv">
            Download the CSV template
          </a>
        </p>
        <label className="field">
          CSV file
          <input className="input" type="file" accept=".csv,text/csv" onChange={onFile} />
        </label>
        <label className="field">
          Or paste the rows
          <textarea
            className="textarea"
            rows={8}
            value={csv}
            spellCheck={false}
            onChange={(e) => {
              setCsv(e.target.value);
              reset();
            }}
          />
        </label>
        <div className="row-actions">
          <button
            className="button"
            type="button"
            disabled={pending || !csv.trim()}
            onClick={check}
          >
            {pending && !report ? 'Checking…' : 'Check file'}
          </button>
        </div>
      </section>

      {error ? (
        <p className="alert" role="alert">
          {error}
        </p>
      ) : null}

      {done ? (
        <p className="card" role="status" style={{ padding: 20 }}>
          Imported {done.created} draft{done.created === 1 ? '' : 's'}
          {done.skipped > 0 ? `, skipped ${done.skipped} that already exist` : ''}.{' '}
          <Link href="/opportunities?status=DRAFT">Review the drafts</Link>
        </p>
      ) : null}

      {report ? (
        <section
          className="card"
          aria-label="Report"
          style={{ padding: 20, display: 'grid', gap: 12 }}
        >
          <h2>Report</h2>
          <p style={{ margin: 0 }}>
            {report.validCount} of {report.totalCount} row{report.totalCount === 1 ? '' : 's'} can
            be imported.
            {report.issues.length > 0
              ? ` ${report.issues.length} problem${report.issues.length === 1 ? '' : 's'} found.`
              : ''}
          </p>
          {report.issues.length > 0 ? (
            <div className="table-wrap">
              <table className="data">
                <caption style={{ position: 'absolute', left: -9999 }}>Problems found</caption>
                <thead>
                  <tr>
                    <th scope="col">Line</th>
                    <th scope="col">Column</th>
                    <th scope="col">Problem</th>
                  </tr>
                </thead>
                <tbody>
                  {report.issues.map((i, n) => (
                    <tr key={n}>
                      <td>{i.line}</td>
                      <td>{i.column ?? '—'}</td>
                      <td>{i.message}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : null}
          {report.preview.length > 0 ? (
            <div className="table-wrap">
              <table className="data">
                <caption style={{ position: 'absolute', left: -9999 }}>
                  Rows that will be imported
                </caption>
                <thead>
                  <tr>
                    <th scope="col">Line</th>
                    <th scope="col">Title</th>
                    <th scope="col">Provider</th>
                    <th scope="col">Type</th>
                    <th scope="col">Deadline</th>
                  </tr>
                </thead>
                <tbody>
                  {report.preview.map((r) => (
                    <tr key={r.line}>
                      <td>{r.line}</td>
                      <td>{r.title}</td>
                      <td>
                        {r.provider}
                        {r.providerExists ? '' : ' (new, unverified)'}
                      </td>
                      <td>{titleCase(r.type)}</td>
                      <td>{r.deadlineAt ? r.deadlineAt.slice(0, 10) : 'Rolling'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : null}
          <div className="row-actions">
            <button
              className="button"
              type="button"
              disabled={pending || report.validCount === 0}
              onClick={commit}
            >
              {pending
                ? 'Importing…'
                : `Import ${report.validCount} valid row${report.validCount === 1 ? '' : 's'} as drafts`}
            </button>
          </div>
        </section>
      ) : null}
    </div>
  );
}
