import { ApiException } from '../common/api.exception';
import { parseCsv, validateImport } from './opportunity-csv';
import {
  applicationDomain,
  assertCanUnsave,
  assertTransition,
  daysLeft,
  eatDaysUntil,
  isOpen,
  nextTracking,
  parseApplicationUrl,
  slugify,
  urgencyFor,
  valueLabel,
} from './opportunity-logic';
import {
  evaluateRule,
  evaluateRules,
  parseRuleParams,
  type RuleInput,
  type ViewerFacts,
} from './opportunity-rules';

const D1 = '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b';
const D2 = '4a3c9d2f-6b5e-4f70-9b2c-1d0e8f7a6b5c';
const S1 = '5b4d0e3a-7c6f-4081-8c3d-2e1f9a8b7c6d';
const S2 = '6c5e1f4b-8d70-4192-9d4e-3f2a0b9c8d7e';

const facts = (over: Partial<ViewerFacts> = {}): ViewerFacts => ({
  countryCode: 'KE',
  countyCode: 'NBI',
  disciplineIds: new Set([D1]),
  skillIds: new Set([S1]),
  projectCount: 2,
  ...over,
});

const rule = (over: Partial<RuleInput> & Pick<RuleInput, 'ruleType' | 'params'>): RuleInput => ({
  id: 'r1',
  label: 'A rule',
  isBlocking: true,
  ...over,
});

const NOW = new Date('2026-10-24T09:00:00Z');
const inDays = (n: number) => new Date(NOW.getTime() + n * 86_400_000);

const code = (fn: () => unknown): string | undefined => {
  try {
    fn();
  } catch (e) {
    return (e as ApiException).code;
  }
  return undefined;
};

describe('profile-gap rule engine', () => {
  it('RESIDENCY: country and county', () => {
    const r = (params: unknown) => rule({ ruleType: 'RESIDENCY', params });
    expect(evaluateRule(r({ countryCode: 'KE' }), facts()).state).toBe('MET');
    expect(evaluateRule(r({ countryCode: 'UG' }), facts()).state).toBe('MISSING');
    expect(evaluateRule(r({ countyCodes: ['NBI', 'MSA'] }), facts()).state).toBe('MET');
    expect(evaluateRule(r({ countyCodes: ['MSA'] }), facts()).state).toBe('MISSING');
    expect(evaluateRule(r({ countyCodes: ['NBI'] }), facts({ countyCode: null })).state).toBe(
      'MISSING',
    );
    const none = evaluateRule(
      r({ countryCode: 'KE' }),
      facts({ countryCode: null, countyCode: null }),
    );
    expect(none.state).toBe('MISSING');
    expect(none.fix?.path).toBe('/profile');
  });

  it('DISCIPLINE_IN: any discipline of the member matches', () => {
    const r = rule({ ruleType: 'DISCIPLINE_IN', params: { disciplineIds: [D1, D2] } });
    expect(evaluateRule(r, facts()).state).toBe('MET');
    expect(evaluateRule(r, facts({ disciplineIds: new Set([S1]) })).state).toBe('MISSING');
  });

  it('SKILL_IN: any (default) and all', () => {
    const any = rule({ ruleType: 'SKILL_IN', params: { skillIds: [S1, S2], mode: 'any' } });
    const all = rule({ ruleType: 'SKILL_IN', params: { skillIds: [S1, S2], mode: 'all' } });
    expect(evaluateRule(any, facts()).state).toBe('MET');
    const missing = evaluateRule(all, facts());
    expect(missing.state).toBe('MISSING');
    expect(missing.detail).toBe('You have 1 of 2 of these skills.');
    expect(missing.fix?.path).toBe('/skills');
    expect(evaluateRule(all, facts({ skillIds: new Set([S1, S2]) })).state).toBe('MET');
  });

  it('MIN_PROJECTS counts published projects and links to the new project editor', () => {
    const r = rule({ ruleType: 'MIN_PROJECTS', params: { count: 3 } });
    const res = evaluateRule(r, facts({ projectCount: 1 }));
    expect(res.state).toBe('MISSING');
    expect(res.detail).toBe('You have 1 of 3 published projects.');
    expect(res.fix?.path).toBe('/portfolio/new/edit');
    expect(evaluateRule(r, facts({ projectCount: 3 })).state).toBe('MET');
  });

  it('rules Atarah cannot check are UNKNOWN, never guessed', () => {
    const age = evaluateRule(
      rule({ ruleType: 'AGE_RANGE', params: { min: 18, max: 35 } }),
      facts(),
    );
    expect(age.state).toBe('UNKNOWN');
    const doc = evaluateRule(
      rule({ ruleType: 'DOCUMENT', params: { document: 'ARTIST_STATEMENT' } }),
      facts(),
    );
    expect(doc.state).toBe('UNKNOWN');
    expect(doc.fix?.path).toBe('/soon/p2?name=Artist%20statement');
    expect(evaluateRule(rule({ ruleType: 'CUSTOM_TEXT', params: {} }), facts()).state).toBe(
      'UNKNOWN',
    );
  });

  it('a met rule has no fix link', () => {
    const r = evaluateRule(rule({ ruleType: 'MIN_PROJECTS', params: { count: 1 } }), facts());
    expect(r.state).toBe('MET');
    expect(r.fix).toBeNull();
  });

  it('summarises: missing 2 requirements, ready, unchecked, no rules', () => {
    const rules: RuleInput[] = [
      rule({ id: 'a', ruleType: 'MIN_PROJECTS', params: { count: 5 } }),
      rule({ id: 'b', ruleType: 'SKILL_IN', params: { skillIds: [S2] } }),
      rule({ id: 'c', ruleType: 'DISCIPLINE_IN', params: { disciplineIds: [D1] } }),
      rule({ id: 'd', ruleType: 'AGE_RANGE', params: { min: 18 } }),
    ];
    const gap = evaluateRules(rules, facts());
    expect(gap).toMatchObject({
      verdict: 'MISSING',
      metCount: 1,
      missingCount: 2,
      unknownCount: 1,
      blockingMissingCount: 2,
    });
    expect(gap.rules.map((r) => r.state)).toEqual(['MISSING', 'MISSING', 'MET', 'UNKNOWN']);

    const advice = evaluateRules(
      [rule({ ruleType: 'MIN_PROJECTS', params: { count: 5 }, isBlocking: false })],
      facts(),
    );
    expect(advice.blockingMissingCount).toBe(0);
    expect(advice.missingCount).toBe(1);

    expect(evaluateRules(rules.slice(2, 3), facts()).verdict).toBe('READY');
    expect(evaluateRules(rules.slice(3), facts()).verdict).toBe('UNCHECKED');
    expect(evaluateRules([], facts()).verdict).toBe('NO_RULES');
  });

  it('is computed only from the facts it is given', () => {
    // The engine takes one member's facts and the rule; there is no input through which another member's data could enter.
    const out = evaluateRules([rule({ ruleType: 'MIN_PROJECTS', params: { count: 1 } })], facts());
    expect(JSON.stringify(out)).not.toMatch(/userId|email|handle/);
  });
});

describe('rule params validation', () => {
  it.each([
    ['RESIDENCY', {}],
    ['RESIDENCY', { countryCode: 'KENYA' }],
    ['AGE_RANGE', {}],
    ['AGE_RANGE', { min: 40, max: 20 }],
    ['DISCIPLINE_IN', { disciplineIds: [] }],
    ['DISCIPLINE_IN', { disciplineIds: ['nope'] }],
    ['SKILL_IN', { skillIds: [S1], mode: 'some' }],
    ['MIN_PROJECTS', { count: 0 }],
    ['DOCUMENT', { document: 'PASSPORT' }],
    ['CUSTOM_TEXT', { extra: 1 }],
  ] as const)('rejects %s %j', (type, params) => {
    expect(code(() => parseRuleParams(type, params))).toBe('VALIDATION_ERROR');
  });

  it('normalises good params', () => {
    expect(parseRuleParams('RESIDENCY', { countryCode: 'ke', countyCodes: ['nbi'] })).toEqual({
      countryCode: 'KE',
      countyCodes: ['NBI'],
    });
    expect(parseRuleParams('SKILL_IN', { skillIds: [S1] })).toEqual({
      skillIds: [S1],
      mode: 'any',
    });
    expect(parseRuleParams('MIN_PROJECTS', { count: 3 })).toEqual({ count: 3 });
  });
});

describe('tracking state machine', () => {
  it('goes forward one step or skips ahead, never back', () => {
    expect(nextTracking(null, { status: 'SAVED' })).toBe('create');
    expect(nextTracking(null, { status: 'APPLIED' })).toBe('create');
    expect(nextTracking('SAVED', { status: 'IN_PROGRESS' })).toBe('advance');
    expect(nextTracking('SAVED', { status: 'APPLIED' })).toBe('advance');
    expect(nextTracking('IN_PROGRESS', { status: 'APPLIED' })).toBe('advance');
    expect(nextTracking('APPLIED', { status: 'COMPLETED', outcome: 'AWARDED' })).toBe('advance');
    expect(nextTracking('APPLIED', { status: 'APPLIED' })).toBe('same');
    expect(code(() => nextTracking('APPLIED', { status: 'SAVED' }))).toBe('INVALID_STATE');
    expect(code(() => nextTracking('APPLIED', { status: 'IN_PROGRESS' }))).toBe('INVALID_STATE');
    expect(code(() => nextTracking('COMPLETED', { status: 'APPLIED' }))).toBe('INVALID_STATE');
  });

  it('COMPLETED is reachable only from APPLIED', () => {
    expect(code(() => nextTracking(null, { status: 'COMPLETED' }))).toBe('INVALID_STATE');
    expect(code(() => nextTracking('SAVED', { status: 'COMPLETED' }))).toBe('INVALID_STATE');
    expect(code(() => nextTracking('IN_PROGRESS', { status: 'COMPLETED' }))).toBe('INVALID_STATE');
  });

  it('an outcome belongs to COMPLETED only', () => {
    expect(code(() => nextTracking('SAVED', { status: 'APPLIED', outcome: 'AWARDED' }))).toBe(
      'VALIDATION_ERROR',
    );
  });

  it('un-saving is allowed only from SAVED', () => {
    expect(() => assertCanUnsave('SAVED')).not.toThrow();
    for (const s of ['IN_PROGRESS', 'APPLIED', 'COMPLETED'] as const) {
      expect(code(() => assertCanUnsave(s))).toBe('INVALID_STATE');
    }
  });
});

describe('closing soon and deadlines', () => {
  it('counts whole days, rounding up', () => {
    expect(daysLeft(null, NOW)).toBeNull();
    expect(daysLeft(inDays(7), NOW)).toBe(7);
    expect(daysLeft(new Date(NOW.getTime() + 3_600_000), NOW)).toBe(1);
  });

  it('7 days or fewer is URGENT (coral), 8 to 14 is SOON (tangerine), beyond is nothing', () => {
    expect(urgencyFor(inDays(1), NOW, null)).toBe('URGENT');
    expect(urgencyFor(inDays(7), NOW, 'SAVED')).toBe('URGENT');
    expect(urgencyFor(inDays(8), NOW, null)).toBe('SOON');
    expect(urgencyFor(inDays(14), NOW, 'IN_PROGRESS')).toBe('SOON');
    expect(urgencyFor(inDays(15), NOW, null)).toBeNull();
    expect(urgencyFor(null, NOW, null)).toBeNull();
    expect(urgencyFor(inDays(-1), NOW, null)).toBeNull();
  });

  it('is not shown once the member applied or completed', () => {
    expect(urgencyFor(inDays(3), NOW, 'APPLIED')).toBeNull();
    expect(urgencyFor(inDays(3), NOW, 'COMPLETED')).toBeNull();
  });

  it('open means published with a future or no deadline', () => {
    expect(isOpen({ status: 'PUBLISHED', deadlineAt: null }, NOW)).toBe(true);
    expect(isOpen({ status: 'PUBLISHED', deadlineAt: inDays(1) }, NOW)).toBe(true);
    expect(isOpen({ status: 'PUBLISHED', deadlineAt: inDays(-1) }, NOW)).toBe(false);
    expect(isOpen({ status: 'CLOSED', deadlineAt: inDays(5) }, NOW)).toBe(false);
  });

  it('reminders count Nairobi calendar days', () => {
    // 08:00 EAT on 24 Oct is 05:00 UTC. A deadline of 23:59 EAT on 31 Oct (20:59 UTC) is 7 days away.
    const eight = new Date('2026-10-24T05:00:00Z');
    expect(eatDaysUntil(new Date('2026-10-31T20:59:00Z'), eight)).toBe(7);
    expect(eatDaysUntil(new Date('2026-10-25T20:59:00Z'), eight)).toBe(1);
    // 22:00 UTC on 24 Oct is already 25 Oct in Nairobi.
    expect(eatDaysUntil(new Date('2026-10-25T22:00:00Z'), eight)).toBe(2);
    expect(eatDaysUntil(new Date('2026-10-24T12:00:00Z'), eight)).toBe(0);
  });
});

describe('publication and trust transitions', () => {
  it('allows the lifecycle moves staff make and refuses the rest', () => {
    expect(assertTransition('publish', 'DRAFT')).toBe('PUBLISHED');
    expect(assertTransition('publish', 'PENDING_REVIEW')).toBe('PUBLISHED');
    expect(assertTransition('close', 'PUBLISHED')).toBe('CLOSED');
    expect(assertTransition('reject', 'PENDING_REVIEW')).toBe('DRAFT');
    expect(code(() => assertTransition('publish', 'REMOVED'))).toBe('INVALID_STATE');
    expect(code(() => assertTransition('publish', 'ARCHIVED'))).toBe('INVALID_STATE');
    expect(code(() => assertTransition('close', 'DRAFT'))).toBe('INVALID_STATE');
    expect(code(() => assertTransition('reject', 'PUBLISHED'))).toBe('INVALID_STATE');
  });
});

describe('display helpers', () => {
  const v = (
    min: number | null,
    max: number | null,
    text: string | null = null,
    cur: string | null = 'KES',
  ) => ({
    valueMinMinor: min === null ? null : BigInt(min * 100),
    valueMaxMinor: max === null ? null : BigInt(max * 100),
    valueCurrency: cur,
    valueText: text,
  });

  it('formats the value', () => {
    expect(valueLabel(v(500000, 500000))).toBe('KES 500,000');
    expect(valueLabel(v(100000, 500000))).toBe('KES 100,000 to 500,000');
    expect(valueLabel(v(null, 2000000))).toBe('Up to KES 2,000,000');
    expect(valueLabel(v(50000, null))).toBe('From KES 50,000');
    expect(valueLabel(v(null, null, 'Paid stipend'))).toBe('Paid stipend');
    expect(valueLabel(v(null, null))).toBeNull();
  });

  it('names the domain a member leaves for', () => {
    expect(applicationDomain('EXTERNAL_WEBSITE', 'https://www.Example.org/apply?x=1', null)).toBe(
      'example.org',
    );
    expect(applicationDomain('EMAIL', null, 'jobs@studio.co.ke')).toBe('studio.co.ke');
    expect(applicationDomain('EXTERNAL_WEBSITE', null, null)).toBeNull();
  });

  it('only accepts https application links without credentials', () => {
    expect(parseApplicationUrl(' https://example.org/apply ').hostname).toBe('example.org');
    for (const bad of [
      'http://example.org',
      'ftp://example.org',
      'https://u:p@example.org',
      'not a url',
      'https://intranet',
    ]) {
      expect(code(() => parseApplicationUrl(bad))).toBe('VALIDATION_ERROR');
    }
  });

  it('makes tidy slugs', () => {
    expect(slugify('  Africa Creative Fund — 2026 Call! ')).toBe('africa-creative-fund-2026-call');
    expect(slugify('***')).toBe('opportunity');
  });
});

describe('CSV import', () => {
  const HEADER =
    'title,provider,type,summary,application_url,deadline,county,work_mode,value_min,value_max,currency,disciplines,requirements';
  const GOOD =
    'Film Fund 2027,Kenya Film Commission,GRANT,Support for new short films from Kenyan directors.,https://kfc.example.org/apply,2099-03-31,Nairobi,ONSITE,100000,500000,KES,Film,"Kenyan resident|A finished script"';

  it('parses quoted fields, doubled quotes, embedded commas and line breaks, and a BOM', () => {
    const rows = parseCsv('﻿a,b\r\n"x, y","say ""hi"""\r\n"line\nbreak",z\r\n');
    expect(rows).toEqual([
      ['a', 'b'],
      ['x, y', 'say "hi"'],
      ['line\nbreak', 'z'],
    ]);
  });

  it('accepts a valid row and converts amounts, dates and lists', () => {
    const report = validateImport(`${HEADER}\n${GOOD}`, new Date('2026-10-24T00:00:00Z'));
    expect(report.issues).toEqual([]);
    expect(report.validCount).toBe(1);
    const row = report.rows[0]!;
    expect(row.type).toBe('GRANT');
    expect(row.valueMinMinor).toBe(10_000_000n);
    expect(row.valueMaxMinor).toBe(50_000_000n);
    expect(row.deadlineAt?.toISOString()).toBe('2099-03-31T20:59:00.000Z');
    expect(row.requirements).toEqual(['Kenyan resident', 'A finished script']);
    expect(row.applicationUrl).toBe('https://kfc.example.org/apply');
  });

  it('reports every bad row by line and keeps the good ones', () => {
    const bad = [
      'Hi,,NOPE,short,http://insecure.example.org,2001-01-01,,SIDEWAYS,5,1,KES,,',
      GOOD,
    ].join('\n');
    const report = validateImport(`${HEADER}\n${bad}`, new Date('2026-10-24T00:00:00Z'));
    expect(report.totalCount).toBe(2);
    expect(report.validCount).toBe(1);
    const cols = report.issues.filter((i) => i.line === 2).map((i) => i.column);
    expect(cols).toEqual(
      expect.arrayContaining([
        'title',
        'provider',
        'type',
        'summary',
        'application_url',
        'deadline',
        'work_mode',
        'value_min',
      ]),
    );
    expect(report.issues.every((i) => i.line === 2)).toBe(true);
  });

  it('rejects a file with a missing required column', () => {
    const report = validateImport('title,provider\nA,B');
    expect(report.validCount).toBe(0);
    expect(report.issues[0]!.message).toMatch(/Missing columns: type, summary, application_url/);
  });
});
