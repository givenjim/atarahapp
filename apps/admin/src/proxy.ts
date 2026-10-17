import { NextResponse, type NextRequest } from 'next/server';

const ACCESS_COOKIE = 'atarah_admin_at';
const REFRESH_COOKIE = 'atarah_admin_rt';
const PUBLIC_PREFIXES = ['/login'];

const apiBase = () => process.env.ATARAH_API_BASE_URL ?? 'http://localhost:3000';
const secure = () => process.env.NODE_ENV === 'production';

interface RefreshBody {
  data?: {
    accessToken: string;
    accessTokenExpiresAt: string;
    refreshToken: string;
    refreshTokenExpiresAt: string;
  };
}

function toLogin(request: NextRequest): NextResponse {
  const res = NextResponse.redirect(new URL('/login', request.url));
  res.cookies.delete(ACCESS_COOKIE);
  res.cookies.delete(REFRESH_COOKIE);
  return res;
}

/**
 * Keeps the session alive. The access token is short-lived, so when its cookie has expired but the
 * refresh cookie is present this rotates both and forwards the new values to the page being rendered.
 * Anything without a session is sent to the sign-in page.
 */
export async function proxy(request: NextRequest): Promise<NextResponse> {
  const { pathname } = request.nextUrl;
  if (PUBLIC_PREFIXES.some((p) => pathname === p || pathname.startsWith(`${p}/`))) {
    return NextResponse.next();
  }

  const access = request.cookies.get(ACCESS_COOKIE)?.value;
  if (access) return NextResponse.next();

  const refresh = request.cookies.get(REFRESH_COOKIE)?.value;
  if (!refresh) return toLogin(request);

  let body: RefreshBody;
  try {
    const res = await fetch(`${apiBase()}/api/v1/admin/auth/refresh`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ refreshToken: refresh }),
      cache: 'no-store',
    });
    if (!res.ok) return toLogin(request);
    body = (await res.json()) as RefreshBody;
  } catch {
    return toLogin(request);
  }
  const t = body.data;
  if (!t) return toLogin(request);

  // Make the new tokens visible to the Server Components rendering this very request, and persist them.
  const headers = new Headers(request.headers);
  const jar = request.cookies
    .getAll()
    .filter((c) => c.name !== ACCESS_COOKIE && c.name !== REFRESH_COOKIE)
    .map((c) => `${c.name}=${c.value}`);
  jar.push(`${ACCESS_COOKIE}=${t.accessToken}`, `${REFRESH_COOKIE}=${t.refreshToken}`);
  headers.set('cookie', jar.join('; '));

  const res = NextResponse.next({ request: { headers } });
  const base = { httpOnly: true, sameSite: 'lax' as const, secure: secure(), path: '/' };
  res.cookies.set(ACCESS_COOKIE, t.accessToken, {
    ...base,
    expires: new Date(t.accessTokenExpiresAt),
  });
  res.cookies.set(REFRESH_COOKIE, t.refreshToken, {
    ...base,
    expires: new Date(t.refreshTokenExpiresAt),
  });
  return res;
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:png|svg|jpg|ico|woff2?)$).*)'],
};
