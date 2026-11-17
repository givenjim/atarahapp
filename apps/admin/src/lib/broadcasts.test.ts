import { describe, expect, it } from 'vitest';
import {
  audienceBody,
  BODY_MAX,
  broadcastMessage,
  broadcastStatusMeta,
  canBroadcast,
  canCancelBroadcast,
  emptyBroadcastForm,
  formatWhen,
  isInAppPath,
  parseBroadcastStatus,
  targetSummary,
  timingLine,
  TITLE_MAX,
  toBroadcastPayload,
  validateBroadcastForm,
  type BroadcastForm,
} from './broadcasts';

const NOW = new Date('2026-11-03T06:00:00Z').getTime();

const form = (over: Partial<BroadcastForm> = {}): BroadcastForm => ({
  ...emptyBroadcastForm(),
  title: 'New opportunities this week',
  body: 'Twelve new listings were added. Take a look before they close.',
  ...over,
});

describe('broadcast form validation', () => {
  it('accepts a good broadcast to everyone', () => {
    expect(validateBroadcastForm(form(), NOW)).toBeNull();
  });

  it('checks the title and message lengths', () => {
    expect(validateBroadcastForm(form({ title: 'ab' }), NOW)).toMatch(/title/);
    expect(validateBroadcastForm(form({ title: 'x'.repeat(TITLE_MAX + 1) }), NOW)).toMatch(/title/);
    expect(validateBroadcastForm(form({ body: ' ' }), NOW)).toMatch(/message/);
    expect(validateBroadcastForm(form({ body: 'x'.repeat(BODY_MAX + 1) }), NOW)).toMatch(/message/);
  });

  it('only allows in-app paths as the link', () => {
    expect(isInAppPath('/opportunities')).toBe(true);
    expect(isInAppPath('/learning/courses/abc')).toBe(true);
    for (const bad of [
      'opportunities',
      '//evil.example.com',
      'https://evil.example.com',
      '/a b',
      '/a\\b',
    ]) {
      expect(isInAppPath(bad)).toBe(false);
      expect(validateBroadcastForm(form({ deepLink: bad }), NOW)).toMatch(/in-app path/);
    }
    expect(validateBroadcastForm(form({ deepLink: '/opportunities' }), NOW)).toBeNull();
  });

  it('needs a chosen audience for a role, a discipline or a county', () => {
    expect(validateBroadcastForm(form({ target: 'ROLE' }), NOW)).toBe('Choose the role.');
    expect(validateBroadcastForm(form({ target: 'DISCIPLINE' }), NOW)).toBe(
      'Choose the discipline.',
    );
    expect(validateBroadcastForm(form({ target: 'COUNTY' }), NOW)).toBe('Choose the county.');
    expect(validateBroadcastForm(form({ target: 'COUNTY', targetValue: 'c1' }), NOW)).toBeNull();
  });

  it('scheduling needs a real time in the future (Nairobi time)', () => {
    expect(validateBroadcastForm(form({ when: 'later' }), NOW)).toMatch(/date and time/);
    // 2026-11-03T08:00 Nairobi is 05:00 UTC, an hour before NOW (06:00 UTC).
    expect(
      validateBroadcastForm(form({ when: 'later', scheduledLocal: '2026-11-03T08:00' }), NOW),
    ).toMatch(/future/);
    expect(
      validateBroadcastForm(form({ when: 'later', scheduledLocal: '2026-11-03T12:00' }), NOW),
    ).toBeNull();
  });
});

describe('broadcast payload', () => {
  it('sends the minimum for a broadcast to everyone, right now', () => {
    expect(toBroadcastPayload(form())).toEqual({
      title: 'New opportunities this week',
      body: 'Twelve new listings were added. Take a look before they close.',
      category: 'SYSTEM',
      target: 'ALL',
    });
  });

  it('adds the audience, link and schedule only when they apply', () => {
    const p = toBroadcastPayload(
      form({
        target: 'ROLE',
        targetValue: 'MENTOR',
        deepLink: ' /opportunities ',
        category: 'OPPORTUNITIES',
        when: 'later',
        scheduledLocal: '2026-12-01T09:00',
      }),
    );
    expect(p).toMatchObject({
      target: 'ROLE',
      targetValue: 'MENTOR',
      deepLink: '/opportunities',
      category: 'OPPORTUNITIES',
      // 09:00 in Nairobi is 06:00 UTC.
      scheduledAt: '2026-12-01T06:00:00.000Z',
    });
    // A value left over from another target is not sent for ALL.
    expect(toBroadcastPayload(form({ target: 'ALL', targetValue: 'stale' }))).not.toHaveProperty(
      'targetValue',
    );
    expect(
      toBroadcastPayload(form({ when: 'now', scheduledLocal: '2026-12-01T09:00' })),
    ).not.toHaveProperty('scheduledAt');
  });

  it('builds the audience preview body from the target alone', () => {
    expect(audienceBody({ target: 'ALL', targetValue: 'x' })).not.toHaveProperty('targetValue');
    expect(audienceBody({ target: 'COUNTY', targetValue: 'c1' })).toMatchObject({
      target: 'COUNTY',
      targetValue: 'c1',
    });
  });
});

describe('labels and status', () => {
  it('summarises the audience', () => {
    expect(targetSummary({ target: 'ALL' })).toBe('Every member');
    expect(targetSummary({ target: 'ROLE', targetLabel: 'Mentor', targetValue: 'MENTOR' })).toBe(
      'Members with a role: Mentor',
    );
    expect(targetSummary({ target: 'COUNTY', targetLabel: null, targetValue: 'c1' })).toBe(
      'Members in a county: c1',
    );
  });

  it('names statuses and says what can be cancelled', () => {
    expect(broadcastStatusMeta('SCHEDULED')).toEqual({ label: 'Scheduled', tone: 'warning' });
    expect(broadcastStatusMeta('SENT').tone).toBe('success');
    expect(broadcastStatusMeta('WEIRD').label).toBe('Weird');
    expect(parseBroadcastStatus('SENT')).toBe('SENT');
    expect(parseBroadcastStatus('nope')).toBeUndefined();
    expect(canCancelBroadcast('SCHEDULED')).toBe(true);
    for (const s of ['SENDING', 'SENT', 'CANCELLED']) expect(canCancelBroadcast(s)).toBe(false);
  });

  it('shows times in Nairobi time', () => {
    expect(formatWhen('2026-12-01T06:00:00.000Z')).toBe('2026-12-01 09:00 EAT');
    expect(formatWhen(null)).toBe('—');
    expect(formatWhen('garbage')).toBe('—');
    expect(timingLine({ status: 'SCHEDULED', scheduledAt: '2026-12-01T06:00:00.000Z' })).toBe(
      'Scheduled for 2026-12-01 09:00 EAT',
    );
    expect(timingLine({ status: 'SENT', sentAt: '2026-12-01T06:05:00.000Z' })).toBe(
      'Sent 2026-12-01 09:05 EAT',
    );
    expect(timingLine({ status: 'CANCELLED' })).toMatch(/Cancelled/);
    expect(timingLine({ status: 'SENDING' })).toBe('Sending now');
  });

  it('gates the section on the permission and words API errors kindly', () => {
    expect(canBroadcast(['admin.access', 'notification.broadcast'])).toBe(true);
    expect(canBroadcast(['admin.access', 'help.manage'])).toBe(false);
    expect(broadcastMessage(403, 'x')).toMatch(/permission/);
    expect(broadcastMessage(404, 'x')).toMatch(/no longer exists/);
    expect(broadcastMessage(409, 'Already sent.')).toBe('Already sent.');
    expect(broadcastMessage(400, 'Pick a time in the future.')).toBe('Pick a time in the future.');
  });
});
