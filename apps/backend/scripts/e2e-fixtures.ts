import 'dotenv/config';
import { randomBytes } from 'node:crypto';
import { PrismaClient, type RoleKey } from '@prisma/client';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';

/**
 * Creates a throwaway administrator and a throwaway member for the Playwright flow, and prints them as JSON.
 * Development only: it refuses to run unless ATARAH_ENV is `dev`. Accounts are created through the Supabase
 * Auth admin API (the service-role key is read from this app's .env and never leaves this process); the
 * database trigger creates the `users` row, and roles are then assigned with Prisma. The administrator has
 * no TOTP factor yet, so the test enrols one through the real UI.
 */
async function main(): Promise<void> {
  if ((process.env.ATARAH_ENV ?? 'dev') !== 'dev') {
    throw new Error('e2e fixtures only run with ATARAH_ENV=dev.');
  }
  const prisma = new PrismaClient({ datasourceUrl: process.env.ATARAH_DATABASE_URL });
  try {
    if (process.argv[2] === 'cleanup-taxonomy') {
      await cleanupTaxonomy(prisma, process.argv[3] ?? '');
      return;
    }
    const run = randomBytes(4).toString('hex');
    const password = `E2e-${randomBytes(6).toString('hex')}-1`;
    const supabase = adminClient();

    const admin = await createAccount(supabase, prisma, {
      email: `e2e.admin.${run}@demo.atarah.test`,
      fullName: `E2E Admin ${run}`,
      password,
      // `E2E_ADMIN_ROLE` picks another role (for example CONTENT_ADMIN for Skill Labs, which a platform admin cannot manage).
      roleKey: (process.env.E2E_ADMIN_ROLE as RoleKey | undefined) ?? 'PLATFORM_ADMIN',
    });
    const member = await createAccount(supabase, prisma, {
      email: `e2e.member.${run}@demo.atarah.test`,
      fullName: `E2E Member ${run}`,
      password,
    });
    process.stdout.write(
      JSON.stringify({
        adminEmail: admin.email,
        adminName: admin.fullName,
        password,
        memberEmail: member.email,
        memberName: member.fullName,
        memberId: member.id,
      }),
    );
  } finally {
    await prisma.$disconnect();
  }
}

function adminClient(): SupabaseClient {
  const url = process.env.ATARAH_SUPABASE_URL;
  const key = process.env.ATARAH_SUPABASE_SECRET_KEY;
  if (!url || !key) {
    throw new Error(
      'ATARAH_SUPABASE_URL and ATARAH_SUPABASE_SECRET_KEY must be set in apps/backend/.env.',
    );
  }
  return createClient(url, key, { auth: { autoRefreshToken: false, persistSession: false } });
}

async function createAccount(
  supabase: SupabaseClient,
  prisma: PrismaClient,
  a: { email: string; fullName: string; password: string; roleKey?: RoleKey },
): Promise<{ id: string; email: string; fullName: string }> {
  // Resolve the role first so a missing seed fails before an auth user is created.
  const role = a.roleKey
    ? await prisma.role.findUniqueOrThrow({ where: { key: a.roleKey } })
    : null;
  const created = await supabase.auth.admin.createUser({
    email: a.email,
    password: a.password,
    email_confirm: true,
    user_metadata: { full_name: a.fullName },
  });
  if (created.error || !created.data.user) {
    throw new Error(`createUser ${a.email}: ${created.error?.message}`);
  }
  const id = created.data.user.id;
  const user = await prisma.user.update({
    where: { id },
    data: { status: 'ACTIVE', statusChangedAt: new Date(), isDemo: true },
  });
  if (role) {
    await prisma.userRole.create({ data: { userId: user.id, roleId: role.id } });
  }
  return { id: user.id, email: a.email, fullName: user.fullName };
}

/**
 * Removes the disciplines whose name starts with `prefix` (default "E2E Taxonomy ") together with their
 * specialisations and suggestions, which the admin API can only archive. Never touches seeded rows: a
 * prefix shorter than "E2E " is refused.
 */
async function cleanupTaxonomy(prisma: PrismaClient, prefix: string): Promise<void> {
  if (!prefix.startsWith('E2E ') || prefix.length < 8) {
    throw new Error('cleanup-taxonomy needs a prefix that starts with "E2E ".');
  }
  const disciplines = await prisma.discipline.findMany({
    where: { name: { startsWith: prefix } },
    select: { id: true },
  });
  const disciplineId = { in: disciplines.map((d) => d.id) };
  await prisma.specialisationSuggestion.deleteMany({ where: { disciplineId } });
  await prisma.creativeSpecialisation.deleteMany({ where: { specialisation: { disciplineId } } });
  await prisma.specialisation.deleteMany({ where: { disciplineId } });
  await prisma.discipline.deleteMany({ where: { id: disciplineId } });
  process.stdout.write(JSON.stringify({ removedDisciplines: disciplines.length }));
}

main().catch((err: unknown) => {
  console.error(err);
  process.exit(1);
});
