export type Appearance = 'system' | 'light' | 'dark';

export const APPEARANCE_KEY = 'atarah-admin-appearance';

export const isAppearance = (v: unknown): v is Appearance =>
  v === 'system' || v === 'light' || v === 'dark';

/** Stored choice; 'system' when nothing (valid) is stored or storage is unavailable. */
export function readAppearance(): Appearance {
  try {
    const v = window.localStorage.getItem(APPEARANCE_KEY);
    return isAppearance(v) ? v : 'system';
  } catch {
    return 'system';
  }
}

/** 'system' removes the override so the prefers-color-scheme media query applies. */
export function applyAppearance(value: Appearance, root: HTMLElement = document.documentElement) {
  if (value === 'system') root.removeAttribute('data-theme');
  else root.setAttribute('data-theme', value);
}

/** Runs before first paint (inline in <head>) so there is no flash. Keep in sync with the helpers above. */
export const appearanceInitScript = `try{var v=localStorage.getItem('${APPEARANCE_KEY}');if(v==='light'||v==='dark')document.documentElement.setAttribute('data-theme',v)}catch(e){}`;
