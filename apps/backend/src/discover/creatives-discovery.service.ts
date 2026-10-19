import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { pageMeta } from '../common/pagination';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import { type CreativeCardDto, type CreativesQueryDto, MIN_QUERY } from './discover.dto';
import { ApiException } from '../common/api.exception';

/** `%` and `_` in what someone typed must match themselves, not act as wildcards. */
export const likePattern = (q: string): string => `%${q.replace(/[\\%_]/g, (c) => `\\${c}`)}%`;
export const prefixPattern = (q: string): string => `${likePattern(q).slice(1, -1)}%`;

/** Collapses whitespace and checks the length. Throws a VALIDATION_ERROR for something too short to search. */
export function cleanQuery(raw: string | undefined, required: boolean): string | undefined {
  const q = raw?.replace(/\s+/g, ' ').trim();
  if (!q) {
    if (required) {
      throw ApiException.validation('Type at least 2 characters to search.', { field: 'q' });
    }
    return undefined;
  }
  if (q.length < MIN_QUERY) {
    throw ApiException.validation('Type at least 2 characters to search.', { field: 'q' });
  }
  return q;
}

export const CARD_INCLUDE = {
  primaryDiscipline: { select: { id: true, name: true, icon: true } },
  county: { select: { name: true } },
  skills: { include: { skill: { select: { name: true } } } },
  profileSectionVisibilities: true,
  verification: { select: { status: true } },
} satisfies Prisma.CreativeProfileInclude;

export type CardRow = Prisma.CreativeProfileGetPayload<{ include: typeof CARD_INCLUDE }>;

/**
 * Finding other members. Everyone who may be found has finished onboarding, has a handle and an active account.
 * Callers are signed-in members, so they see PUBLIC and MEMBERS fields; a PRIVATE field is never shown, matched
 * against or filtered on (filtering on a hidden county would leak it).
 */
@Injectable()
export class CreativesDiscoveryService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
  ) {}

  /** Profile ids that match, best first, plus how many there are in all. */
  async find(
    viewerId: string,
    f: Pick<
      CreativesQueryDto,
      'q' | 'disciplineId' | 'specialisationId' | 'countyId' | 'available' | 'verified' | 'sort'
    >,
    page: { page: number; limit: number },
  ): Promise<{ ids: string[]; total: number }> {
    const q = cleanQuery(f.q, false);
    const like = q ? likePattern(q) : null;
    const prefix = q ? prefixPattern(q) : null;

    const skillsShown = Prisma.sql`NOT EXISTS (SELECT 1 FROM profile_section_visibility v
      WHERE v."profileId" = p.id AND v.section::text = 'SKILLS' AND v.visibility::text = 'PRIVATE')`;
    const disciplineHit = (): Prisma.Sql => Prisma.sql`EXISTS (SELECT 1 FROM creative_disciplines cd
      JOIN disciplines d ON d.id = cd."disciplineId"
      WHERE cd."profileId" = p.id AND (d.name ILIKE ${like} OR similarity(d.name, ${q}) > 0.4))`;
    const skillHit =
      (): Prisma.Sql => Prisma.sql`(${skillsShown} AND EXISTS (SELECT 1 FROM creative_skills cs
      JOIN skills s ON s.id = cs."skillId"
      WHERE cs."profileId" = p.id AND (s.name ILIKE ${like} OR similarity(s.name, ${q}) > 0.4)))`;

    const conditions: Prisma.Sql[] = [
      Prisma.sql`p."onboardingCompletedAt" IS NOT NULL`,
      Prisma.sql`p.handle IS NOT NULL`,
      Prisma.sql`u.status::text = 'ACTIVE' AND u."deletedAt" IS NULL`,
      Prisma.sql`p."userId" <> ${viewerId}::uuid`,
    ];
    if (f.disciplineId) {
      conditions.push(Prisma.sql`EXISTS (SELECT 1 FROM creative_disciplines cd
        WHERE cd."profileId" = p.id AND cd."disciplineId" = ${f.disciplineId}::uuid)`);
    }
    if (f.specialisationId) {
      conditions.push(Prisma.sql`EXISTS (SELECT 1 FROM creative_specialisations cs
        WHERE cs."profileId" = p.id AND cs."specialisationId" = ${f.specialisationId}::uuid)`);
    }
    if (f.countyId) {
      conditions.push(
        Prisma.sql`p."countyId" = ${f.countyId}::uuid AND p."locationVisibility"::text <> 'PRIVATE'`,
      );
    }
    if (f.available) conditions.push(Prisma.sql`p."openToCommissions" = true`);
    if (f.verified) {
      conditions.push(Prisma.sql`EXISTS (SELECT 1 FROM creative_verifications cv
        WHERE cv."profileId" = p.id AND cv.status::text = 'VERIFIED')`);
    }
    if (q) {
      conditions.push(Prisma.sql`(
        p."displayName" ILIKE ${like} OR p.headline ILIKE ${like} OR p.handle::text ILIKE ${prefix}
        OR similarity(p."displayName", ${q}) > 0.3 OR word_similarity(${q}, p."displayName") > 0.5
        OR ${disciplineHit()} OR ${skillHit()})`);
    }

    const score = q
      ? Prisma.sql`GREATEST(
          similarity(p."displayName", ${q}),
          word_similarity(${q}, p."displayName"),
          CASE WHEN p."displayName" ILIKE ${like} THEN 0.9 ELSE 0 END,
          CASE WHEN p.handle::text ILIKE ${prefix} THEN 0.8 ELSE 0 END,
          CASE WHEN p.headline ILIKE ${like} THEN 0.5 ELSE 0 END,
          CASE WHEN ${disciplineHit()} THEN 0.4 ELSE 0 END,
          CASE WHEN ${skillHit()} THEN 0.3 ELSE 0 END)`
      : Prisma.sql`0`;

    const order =
      f.sort === 'recent'
        ? Prisma.sql`p."onboardingCompletedAt" DESC, p.id`
        : Prisma.sql`score DESC, p."completionPercent" DESC, p."onboardingCompletedAt" DESC, p.id`;

    const rows = await this.prisma.$queryRaw<Array<{ id: string; total: bigint }>>(Prisma.sql`
      SELECT p.id, count(*) OVER() AS total, ${score} AS score
      FROM creative_profiles p
      JOIN users u ON u.id = p."userId"
      WHERE ${Prisma.join(conditions, ' AND ')}
      ORDER BY ${order}
      LIMIT ${page.limit} OFFSET ${(page.page - 1) * page.limit}`);

    if (rows.length > 0) return { ids: rows.map((r) => r.id), total: Number(rows[0]!.total) };
    // An empty page past the end still needs the real total.
    if (page.page === 1) return { ids: [], total: 0 };
    const [counted] = await this.prisma.$queryRaw<Array<{ n: bigint }>>(Prisma.sql`
      SELECT count(*) AS n FROM creative_profiles p JOIN users u ON u.id = p."userId"
      WHERE ${Prisma.join(conditions, ' AND ')}`);
    return { ids: [], total: Number(counted?.n ?? 0) };
  }

  async search(viewerId: string, q: CreativesQueryDto) {
    const { ids, total } = await this.find(viewerId, q, q);
    return { items: await this.cardsFor(ids), meta: pageMeta(q, total) };
  }

  /** Cards for the given profiles, in the order given. Hidden fields are left out here, once. */
  async cardsFor(
    ids: string[],
    reasons: Map<string, string> = new Map(),
  ): Promise<CreativeCardDto[]> {
    if (ids.length === 0) return [];
    const rows = await this.prisma.creativeProfile.findMany({
      where: { id: { in: ids } },
      include: CARD_INCLUDE,
    });
    const byId = new Map(rows.map((r) => [r.id, r]));
    const out: CreativeCardDto[] = [];
    for (const id of ids) {
      const r = byId.get(id);
      if (r?.handle) out.push(await this.card(r, reasons.get(id) ?? null));
    }
    return out;
  }

  async card(p: CardRow, reason: string | null = null): Promise<CreativeCardDto> {
    const skillsHidden = p.profileSectionVisibilities.some(
      (v) => v.section === 'SKILLS' && v.visibility === 'PRIVATE',
    );
    const tags = skillsHidden
      ? []
      : p.skills
          .map((s) => s.skill.name)
          .sort((a, b) => a.localeCompare(b))
          .slice(0, 3);
    return {
      handle: p.handle!,
      displayName: p.displayName,
      headline: p.headline,
      avatarUrl: await this.media.imageUrl(p.avatarMediaId, 200),
      discipline: p.primaryDiscipline
        ? {
            id: p.primaryDiscipline.id,
            name: p.primaryDiscipline.name,
            icon: p.primaryDiscipline.icon,
          }
        : null,
      tags,
      location: p.locationVisibility === 'PRIVATE' ? null : (p.county?.name ?? null),
      verified: p.verification?.status === 'VERIFIED',
      openToCommissions: p.openToCommissions,
      reason,
    };
  }
}
