import { scrub } from './audit.service';

describe('audit scrub', () => {
  it('redacts sensitive keys at any depth and leaves other data intact', () => {
    const out = scrub({
      email: 'a@b.co',
      password: 'hunter2',
      nested: { refreshToken: 'abc', code: '123456', ok: true, list: [{ idNumber: '1234' }] },
    });
    expect(out).toEqual({
      email: 'a@b.co',
      password: '[redacted]',
      nested: {
        refreshToken: '[redacted]',
        code: '[redacted]',
        ok: true,
        list: [{ idNumber: '[redacted]' }],
      },
    });
  });

  it('serialises dates and survives deep structures', () => {
    expect(scrub({ at: new Date('2026-01-01T00:00:00Z') })).toEqual({
      at: '2026-01-01T00:00:00.000Z',
    });
    let deep: Record<string, unknown> = { v: 1 };
    for (let i = 0; i < 20; i++) deep = { child: deep };
    expect(() => scrub(deep)).not.toThrow();
  });
});
