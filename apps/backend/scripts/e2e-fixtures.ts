import 'dotenv/config';
import { randomBytes } from 'node:crypto';
import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';

/**
 * Creates a throwaway administrator and a throwaway member for the Playwright flow, and prints them as JSON.
 * Development only: it refuses to run unless ATARAH_ENV is `dev`. Every record is flagged `isDemo`, and the
 * administrator has no TOTP yet, so the test enrols one through the real UI.
 */
async function main(): Promise<void> {
  if ((process.env.ATARAH_ENV ?? 'dev') !== 'dev') {
    throw new Error('e2e fixtures only run with ATARAH_ENV=dev.');
  }
  const prisma = new PrismaClient({ datasourceUrl: process.env.ATARAH_DATABASE_URL });
  try {
    const run = randomBytes(4).toString('hex');
    const password = `E2e-${randomBytes(6).toString('hex')}-1`;
    const passwordHash = await argon2.hash(password, { type: argon2.argon2id });
    const role = await prisma.role.findUniqueOrThrow({ where: { key: 'PLATFORM_ADMIN' } });
    const now = new Date();

    const admin = await prisma.user.create({
      data: {
        fullName: `E2E Admin ${run}`,
        email: `e2e.admin.${run}@demo.atarah.test`,
        emailVerifiedAt: now,
        status: 'ACTIVE',
        isDemo: true,
        credential: { create: { passwordHash } },
        roles: { create: { roleId: role.id } },
      },
    });
    const member = await prisma.user.create({
      data: {
        fullName: `E2E Member ${run}`,
        email: `e2e.member.${run}@demo.atarah.test`,
        emailVerifiedAt: now,
        status: 'ACTIVE',
        isDemo: true,
        credential: { create: { passwordHash } },
      },
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

main().catch((err: unknown) => {
  console.error(err);
  process.exit(1);
});
