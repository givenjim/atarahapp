import { type DynamicModule, type INestApplication, type Type } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { type AccountStatus, type MembershipStatus, type RoleKey } from '@prisma/client';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { generateSync } from 'otplib';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/configure-app';
import { DevOutbox } from '../src/messaging/dev-providers';
import { PrismaService } from '../src/prisma/prisma.service';
import { runReferenceSeed } from '../prisma/seed/reference';
import { StorageService } from '../src/storage/storage.service';
import { SupabaseAdminService } from '../src/supabase/supabase-admin.service';
import { applyTestEnv } from './test-env';

export const PASSWORD = 'Passw0rd-test-1';

export async function createTestApp(
  extraImports: Array<Type<unknown> | DynamicModule> = [],
  options: { realStorage?: boolean } = {},
): Promise<INestApplication> {
  applyTestEnv();
  let builder = Test.createTestingModule({ imports: [AppModule, ...extraImports] });
  // Most suites do not touch object storage. Suites that do pass `realStorage` and use the local Supabase Storage.
  if (!options.realStorage) {
    builder = builder
      .overrideProvider(StorageService)
      .useValue({ onModuleInit: async () => undefined, check: async () => undefined });
  }
  const moduleRef = await builder.compile();
  const app = moduleRef.createNestApplication({ rawBody: true });
  configureApp(app, { useLogger: false });
  await app.init();
  // Roles, permissions and plans come from the real reference seed.
  await runReferenceSeed(app.get(PrismaService));
  return app;
}

let counter = 0;
export const uniq = (): string => `${Date.now().toString(36)}${(counter++).toString(36)}`;
export const emailFor = (label = 'user'): string => `${label}.${uniq()}@test.atarah.local`;

export interface MakeUserOptions {
  email?: string;
  phone?: string | null;
  password?: string;
  status?: AccountStatus;
  roles?: RoleKey[];
  /** Create a membership with this status on the PRO plan. */
  membership?: { status: MembershipStatus; periodEndInDays: number | null };
  fullName?: string;
}

/** A real Supabase Auth user (created through the admin API; the database trigger creates `users`). */
export async function makeUser(app: INestApplication, opts: MakeUserOptions = {}) {
  const prisma = app.get(PrismaService);
  const password = opts.password ?? PASSWORD;
  const email = opts.email ?? emailFor();
  const created = await app.get(SupabaseAdminService).auth.createUser({
    email,
    password,
    email_confirm: true,
    ...(opts.phone ? { phone: opts.phone, phone_confirm: true } : {}),
    user_metadata: { full_name: opts.fullName ?? 'Test Person' },
  });
  if (created.error || !created.data.user) throw new Error(`createUser: ${created.error?.message}`);
  const id = created.data.user.id;
  const status = opts.status ?? 'ACTIVE';
  const user = await prisma.user.update({
    where: { id },
    data: { status, statusChangedAt: new Date() },
  });
  for (const key of opts.roles ?? []) {
    const role = await prisma.role.findUniqueOrThrow({ where: { key } });
    await prisma.userRole.create({ data: { userId: user.id, roleId: role.id } });
  }
  if (opts.membership) {
    const plan = await prisma.membershipPlan.findUniqueOrThrow({ where: { key: 'PRO' } });
    await prisma.membership.create({
      data: {
        userId: user.id,
        planId: plan.id,
        source: 'ADMIN_GRANT',
        status: opts.membership.status,
        currentPeriodEnd:
          opts.membership.periodEndInDays === null
            ? null
            : new Date(Date.now() + opts.membership.periodEndInDays * 24 * 3600 * 1000),
      },
    });
  }
  return { user, email, password };
}

/** A client that behaves like the apps: publishable key, no service role. */
export function anonClient(): SupabaseClient {
  return createClient(
    process.env.ATARAH_SUPABASE_URL!,
    process.env.ATARAH_TEST_SUPABASE_PUBLISHABLE_KEY!,
    {
      auth: { autoRefreshToken: false, persistSession: false },
    },
  );
}

export interface AuthBody {
  accessToken: string;
  refreshToken: string;
  userId: string;
  client: SupabaseClient;
}

/** Signs in through Supabase Auth exactly as the app does and returns the access token the API accepts. */
export async function loginMember(
  _app: INestApplication,
  email: string,
  password = PASSWORD,
): Promise<AuthBody> {
  const client = anonClient();
  const { data, error } = await client.auth.signInWithPassword({ email, password });
  if (error || !data.session) throw new Error(`signIn: ${error?.message}`);
  return {
    accessToken: data.session.access_token,
    refreshToken: data.session.refresh_token,
    userId: data.user.id,
    client,
  };
}

export const bearer = (token: string): [string, string] => ['Authorization', `Bearer ${token}`];

/** Admin sign-in as the console does it: password, then enrol or verify a TOTP factor to reach AAL2. */
export async function adminSignIn(app: INestApplication, email: string, password = PASSWORD) {
  const auth = await loginMember(app, email, password);
  const enrol = await auth.client.auth.mfa.enroll({
    factorType: 'totp',
    friendlyName: `admin-${Date.now()}`,
  });
  if (enrol.error || !enrol.data) throw new Error(`mfa.enroll: ${enrol.error?.message}`);
  const secret = enrol.data.totp.secret;
  const verified = await auth.client.auth.mfa.challengeAndVerify({
    factorId: enrol.data.id,
    code: generateSync({ secret }),
  });
  if (verified.error || !verified.data) throw new Error(`mfa.verify: ${verified.error?.message}`);
  const session = {
    accessToken: verified.data.access_token,
    refreshToken: verified.data.refresh_token,
  };
  return { session, secret, userId: auth.userId, factorId: enrol.data.id, client: auth.client };
}

/** TOTP step the next code must come from: wait for the next 30 s window so the same code is not replayed. */
export async function nextTotpCode(secret: string): Promise<string> {
  const step = 30_000;
  const wait = step - (Date.now() % step) + 200;
  await new Promise((r) => setTimeout(r, wait));
  return generateSync({ secret });
}

export const outbox = (app: INestApplication): DevOutbox => app.get(DevOutbox);

/** Removes test accounts from Supabase Auth (the `users` rows cascade), so no orphan auth users are left behind. */
export async function deleteUsers(app: INestApplication, ids: string[]): Promise<void> {
  const admin = app.get(SupabaseAdminService);
  for (const id of ids) await admin.auth.deleteUser(id);
}
