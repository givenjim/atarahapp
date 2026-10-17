import { type PrismaClient } from '@prisma/client';
import { FLAG_REGISTRY } from '../../src/feature-flags/flags.registry';
import { ENTITLEMENTS, PERMISSIONS, PLANS, ROLES } from './data/access';
import { KENYA, KENYA_COUNTIES } from './data/kenya';
import {
  DEVELOPMENT_AREAS,
  DISCIPLINES,
  INTERESTS,
  LEARNING_CATEGORIES,
  MARKETPLACE_CATEGORIES,
  SKILLS,
  SPECIALISATIONS,
  slugify,
} from './data/taxonomy';
import {
  LEGAL_DOCUMENTS,
  LEGAL_PLACEHOLDER_BODY,
  LEGAL_PLACEHOLDER_TITLE_PREFIX,
  SETTINGS,
} from './data/settings';

/**
 * Reference seed: runs in every environment. Create-if-missing only; it never overwrites a value an
 * operator has changed, never deletes, and is safe to run repeatedly (running it twice changes nothing).
 */
export async function runReferenceSeed(prisma: PrismaClient): Promise<Record<string, number>> {
  const created: Record<string, number> = {};
  const add = (name: string, n: number) => (created[name] = (created[name] ?? 0) + n);

  // ---- access ----
  add(
    'permissions',
    (
      await prisma.permission.createMany({
        data: PERMISSIONS.map((p) => ({
          key: p.key,
          description: p.description,
          isMemberDefault: p.memberDefault ?? false,
        })),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'roles',
    (
      await prisma.role.createMany({
        data: ROLES.map((r) => ({
          key: r.key,
          name: r.name,
          description: r.description,
          isStaff: r.isStaff,
        })),
        skipDuplicates: true,
      })
    ).count,
  );
  const perms = new Map((await prisma.permission.findMany()).map((p) => [p.key, p.id]));
  const roles = new Map((await prisma.role.findMany()).map((r) => [r.key, r.id]));
  const rolePermissionRows = ROLES.flatMap((r) => {
    const keys = r.permissions === '*' ? PERMISSIONS.map((p) => p.key) : r.permissions;
    return keys.map((k) => {
      const permissionId = perms.get(k);
      if (!permissionId) throw new Error(`Role ${r.key} references unknown permission "${k}"`);
      return { roleId: roles.get(r.key)!, permissionId };
    });
  });
  add(
    'rolePermissions',
    (await prisma.rolePermission.createMany({ data: rolePermissionRows, skipDuplicates: true }))
      .count,
  );

  // ---- membership ----
  add(
    'entitlements',
    (
      await prisma.entitlement.createMany({
        data: ENTITLEMENTS.map((e) => ({ key: e.key, description: e.description })),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'plans',
    (
      await prisma.membershipPlan.createMany({
        data: PLANS.map((p) => ({ key: p.key, name: p.name, description: p.description })),
        skipDuplicates: true,
      })
    ).count,
  );
  const plans = new Map((await prisma.membershipPlan.findMany()).map((p) => [p.key, p.id]));
  const entitlements = new Map((await prisma.entitlement.findMany()).map((e) => [e.key, e.id]));
  add(
    'planEntitlements',
    (
      await prisma.membershipEntitlement.createMany({
        data: PLANS.flatMap((p) =>
          p.entitlements.map((e) => ({
            planId: plans.get(p.key)!,
            entitlementId: entitlements.get(e as never)!,
          })),
        ),
        skipDuplicates: true,
      })
    ).count,
  );

  // ---- locations ----
  add(
    'countries',
    (
      await prisma.country.createMany({
        data: [{ isoCode: KENYA.isoCode, name: KENYA.name, callingCode: KENYA.callingCode }],
        skipDuplicates: true,
      })
    ).count,
  );
  const kenya = await prisma.country.findUniqueOrThrow({ where: { isoCode: KENYA.isoCode } });
  add(
    'counties',
    (
      await prisma.county.createMany({
        data: KENYA_COUNTIES.map(([code, name], i) => ({
          countryId: kenya.id,
          code,
          name,
          sortOrder: i + 1,
        })),
        skipDuplicates: true,
      })
    ).count,
  );

  // ---- taxonomy ----
  add(
    'disciplines',
    (
      await prisma.discipline.createMany({
        data: DISCIPLINES.map(([name, icon], i) => ({
          slug: slugify(name),
          name,
          icon,
          sortOrder: i + 1,
        })),
        skipDuplicates: true,
      })
    ).count,
  );
  const disciplines = new Map((await prisma.discipline.findMany()).map((d) => [d.name, d.id]));
  add(
    'specialisations',
    (
      await prisma.specialisation.createMany({
        data: Object.entries(SPECIALISATIONS).flatMap(([discipline, names]) =>
          names.map((name, i) => {
            const disciplineId = disciplines.get(discipline);
            if (!disciplineId) throw new Error(`Unknown discipline "${discipline}"`);
            return { disciplineId, slug: slugify(name), name, sortOrder: i + 1 };
          }),
        ),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'skills',
    (
      await prisma.skill.createMany({
        data: SKILLS.map((name, i) => ({ slug: slugify(name), name, sortOrder: i + 1 })),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'interests',
    (
      await prisma.interest.createMany({
        data: INTERESTS.map((name, i) => ({ slug: slugify(name), name, sortOrder: i + 1 })),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'developmentAreas',
    (
      await prisma.developmentArea.createMany({
        data: DEVELOPMENT_AREAS.map((name, i) => ({ slug: slugify(name), name, sortOrder: i + 1 })),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'learningCategories',
    (
      await prisma.learningCategory.createMany({
        data: LEARNING_CATEGORIES.flatMap(({ group, names }) =>
          names.map((name, i) => ({ slug: slugify(name), name, group, sortOrder: i + 1 })),
        ),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'marketplaceCategories',
    (
      await prisma.marketplaceCategory.createMany({
        data: MARKETPLACE_CATEGORIES.map(([name, icon, tone], i) => ({
          slug: slugify(name),
          name,
          icon,
          tone,
          sortOrder: i + 1,
        })),
        skipDuplicates: true,
      })
    ).count,
  );

  // ---- settings, flags, legal placeholders ----
  add(
    'settings',
    (
      await prisma.platformSetting.createMany({
        data: SETTINGS.map((s) => ({ key: s.key, value: s.value, description: s.description })),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'featureFlags',
    (
      await prisma.featureFlag.createMany({
        data: FLAG_REGISTRY.map((f) => ({
          key: f.key,
          description: f.description,
          phase: f.phase,
          enabled: f.defaultEnabled,
        })),
        skipDuplicates: true,
      })
    ).count,
  );
  add(
    'legalDocuments',
    (
      await prisma.legalDocument.createMany({
        data: LEGAL_DOCUMENTS.map((d) => ({
          type: d.type,
          version: '0.0-draft',
          title: `${LEGAL_PLACEHOLDER_TITLE_PREFIX} — ${d.name}`,
          body: LEGAL_PLACEHOLDER_BODY,
          status: 'DRAFT' as const,
        })),
        skipDuplicates: true,
      })
    ).count,
  );

  return created;
}
