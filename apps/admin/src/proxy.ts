import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';
import { gateRequest, type AssuranceLevel } from '@/lib/gate';
import { hardenCookie, supabaseConfig } from '@/lib/supabase/config';

/**
 * Keeps the Supabase session fresh (rotating its httpOnly cookies) and gates every route: no session goes to
 * sign-in, and a session that has not passed the authenticator step (AAL1) can only reach the code page.
 */
export async function proxy(request: NextRequest): Promise<NextResponse> {
  let response = NextResponse.next({ request });
  const { url, publishableKey } = supabaseConfig();
  const supabase = createServerClient(url, publishableKey, {
    cookies: {
      getAll: () => request.cookies.getAll(),
      setAll: (list) => {
        for (const { name, value } of list) request.cookies.set(name, value);
        response = NextResponse.next({ request });
        for (const { name, value, options } of list) {
          response.cookies.set(name, value, hardenCookie(options));
        }
      },
    },
  });

  // getClaims verifies the token's signature and refreshes it when it has expired.
  const { data } = await supabase.auth.getClaims();
  const claims = data?.claims;
  const gate = gateRequest(
    request.nextUrl.pathname,
    claims?.aal as AssuranceLevel,
    Boolean(claims?.sub),
  );
  if (gate.action === 'allow') return response;

  const redirect = NextResponse.redirect(new URL(gate.to, request.url));
  // Carry over any cookies the refresh just wrote.
  for (const cookie of response.cookies.getAll()) redirect.cookies.set(cookie);
  return redirect;
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:png|svg|jpg|ico|woff2?)$).*)'],
};
