'use client';

import { useEffect, useState } from 'react';
import { APPEARANCE_KEY, applyAppearance, readAppearance, type Appearance } from '@/lib/appearance';

const OPTIONS: { value: Appearance; label: string }[] = [
  { value: 'system', label: 'System' },
  { value: 'light', label: 'Light' },
  { value: 'dark', label: 'Dark' },
];

/** System / Light / Dark. The choice is stored in this browser only. */
export function AppearanceToggle() {
  const [value, setValue] = useState<Appearance>('system');
  useEffect(() => {
    // Read after mount so server and first client render agree.
    const id = window.setTimeout(() => setValue(readAppearance()), 0);
    return () => window.clearTimeout(id);
  }, []);

  const choose = (next: Appearance) => {
    setValue(next);
    try {
      if (next === 'system') window.localStorage.removeItem(APPEARANCE_KEY);
      else window.localStorage.setItem(APPEARANCE_KEY, next);
    } catch {
      /* storage unavailable: the choice applies for this page view only */
    }
    applyAppearance(next);
  };

  return (
    <div className="appearance" role="group" aria-label="Appearance">
      {OPTIONS.map((o) => (
        <button
          key={o.value}
          type="button"
          aria-pressed={value === o.value}
          onClick={() => choose(o.value)}
        >
          {o.label}
        </button>
      ))}
    </div>
  );
}
