import { describe, expect, it } from 'vitest';
import { gateRequest } from './gate';

describe('gateRequest', () => {
  it('sends visitors without a session to sign-in', () => {
    expect(gateRequest('/users', undefined, false)).toEqual({ action: 'redirect', to: '/login' });
    expect(gateRequest('/login/totp', undefined, false)).toEqual({
      action: 'redirect',
      to: '/login',
    });
  });

  it('lets anyone reach sign-in and the sign-out route', () => {
    expect(gateRequest('/login', undefined, false).action).toBe('allow');
    expect(gateRequest('/login', 'aal1', true).action).toBe('allow');
    expect(gateRequest('/auth/exit', 'aal1', true).action).toBe('allow');
  });

  it('keeps an AAL1 session on the code page', () => {
    expect(gateRequest('/', 'aal1', true)).toEqual({ action: 'redirect', to: '/login/totp' });
    expect(gateRequest('/audit-logs', 'aal1', true)).toEqual({
      action: 'redirect',
      to: '/login/totp',
    });
    expect(gateRequest('/login/totp', 'aal1', true).action).toBe('allow');
  });

  it('admits an AAL2 session to the console and bounces it off the code page', () => {
    expect(gateRequest('/users', 'aal2', true).action).toBe('allow');
    expect(gateRequest('/login/totp', 'aal2', true)).toEqual({ action: 'redirect', to: '/' });
  });
});
