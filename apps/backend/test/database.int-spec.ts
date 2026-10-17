import { execSync } from 'node:child_process';
import { PrismaClient } from '@prisma/client';
import { KENYA_COUNTIES } from '../prisma/seed/data/kenya';
import { runDemoSeed } from '../prisma/seed/demo';
import { runReferenceSeed } from '../prisma/seed/reference';

/** Real PostgreSQL 16 (Testcontainers) with every migration applied from an empty database. */
describe('Database baseline', () => {
  let prisma: PrismaClient;

  beforeAll(async () => {
    prisma = new PrismaClient({ datasourceUrl: process.env.ATARAH_DATABASE_URL });
    await runReferenceSeed(prisma);
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  describe('migrations', () => {
    it('applied from empty, with the required extensions installed', async () => {
      const ext = await prisma.$queryRaw<{ extname: string }[]>`SELECT extname FROM pg_extension`;
      expect(ext.map((e) => e.extname)).toEqual(
        expect.arrayContaining(['pg_trgm', 'unaccent', 'citext']),
      );
      const migrations = await prisma.$queryRaw<{ migration_name: string }[]>`
        SELECT migration_name FROM _prisma_migrations WHERE finished_at IS NOT NULL`;
      expect(migrations.map((m) => m.migration_name)).toEqual(
        expect.arrayContaining([
          expect.stringMatching(/init_system/),
          expect.stringMatching(/init_foundation/),
        ]),
      );
    });

    it('creates every Section 6 enum with the exact values', async () => {
      const rows = await prisma.$queryRaw<{ typname: string; labels: string[] }[]>`
        SELECT t.typname, array_agg(e.enumlabel ORDER BY e.enumsortorder) AS labels
        FROM pg_type t JOIN pg_enum e ON e.enumtypid = t.oid GROUP BY t.typname`;
      const enums = Object.fromEntries(rows.map((r) => [r.typname, r.labels]));
      expect(enums.AccountStatus).toEqual([
        'PENDING_VERIFICATION',
        'ACTIVE',
        'SUSPENDED',
        'DEACTIVATED',
        'DELETED',
      ]);
      expect(enums.RoleKey).toEqual([
        'MENTOR',
        'SELLER',
        'OPPORTUNITY_PROVIDER',
        'INSTRUCTOR',
        'MODERATOR',
        'CONTENT_ADMIN',
        'PLATFORM_ADMIN',
        'SUPER_ADMIN',
      ]);
      expect(enums.BookingStatus).toEqual([
        'PENDING_PAYMENT',
        'CONFIRMED',
        'COMPLETED',
        'CANCELLED_BY_MENTEE',
        'CANCELLED_BY_MENTOR',
        'DECLINED_BY_MENTOR',
        'NO_SHOW',
        'PAYMENT_FAILED',
      ]);
      expect(enums.OpportunityTrust).toEqual(['VERIFIED', 'SOURCE_CONFIRMED', 'EXTERNAL_SOURCE']);
      expect(enums.VerificationStatus).toEqual([
        'NOT_SUBMITTED',
        'SUBMITTED',
        'UNDER_REVIEW',
        'VERIFIED',
        'REJECTED',
        'EXPIRED',
        'REVOKED',
      ]);
      expect(enums.NotificationCategory).toEqual([
        'OPPORTUNITIES',
        'MENTORSHIP',
        'COMMUNITY',
        'LEARNING',
        'PROFILE',
        'MARKETPLACE',
        'SYSTEM',
      ]);
      expect(enums.PaymentStatus).toEqual([
        'INITIATED',
        'PENDING',
        'SUCCEEDED',
        'FAILED',
        'CANCELLED',
        'REFUNDED',
        'PARTIALLY_REFUNDED',
      ]);
      // 34 canonical enums from §6 plus 8 infrastructure enums defined by the baseline schema.
      for (const name of [
        'Visibility',
        'PublicationStatus',
        'SkillLevel',
        'SkillSource',
        'GrowthStrength',
        'CreativeDocumentFormat',
        'OpportunityType',
        'OpportunityStatus',
        'ApplicationMethod',
        'OpportunityTrackingStatus',
        'OpportunityOutcome',
        'ContentSource',
        'ContentDelivery',
        'LearningContentType',
        'LearningCategoryGroup',
        'LessonProgressStatus',
        'PostType',
        'PostAudience',
        'GroupType',
        'ConnectionStatus',
        'ReportReason',
        'ReportStatus',
        'ModerationAction',
        'ListingType',
        'PricingType',
        'ListingStatus',
        'ProfileServiceStatus',
        'EnquiryStatus',
        'MentorSessionFormat',
        'PaymentMethod',
        'PaymentPurpose',
        'MembershipPlanKey',
        'MembershipSource',
        'MembershipStatus',
        'EntitlementKey',
      ]) {
        expect(enums[name]).toBeDefined();
      }
    });
  });

  describe('reference seed', () => {
    it('is idempotent: a second run creates nothing and changes nothing', async () => {
      const snapshot = async () =>
        prisma.$queryRaw<{ t: string; n: bigint; latest: Date | null }[]>`
          SELECT 'permissions' t, count(*) n, max("updatedAt") latest FROM permissions
          UNION ALL SELECT 'roles', count(*), max("updatedAt") FROM roles
          UNION ALL SELECT 'counties', count(*), max("updatedAt") FROM counties
          UNION ALL SELECT 'disciplines', count(*), max("updatedAt") FROM disciplines
          UNION ALL SELECT 'specialisations', count(*), max("updatedAt") FROM specialisations
          UNION ALL SELECT 'settings', count(*), max("updatedAt") FROM platform_settings
          UNION ALL SELECT 'flags', count(*), max("updatedAt") FROM feature_flags
          UNION ALL SELECT 'role_permissions', count(*), NULL FROM role_permissions`;
      const before = await snapshot();
      const created = await runReferenceSeed(prisma);
      expect(Object.values(created).every((n) => n === 0)).toBe(true);
      expect(await snapshot()).toEqual(before);
    });

    it('never overwrites a value an operator changed', async () => {
      await prisma.platformSetting.update({
        where: { key: 'membership.pro.price_minor' },
        data: { value: 150000 },
      });
      await runReferenceSeed(prisma);
      const row = await prisma.platformSetting.findUniqueOrThrow({
        where: { key: 'membership.pro.price_minor' },
      });
      expect(row.value).toBe(150000);
      await prisma.platformSetting.update({
        where: { key: 'membership.pro.price_minor' },
        data: { value: 120000 },
      });
    });

    it('seeds Kenya with all 47 counties and unique three-letter codes', async () => {
      const kenya = await prisma.country.findUniqueOrThrow({ where: { isoCode: 'KE' } });
      const counties = await prisma.county.findMany({ where: { countryId: kenya.id } });
      expect(counties).toHaveLength(47);
      expect(KENYA_COUNTIES).toHaveLength(47);
      expect(new Set(counties.map((c) => c.code)).size).toBe(47);
      expect(counties.every((c) => /^[A-Z]{3}$/.test(c.code))).toBe(true);
      expect(counties.find((c) => c.code === 'NBI')?.name).toBe('Nairobi');
      expect(counties.find((c) => c.code === 'MSA')?.name).toBe('Mombasa');
      expect(counties.find((c) => c.code === 'KSM')?.name).toBe('Kisumu');
      expect(counties.find((c) => c.code === 'NKR')?.name).toBe('Nakuru');
    });

    it('seeds the 12 disciplines and the prototype specialisations', async () => {
      expect(await prisma.discipline.count()).toBe(12);
      const animation = await prisma.discipline.findUniqueOrThrow({
        where: { slug: 'animation' },
        include: { specialisations: { orderBy: { sortOrder: 'asc' } } },
      });
      expect(animation.icon).toBe('aperture');
      expect(animation.specialisations.map((s) => s.name)).toEqual([
        '2D animation',
        '3D animation',
        'Motion graphics',
        'Character design',
        'Storyboarding',
      ]);
      expect(
        (await prisma.discipline.findUniqueOrThrow({ where: { slug: 'film-video' } })).name,
      ).toBe('Film / Video');
    });

    it('seeds learning and marketplace categories', async () => {
      const groups = await prisma.learningCategory.groupBy({ by: ['group'], _count: true });
      expect(Object.fromEntries(groups.map((g) => [g.group, g._count]))).toEqual({
        CREATIVE: 7,
        BUSINESS: 4,
        PROFESSIONAL: 4,
      });
      expect(await prisma.marketplaceCategory.count()).toBe(8);
    });

    it('stores the Pro price and policy windows as settings, not code', async () => {
      const get = async (key: string) =>
        (await prisma.platformSetting.findUniqueOrThrow({ where: { key } })).value;
      expect(await get('membership.pro.price_minor')).toBe(120000);
      expect(await get('membership.pro.currency')).toBe('KES');
      expect(await get('mentorship.free_cancellation_hours')).toBe(24);
      expect(await get('mentorship.late_cancellation_refund_percent')).toBe(50);
      expect(await get('verification.sla_working_days')).toBe(5);
    });

    it('seeds legal documents only as clearly labelled drafts', async () => {
      const docs = await prisma.legalDocument.findMany();
      expect(docs).toHaveLength(6);
      expect(
        docs.every(
          (d) => d.status === 'DRAFT' && d.title.startsWith('DRAFT — pending legal review'),
        ),
      ).toBe(true);
    });

    it('creates every registry feature flag, all off by default', async () => {
      const flags = await prisma.featureFlag.findMany();
      expect(flags.length).toBeGreaterThanOrEqual(22);
      expect(flags.every((f) => f.enabled === false)).toBe(true);
    });
  });

  describe('roles, permissions and plans (Master Prompt §6.1)', () => {
    const permissionsOf = async (role: string): Promise<Set<string>> => {
      const rows = await prisma.rolePermission.findMany({
        where: { role: { key: role as never } },
        include: { permission: true },
      });
      return new Set(rows.map((r) => r.permission.key));
    };

    it('does not model Premium, Verified or Member as roles', async () => {
      const keys = (await prisma.role.findMany()).map((r) => r.key).sort();
      expect(keys).toEqual([
        'CONTENT_ADMIN',
        'INSTRUCTOR',
        'MENTOR',
        'MODERATOR',
        'OPPORTUNITY_PROVIDER',
        'PLATFORM_ADMIN',
        'SELLER',
        'SUPER_ADMIN',
      ]);
    });

    it('gives SUPER_ADMIN every permission', async () => {
      const all = await prisma.permission.count();
      expect((await permissionsOf('SUPER_ADMIN')).size).toBe(all);
    });

    it('keeps payment.manage and role management away from PLATFORM_ADMIN', async () => {
      const p = await permissionsOf('PLATFORM_ADMIN');
      for (const denied of [
        'payment.manage',
        'role.manage',
        'permission.manage',
        'admin.manage',
        'security.manage',
        'emergency.control',
      ]) {
        expect(p.has(denied)).toBe(false);
      }
      for (const allowed of [
        'user.suspend',
        'membership.manage',
        'opportunity.verify',
        'verification.decide',
        'mentor.manage',
      ]) {
        expect(p.has(allowed)).toBe(true);
      }
    });

    it('keeps CONTENT_ADMIN away from opportunities, verification decisions, users and payments', async () => {
      const p = await permissionsOf('CONTENT_ADMIN');
      for (const denied of [
        'opportunity.manage',
        'opportunity.verify',
        'verification.decide',
        'user.suspend',
        'payment.view',
        'payment.manage',
        'role.manage',
      ]) {
        expect(p.has(denied)).toBe(false);
      }
      expect(p.has('article.manage')).toBe(true);
      expect(p.has('learning.manage')).toBe(true);
    });

    it('limits MODERATOR to reports and community content', async () => {
      const p = [...(await permissionsOf('MODERATOR'))].sort();
      expect(p).toEqual([
        'admin.access',
        'community.moderate',
        'moderation.act',
        'report.resolve',
        'report.view',
      ]);
    });

    it('keeps staff capabilities out of the member-default set and out of non-staff roles', async () => {
      const defaults = (await prisma.permission.findMany({ where: { isMemberDefault: true } })).map(
        (p) => p.key,
      );
      expect(defaults).not.toContain('admin.access');
      expect(defaults.some((k) => k.startsWith('payment.') || k.startsWith('role.'))).toBe(false);
      for (const role of ['MENTOR', 'SELLER', 'OPPORTUNITY_PROVIDER', 'INSTRUCTOR']) {
        expect((await permissionsOf(role)).has('admin.access')).toBe(false);
      }
    });

    it('grants Pro five entitlements and Free none', async () => {
      const entitlementsOf = async (plan: 'FREE' | 'PRO') =>
        (
          await prisma.membershipEntitlement.findMany({
            where: { plan: { key: plan } },
            include: { entitlement: true },
          })
        )
          .map((e) => e.entitlement.key)
          .sort();
      expect(await entitlementsOf('FREE')).toEqual([]);
      expect(await entitlementsOf('PRO')).toEqual([
        'CREATIVE_VERIFICATION',
        'MENTORSHIP_BOOKING',
        'PREMIUM_CONTENT',
        'REDUCED_MARKETPLACE_FEES',
        'SKILL_VERIFICATION',
      ]);
    });
  });

  describe('constraints', () => {
    const uniq = () => `${Date.now()}${Math.floor(Math.random() * 1e6)}`;

    it('rejects an account with neither email nor phone', async () => {
      await expect(prisma.user.create({ data: { fullName: 'No Contact' } })).rejects.toThrow(
        /users_identifier_present/,
      );
    });

    it('rejects a phone number that is not E.164', async () => {
      await expect(
        prisma.user.create({ data: { fullName: 'Bad Phone', phone: '0712345678' } }),
      ).rejects.toThrow(/users_phone_e164/);
    });

    it('treats email as case-insensitive and unique', async () => {
      const email = `Case${uniq()}@Example.com`;
      await prisma.user.create({ data: { fullName: 'First', email } });
      await expect(
        prisma.user.create({ data: { fullName: 'Second', email: email.toLowerCase() } }),
      ).rejects.toThrow(/Unique constraint/);
    });

    it('allows only one live membership per user, but history after expiry', async () => {
      const user = await prisma.user.create({
        data: { fullName: 'Member', email: `m${uniq()}@example.com` },
      });
      const pro = await prisma.membershipPlan.findUniqueOrThrow({ where: { key: 'PRO' } });
      const first = await prisma.membership.create({
        data: { userId: user.id, planId: pro.id, source: 'PAID', status: 'ACTIVE' },
      });
      await expect(
        prisma.membership.create({
          data: { userId: user.id, planId: pro.id, source: 'PAID', status: 'PAST_DUE' },
        }),
      ).rejects.toThrow(/memberships_one_live_per_user|Unique constraint/);
      await prisma.membership.update({ where: { id: first.id }, data: { status: 'EXPIRED' } });
      await expect(
        prisma.membership.create({
          data: { userId: user.id, planId: pro.id, source: 'PAID', status: 'ACTIVE' },
        }),
      ).resolves.toBeDefined();
    });

    it('rejects malformed county codes and duplicate codes within a country', async () => {
      const kenya = await prisma.country.findUniqueOrThrow({ where: { isoCode: 'KE' } });
      await expect(
        prisma.county.create({ data: { countryId: kenya.id, code: 'nbi', name: 'Lowercase' } }),
      ).rejects.toThrow(/counties_code_format/);
      await expect(
        prisma.county.create({
          data: { countryId: kenya.id, code: 'NBI', name: 'Another Nairobi' },
        }),
      ).rejects.toThrow(/Unique constraint/);
    });

    it('enforces foreign keys and cascades a user delete to its credentials and sessions', async () => {
      await expect(
        prisma.session.create({
          data: {
            userId: '00000000-0000-4000-8000-00000000dead',
            familyId: '00000000-0000-4000-8000-00000000beef',
            refreshTokenHash: `h${uniq()}`,
            client: 'ANDROID',
            expiresAt: new Date(Date.now() + 1000),
          },
        }),
      ).rejects.toThrow(/Foreign key/);

      const user = await prisma.user.create({
        data: {
          fullName: 'Cascade',
          email: `c${uniq()}@example.com`,
          credential: { create: { passwordHash: 'x' } },
          sessions: {
            create: {
              familyId: '00000000-0000-4000-8000-00000000beef',
              refreshTokenHash: `h${uniq()}`,
              client: 'WEB',
              expiresAt: new Date(Date.now() + 1000),
            },
          },
        },
      });
      await prisma.user.delete({ where: { id: user.id } });
      expect(await prisma.credential.count({ where: { userId: user.id } })).toBe(0);
      expect(await prisma.session.count({ where: { userId: user.id } })).toBe(0);
    });

    it('does not let a role be deleted while users hold it', async () => {
      const user = await prisma.user.create({
        data: { fullName: 'Holder', email: `h${uniq()}@example.com` },
      });
      const role = await prisma.role.findUniqueOrThrow({ where: { key: 'MENTOR' } });
      await prisma.userRole.create({ data: { userId: user.id, roleId: role.id } });
      await expect(prisma.role.delete({ where: { id: role.id } })).rejects.toThrow(/Foreign key/);
    });
  });

  describe('demo seed', () => {
    it('creates only flagged demo records and is idempotent', async () => {
      const first = await runDemoSeed(prisma);
      expect(
        first.users + (await prisma.user.count({ where: { isDemo: true } })),
      ).toBeGreaterThanOrEqual(5);
      expect((await runDemoSeed(prisma)).users).toBe(0);
      const demo = await prisma.user.findMany({
        where: { isDemo: true },
        include: { memberships: true, roles: true },
      });
      expect(demo.every((u) => u.email?.endsWith('@demo.atarah.test'))).toBe(true);
      expect(demo.find((u) => u.fullName === 'Amani Otieno')?.memberships).toHaveLength(1);
    });

    it('is skipped outside dev: the seed command run as production creates no demo users', async () => {
      await prisma.user.deleteMany({ where: { isDemo: true } });
      const out = execSync('npx ts-node --transpile-only prisma/seed/index.ts', {
        encoding: 'utf8',
        env: { ...process.env, ATARAH_ENV: 'production' },
      });
      expect(out).toMatch(/Demo seed skipped \(ATARAH_ENV=production\)/);
      expect(await prisma.user.count({ where: { isDemo: true } })).toBe(0);
    });
  });
});
