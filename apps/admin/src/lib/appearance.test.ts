import { afterEach, describe, expect, it } from 'vitest';
import {
  APPEARANCE_KEY,
  appearanceInitScript,
  applyAppearance,
  readAppearance,
} from './appearance';

afterEach(() => {
  window.localStorage.clear();
  document.documentElement.removeAttribute('data-theme');
});

describe('appearance', () => {
  it('defaults to system and ignores invalid stored values', () => {
    expect(readAppearance()).toBe('system');
    window.localStorage.setItem(APPEARANCE_KEY, 'purple');
    expect(readAppearance()).toBe('system');
    window.localStorage.setItem(APPEARANCE_KEY, 'dark');
    expect(readAppearance()).toBe('dark');
  });

  it('sets and clears data-theme', () => {
    applyAppearance('dark');
    expect(document.documentElement.getAttribute('data-theme')).toBe('dark');
    applyAppearance('system');
    expect(document.documentElement.hasAttribute('data-theme')).toBe(false);
  });

  it('the pre-paint script applies a stored choice', () => {
    window.localStorage.setItem(APPEARANCE_KEY, 'light');
    new Function(appearanceInitScript)();
    expect(document.documentElement.getAttribute('data-theme')).toBe('light');
  });
});
