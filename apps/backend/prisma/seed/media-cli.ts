import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { seedSupabaseClient } from './demo';
import { seedDemoMedia } from './demo-media';

/**
 * `pnpm db:seed:media`: puts placeholder pictures into every empty picture slot of a development database
 * (DEC-088). Use it on a database that was seeded before the pictures existed, for example the hosted dev project:
 *
 *   cd apps/backend && node --env-file=.env.cloud -r ts-node/register/transpile-only prisma/seed/media-cli.ts
 *
 * Set ATARAH_SEED_MEDIA_DEMO_ONLY=1 to touch demo records only. Refuses to run unless ATARAH_ENV is dev.
 */
async function main(): Promise<void> {
  const env = process.env.ATARAH_ENV ?? 'dev';
  if (env !== 'dev') throw new Error(`Refusing to add placeholder pictures when ATARAH_ENV=${env}.`);
  const prisma = new PrismaClient({ datasourceUrl: process.env.ATARAH_DATABASE_URL });
  try {
    const result = await seedDemoMedia(prisma, seedSupabaseClient(), {
      everything: process.env.ATARAH_SEED_MEDIA_DEMO_ONLY !== '1',
    });
    console.log('Placeholder pictures added:', JSON.stringify(result));
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err: unknown) => {
  console.error(err);
  process.exit(1);
});
