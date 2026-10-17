import { ApiException } from '../common/api.exception';
import { assertNotSelf, assertOwner, canView, visibleOrNull } from './visibility.policy';

describe('canView (ownership and visibility)', () => {
  const owner = 'owner-1';
  const stranger = { viewerId: 'someone-else', isMember: true };
  const anon = { isMember: false };
  const self = { viewerId: owner, isMember: true };

  it.each([
    ['PUBLIC', anon, true],
    ['PUBLIC', stranger, true],
    ['MEMBERS', anon, false],
    ['MEMBERS', stranger, true],
    ['PRIVATE', anon, false],
    ['PRIVATE', stranger, false],
  ] as const)('%s is visible to %j: %s', (visibility, viewer, expected) => {
    expect(canView(visibility, owner, viewer)).toBe(expected);
  });

  it('always lets the owner see their own data, even PRIVATE', () => {
    expect(canView('PRIVATE', owner, self)).toBe(true);
    expect(canView('MEMBERS', owner, self)).toBe(true);
  });

  it('does not treat a signed-in non-member session as a member', () => {
    expect(canView('MEMBERS', owner, { viewerId: 'x', isMember: false })).toBe(false);
  });

  it('visibleOrNull returns null for hidden fields', () => {
    expect(visibleOrNull('+254700000001', 'PRIVATE', owner, stranger)).toBeNull();
    expect(visibleOrNull('Nairobi', 'MEMBERS', owner, stranger)).toBe('Nairobi');
  });
});

describe('ownership and self-action rules', () => {
  it('assertOwner passes for the owner and throws FORBIDDEN otherwise', () => {
    expect(() => assertOwner('a', 'a')).not.toThrow();
    expect(() => assertOwner('a', 'b')).toThrow(ApiException);
  });

  it('assertNotSelf blocks granting roles or verifying one’s own skill or opportunity', () => {
    expect(() => assertNotSelf('a', 'b', 'grant a role to')).not.toThrow();
    try {
      assertNotSelf('a', 'a', 'verify');
      fail('expected a throw');
    } catch (err) {
      expect((err as ApiException).getStatus()).toBe(403);
      expect((err as ApiException).details).toEqual({ reason: 'SELF_ACTION' });
    }
  });
});
