/** Public configuration for the marketing site. Only `NEXT_PUBLIC_` values reach the browser. */

export const siteUrl = (): string => process.env.NEXT_PUBLIC_SITE_URL ?? 'https://atarah.app';

export interface StoreLinks {
  enabled: boolean;
  playStore?: string;
  appStore?: string;
}

/**
 * App store links stay behind a flag until the apps are published. With the flag off (the default) the
 * page says the apps are coming soon and links nowhere, so there is never a dead button.
 */
export function storeLinks(env: Record<string, string | undefined> = process.env): StoreLinks {
  const enabled = env.NEXT_PUBLIC_STORE_LINKS_ENABLED === 'true';
  const playStore = env.NEXT_PUBLIC_PLAY_STORE_URL || undefined;
  const appStore = env.NEXT_PUBLIC_APP_STORE_URL || undefined;
  return { enabled: enabled && Boolean(playStore || appStore), playStore, appStore };
}

export const apiBaseUrl = (): string => process.env.ATARAH_API_BASE_URL ?? 'http://localhost:3000';
