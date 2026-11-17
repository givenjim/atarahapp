import { describe, expect, it } from 'vitest';
import {
  actionsFor,
  buildRuleParams,
  canVerify,
  csvTemplate,
  CSV_COLUMNS,
  deadlineToIso,
  emptyForm,
  emptyRule,
  formatDeadline,
  formFromDto,
  isoToDeadline,
  moveRule,
  opportunityMessage,
  providerPayload,
  ruleFromDto,
  statusMeta,
  toPayload,
  trustMeta,
  validateOppForm,
  validateProvider,
  validateRule,
  type OppDtoLike,
  type OppForm,
} from './opportunities';

const D1 = '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b';
const S1 = '5b4d0e3a-7c6f-4081-8c3d-2e1f9a8b7c6d';

const filled = (over: Partial<OppForm> = {}): OppForm => ({
  ...emptyForm(),
  title: 'Emerging Creatives Grant',
  providerId: D1,
  summary: 'Seed grants for early-career creatives.',
  applicationUrl: 'https://fund.example.org/apply',
  ...over,
});

describe('labels and gating', () => {
  it('labels statuses and trust levels the way members see them', () => {
    expect(statusMeta('PENDING_REVIEW')).toEqual({ label: 'Pending review', tone: 'warning' });
    expect(statusMeta('PUBLISHED').tone).toBe('success');
    expect(statusMeta('REMOVED').tone).toBe('danger');
    expect(statusMeta('SOMETHING_NEW').label).toBe('Something new');
    expect(trustMeta('VERIFIED').label).toBe('Verified by Atarah');
    expect(trustMeta('SOURCE_CONFIRMED').label).toBe('Source confirmed');
    expect(trustMeta('EXTERNAL_SOURCE').label).toBe('External source');
  });

  it('only opportunity.verify unlocks the Verified badge', () => {
    expect(canVerify(['admin.access', 'opportunity.manage'])).toBe(false);
    expect(canVerify(['admin.access', 'opportunity.manage', 'opportunity.verify'])).toBe(true);
    expect(canVerify([])).toBe(false);
  });

  it('offers only the moves the API allows for a status', () => {
    expect(actionsFor('DRAFT')).toEqual(['publish', 'archive', 'remove']);
    expect(actionsFor('PENDING_REVIEW')).toEqual(['publish', 'archive', 'remove', 'reject']);
    expect(actionsFor('PUBLISHED')).toEqual(['close', 'archive', 'remove', 'feature']);
    expect(actionsFor('CLOSED')).toEqual(['publish', 'archive', 'remove']);
    expect(actionsFor('ARCHIVED')).toEqual(['remove']);
    expect(actionsFor('REMOVED')).toEqual([]);
  });

  it('turns API answers into plain wording', () => {
    expect(opportunityMessage(403, 'x')).toBe('You do not have permission to do that.');
    expect(opportunityMessage(404, 'x')).toMatch(/no longer exists/);
    expect(opportunityMessage(409, 'A draft cannot be closed.')).toBe('A draft cannot be closed.');
    expect(opportunityMessage(400, 'Bad.')).toBe('Bad.');
  });
});

describe('deadlines in Nairobi time', () => {
  it('converts a local value to an instant and back', () => {
    expect(deadlineToIso('2026-12-31T23:59')).toBe('2026-12-31T20:59:00.000Z');
    expect(isoToDeadline('2026-12-31T20:59:00.000Z')).toBe('2026-12-31T23:59');
    expect(isoToDeadline(deadlineToIso('2027-03-01T00:00'))).toBe('2027-03-01T00:00');
  });

  it('empty is a rolling deadline', () => {
    expect(deadlineToIso('')).toBeNull();
    expect(isoToDeadline(null)).toBe('');
    expect(formatDeadline(null)).toBe('Rolling');
    expect(formatDeadline('2026-12-31T20:59:00.000Z')).toBe('2026-12-31 23:59 EAT');
  });
});

describe('rule params builders', () => {
  const rule = (type: Parameters<typeof emptyRule>[0], over: Record<string, unknown> = {}) => ({
    ...emptyRule(type),
    label: 'A rule',
    ...over,
  });

  it('RESIDENCY: upper-cases the country and splits county codes', () => {
    expect(
      buildRuleParams(rule('RESIDENCY', { countryCode: 'ke', countyCodes: 'nbi, msa kis' })),
    ).toEqual({
      countryCode: 'KE',
      countyCodes: ['NBI', 'MSA', 'KIS'],
    });
    expect(buildRuleParams(rule('RESIDENCY', { countryCode: '', countyCodes: '' }))).toEqual({});
  });

  it('AGE_RANGE sends numbers and omits blanks', () => {
    expect(buildRuleParams(rule('AGE_RANGE', { min: '18', max: '35' }))).toEqual({
      min: 18,
      max: 35,
    });
    expect(buildRuleParams(rule('AGE_RANGE', { min: '18', max: '' }))).toEqual({ min: 18 });
  });

  it('the other types', () => {
    expect(buildRuleParams(rule('DISCIPLINE_IN', { disciplineIds: [D1] }))).toEqual({
      disciplineIds: [D1],
    });
    expect(buildRuleParams(rule('SKILL_IN', { skillIds: [S1], mode: 'all' }))).toEqual({
      skillIds: [S1],
      mode: 'all',
    });
    expect(buildRuleParams(rule('MIN_PROJECTS', { count: '3' }))).toEqual({ count: 3 });
    expect(buildRuleParams(rule('DOCUMENT', { document: 'CV' }))).toEqual({ document: 'CV' });
    expect(buildRuleParams(rule('CUSTOM_TEXT'))).toEqual({});
  });

  it('validates a row before it is sent', () => {
    expect(validateRule({ ...rule('MIN_PROJECTS'), label: 'x' })).toMatch(/label/);
    expect(validateRule(rule('MIN_PROJECTS', { count: '0' }))).toMatch(/1 to 100/);
    expect(validateRule(rule('MIN_PROJECTS', { count: '3' }))).toBeNull();
    expect(validateRule(rule('RESIDENCY', { countryCode: '' }))).toMatch(
      /country or at least one county/,
    );
    expect(validateRule(rule('RESIDENCY', { countryCode: 'KEN' }))).toMatch(/two letters/);
    expect(validateRule(rule('RESIDENCY', { countryCode: '', countyCodes: 'NB' }))).toMatch(
      /three letters/,
    );
    expect(validateRule(rule('AGE_RANGE'))).toMatch(/minimum or a maximum/);
    expect(validateRule(rule('AGE_RANGE', { min: '40', max: '20' }))).toMatch(/cannot be above/);
    expect(validateRule(rule('DISCIPLINE_IN'))).toMatch(/at least one discipline/);
    expect(validateRule(rule('SKILL_IN'))).toMatch(/at least one skill/);
    expect(validateRule(rule('CUSTOM_TEXT'))).toBeNull();
  });

  it('reorders without mutating and stays in bounds', () => {
    const list = ['a', 'b', 'c'];
    expect(moveRule(list, 1, -1)).toEqual(['b', 'a', 'c']);
    expect(moveRule(list, 1, 1)).toEqual(['a', 'c', 'b']);
    expect(moveRule(list, 0, -1)).toEqual(['a', 'b', 'c']);
    expect(moveRule(list, 2, 1)).toEqual(['a', 'b', 'c']);
    expect(list).toEqual(['a', 'b', 'c']);
  });

  it('reads a stored rule back into the editor', () => {
    const d = ruleFromDto({
      ruleType: 'RESIDENCY',
      params: { countryCode: 'KE', countyCodes: ['NBI', 'MSA'] },
      label: 'Based in Kenya',
      isBlocking: false,
    });
    expect(d).toMatchObject({
      ruleType: 'RESIDENCY',
      countryCode: 'KE',
      countyCodes: 'NBI, MSA',
      isBlocking: false,
    });
    expect(buildRuleParams(d)).toEqual({ countryCode: 'KE', countyCodes: ['NBI', 'MSA'] });
    expect(
      ruleFromDto({
        ruleType: 'SKILL_IN',
        params: { skillIds: [S1], mode: 'all' },
        label: 'Skills',
        isBlocking: true,
      }),
    ).toMatchObject({
      skillIds: [S1],
      mode: 'all',
    });
  });
});

describe('opportunity form', () => {
  it('validates the essentials', () => {
    expect(validateOppForm(filled({ title: 'Hi' }), 'create')).toMatch(/title/);
    expect(validateOppForm(filled({ providerId: '' }), 'create')).toMatch(/provider/i);
    expect(validateOppForm(filled({ summary: 'short' }), 'create')).toMatch(/summary/);
    expect(validateOppForm(filled({ applicationUrl: '' }), 'create')).toMatch(/web address/);
    expect(validateOppForm(filled({ applicationUrl: '' }), 'edit')).toBeNull();
    expect(
      validateOppForm(filled({ applicationUrl: 'http://insecure.example.org' }), 'create'),
    ).toMatch(/https/);
    expect(
      validateOppForm(filled({ applicationMethod: 'EMAIL', applicationEmail: 'nope' }), 'create'),
    ).toMatch(/email/);
    expect(validateOppForm(filled({ valueMin: '500', valueMax: '100' }), 'create')).toMatch(
      /smallest/,
    );
    expect(validateOppForm(filled({ valueMin: 'abc' }), 'create')).toMatch(/positive numbers/);
    expect(validateOppForm(filled({ valueMin: '10', valueCurrency: 'K' }), 'create')).toMatch(
      /three-letter/,
    );
    expect(validateOppForm(filled({ sourceUrl: 'ftp://x.example.org' }), 'create')).toMatch(
      /source link/,
    );
    expect(
      validateOppForm(
        filled({ rules: [{ ...emptyRule('MIN_PROJECTS'), label: 'Projects', count: '0' }] }),
        'create',
      ),
    ).toMatch(/1 to 100/);
    expect(validateOppForm(filled(), 'create')).toBeNull();
  });

  it('sends money as major units, never cents, and the deadline as an instant', () => {
    const body = toPayload(
      filled({
        valueMin: '100,000',
        valueMax: '500000',
        valueCurrency: 'kes',
        deadline: '2026-12-31T23:59',
      }),
      'create',
    );
    expect(body).toMatchObject({
      valueMin: 100000,
      valueMax: 500000,
      valueCurrency: 'KES',
      deadlineAt: '2026-12-31T20:59:00.000Z',
    });
  });

  it('creating omits empty optional fields; editing clears them explicitly', () => {
    const create = toPayload(filled(), 'create');
    for (const k of [
      'valueMin',
      'valueMax',
      'valueCurrency',
      'valueText',
      'countyId',
      'sourceUrl',
    ]) {
      expect(create).not.toHaveProperty(k);
    }
    expect(create.deadlineAt).toBeNull();
    const edit = toPayload(filled(), 'edit');
    expect(edit).toMatchObject({
      valueMin: null,
      valueMax: null,
      valueText: null,
      countyId: null,
      sourceUrl: '',
    });
    expect(edit).not.toHaveProperty('valueCurrency');
  });

  it('drops blank list items and sends only the chosen application route', () => {
    const body = toPayload(filled({ requirements: ['A', ' ', 'B '], benefits: [''] }), 'create');
    expect(body.requirements).toEqual(['A', 'B']);
    expect(body.benefits).toEqual([]);
    expect(body).toHaveProperty('applicationUrl', 'https://fund.example.org/apply');
    expect(body).not.toHaveProperty('applicationEmail');
    const mail = toPayload(
      filled({
        applicationMethod: 'EMAIL',
        applicationEmail: ' jobs@studio.co.ke ',
        applicationUrl: 'https://old.example.org',
      }),
      'edit',
    );
    expect(mail).toMatchObject({
      applicationMethod: 'EMAIL',
      applicationEmail: 'jobs@studio.co.ke',
    });
    expect(mail).not.toHaveProperty('applicationUrl');
  });

  it('includes the rules with built params, in order', () => {
    const body = toPayload(
      filled({
        rules: [
          { ...emptyRule('MIN_PROJECTS'), label: ' Projects ', count: '2' },
          { ...emptyRule('CUSTOM_TEXT'), label: 'Read the call', isBlocking: false },
        ],
      }),
      'create',
    );
    expect(body.rules).toEqual([
      { ruleType: 'MIN_PROJECTS', params: { count: 2 }, label: 'Projects', isBlocking: true },
      { ruleType: 'CUSTOM_TEXT', params: {}, label: 'Read the call', isBlocking: false },
    ]);
  });

  it('round-trips an API listing through the form', () => {
    const dto: OppDtoLike = {
      title: 'Film Fund',
      provider: { id: D1 },
      type: 'FUNDING',
      summary: 'A fund for new short films.',
      about: 'More',
      requirements: ['Kenyan resident'],
      benefits: [],
      valueMin: 100000,
      valueMax: 250000,
      valueCurrency: 'KES',
      valueText: null,
      deadlineAt: '2026-12-31T20:59:00.000Z',
      countyId: null,
      workMode: 'HYBRID',
      applicationMethod: 'EXTERNAL_WEBSITE',
      applicationUrl: 'https://fund.example.org/apply',
      applicationEmail: null,
      sourceUrl: null,
      disciplineIds: [D1],
      rules: [
        { ruleType: 'MIN_PROJECTS', params: { count: 1 }, label: 'One project', isBlocking: true },
      ],
    };
    const form = formFromDto(dto);
    expect(form).toMatchObject({
      valueMin: '100000',
      deadline: '2026-12-31T23:59',
      benefits: [''],
      workMode: 'HYBRID',
    });
    const body = toPayload(form, 'edit');
    expect(body).toMatchObject({
      title: 'Film Fund',
      providerId: D1,
      valueMin: 100000,
      valueMax: 250000,
      deadlineAt: '2026-12-31T20:59:00.000Z',
      disciplineIds: [D1],
    });
  });
});

describe('providers and the CSV template', () => {
  it('validates and builds provider bodies', () => {
    expect(validateProvider({ name: 'A', type: 'NGO', website: '', ownerUserId: '' })).toMatch(
      /name/,
    );
    expect(
      validateProvider({
        name: 'Kilifi Arts',
        type: 'NGO',
        website: 'http://x.org',
        ownerUserId: '',
      }),
    ).toMatch(/https/);
    expect(
      validateProvider({ name: 'Kilifi Arts', type: 'NGO', website: '', ownerUserId: 'abc' }),
    ).toMatch(/UUID/);
    expect(
      validateProvider({
        name: 'Kilifi Arts',
        type: 'NGO',
        website: 'https://kilifi.example.org',
        ownerUserId: D1,
      }),
    ).toBeNull();
    expect(
      providerPayload(
        { name: ' Kilifi Arts ', type: 'NGO', website: '', ownerUserId: '' },
        'create',
      ),
    ).toEqual({
      name: 'Kilifi Arts',
      type: 'NGO',
    });
    expect(
      providerPayload({ name: 'Kilifi Arts', type: 'NGO', website: '', ownerUserId: '' }, 'edit'),
    ).toEqual({
      name: 'Kilifi Arts',
      type: 'NGO',
      website: null,
      ownerUserId: null,
    });
  });

  it('the template has every column once, plus one example row', () => {
    const [header, example] = csvTemplate().trim().split('\n');
    expect(header!.split(',')).toEqual([...CSV_COLUMNS]);
    expect(header).toBe(
      'title,provider,type,summary,about,deadline,county,work_mode,application_url,source_url,value_min,value_max,currency,value_text,disciplines,requirements,benefits',
    );
    expect(example).toContain('Film / Video|Photography');
    expect(example).toContain('Kenyan resident|Two finished projects');
  });
});
