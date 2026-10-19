import { Injectable, Logger } from '@nestjs/common';
import { type Article } from '@prisma/client';
import { ArticlesService, livePublished } from '../content/articles.service';
import { CreativeProfileService } from '../creative/creative-profile.service';
import { PrismaService } from '../prisma/prisma.service';
import { CARD_INCLUDE, CreativesDiscoveryService } from './creatives-discovery.service';
import { type CreativeCardDto, type HomeDto, type RecommendationDto } from './discover.dto';

const MAX_RECOMMENDED = 5;
const MAX_CREATIVES = 8;
const CANDIDATES = 150;

type TagKind = 'discipline' | 'specialisation' | 'interest' | 'skill';

interface Facts {
  firstName: string;
  completionPercent: number;
  /** slug -> display name, for everything the member picked. */
  tags: Map<string, { name: string; kind: TagKind }>;
  disciplineIds: Set<string>;
  primaryDisciplineId: string | null;
  skillIds: Set<string>;
  countyId: string | null;
}

const joinNames = (names: string[]): string =>
  names.length <= 1 ? (names[0] ?? '') : `${names[0]} and ${names[1]}`;

/**
 * One aggregated payload for the Home tab. Recommendations are rule-based (discipline, specialisation, skills,
 * interests, county) and every item says why it is there. A section that fails or has nothing to show is left
 * empty, so a slow part of the page never blocks the rest.
 */
@Injectable()
export class HomeService {
  private readonly log = new Logger(HomeService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly profiles: CreativeProfileService,
    private readonly creatives: CreativesDiscoveryService,
    private readonly articles: ArticlesService,
  ) {}

  async home(userId: string): Promise<HomeDto> {
    const unavailable: string[] = [];
    const safe = async <T>(name: string, fn: () => Promise<T>, fallback: T): Promise<T> => {
      try {
        return await fn();
      } catch (e) {
        this.log.warn(`Home section "${name}" failed: ${(e as Error).message}`);
        unavailable.push(name);
        return fallback;
      }
    };

    const { id: profileId } = await this.profiles.ensureProfile(userId);
    const facts = await this.facts(profileId, userId);

    const [unread, article] = await Promise.all([
      this.prisma.notification.count({ where: { userId, readAt: null } }).catch(() => 0),
      safe('article', () => this.featuredArticle(), null),
    ]);
    const [recommended, creatives] = await Promise.all([
      safe('recommended', () => this.recommended(facts, article?.id), [] as RecommendationDto[]),
      safe('creatives', () => this.creativesToMeet(userId, facts), [] as CreativeCardDto[]),
    ]);

    return {
      firstName: facts.firstName,
      completionPercent: facts.completionPercent,
      unreadNotifications: unread,
      article: article ? (await this.articles.cards([article]))[0]! : null,
      recommended,
      creatives,
      unavailable,
    };
  }

  private async facts(profileId: string, userId: string): Promise<Facts> {
    const [p, user] = await Promise.all([
      this.prisma.creativeProfile.findUniqueOrThrow({
        where: { id: profileId },
        select: {
          displayName: true,
          completionPercent: true,
          primaryDisciplineId: true,
          countyId: true,
          disciplines: {
            select: { disciplineId: true, discipline: { select: { slug: true, name: true } } },
          },
          specialisations: { select: { specialisation: { select: { slug: true, name: true } } } },
          skills: { select: { skillId: true, skill: { select: { slug: true, name: true } } } },
          interests: { select: { interest: { select: { slug: true, name: true } } } },
        },
      }),
      this.prisma.user.findUniqueOrThrow({ where: { id: userId }, select: { fullName: true } }),
    ]);
    const tags: Facts['tags'] = new Map();
    const add = (kind: TagKind, t: { slug: string; name: string }) => {
      if (!tags.has(t.slug)) tags.set(t.slug, { name: t.name, kind });
    };
    for (const d of p.disciplines) add('discipline', d.discipline);
    for (const s of p.specialisations) add('specialisation', s.specialisation);
    for (const i of p.interests) add('interest', i.interest);
    for (const s of p.skills) add('skill', s.skill);
    const name = (p.displayName || user.fullName).trim();
    return {
      firstName: name.split(/\s+/)[0] ?? name,
      completionPercent: p.completionPercent,
      tags,
      disciplineIds: new Set(p.disciplines.map((d) => d.disciplineId)),
      primaryDisciplineId: p.primaryDisciplineId,
      skillIds: new Set(p.skills.map((s) => s.skillId)),
      countyId: p.countyId,
    };
  }

  /** The article an admin pinned if it is live, otherwise the newest live one. */
  private async featuredArticle(): Promise<Article | null> {
    const cfg = await this.prisma.homeConfig.findUnique({ where: { id: 'home' } });
    if (cfg?.featuredArticleId) {
      const pinned = await this.prisma.article.findFirst({
        where: { id: cfg.featuredArticleId, ...livePublished() },
      });
      if (pinned) return pinned;
    }
    return this.prisma.article.findFirst({
      where: livePublished(),
      orderBy: [{ publishedAt: 'desc' }, { id: 'asc' }],
    });
  }

  private async recommended(f: Facts, skipId: string | undefined): Promise<RecommendationDto[]> {
    if (f.tags.size === 0) return [];
    const rows = await this.prisma.article.findMany({
      where: {
        ...livePublished(),
        tags: { hasSome: [...f.tags.keys()] },
        ...(skipId ? { id: { not: skipId } } : {}),
      },
      orderBy: [{ publishedAt: 'desc' }, { id: 'asc' }],
      take: 50,
    });
    const rank = { discipline: 0, specialisation: 1, interest: 2, skill: 3 } as const;
    const scored = rows
      .map((a) => {
        const hits = a.tags.flatMap((t) => (f.tags.has(t) ? [f.tags.get(t)!] : []));
        hits.sort((x, y) => rank[x.kind] - rank[y.kind]);
        return { a, hits };
      })
      .sort((x, y) => y.hits.length - x.hits.length)
      .slice(0, MAX_RECOMMENDED);
    const cards = await this.articles.cards(scored.map((s) => s.a));
    return scored.map((s, i) => ({
      type: 'ARTICLE',
      id: cards[i]!.id,
      title: cards[i]!.title,
      subtitle: `${cards[i]!.authorName} · ${cards[i]!.readMinutes} min read`,
      imageUrl: cards[i]!.heroUrl,
      path: `/articles/${cards[i]!.slug}`,
      reason: `Because you selected ${joinNames(s.hits.map((h) => h.name))}`,
    }));
  }

  /**
   * People worth meeting: same discipline, shared skills and the same county score highest; whoever is left is
   * the newest to join. Nobody the member already knows or has asked is suggested.
   */
  private async creativesToMeet(userId: string, f: Facts): Promise<CreativeCardDto[]> {
    const rows = await this.prisma.creativeProfile.findMany({
      where: {
        onboardingCompletedAt: { not: null },
        handle: { not: null },
        userId: { not: userId },
        user: { status: 'ACTIVE', deletedAt: null },
        NOT: {
          user: {
            OR: [
              {
                connectionsSent: {
                  some: { addresseeId: userId, status: { in: ['PENDING', 'ACCEPTED'] } },
                },
              },
              {
                connectionsReceived: {
                  some: { requesterId: userId, status: { in: ['PENDING', 'ACCEPTED'] } },
                },
              },
            ],
          },
        },
      },
      include: { ...CARD_INCLUDE, disciplines: { select: { disciplineId: true } } },
      orderBy: [{ onboardingCompletedAt: 'desc' }, { id: 'asc' }],
      take: CANDIDATES,
    });

    const scored = rows.map((r) => {
      const skillsShown = !r.profileSectionVisibilities.some(
        (v) => v.section === 'SKILLS' && v.visibility === 'PRIVATE',
      );
      const shared = skillsShown ? r.skills.filter((s) => f.skillIds.has(s.skillId)).length : 0;
      const sameDiscipline =
        (f.primaryDisciplineId !== null && r.primaryDisciplineId === f.primaryDisciplineId) ||
        r.disciplines.some((d) => f.disciplineIds.has(d.disciplineId));
      const sameCounty =
        f.countyId !== null && r.countyId === f.countyId && r.locationVisibility !== 'PRIVATE';
      const score =
        (r.primaryDisciplineId === f.primaryDisciplineId && f.primaryDisciplineId ? 4 : 0) +
        (sameDiscipline ? 2 : 0) +
        Math.min(shared, 3) +
        (sameCounty ? 2 : 0);
      const reason = sameDiscipline
        ? `Also works in ${r.primaryDisciplineId === f.primaryDisciplineId ? r.primaryDiscipline?.name : 'your field'}`
        : shared > 0
          ? `Shares ${shared} of your skills`
          : sameCounty
            ? `Also in ${r.county?.name}`
            : 'New on Atarah';
      return { r, score, reason };
    });
    // Stable sort keeps "newest first" among equal scores.
    scored.sort((a, b) => b.score - a.score);
    const picked = scored.slice(0, MAX_CREATIVES);
    return Promise.all(picked.map((s) => this.creatives.card(s.r, s.reason)));
  }
}
