/** Pure helpers for the Opportunities screens (no server imports): labels, form ↔ payload, rules editor, gating. */

export const OPP_TYPES = [
  'GRANT',
  'FUNDING',
  'JOB',
  'INTERNSHIP',
  'GIG',
  'COMPETITION',
  'FESTIVAL',
  'PARTNERSHIP',
  'FELLOWSHIP',
  'RESIDENCY',
  'PROGRAMME',
] as const;
export const OPP_STATUSES = [
  'DRAFT',
  'PENDING_REVIEW',
  'PUBLISHED',
  'CLOSED',
  'EXPIRED',
  'ARCHIVED',
  'REMOVED',
] as const;
export const PROVIDER_TYPES = [
  'GOVERNMENT',
  'NGO',
  'CORPORATE',
  'FESTIVAL',
  'STUDIO',
  'EDUCATION',
  'OTHER',
] as const;
export const WORK_MODES = ['ONSITE', 'REMOTE', 'HYBRID'] as const;
export const DOCUMENTS = ['CV', 'BIO', 'EPK', 'DECK', 'ARTIST_STATEMENT'] as const;
export const LINK_RESULTS = ['BROKEN', 'OK', 'UNKNOWN'] as const;

export const titleCase = (v: string): string =>
  v.charAt(0) + v.slice(1).toLowerCase().replace(/_/g, ' ');

type Tone = '' | 'success' | 'warning' | 'danger' | 'muted';

export const STATUS_META: Record<string, { label: string; tone: Tone }> = {
  DRAFT: { label: 'Draft', tone: 'muted' },
  PENDING_REVIEW: { label: 'Pending review', tone: 'warning' },
  PUBLISHED: { label: 'Published', tone: 'success' },
  CLOSED: { label: 'Closed', tone: 'muted' },
  EXPIRED: { label: 'Expired', tone: 'muted' },
  ARCHIVED: { label: 'Archived', tone: 'muted' },
  REMOVED: { label: 'Removed', tone: 'danger' },
};
export const statusMeta = (s: string) =>
  STATUS_META[s] ?? { label: titleCase(s), tone: '' as Tone };

export const TRUST_META: Record<string, { label: string; tone: Tone }> = {
  VERIFIED: { label: 'Verified by Atarah', tone: 'success' },
  SOURCE_CONFIRMED: { label: 'Source confirmed', tone: '' },
  EXTERNAL_SOURCE: { label: 'External source', tone: 'muted' },
};
export const trustMeta = (t: string) => TRUST_META[t] ?? { label: titleCase(t), tone: '' as Tone };

export const LINK_META: Record<string, { label: string; tone: Tone }> = {
  OK: { label: 'Link works', tone: 'success' },
  BROKEN: { label: 'Link broken', tone: 'danger' },
  UNKNOWN: { label: 'Not checked yet', tone: 'muted' },
};
export const linkMeta = (l: string) => LINK_META[l] ?? { label: titleCase(l), tone: '' as Tone };

export const VERIFICATION_META: Record<string, { label: string; tone: Tone }> = {
  NOT_SUBMITTED: { label: 'Not verified', tone: 'muted' },
  SUBMITTED: { label: 'Submitted', tone: 'warning' },
  UNDER_REVIEW: { label: 'Under review', tone: 'warning' },
  VERIFIED: { label: 'Verified', tone: 'success' },
  REJECTED: { label: 'Rejected', tone: 'danger' },
  EXPIRED: { label: 'Expired', tone: 'muted' },
  REVOKED: { label: 'Revoked', tone: 'danger' },
};
export const verificationMeta = (v: string) =>
  VERIFICATION_META[v] ?? { label: titleCase(v), tone: '' as Tone };

// ---- permissions and lifecycle -------------------------------------------------------------------------------

/** "Verified by Atarah" and provider verification need `opportunity.verify`; the backend enforces it as well. */
export const canVerify = (permissions: readonly string[]): boolean =>
  permissions.includes('opportunity.verify');

export type LifecycleAction = 'publish' | 'close' | 'archive' | 'remove' | 'reject' | 'feature';

const ALLOWED: Record<LifecycleAction, readonly string[]> = {
  publish: ['DRAFT', 'PENDING_REVIEW', 'CLOSED', 'EXPIRED'],
  close: ['PUBLISHED'],
  archive: ['DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'CLOSED', 'EXPIRED'],
  remove: ['DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'CLOSED', 'EXPIRED', 'ARCHIVED'],
  reject: ['PENDING_REVIEW'],
  feature: ['PUBLISHED'],
};

/** The actions that make sense for a status (the same moves the API allows; it checks them again). */
export const actionsFor = (status: string): LifecycleAction[] =>
  (Object.keys(ALLOWED) as LifecycleAction[]).filter((a) => ALLOWED[a].includes(status));

// ---- deadlines (entered and shown in Nairobi time, UTC+3, no daylight saving) --------------------------------------

/** `2026-12-31T23:59` (a datetime-local value, Nairobi time) to an ISO instant; empty means a rolling deadline. */
export function deadlineToIso(local: string): string | null {
  const v = local.trim();
  if (!v) return null;
  const d = new Date(`${v.length === 16 ? `${v}:00` : v}+03:00`);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

/** An ISO instant to a datetime-local value in Nairobi time. */
export function isoToDeadline(iso: string | null | undefined): string {
  if (!iso) return '';
  const t = new Date(iso).getTime();
  if (Number.isNaN(t)) return '';
  return new Date(t + 3 * 3_600_000).toISOString().slice(0, 16);
}

export const formatDeadline = (iso: string | null | undefined): string =>
  iso ? `${isoToDeadline(iso).replace('T', ' ')} EAT` : 'Rolling';

// ---- rules editor --------------------------------------------------------------------------------------------

export const RULE_TYPES = [
  'RESIDENCY',
  'AGE_RANGE',
  'DISCIPLINE_IN',
  'SKILL_IN',
  'MIN_PROJECTS',
  'DOCUMENT',
  'CUSTOM_TEXT',
] as const;
export type RuleType = (typeof RULE_TYPES)[number];

export const RULE_LABELS: Record<RuleType, string> = {
  RESIDENCY: 'Residency',
  AGE_RANGE: 'Age range',
  DISCIPLINE_IN: 'Discipline',
  SKILL_IN: 'Skills',
  MIN_PROJECTS: 'Minimum projects',
  DOCUMENT: 'Document',
  CUSTOM_TEXT: 'Custom (advice only)',
};

export const RULE_HELP: Record<RuleType, string> = {
  RESIDENCY: 'Checked against the member’s country and county.',
  AGE_RANGE: 'Atarah does not know members’ ages, so this is shown as "provider will confirm".',
  DISCIPLINE_IN: 'Met when the member practises any of the chosen disciplines.',
  SKILL_IN: 'Met when the member has any (or all) of the chosen skills.',
  MIN_PROJECTS: 'Counts published portfolio projects.',
  DOCUMENT: 'Creative documents arrive in Phase 2, so this is shown as "coming soon".',
  CUSTOM_TEXT: 'Cannot be checked. Shown to the member as a requirement to read.',
};

export interface RuleDraft {
  key: string;
  ruleType: RuleType;
  label: string;
  isBlocking: boolean;
  countryCode: string;
  /** Comma or space separated three-letter county codes. */
  countyCodes: string;
  min: string;
  max: string;
  disciplineIds: string[];
  skillIds: string[];
  mode: 'any' | 'all';
  count: string;
  document: string;
}

let counter = 0;
const nextKey = () => `rule-${(counter += 1)}`;

export const emptyRule = (ruleType: RuleType = 'MIN_PROJECTS'): RuleDraft => ({
  key: nextKey(),
  ruleType,
  label: '',
  isBlocking: true,
  countryCode: ruleType === 'RESIDENCY' ? 'KE' : '',
  countyCodes: '',
  min: '',
  max: '',
  disciplineIds: [],
  skillIds: [],
  mode: 'any',
  count: '1',
  document: 'ARTIST_STATEMENT',
});

const words = (v: string): string[] =>
  v
    .split(/[\s,]+/)
    .map((s) => s.trim().toUpperCase())
    .filter(Boolean);

const int = (v: string): number | undefined => {
  const t = v.trim();
  return /^\d+$/.test(t) ? Number.parseInt(t, 10) : undefined;
};

/** The `params` the API expects for a rule (it validates them again and answers with a field error). */
export function buildRuleParams(d: RuleDraft): Record<string, unknown> {
  switch (d.ruleType) {
    case 'RESIDENCY': {
      const counties = words(d.countyCodes);
      return {
        ...(d.countryCode.trim() ? { countryCode: d.countryCode.trim().toUpperCase() } : {}),
        ...(counties.length > 0 ? { countyCodes: counties } : {}),
      };
    }
    case 'AGE_RANGE':
      return {
        ...(int(d.min) !== undefined ? { min: int(d.min) } : {}),
        ...(int(d.max) !== undefined ? { max: int(d.max) } : {}),
      };
    case 'DISCIPLINE_IN':
      return { disciplineIds: d.disciplineIds };
    case 'SKILL_IN':
      return { skillIds: d.skillIds, mode: d.mode };
    case 'MIN_PROJECTS':
      return { count: int(d.count) ?? 0 };
    case 'DOCUMENT':
      return { document: d.document };
    case 'CUSTOM_TEXT':
      return {};
  }
}

/** First problem with a rule row, or null. Mirrors the API so most mistakes never leave the browser. */
export function validateRule(d: RuleDraft): string | null {
  const label = d.label.trim();
  if (label.length < 3 || label.length > 140)
    return 'Each rule needs a label of 3 to 140 characters.';
  const p = buildRuleParams(d);
  switch (d.ruleType) {
    case 'RESIDENCY':
      if (!p.countryCode && !p.countyCodes)
        return `“${label}”: name a country or at least one county.`;
      if (typeof p.countryCode === 'string' && p.countryCode.length !== 2)
        return `“${label}”: the country code has two letters, like KE.`;
      if ((p.countyCodes as string[] | undefined)?.some((c) => c.length !== 3))
        return `“${label}”: county codes have three letters, like NBI.`;
      return null;
    case 'AGE_RANGE':
      if (p.min === undefined && p.max === undefined)
        return `“${label}”: give a minimum or a maximum age.`;
      if (
        typeof p.min === 'number' &&
        typeof p.max === 'number' &&
        (p.min > p.max || p.min < 10 || p.max > 120)
      )
        return `“${label}”: the minimum age cannot be above the maximum.`;
      return null;
    case 'DISCIPLINE_IN':
      return d.disciplineIds.length === 0 ? `“${label}”: choose at least one discipline.` : null;
    case 'SKILL_IN':
      return d.skillIds.length === 0 ? `“${label}”: choose at least one skill.` : null;
    case 'MIN_PROJECTS':
      return (p.count as number) < 1 || (p.count as number) > 100
        ? `“${label}”: the number of projects is 1 to 100.`
        : null;
    default:
      return null;
  }
}

export function moveRule<T>(rules: readonly T[], index: number, direction: -1 | 1): T[] {
  const to = index + direction;
  if (to < 0 || to >= rules.length) return [...rules];
  const out = [...rules];
  [out[index], out[to]] = [out[to]!, out[index]!];
  return out;
}

interface RuleLike {
  ruleType: string;
  params: Record<string, unknown>;
  label: string;
  isBlocking: boolean;
}

export function ruleFromDto(r: RuleLike): RuleDraft {
  const d = emptyRule(r.ruleType as RuleType);
  const p = r.params;
  const strs = (v: unknown): string[] => (Array.isArray(v) ? v.map(String) : []);
  d.label = r.label;
  d.isBlocking = r.isBlocking;
  d.countryCode = typeof p.countryCode === 'string' ? p.countryCode : '';
  d.countyCodes = strs(p.countyCodes).join(', ');
  d.min = typeof p.min === 'number' ? String(p.min) : '';
  d.max = typeof p.max === 'number' ? String(p.max) : '';
  d.disciplineIds = strs(p.disciplineIds);
  d.skillIds = strs(p.skillIds);
  d.mode = p.mode === 'all' ? 'all' : 'any';
  d.count = typeof p.count === 'number' ? String(p.count) : '1';
  d.document = typeof p.document === 'string' ? p.document : 'ARTIST_STATEMENT';
  return d;
}

// ---- the opportunity form ------------------------------------------------------------------------------------

export interface OppForm {
  title: string;
  providerId: string;
  type: string;
  summary: string;
  about: string;
  requirements: string[];
  benefits: string[];
  valueMin: string;
  valueMax: string;
  valueCurrency: string;
  valueText: string;
  /** datetime-local, Nairobi time. Empty is a rolling deadline. */
  deadline: string;
  countyId: string;
  workMode: string;
  applicationMethod: 'EXTERNAL_WEBSITE' | 'EMAIL';
  applicationUrl: string;
  applicationEmail: string;
  sourceUrl: string;
  disciplineIds: string[];
  rules: RuleDraft[];
}

export const emptyForm = (): OppForm => ({
  title: '',
  providerId: '',
  type: 'GRANT',
  summary: '',
  about: '',
  requirements: [''],
  benefits: [''],
  valueMin: '',
  valueMax: '',
  valueCurrency: 'KES',
  valueText: '',
  deadline: '',
  countyId: '',
  workMode: 'ONSITE',
  applicationMethod: 'EXTERNAL_WEBSITE',
  applicationUrl: '',
  applicationEmail: '',
  sourceUrl: '',
  disciplineIds: [],
  rules: [],
});

export interface OppDtoLike {
  title: string;
  provider: { id: string };
  type: string;
  summary: string;
  about: string;
  requirements: string[];
  benefits: string[];
  valueMin?: number | null;
  valueMax?: number | null;
  valueCurrency?: string | null;
  valueText?: string | null;
  deadlineAt?: string | null;
  countyId?: string | null;
  workMode: string;
  applicationMethod: string;
  applicationUrl?: string | null;
  applicationEmail?: string | null;
  sourceUrl?: string | null;
  disciplineIds: string[];
  rules: RuleLike[];
}

export function formFromDto(o: OppDtoLike): OppForm {
  return {
    title: o.title,
    providerId: o.provider.id,
    type: o.type,
    summary: o.summary,
    about: o.about,
    requirements: o.requirements.length > 0 ? [...o.requirements] : [''],
    benefits: o.benefits.length > 0 ? [...o.benefits] : [''],
    valueMin: o.valueMin === null || o.valueMin === undefined ? '' : String(o.valueMin),
    valueMax: o.valueMax === null || o.valueMax === undefined ? '' : String(o.valueMax),
    valueCurrency: o.valueCurrency ?? 'KES',
    valueText: o.valueText ?? '',
    deadline: isoToDeadline(o.deadlineAt),
    countyId: o.countyId ?? '',
    workMode: o.workMode,
    applicationMethod: o.applicationMethod === 'EMAIL' ? 'EMAIL' : 'EXTERNAL_WEBSITE',
    applicationUrl: o.applicationUrl ?? '',
    applicationEmail: o.applicationEmail ?? '',
    sourceUrl: o.sourceUrl ?? '',
    disciplineIds: [...o.disciplineIds],
    rules: o.rules.map(ruleFromDto),
  };
}

const cleanList = (items: string[]): string[] => items.map((s) => s.trim()).filter(Boolean);
const amount = (v: string): number | null => {
  const t = v.replace(/,/g, '').trim();
  if (!t) return null;
  const n = Number(t);
  return Number.isFinite(n) && n >= 0 ? n : Number.NaN;
};

/** First problem with the form, or null. The API repeats every rule. */
export function validateOppForm(f: OppForm, mode: 'create' | 'edit'): string | null {
  if (f.title.trim().length < 3 || f.title.trim().length > 140)
    return 'The title must be 3 to 140 characters.';
  if (!f.providerId) return 'Choose the provider.';
  if (f.summary.trim().length < 10 || f.summary.trim().length > 300)
    return 'The summary must be 10 to 300 characters.';
  if (f.about.length > 8000) return 'The description is too long (8,000 characters at most).';
  const min = amount(f.valueMin);
  const max = amount(f.valueMax);
  if (Number.isNaN(min) || Number.isNaN(max)) return 'Amounts must be positive numbers.';
  if (min !== null && max !== null && min > max) return 'The smallest amount is above the largest.';
  if ((min !== null || max !== null) && !/^[A-Za-z]{3}$/.test(f.valueCurrency.trim()))
    return 'The currency is a three-letter code, like KES.';
  if (f.deadline.trim() && deadlineToIso(f.deadline) === null)
    return 'That deadline is not a date.';
  if (f.applicationMethod === 'EXTERNAL_WEBSITE') {
    const url = f.applicationUrl.trim();
    if (!url && mode === 'create')
      return 'Add the web address where members apply (it is needed before publishing).';
    if (url && !/^https:\/\/[^\s/]+\.[^\s/]+/i.test(url))
      return 'Application links must start with https://.';
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(f.applicationEmail.trim())) {
    return 'Add the email address where members apply.';
  }
  if (f.sourceUrl.trim() && !/^https:\/\/[^\s/]+\.[^\s/]+/i.test(f.sourceUrl.trim()))
    return 'The source link must start with https://.';
  for (const r of f.rules) {
    const problem = validateRule(r);
    if (problem) return problem;
  }
  return null;
}

/**
 * The request body. Money goes as major units (KES 100000, not cents); the API converts. Creating omits empty
 * optional fields; editing sends null (or an empty string) so a cleared field is cleared.
 */
export function toPayload(f: OppForm, mode: 'create' | 'edit'): Record<string, unknown> {
  const edit = mode === 'edit';
  const min = amount(f.valueMin);
  const max = amount(f.valueMax);
  const hasAmount = min !== null || max !== null;
  const body: Record<string, unknown> = {
    title: f.title.trim(),
    providerId: f.providerId,
    type: f.type,
    summary: f.summary.trim(),
    about: f.about.trim(),
    requirements: cleanList(f.requirements),
    benefits: cleanList(f.benefits),
    workMode: f.workMode,
    applicationMethod: f.applicationMethod,
    disciplineIds: f.disciplineIds,
    rules: f.rules.map((r) => ({
      ruleType: r.ruleType,
      params: buildRuleParams(r),
      label: r.label.trim(),
      isBlocking: r.isBlocking,
    })),
  };
  if (min !== null) body.valueMin = min;
  else if (edit) body.valueMin = null;
  if (max !== null) body.valueMax = max;
  else if (edit) body.valueMax = null;
  if (hasAmount) body.valueCurrency = f.valueCurrency.trim().toUpperCase();
  if (f.valueText.trim()) body.valueText = f.valueText.trim();
  else if (edit) body.valueText = null;
  const deadline = deadlineToIso(f.deadline);
  if (deadline) body.deadlineAt = deadline;
  else body.deadlineAt = null;
  if (f.countyId) body.countyId = f.countyId;
  else if (edit) body.countyId = null;
  if (f.applicationMethod === 'EXTERNAL_WEBSITE') {
    if (f.applicationUrl.trim()) body.applicationUrl = f.applicationUrl.trim();
  } else {
    body.applicationEmail = f.applicationEmail.trim();
  }
  if (f.sourceUrl.trim()) body.sourceUrl = f.sourceUrl.trim();
  else if (edit) body.sourceUrl = '';
  return body;
}

export interface ProviderForm {
  name: string;
  type: string;
  website: string;
  ownerUserId: string;
}

export const emptyProviderForm = (): ProviderForm => ({
  name: '',
  type: 'OTHER',
  website: '',
  ownerUserId: '',
});

export const isUuid = (v: string): boolean =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v.trim());

export function validateProvider(f: ProviderForm): string | null {
  if (f.name.trim().length < 2 || f.name.trim().length > 120)
    return 'The name must be 2 to 120 characters.';
  if (f.website.trim() && !/^https:\/\/[^\s/]+\.[^\s/]+/i.test(f.website.trim()))
    return 'The website must start with https://.';
  if (f.ownerUserId.trim() && !isUuid(f.ownerUserId))
    return 'The owner is a user id (a UUID) copied from the member’s page.';
  return null;
}

export function providerPayload(f: ProviderForm, mode: 'create' | 'edit'): Record<string, unknown> {
  const body: Record<string, unknown> = { name: f.name.trim(), type: f.type };
  if (f.website.trim()) body.website = f.website.trim();
  else if (mode === 'edit') body.website = null;
  if (f.ownerUserId.trim()) body.ownerUserId = f.ownerUserId.trim();
  else if (mode === 'edit') body.ownerUserId = null;
  return body;
}

// ---- messages and the CSV template -----------------------------------------------------------------------------

/** Friendly wording for the answers staff can see; anything else keeps the API's own message. */
export function opportunityMessage(status: number | undefined, message: string): string {
  if (status === 403) return 'You do not have permission to do that.';
  if (status === 404) return 'That opportunity or provider no longer exists.';
  if (status === 409) return message || 'That is not possible in the current state.';
  return message;
}

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

const csvCell = (v: string): string => (/[",\n\r]/.test(v) ? `"${v.replace(/"/g, '""')}"` : v);

/** A header row and one example row, so the file shape is clear. List values are separated with |. */
export function csvTemplate(): string {
  const example: Record<(typeof CSV_COLUMNS)[number], string> = {
    title: 'Example Fund 2027',
    provider: 'Example Foundation',
    type: 'GRANT',
    summary: 'One or two sentences members read on the card.',
    about: 'The longer description.',
    deadline: '2027-03-31',
    county: 'Nairobi',
    work_mode: 'ONSITE',
    application_url: 'https://example.org/apply',
    source_url: 'https://example.org/call',
    value_min: '100000',
    value_max: '500000',
    currency: 'KES',
    value_text: '',
    disciplines: 'Film / Video|Photography',
    requirements: 'Kenyan resident|Two finished projects',
    benefits: 'Funding|Mentorship',
  };
  return `${CSV_COLUMNS.join(',')}\n${CSV_COLUMNS.map((c) => csvCell(example[c])).join(',')}\n`;
}

export const IMPORT_MAX_BYTES = 1_000_000;
