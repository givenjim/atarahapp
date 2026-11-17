import { type OpportunityRuleType } from '@prisma/client';
import { z } from 'zod';
import { ApiException } from '../common/api.exception';

/**
 * Structured eligibility rules (P1-M9). A rule's `params` are validated per type when staff save it, and evaluated
 * here against the viewer's own profile facts. Nothing in this file reads the database or another member's data.
 */

const uuidList = (max: number) => z.array(z.uuid()).min(1).max(max);

export const RULE_PARAMS = {
  RESIDENCY: z
    .object({
      /** ISO 3166-1 alpha-2, e.g. KE. */
      countryCode: z.string().length(2).toUpperCase().optional(),
      /** Atarah county codes, e.g. NBI. The member's county must be one of them. */
      countyCodes: z.array(z.string().length(3).toUpperCase()).min(1).max(50).optional(),
    })
    .refine((v) => v.countryCode !== undefined || v.countyCodes !== undefined, {
      message: 'Name a country or at least one county.',
    }),
  AGE_RANGE: z
    .object({
      min: z.number().int().min(10).max(120).optional(),
      max: z.number().int().min(10).max(120).optional(),
    })
    .refine((v) => v.min !== undefined || v.max !== undefined, {
      message: 'Give a minimum or a maximum age.',
    })
    .refine((v) => v.min === undefined || v.max === undefined || v.min <= v.max, {
      message: 'The minimum age cannot be above the maximum.',
    }),
  DISCIPLINE_IN: z.object({ disciplineIds: uuidList(20) }),
  SKILL_IN: z.object({
    skillIds: uuidList(30),
    /** `any` (default): one of the skills is enough. `all`: every skill is needed. */
    mode: z.enum(['any', 'all']).default('any'),
  }),
  MIN_PROJECTS: z.object({ count: z.number().int().min(1).max(100) }),
  DOCUMENT: z.object({
    document: z.enum(['CV', 'BIO', 'EPK', 'DECK', 'ARTIST_STATEMENT']),
  }),
  CUSTOM_TEXT: z.object({}).strict(),
} as const satisfies Record<OpportunityRuleType, z.ZodType>;

export const RULE_TYPES = Object.keys(RULE_PARAMS) as OpportunityRuleType[];

/** Validates and normalises a rule's params, answering with a field-level 422 the admin form can show. */
export function parseRuleParams(
  type: OpportunityRuleType,
  params: unknown,
): Record<string, unknown> {
  const schema = RULE_PARAMS[type];
  const parsed = schema.safeParse(params ?? {});
  if (!parsed.success) {
    throw ApiException.validation(
      parsed.error.issues[0]?.message ?? 'Those rule settings are not valid.',
      { field: 'params' },
    );
  }
  return parsed.data as Record<string, unknown>;
}

// ---- evaluation -----------------------------------------------------------------------------------------------

/** What the engine knows about the signed-in member. Built by the service; never contains anyone else's data. */
export interface ViewerFacts {
  countryCode: string | null;
  countyCode: string | null;
  disciplineIds: ReadonlySet<string>;
  skillIds: ReadonlySet<string>;
  /** Published projects (not deleted, not hidden). */
  projectCount: number;
}

export type RuleState = 'MET' | 'MISSING' | 'UNKNOWN';

export interface RuleInput {
  id: string;
  ruleType: OpportunityRuleType;
  params: unknown;
  label: string;
  isBlocking: boolean;
}

/** An in-app path the member can follow to fix a missing requirement. Null when nothing in the app can fix it. */
export interface RuleFix {
  label: string;
  path: string;
}

export interface RuleResult {
  id: string;
  ruleType: OpportunityRuleType;
  label: string;
  isBlocking: boolean;
  state: RuleState;
  /** Plain-language reason, shown under the row ("You have 1 of 3 projects"). */
  detail: string | null;
  fix: RuleFix | null;
}

const soon = (name: string): RuleFix => ({
  label: 'Soon',
  path: `/soon/p2?name=${encodeURIComponent(name)}`,
});

const DOCUMENT_NAMES: Record<string, string> = {
  CV: 'Creative CV',
  BIO: 'Artist biography',
  EPK: 'Electronic press kit',
  DECK: 'Portfolio presentation',
  ARTIST_STATEMENT: 'Artist statement',
};

const n = (v: unknown): number => (typeof v === 'number' ? v : 0);
const list = (v: unknown): string[] =>
  Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string') : [];

export function evaluateRule(rule: RuleInput, facts: ViewerFacts): RuleResult {
  const base = {
    id: rule.id,
    ruleType: rule.ruleType,
    label: rule.label,
    isBlocking: rule.isBlocking,
  };
  const params = (rule.params ?? {}) as Record<string, unknown>;
  const result = (state: RuleState, detail: string | null, fix: RuleFix | null): RuleResult => ({
    ...base,
    state,
    detail,
    fix: state === 'MET' ? null : fix,
  });

  switch (rule.ruleType) {
    case 'RESIDENCY': {
      const country = typeof params.countryCode === 'string' ? params.countryCode : null;
      const counties = list(params.countyCodes);
      const fix = { label: 'Add', path: '/profile' };
      if (facts.countryCode === null && facts.countyCode === null) {
        return result('MISSING', 'Add where you are based to your profile.', fix);
      }
      if (country && facts.countryCode && facts.countryCode !== country) {
        return result('MISSING', null, fix);
      }
      if (counties.length > 0) {
        if (facts.countyCode === null) {
          return result('MISSING', 'Add your county to your profile.', fix);
        }
        return counties.includes(facts.countyCode)
          ? result('MET', null, null)
          : result('MISSING', null, fix);
      }
      return facts.countryCode === null
        ? result('MISSING', 'Add your country to your profile.', fix)
        : result('MET', null, null);
    }
    case 'AGE_RANGE':
      // Atarah does not collect a date of birth, so age can only be confirmed by the provider.
      return result('UNKNOWN', 'Atarah cannot check this. The provider will confirm it.', null);
    case 'DISCIPLINE_IN': {
      const wanted = list(params.disciplineIds);
      const hit = wanted.some((id) => facts.disciplineIds.has(id));
      return result(hit ? 'MET' : 'MISSING', hit ? null : 'None of your disciplines match.', {
        label: 'Add',
        path: '/profile',
      });
    }
    case 'SKILL_IN': {
      const wanted = list(params.skillIds);
      const have = wanted.filter((id) => facts.skillIds.has(id)).length;
      const ok = params.mode === 'all' ? have === wanted.length : have > 0;
      return result(
        ok ? 'MET' : 'MISSING',
        ok ? null : `You have ${have} of ${wanted.length} of these skills.`,
        { label: 'Add', path: '/skills' },
      );
    }
    case 'MIN_PROJECTS': {
      const need = n(params.count);
      const ok = facts.projectCount >= need;
      return result(
        ok ? 'MET' : 'MISSING',
        ok ? null : `You have ${facts.projectCount} of ${need} published projects.`,
        { label: 'Add', path: '/portfolio/new/edit' },
      );
    }
    case 'DOCUMENT': {
      const name = DOCUMENT_NAMES[String(params.document)] ?? 'Document';
      // Creative documents arrive in Phase 2, so this can only be confirmed later.
      return result('UNKNOWN', `${name} needed. Documents arrive soon.`, soon(name));
    }
    case 'CUSTOM_TEXT':
      return result('UNKNOWN', 'Atarah cannot check this. Read the listing for details.', null);
  }
}

export type EligibilityVerdict = 'READY' | 'MISSING' | 'UNCHECKED' | 'NO_RULES';

export interface ProfileGap {
  /**
   * READY: every checkable rule is met. MISSING: something checkable is not met. UNCHECKED: nothing could be
   * checked. NO_RULES: the listing sets no structured requirements.
   */
  verdict: EligibilityVerdict;
  metCount: number;
  missingCount: number;
  unknownCount: number;
  /** Missing blocking rules: the count the card headline quotes ("missing 2 requirements"). */
  blockingMissingCount: number;
  rules: RuleResult[];
}

export function evaluateRules(rules: RuleInput[], facts: ViewerFacts): ProfileGap {
  const results = rules.map((r) => evaluateRule(r, facts));
  const count = (s: RuleState) => results.filter((r) => r.state === s).length;
  const missing = count('MISSING');
  const met = count('MET');
  const unknown = count('UNKNOWN');
  const verdict: EligibilityVerdict =
    rules.length === 0 ? 'NO_RULES' : missing > 0 ? 'MISSING' : met > 0 ? 'READY' : 'UNCHECKED';
  return {
    verdict,
    metCount: met,
    missingCount: missing,
    unknownCount: unknown,
    blockingMissingCount: results.filter((r) => r.state === 'MISSING' && r.isBlocking).length,
    rules: results,
  };
}
