import { describe, expect, it } from 'vitest';
import { visibleNav } from './nav';
import {
  actionMeta,
  actionNeedsReason,
  communityMessage,
  formatAge,
  isBacklog,
  isUuid,
  validateAnnouncement,
  validateDecision,
  validateGroup,
} from './moderation';

describe('moderation helpers', () => {
  it('needs a reason for everything except a dismissal', () => {
    expect(actionNeedsReason('NO_ACTION')).toBe(false);
    expect(actionNeedsReason('HIDE_CONTENT')).toBe(true);
    expect(validateDecision({ action: 'NO_ACTION', reason: '' })).toBeNull();
    expect(validateDecision({ action: 'HIDE_CONTENT', reason: 'no' })).toMatch(/at least 5/);
    expect(validateDecision({ action: 'HIDE_CONTENT', reason: 'x'.repeat(501) })).toMatch(/500/);
    expect(validateDecision({ action: 'WARN_USER', reason: 'Abusive wording' })).toBeNull();
  });

  it('checks the restriction length', () => {
    const base = { action: 'RESTRICT_ACCOUNT', reason: 'Repeated spam' };
    expect(validateDecision({ ...base, restrictDays: 7 })).toBeNull();
    expect(validateDecision({ ...base })).toBeNull();
    expect(validateDecision({ ...base, restrictDays: 0 })).toMatch(/1 to 365/);
    expect(validateDecision({ ...base, restrictDays: 366 })).toMatch(/1 to 365/);
    expect(validateDecision({ ...base, restrictDays: 1.5 })).toMatch(/whole number/);
  });

  it('flags open cases older than 48 hours as backlog', () => {
    expect(isBacklog(47, 'SUBMITTED')).toBe(false);
    expect(isBacklog(48, 'IN_REVIEW')).toBe(true);
    expect(isBacklog(200, 'RESOLVED')).toBe(false);
  });

  it('formats age', () => {
    expect(formatAge(0.2)).toBe('under 1 h');
    expect(formatAge(5.9)).toBe('5 h');
    expect(formatAge(72)).toBe('3 d');
  });

  it('describes known actions and tolerates unknown ones', () => {
    expect(actionMeta('SUSPEND_ACCOUNT').effect).toMatch(/authenticator/);
    expect(actionMeta('NEW_THING').label).toBe('NEW_THING');
  });

  it('validates announcements and groups', () => {
    expect(validateAnnouncement('  ', '')).toMatch(/Write/);
    expect(validateAnnouncement('Hello', 'nope')).toMatch(/Choose a group/);
    expect(validateAnnouncement('Hello', '3f0a1c2e-1b2c-4d3e-8f4a-5b6c7d8e9f00')).toBeNull();
    expect(validateGroup({ name: 'A', description: '' }, true)).toMatch(/2 to 80/);
    expect(validateGroup({ name: 'Nairobi', slug: 'Bad Slug', description: '' }, true)).toMatch(
      /lower-case/,
    );
    expect(validateGroup({ name: 'Nairobi', slug: 'nairobi', description: '' }, true)).toBeNull();
    expect(isUuid('3f0a1c2e-1b2c-4d3e-8f4a-5b6c7d8e9f00')).toBe(true);
    expect(isUuid('abc')).toBe(false);
  });

  it('maps API errors to kind messages', () => {
    expect(communityMessage(404, 'x')).toMatch(/no longer exists/);
    expect(communityMessage(409, 'Case is closed')).toBe('Case is closed');
    expect(communityMessage(500, 'Boom')).toBe('Boom');
  });
});

describe('community navigation', () => {
  it('shows each community section only with its permission', () => {
    const slugs = (p: string[]) => visibleNav(p).map((s) => s.slug);
    expect(slugs(['report.view'])).toContain('community');
    expect(slugs(['report.view'])).not.toContain('groups');
    expect(slugs(['community.group.manage'])).toContain('groups');
    expect(slugs(['community.announce'])).toContain('announcements');
    expect(slugs([])).not.toContain('announcements');
  });
});
