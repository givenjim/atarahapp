import { OpportunityType } from '@prisma/client';
import { parseApplicationUrl } from './opportunity-logic';

/**
 * CSV import (P1-M9). The file is parsed and validated into a report first; nothing is written until staff commit the
 * valid rows, and committed rows are always DRAFT (an import never publishes).
 */

export const CSV_COLUMNS = [
  'title',
  'provider',
  'type',
  'summary',
  'about',
  'deadline',
  'county',
  'work_mode',
  'application_url',
  'source_url',
  'value_min',
  'value_max',
  'currency',
  'value_text',
  'disciplines',
  'requirements',
  'benefits',
] as const;
const REQUIRED = ['title', 'provider', 'type', 'summary', 'application_url'] as const;
export const MAX_IMPORT_ROWS = 500;
export const MAX_IMPORT_BYTES = 1_000_000;

/** RFC 4180: quoted fields, doubled quotes, commas and line breaks inside quotes. Tolerates a BOM and CRLF. */
export function parseCsv(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let field = '';
  let quoted = false;
  const src = text.charCodeAt(0) === 0xfeff ? text.slice(1) : text;
  for (let i = 0; i < src.length; i += 1) {
    const c = src[i]!;
    if (quoted) {
      if (c === '"') {
        if (src[i + 1] === '"') {
          field += '"';
          i += 1;
        } else quoted = false;
      } else field += c;
    } else if (c === '"' && field === '') quoted = true;
    else if (c === ',') {
      row.push(field);
      field = '';
    } else if (c === '\n' || c === '\r') {
      if (c === '\r' && src[i + 1] === '\n') i += 1;
      row.push(field);
      field = '';
      if (row.some((f) => f.trim() !== '')) rows.push(row);
      row = [];
    } else field += c;
  }
  row.push(field);
  if (row.some((f) => f.trim() !== '')) rows.push(row);
  return rows;
}

export interface ImportRow {
  line: number;
  title: string;
  provider: string;
  type: OpportunityType;
  summary: string;
  about: string;
  deadlineAt: Date | null;
  county: string | null;
  workMode: 'ONSITE' | 'REMOTE' | 'HYBRID';
  applicationUrl: string;
  sourceUrl: string | null;
  valueMinMinor: bigint | null;
  valueMaxMinor: bigint | null;
  valueCurrency: string | null;
  valueText: string | null;
  disciplines: string[];
  requirements: string[];
  benefits: string[];
}

export interface ImportIssue {
  line: number;
  column: string | null;
  message: string;
}

export interface ImportReport {
  rows: ImportRow[];
  issues: ImportIssue[];
  /** Rows with no issue: the only ones a commit will create. */
  validCount: number;
  totalCount: number;
}

const pipeList = (v: string): string[] =>
  v
    .split('|')
    .map((s) => s.trim())
    .filter(Boolean)
    .slice(0, 20);

const toMinor = (v: string): bigint | null => {
  if (v.trim() === '') return null;
  const n = Number(v.replace(/,/g, ''));
  if (!Number.isFinite(n) || n < 0) return null;
  return BigInt(Math.round(n * 100));
};

/** Validates every row and reports problems by line (line 1 is the header, so data starts at line 2). */
export function validateImport(text: string, now = new Date()): ImportReport {
  const table = parseCsv(text);
  const issues: ImportIssue[] = [];
  const header = (table[0] ?? []).map((h) => h.trim().toLowerCase());
  const missing = REQUIRED.filter((c) => !header.includes(c));
  if (missing.length > 0) {
    return {
      rows: [],
      issues: [
        {
          line: 1,
          column: null,
          message: `Missing column${missing.length > 1 ? 's' : ''}: ${missing.join(', ')}.`,
        },
      ],
      validCount: 0,
      totalCount: 0,
    };
  }
  const body = table.slice(1);
  if (body.length > MAX_IMPORT_ROWS) {
    return {
      rows: [],
      issues: [
        { line: 1, column: null, message: `A file can have at most ${MAX_IMPORT_ROWS} rows.` },
      ],
      validCount: 0,
      totalCount: body.length,
    };
  }
  const rows: ImportRow[] = [];
  const bad = new Set<number>();
  const fail = (line: number, column: string | null, message: string) => {
    issues.push({ line, column, message });
    bad.add(line);
  };
  const types = Object.values(OpportunityType) as string[];

  body.forEach((cells, idx) => {
    const line = idx + 2;
    const get = (name: string): string => (cells[header.indexOf(name)] ?? '').trim();
    const title = get('title');
    const provider = get('provider');
    const type = get('type').toUpperCase();
    const summary = get('summary');
    if (title.length < 3 || title.length > 140)
      fail(line, 'title', 'Title must be 3 to 140 characters.');
    if (provider.length < 2 || provider.length > 120)
      fail(line, 'provider', 'Provider must be 2 to 120 characters.');
    if (!types.includes(type)) fail(line, 'type', `Type must be one of ${types.join(', ')}.`);
    if (summary.length < 10 || summary.length > 300)
      fail(line, 'summary', 'Summary must be 10 to 300 characters.');

    let applicationUrl = get('application_url');
    try {
      applicationUrl = parseApplicationUrl(applicationUrl).href;
    } catch {
      fail(line, 'application_url', 'Application link must be a valid https:// address.');
    }
    const sourceRaw = get('source_url');
    let sourceUrl: string | null = null;
    if (sourceRaw) {
      try {
        sourceUrl = parseApplicationUrl(sourceRaw).href;
      } catch {
        fail(line, 'source_url', 'Source link must be a valid https:// address.');
      }
    }
    const deadlineRaw = get('deadline');
    let deadlineAt: Date | null = null;
    if (deadlineRaw) {
      // A date alone means the end of that day in Nairobi.
      const d = /^\d{4}-\d{2}-\d{2}$/.test(deadlineRaw)
        ? new Date(`${deadlineRaw}T23:59:00+03:00`)
        : new Date(deadlineRaw);
      if (Number.isNaN(d.getTime()))
        fail(line, 'deadline', 'Deadline must be a date like 2026-12-31.');
      else if (d <= now) fail(line, 'deadline', 'Deadline is in the past.');
      else deadlineAt = d;
    }
    const mode = (get('work_mode') || 'ONSITE').toUpperCase();
    if (!['ONSITE', 'REMOTE', 'HYBRID'].includes(mode))
      fail(line, 'work_mode', 'Work mode must be ONSITE, REMOTE or HYBRID.');
    const min = toMinor(get('value_min'));
    const max = toMinor(get('value_max'));
    if ((get('value_min') && min === null) || (get('value_max') && max === null)) {
      fail(line, 'value_min', 'Amounts must be positive numbers.');
    } else if (min !== null && max !== null && min > max) {
      fail(line, 'value_min', 'The smallest amount is above the largest.');
    }
    const currency = (get('currency') || (min !== null || max !== null ? 'KES' : '')).toUpperCase();
    if (currency && !/^[A-Z]{3}$/.test(currency))
      fail(line, 'currency', 'Currency must be a three-letter code.');

    if (!bad.has(line)) {
      rows.push({
        line,
        title,
        provider,
        type: type as OpportunityType,
        summary,
        about: get('about'),
        deadlineAt,
        county: get('county') || null,
        workMode: mode as ImportRow['workMode'],
        applicationUrl,
        sourceUrl,
        valueMinMinor: min,
        valueMaxMinor: max,
        valueCurrency: currency || null,
        valueText: get('value_text') || null,
        disciplines: pipeList(get('disciplines')),
        requirements: pipeList(get('requirements')),
        benefits: pipeList(get('benefits')),
      });
    }
  });
  return { rows, issues, validCount: rows.length, totalCount: body.length };
}
