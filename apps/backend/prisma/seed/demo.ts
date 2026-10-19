import { type PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';

/**
 * Demo seed: development only, every record flagged `isDemo = true`. The names are illustrative people
 * from the design prototype; they must never appear in production or be hard-coded in UI.
 * All demo accounts share the dev-only password below. Staff demo accounts still enrol their own
 * authenticator on first admin sign-in (no TOTP secret is seeded).
 */
export const DEMO_PASSWORD = 'Atarah-demo-1';

const DEMO_USERS = [
  {
    name: 'Nia Wairimu',
    email: 'nia@demo.atarah.test',
    phone: '+254700000001',
    plan: 'FREE',
    roles: [],
  },
  {
    name: 'Amani Otieno',
    email: 'amani@demo.atarah.test',
    phone: '+254700000002',
    plan: 'PRO',
    roles: ['MENTOR'],
  },
  {
    name: 'Zuri Mwangi',
    email: 'zuri@demo.atarah.test',
    phone: '+254700000003',
    plan: 'FREE',
    roles: ['SELLER'],
  },
  {
    name: 'Kiptoo Langat',
    email: 'kiptoo@demo.atarah.test',
    phone: '+254700000004',
    plan: 'FREE',
    roles: [],
  },
  {
    name: 'Wanjiku Njeri',
    email: 'wanjiku@demo.atarah.test',
    phone: '+254700000005',
    plan: 'PRO',
    roles: [],
  },
  {
    name: 'Demo Moderator',
    email: 'moderator@demo.atarah.test',
    phone: null,
    plan: 'FREE',
    roles: ['MODERATOR'],
  },
  {
    name: 'Demo Admin',
    email: 'admin@demo.atarah.test',
    phone: null,
    plan: 'FREE',
    roles: ['PLATFORM_ADMIN'],
  },
  {
    name: 'Demo Super Admin',
    email: 'superadmin@demo.atarah.test',
    phone: null,
    plan: 'FREE',
    roles: ['SUPER_ADMIN'],
  },
] as const;

export async function runDemoSeed(prisma: PrismaClient): Promise<{ users: number }> {
  const passwordHash = await argon2.hash(DEMO_PASSWORD, { type: argon2.argon2id });
  const plans = new Map((await prisma.membershipPlan.findMany()).map((p) => [p.key, p.id]));
  const roles = new Map((await prisma.role.findMany()).map((r) => [r.key, r.id]));
  let users = 0;

  for (const u of DEMO_USERS) {
    if (await prisma.user.findUnique({ where: { email: u.email } })) continue;
    await prisma.$transaction(async (tx) => {
      const now = new Date();
      const user = await tx.user.create({
        data: {
          fullName: u.name,
          email: u.email,
          phone: u.phone,
          emailVerifiedAt: now,
          phoneVerifiedAt: u.phone ? now : null,
          status: 'ACTIVE',
          isDemo: true,
          credential: { create: { passwordHash } },
        },
      });
      if (u.plan === 'PRO') {
        await tx.membership.create({
          data: {
            userId: user.id,
            planId: plans.get('PRO')!,
            source: 'ADMIN_GRANT',
            status: 'ACTIVE',
            currentPeriodEnd: new Date(now.getTime() + 30 * 24 * 3600 * 1000),
            note: 'Demo seed',
          },
        });
      }
      for (const r of u.roles) {
        await tx.userRole.create({ data: { userId: user.id, roleId: roles.get(r)! } });
      }
    });
    users += 1;
  }
  await seedDemoArticles(prisma);
  return { users };
}

/** Two short editorial articles so Home, Explore and the article screen have something to show in development. */
async function seedDemoArticles(prisma: PrismaClient): Promise<void> {
  const author = await prisma.user.findUnique({ where: { email: 'admin@demo.atarah.test' } });
  if (!author || (await prisma.article.count({ where: { isDemo: true } })) > 0) return;
  const now = new Date();
  const articles = [
    {
      slug: 'how-to-price-commissioned-illustration-in-kenya',
      title: 'How to price commissioned illustration in Kenya',
      summary:
        'Most early-career illustrators under-price because they quote by the hour. Here is a better starting point.',
      authorName: 'Demo Editor',
      tags: ['animation', 'visual-art', 'pricing'],
      body: [
        {
          type: 'paragraph',
          text: 'Clients do not buy hours. They buy usage, reach and reliability.',
        },
        { type: 'heading', text: 'Start with a day rate' },
        {
          type: 'paragraph',
          text: 'Cover your costs and the time you cannot bill, then add a licence fee based on where the work will appear and for how long.',
        },
        {
          type: 'callout',
          title: 'Rule of thumb',
          text: 'An editorial spot and a national billboard are not the same job, even if they take the same afternoon.',
        },
      ],
    },
    {
      slug: 'building-a-portfolio-that-gets-replies',
      title: 'Building a portfolio that gets replies',
      summary: 'Show fewer projects, explain your role in each, and make it easy to say yes.',
      authorName: 'Demo Editor',
      tags: ['portfolio', 'music'],
      body: [
        {
          type: 'paragraph',
          text: 'Pick your five strongest projects and say what you did on each.',
        },
        { type: 'quote', text: 'Show the work you want more of.', attribution: 'Demo Editor' },
      ],
    },
  ];
  for (const [i, a] of articles.entries()) {
    await prisma.article.create({
      data: {
        ...a,
        body: a.body,
        status: 'PUBLISHED',
        publishedAt: new Date(now.getTime() - i * 24 * 3600 * 1000),
        readMinutes: 1,
        createdById: author.id,
        isDemo: true,
      },
    });
  }
}
