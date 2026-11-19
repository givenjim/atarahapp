import {
  generateSlots,
  isValidTimeZone,
  localDateString,
  localToUtc,
  nextAvailability,
  type SlotQuery,
} from './availability';

const base = (over: Partial<SlotQuery> = {}): SlotQuery => ({
  rules: [{ weekday: 1, startMinute: 9 * 60, endMinute: 12 * 60 }], // Mondays 09:00-12:00 local
  timeZone: 'Africa/Nairobi',
  exceptionDates: new Set(),
  busy: [],
  durationMinutes: 60,
  from: new Date('2026-11-23T00:00:00Z'), // a Monday
  to: new Date('2026-11-30T00:00:00Z'),
  now: new Date('2026-11-20T00:00:00Z'),
  minNoticeMinutes: 12 * 60,
  stepMinutes: 30,
  ...over,
});

const iso = (ds: Date[]) => ds.map((d) => d.toISOString());

describe('mentor availability', () => {
  it('converts Nairobi wall-clock time to UTC (UTC+3, no DST)', () => {
    expect(localToUtc(2026, 11, 23, 9 * 60, 'Africa/Nairobi').toISOString()).toBe(
      '2026-11-23T06:00:00.000Z',
    );
  });

  it('generates slots on the mentor weekday in the mentor zone', () => {
    const slots = iso(generateSlots(base()));
    // 09:00, 09:30, 10:00, 10:30, 11:00 start a 60-minute session that ends by 12:00 (EAT = UTC+3)
    expect(slots).toEqual([
      '2026-11-23T06:00:00.000Z',
      '2026-11-23T06:30:00.000Z',
      '2026-11-23T07:00:00.000Z',
      '2026-11-23T07:30:00.000Z',
      '2026-11-23T08:00:00.000Z',
    ]);
  });

  it('respects a mentor in another zone and its daylight saving offset', () => {
    // London: Monday 2026-03-30 is BST (UTC+1); Monday 2026-03-23 is GMT (UTC+0).
    const london = base({
      timeZone: 'Europe/London',
      from: new Date('2026-03-22T00:00:00Z'),
      to: new Date('2026-04-02T00:00:00Z'),
      now: new Date('2026-03-01T00:00:00Z'),
      rules: [{ weekday: 1, startMinute: 10 * 60, endMinute: 11 * 60 }],
    });
    const slots = iso(generateSlots(london));
    expect(slots).toEqual(['2026-03-23T10:00:00.000Z', '2026-03-30T09:00:00.000Z']);
  });

  it('puts a late-evening New York slot on the next UTC day', () => {
    const ny = base({
      timeZone: 'America/New_York',
      from: new Date('2026-11-23T00:00:00Z'),
      to: new Date('2026-11-25T00:00:00Z'),
      rules: [{ weekday: 1, startMinute: 20 * 60, endMinute: 21 * 60 }],
    });
    // 20:00 EST (UTC-5) Monday is 01:00 UTC Tuesday.
    expect(iso(generateSlots(ny))).toEqual(['2026-11-24T01:00:00.000Z']);
  });

  it('drops a whole local date listed as an exception', () => {
    const slots = generateSlots(base({ exceptionDates: new Set(['2026-11-23']) }));
    expect(slots).toHaveLength(0);
  });

  it('removes slots that overlap a booking and keeps the touching ones', () => {
    const busy = [
      { start: new Date('2026-11-23T07:00:00Z'), end: new Date('2026-11-23T08:00:00Z') },
    ];
    const slots = iso(generateSlots(base({ busy })));
    // 06:00 and 06:30 fit before... 06:30 ends 07:30 which overlaps; 08:00 starts exactly when the booking ends.
    expect(slots).toEqual(['2026-11-23T06:00:00.000Z', '2026-11-23T08:00:00.000Z']);
  });

  it('applies the minimum notice', () => {
    const slots = generateSlots(
      base({ now: new Date('2026-11-23T00:00:00Z'), minNoticeMinutes: 7 * 60 }),
    );
    // earliest = 07:00 UTC
    expect(iso(slots)[0]).toBe('2026-11-23T07:00:00.000Z');
  });

  it('never returns slots before from, after to, or when there are no rules', () => {
    expect(generateSlots(base({ rules: [] }))).toEqual([]);
    expect(generateSlots(base({ to: new Date('2026-11-23T06:00:00Z') }))).toEqual([]);
  });

  it('finds the next availability, skipping an exception week', () => {
    const q = base({
      from: new Date('2026-11-20T00:00:00Z'),
      to: new Date('2026-12-31T00:00:00Z'),
      exceptionDates: new Set(['2026-11-23']),
    });
    expect(nextAvailability(q)?.toISOString()).toBe('2026-11-30T06:00:00.000Z');
  });

  it('returns null when nothing is bookable in the window', () => {
    expect(nextAvailability(base({ rules: [] }))).toBeNull();
  });

  it('validates time zones and reads local dates', () => {
    expect(isValidTimeZone('Africa/Nairobi')).toBe(true);
    expect(isValidTimeZone('Mars/Olympus')).toBe(false);
    expect(localDateString('Pacific/Auckland', new Date('2026-11-23T12:30:00Z'))).toBe(
      '2026-11-24',
    );
  });
});
