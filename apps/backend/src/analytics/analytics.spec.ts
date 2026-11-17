import {
  EVENT_NAMES,
  EVENT_SCHEMAS,
  isAnonymousEvent,
  lengthBucket,
  resultBucket,
} from './analytics.events';
import { eatDate } from './analytics.service';

const ID = '3f2b8c1e-5a4d-4e6f-8a1b-0c9d7e6f5a4b';

describe('analytics catalogue', () => {
  it('covers every event of the Phase 1 catalogue', () => {
    expect([...EVENT_NAMES].sort()).toEqual(
      [
        'connection_created',
        'course_completed',
        'course_started',
        'onboarding_completed',
        'opportunity_applied',
        'opportunity_saved',
        'opportunity_viewed',
        'post_created',
        'profile_completed',
        'project_created',
        'registration',
        'search_performed',
      ].sort(),
    );
  });

  it('accepts the documented props', () => {
    expect(EVENT_SCHEMAS.registration.safeParse({ method: 'phone' }).success).toBe(true);
    expect(EVENT_SCHEMAS.post_created.safeParse({ audience: 'GROUP', inGroup: true }).success).toBe(
      true,
    );
    expect(
      EVENT_SCHEMAS.opportunity_saved.safeParse({ opportunityId: ID, type: 'GRANT' }).success,
    ).toBe(true);
    expect(EVENT_SCHEMAS.course_started.safeParse({ courseId: ID }).success).toBe(true);
    expect(
      EVENT_SCHEMAS.search_performed.safeParse({
        scope: 'all',
        results: 'few',
        queryLength: 'short',
      }).success,
    ).toBe(true);
  });

  it.each([
    ['registration', { method: 'email', email: 'a@b.co' }],
    ['registration', { method: 'fax' }],
    ['project_created', { title: 'My secret project' }],
    ['post_created', { audience: 'MEMBERS', inGroup: false, body: 'text' }],
    ['opportunity_viewed', { opportunityId: 'not-a-uuid', type: 'GRANT' }],
    ['opportunity_viewed', { opportunityId: ID, type: 'NOT_A_TYPE' }],
    [
      'search_performed',
      { scope: 'all', results: 'many', queryLength: 'short', q: 'what they typed' },
    ],
    ['search_performed', { scope: 'everything', results: 'many', queryLength: 'short' }],
    ['course_completed', { courseId: ID, userName: 'Tess' }],
  ] as const)(
    'refuses %s with props %j (no free text, no extra keys, no identity)',
    (name, props) => {
      expect(EVENT_SCHEMAS[name].safeParse(props).success).toBe(false);
    },
  );

  it('records registration without an actor and everything else with a hashed one', () => {
    expect(isAnonymousEvent('registration')).toBe(true);
    for (const n of EVENT_NAMES.filter((e) => e !== 'registration'))
      expect(isAnonymousEvent(n)).toBe(false);
  });

  it('turns counts and lengths into coarse buckets', () => {
    expect([0, 1, 5, 6, 400].map(resultBucket)).toEqual(['none', 'few', 'few', 'many', 'many']);
    expect([2, 6, 7, 20, 21].map(lengthBucket)).toEqual([
      'short',
      'short',
      'medium',
      'medium',
      'long',
    ]);
  });

  it('dates events by the Nairobi calendar day', () => {
    expect(eatDate(new Date('2026-10-24T20:59:00Z'))).toBe('2026-10-24');
    expect(eatDate(new Date('2026-10-24T21:00:00Z'))).toBe('2026-10-25');
  });
});
