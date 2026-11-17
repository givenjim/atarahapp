import { describe, expect, it } from 'vitest';
import { supabaseConfig } from './config';

describe('supabaseConfig', () => {
  it('returns the public URL and publishable key', () => {
    expect(
      supabaseConfig({
        NEXT_PUBLIC_SUPABASE_URL: 'http://127.0.0.1:55321',
        NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY: 'sb_publishable_x',
      }),
    ).toEqual({ url: 'http://127.0.0.1:55321', publishableKey: 'sb_publishable_x' });
  });

  it('fails loudly when either value is missing', () => {
    expect(() => supabaseConfig({ NEXT_PUBLIC_SUPABASE_URL: 'http://x' })).toThrow(
      /PUBLISHABLE_KEY/,
    );
    expect(() => supabaseConfig({})).toThrow(/NEXT_PUBLIC_SUPABASE_URL/);
  });
});
