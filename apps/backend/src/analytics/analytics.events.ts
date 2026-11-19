import { OpportunityType, PostAudience } from '@prisma/client';
import { z } from 'zod';

/**
 * The analytics event catalogue (P1-M12). Every event has a strict props schema: only ids of content, enum values
 * and coarse buckets are accepted, never free text, names, contact details or search words. An event that does not
 * match its schema is dropped (and logged) instead of stored, so a careless call site cannot leak personal data.
 */
const id = z.uuid();
const oppType = z.enum(Object.values(OpportunityType) as [string, ...string[]]);
const cvFormat = z.enum(['CV', 'BIO', 'EPK', 'DECK']);

export const EVENT_SCHEMAS = {
  registration: z.object({ method: z.enum(['email', 'phone', 'unknown']) }).strict(),
  onboarding_completed: z.object({}).strict(),
  profile_completed: z.object({}).strict(),
  project_created: z.object({}).strict(),
  post_created: z
    .object({
      audience: z.enum(Object.values(PostAudience) as [string, ...string[]]),
      inGroup: z.boolean(),
    })
    .strict(),
  connection_created: z.object({}).strict(),
  opportunity_viewed: z.object({ opportunityId: id, type: oppType }).strict(),
  opportunity_saved: z.object({ opportunityId: id, type: oppType }).strict(),
  opportunity_applied: z.object({ opportunityId: id, type: oppType }).strict(),
  course_started: z.object({ courseId: id }).strict(),
  course_completed: z.object({ courseId: id }).strict(),
  search_performed: z
    .object({
      /** The kind searched ("all" when none was chosen). Never the words. */
      scope: z.enum([
        'all',
        'creatives',
        'articles',
        'posts',
        'opportunities',
        'learning',
        'marketplace',
        'mentors',
      ]),
      results: z.enum(['none', 'few', 'many']),
      queryLength: z.enum(['short', 'medium', 'long']),
    })
    .strict(),
  // Creative CV / EPK (P2-M7): only the format, never the document, the link or who looked.
  cv_generated: z.object({ format: cvFormat }).strict(),
  cv_downloaded: z.object({ format: cvFormat }).strict(),
  cv_shared: z.object({ format: cvFormat }).strict(),
  cv_viewed: z.object({ format: cvFormat }).strict(),
} as const;

export type AnalyticsEventName = keyof typeof EVENT_SCHEMAS;
export type AnalyticsProps<N extends AnalyticsEventName> = z.input<(typeof EVENT_SCHEMAS)[N]>;

export const EVENT_NAMES = Object.keys(EVENT_SCHEMAS) as AnalyticsEventName[];

/** Events with no actor: counting them needs no member identity at all. */
const ANONYMOUS: ReadonlySet<AnalyticsEventName> = new Set(['registration']);
export const isAnonymousEvent = (n: AnalyticsEventName): boolean => ANONYMOUS.has(n);

export const resultBucket = (n: number): 'none' | 'few' | 'many' =>
  n <= 0 ? 'none' : n <= 5 ? 'few' : 'many';
export const lengthBucket = (len: number): 'short' | 'medium' | 'long' =>
  len <= 6 ? 'short' : len <= 20 ? 'medium' : 'long';

/** Retention of raw events; the daily roll-up is kept longer. */
export const EVENT_RETENTION_DAYS = 400;
/** Longest range an admin chart may ask for. */
export const MAX_RANGE_DAYS = 120;
