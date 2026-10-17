import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { runDemoSeed } from './demo';
import { runReferenceSeed } from './reference';

/**
 * `prisma db seed`. Reference data always; demo data only when ATARAH_ENV=dev.
 * Set ATARAH_SEED_REFERENCE_ONLY=1 to skip demo data even in dev.
 */
async function main(): Promise<void> {
  const env = process.env.ATARAH_ENV ?? 'dev';
  const prisma = new PrismaClient({ datasourceUrl: process.env.ATARAH_DATABASE_URL });
  try {
    const reference = await runReferenceSeed(prisma);
    console.log('Reference seed: created', JSON.stringify(reference));

    if (env === 'dev' && process.env.ATARAH_SEED_REFERENCE_ONLY !== '1') {
      const demo = await runDemoSeed(prisma);
      console.log('Demo seed (dev only): created', JSON.stringify(demo));
    } else {
      console.log(`Demo seed skipped (ATARAH_ENV=${env}).`);
    }
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err: unknown) => {
  console.error(err);
  process.exit(1);
});
