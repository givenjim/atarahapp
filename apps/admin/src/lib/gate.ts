/**
 * Route gate for the console, kept free of framework imports so it can be unit tested.
 * Every page except sign-in needs an AAL2 session (password + authenticator code); an AAL1 session may only
 * reach the code step.
 */
export type AssuranceLevel = 'aal1' | 'aal2' | undefined;

export type Gate = { action: 'allow' } | { action: 'redirect'; to: string };

const isPath = (pathname: string, base: string) =>
  pathname === base || pathname.startsWith(`${base}/`);

export function gateRequest(pathname: string, aal: AssuranceLevel, signedIn: boolean): Gate {
  // Signing out must always work, whatever state the session is in.
  if (isPath(pathname, '/auth/exit')) return { action: 'allow' };
  if (pathname === '/login') return { action: 'allow' };
  if (!signedIn) return { action: 'redirect', to: '/login' };
  if (isPath(pathname, '/login/totp')) {
    return aal === 'aal2' ? { action: 'redirect', to: '/' } : { action: 'allow' };
  }
  if (aal !== 'aal2') return { action: 'redirect', to: '/login/totp' };
  return { action: 'allow' };
}
