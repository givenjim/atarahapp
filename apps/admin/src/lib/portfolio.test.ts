import { describe, expect, it } from 'vitest';
import { isWebUrl, moderationMessage, validateHideReason } from './portfolio';

describe('hide reason', () => {
  it('accepts 5 to 300 characters after trimming and explains the rest', () => {
    expect(validateHideReason('Spam')).toMatch(/at least 5/);
    expect(validateHideReason('   ab   ')).toMatch(/at least 5/);
    expect(validateHideReason('Spam!')).toBeNull();
    expect(validateHideReason('x'.repeat(300))).toBeNull();
    expect(validateHideReason('x'.repeat(301))).toMatch(/300 characters/);
  });
});

describe('links', () => {
  it('treats only http(s) URLs as links', () => {
    expect(isWebUrl('https://example.com/a')).toBe(true);
    expect(isWebUrl('http://example.com')).toBe(true);
    expect(isWebUrl('javascript:alert(1)')).toBe(false);
    expect(isWebUrl('data:text/html,hi')).toBe(false);
  });
});

describe('moderation messages', () => {
  it('turns a 409 into plain language for each direction', () => {
    expect(moderationMessage(409, 'x', true)).toMatch(/already hidden/);
    expect(moderationMessage(409, 'x', false)).toMatch(/not hidden/);
    expect(moderationMessage(404, 'x', true)).toMatch(/no longer/);
    expect(moderationMessage(500, 'Server said no', true)).toBe('Server said no');
  });
});
