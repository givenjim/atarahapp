import { describe, expect, it } from 'vitest';
import {
  addDays,
  ageLabel,
  assignableRoles,
  buildCharts,
  canRevokeRole,
  chartSummary,
  coerceSetting,
  daysBetween,
  defaultRange,
  eventLabel,
  groupSettings,
  historyLabel,
  nairobiDate,
  niceMax,
  parseRange,
  rangeProblem,
  safeConsolePath,
  shortReason,
  sortQueues,
  suspendPayload,
  validateSuspend,
  type AttentionQueue,
  type RoleInfo,
} from './ops';

const q = (over: Partial<AttentionQueue>): AttentionQueue => ({
  key: 'k',
  label: 'L',
  count: 1,
  priority: 'NORMAL',
  oldestAt: null,
  path: '/x',
  ...over,
});

describe('dashboard helpers', () => {
  it('orders queues by priority, then size, then oldest', () => {
    const out = sortQueues([
      q({ key: 'low', priority: 'LOW', count: 99 }),
      q({ key: 'a', priority: 'HIGH', count: 2 }),
      q({ key: 'urgent', priority: 'URGENT', count: 1 }),
      q({ key: 'b', priority: 'HIGH', count: 5 }),
    ]);
    expect(out.map((x) => x.key)).toEqual(['urgent', 'b', 'a', 'low']);
  });

  it('keeps links inside the console', () => {
    expect(safeConsolePath('/community')).toBe('/community');
    expect(safeConsolePath('//evil.example')).toBe('/');
    expect(safeConsolePath('https://evil.example')).toBe('/');
  });

  it('words ages in the largest unit', () => {
    const now = Date.parse('2026-11-10T12:00:00Z');
    expect(ageLabel('2026-11-10T11:59:40Z', now)).toBe('just now');
    expect(ageLabel('2026-11-10T11:55:00Z', now)).toBe('5 minutes');
    expect(ageLabel('2026-11-10T11:00:00Z', now)).toBe('1 hour');
    expect(ageLabel('2026-11-07T12:00:00Z', now)).toBe('3 days');
    expect(ageLabel(null, now)).toBe('—');
  });
});

describe('analytics range', () => {
  it('uses Nairobi dates', () => {
    expect(nairobiDate(Date.parse('2026-11-10T22:30:00Z'))).toBe('2026-11-11');
    expect(addDays('2026-03-01', -1)).toBe('2026-02-28');
    expect(daysBetween('2026-10-01', '2026-10-31')).toBe(30);
  });

  it('defaults to the last 30 days', () => {
    expect(defaultRange(Date.parse('2026-11-10T09:00:00Z'))).toEqual({
      from: '2026-10-12',
      to: '2026-11-10',
    });
  });

  it('allows at most 120 days and rejects reversed or malformed ranges', () => {
    expect(rangeProblem('2026-07-14', '2026-11-10')).toBeNull(); // exactly 120 days
    expect(rangeProblem('2026-07-13', '2026-11-10')).toMatch(/at most 120/);
    expect(rangeProblem('2026-11-10', '2026-11-01')).toMatch(/before/);
    expect(rangeProblem('', '2026-11-01')).toMatch(/Choose a start/);
    expect(rangeProblem('2026-13-45', '2026-11-01')).toMatch(/Choose a start/);
  });

  it('parses the query string and falls back with the reason', () => {
    const now = Date.parse('2026-11-10T09:00:00Z');
    expect(parseRange({}, now).problem).toBeNull();
    const ok = parseRange(
      { from: '2026-11-01', to: '2026-11-05', names: ['registration', 'bogus'] },
      now,
    );
    expect(ok).toMatchObject({ from: '2026-11-01', to: '2026-11-05', names: ['registration'] });
    const bad = parseRange({ from: '2026-01-01', to: '2026-11-05' }, now);
    expect(bad.problem).toMatch(/at most 120/);
    expect(bad.from).toBe('2026-10-12');
  });

  it('labels events', () => {
    expect(eventLabel('onboarding_completed')).toBe('Onboarding completed');
    expect(eventLabel('new_thing')).toBe('New thing');
  });
});

describe('chart data', () => {
  const data = {
    from: '2026-11-01',
    to: '2026-11-04',
    series: [
      { day: '2026-11-02', name: 'registration', events: 3, actors: 3 },
      { day: '2026-11-04', name: 'registration', events: 7, actors: 6 },
    ],
    totals: [{ name: 'registration', events: 10, activeMemberDays: 9 }],
  };

  it('fills every day, including quiet ones, and builds a chart per name', () => {
    const [c] = buildCharts(data, ['registration']);
    expect(c!.days.map((d) => d.events)).toEqual([0, 3, 0, 7]);
    expect(c).toMatchObject({ total: 10, activeMemberDays: 9, max: 10 });
  });

  it('shows a flat chart for an event with no rows', () => {
    const charts = buildCharts(data, ['registration', 'post_created']);
    expect(charts.map((c) => c.name)).toEqual(['registration', 'post_created']);
    expect(charts[1]!.total).toBe(0);
    expect(chartSummary(charts[1]!)).toMatch(/no events/);
  });

  it('summarises the picture in words', () => {
    expect(chartSummary(buildCharts(data, ['registration'])[0]!)).toBe(
      'Registrations, 2026-11-01 to 2026-11-04: 10 events in total, busiest day 2026-11-04 with 7.',
    );
  });

  it('rounds the axis to 1, 2 or 5 times a power of ten', () => {
    expect([0, 1, 3, 7, 12, 55, 101, 999].map(niceMax)).toEqual([1, 1, 5, 10, 20, 100, 200, 1000]);
  });
});

describe('role and suspension rules', () => {
  const roles: RoleInfo[] = [
    { key: 'MENTOR', name: 'Mentor', description: '', isStaff: false, permissions: [] },
    { key: 'MODERATOR', name: 'Moderator', description: '', isStaff: true, permissions: [] },
  ];

  it('offers staff roles only to a super admin, and never a role already held', () => {
    expect(assignableRoles(roles, ['role.assign'], []).map((r) => r.key)).toEqual(['MENTOR']);
    expect(
      assignableRoles(roles, ['role.assign', 'admin.manage'], ['MENTOR']).map((r) => r.key),
    ).toEqual(['MODERATOR']);
    expect(assignableRoles(roles, ['user.view'], [])).toEqual([]);
  });

  it('shows Revoke by permission, staff-ness and self', () => {
    expect(canRevokeRole({ isStaff: false }, ['role.assign'], false)).toBe(true);
    expect(canRevokeRole({ isStaff: true }, ['role.assign'], false)).toBe(false);
    expect(canRevokeRole({ isStaff: true }, ['role.assign', 'admin.manage'], false)).toBe(true);
    expect(canRevokeRole({ isStaff: false }, ['role.assign'], true)).toBe(false);
    expect(canRevokeRole({ isStaff: false }, [], false)).toBe(false);
  });

  it('validates suspension and builds the payload', () => {
    expect(validateSuspend({ reason: 'no', days: '' })).toMatch(/at least 5/);
    expect(validateSuspend({ reason: 'Harassment', days: '0' })).toMatch(/1 to 365/);
    expect(validateSuspend({ reason: 'Harassment', days: '366' })).toMatch(/1 to 365/);
    expect(validateSuspend({ reason: 'Harassment', days: '2.5' })).toMatch(/whole number/);
    expect(validateSuspend({ reason: 'Harassment', days: '' })).toBeNull();
    expect(suspendPayload({ reason: ' Harassment ', days: '30' })).toEqual({
      reason: 'Harassment',
      durationDays: 30,
    });
    expect(suspendPayload({ reason: 'Harassment', days: ' ' })).toEqual({ reason: 'Harassment' });
  });

  it('words audit actions', () => {
    expect(historyLabel('user.suspend')).toBe('Suspended');
    expect(historyLabel('user.something_new')).toBe('User something new');
  });
});

describe('settings and jobs', () => {
  it('accepts only values of the same kind', () => {
    expect(coerceSetting('number', ' 250 ')).toEqual({ ok: true, value: 250 });
    expect(coerceSetting('number', 'abc')).toEqual({ ok: false, error: 'Enter a number.' });
    expect(coerceSetting('number', '')).toMatchObject({ ok: false });
    expect(coerceSetting('boolean', 'false')).toEqual({ ok: true, value: false });
    expect(coerceSetting('boolean', 'yes')).toMatchObject({ ok: false });
    expect(coerceSetting('string', 'x')).toEqual({ ok: true, value: 'x' });
    expect(coerceSetting('string', '  ')).toMatchObject({ ok: false });
  });

  it('groups settings by their first segment', () => {
    const s = (key: string) => ({ key, value: 1, description: null, updatedAt: '' });
    const g = groupSettings([s('membership.a'), s('learning.b'), s('membership.c'), s('solo')]);
    expect(g.map((x) => [x.group, x.items.length])).toEqual([
      ['general', 1],
      ['learning', 1],
      ['membership', 2],
    ]);
  });

  it('shortens failure reasons to their first line', () => {
    expect(shortReason('Boom\n  at stack')).toBe('Boom');
    expect(shortReason('x'.repeat(200)).length).toBe(160);
  });
});
