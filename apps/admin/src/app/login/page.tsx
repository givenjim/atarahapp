import { LOGIN_NOTICES } from '@/lib/auth-errors';
import { LoginForm } from './login-form';

export const metadata = { title: 'Sign in' };

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ reason?: string }>;
}) {
  const { reason } = await searchParams;
  const notice = reason ? LOGIN_NOTICES[reason] : undefined;
  return (
    <>
      {notice ? (
        <p className="alert" role="status">
          {notice}
        </p>
      ) : null}
      <LoginForm />
    </>
  );
}
