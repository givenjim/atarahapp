import { NextResponse, type NextRequest } from 'next/server';
import { LOGIN_NOTICES } from '@/lib/auth-errors';
import { supabaseServer } from '@/lib/supabase/server';

/**
 * Ends the session and returns to sign-in with a notice. Server Components cannot clear cookies, so they
 * redirect here when the API rejects the session (idle timeout, not staff).
 */
export async function GET(request: NextRequest) {
  const supabase = await supabaseServer();
  await supabase.auth.signOut();
  const reason = request.nextUrl.searchParams.get('reason') ?? '';
  const target = new URL('/login', request.url);
  if (reason in LOGIN_NOTICES) target.searchParams.set('reason', reason);
  return NextResponse.redirect(target);
}
