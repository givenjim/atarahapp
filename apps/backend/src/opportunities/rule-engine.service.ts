import { Inject, Injectable, Logger } from '@nestjs/common';
import { type Redis } from 'ioredis';
import { REDIS } from '../redis/redis.module';
import { PrismaService } from '../prisma/prisma.service';
import {
  evaluateRules,
  type ProfileGap,
  type RuleInput,
  type ViewerFacts,
} from './opportunity-rules';

export const GAP_CACHE_SECONDS = 300;
const cacheKey = (userId: string, opportunityId: string) => `opp:gap:${userId}:${opportunityId}`;

/**
 * The profile-gap check (P1-M9). Rules are evaluated on the server against the signed-in member's own profile only:
 * the result never contains another member's data. Results are cached for 5 minutes per member and listing; the cache
 * is best effort (a Redis outage just means evaluating every time) and `refresh` skips it.
 */
@Injectable()
export class RuleEngineService {
  private readonly log = new Logger(RuleEngineService.name);

  constructor(
    private readonly prisma: PrismaService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async gap(
    userId: string,
    opportunityId: string,
    opts: { refresh?: boolean } = {},
  ): Promise<ProfileGap> {
    const key = cacheKey(userId, opportunityId);
    if (!opts.refresh) {
      const hit = await this.redis.get(key).catch(() => null);
      if (hit) {
        try {
          return JSON.parse(hit) as ProfileGap;
        } catch {
          // A damaged entry is simply recomputed.
        }
      }
    }
    const rules = await this.prisma.opportunityRequirementRule.findMany({
      where: { opportunityId },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    const inputs: RuleInput[] = rules.map((r) => ({
      id: r.id,
      ruleType: r.ruleType,
      params: r.params,
      label: r.label,
      isBlocking: r.isBlocking,
    }));
    const gap = evaluateRules(inputs, inputs.length === 0 ? EMPTY_FACTS : await this.facts(userId));
    await this.redis.set(key, JSON.stringify(gap), 'EX', GAP_CACHE_SECONDS).catch((e: Error) => {
      this.log.debug(`Gap cache write skipped: ${e.message}`);
    });
    return gap;
  }

  /** The member's own profile facts. Only what the rules can ask about. */
  async facts(userId: string): Promise<ViewerFacts> {
    const profile = await this.prisma.creativeProfile.findUnique({
      where: { userId },
      select: {
        id: true,
        country: { select: { isoCode: true } },
        county: { select: { code: true } },
        disciplines: { select: { disciplineId: true } },
        skills: { select: { skillId: true } },
      },
    });
    if (!profile) return EMPTY_FACTS;
    const projectCount = await this.prisma.project.count({
      where: { profileId: profile.id, status: 'PUBLISHED', deletedAt: null, hiddenAt: null },
    });
    return {
      countryCode: profile.country?.isoCode ?? null,
      countyCode: profile.county?.code ?? null,
      disciplineIds: new Set(profile.disciplines.map((d) => d.disciplineId)),
      skillIds: new Set(profile.skills.map((s) => s.skillId)),
      projectCount,
    };
  }
}

const EMPTY_FACTS: ViewerFacts = {
  countryCode: null,
  countyCode: null,
  disciplineIds: new Set(),
  skillIds: new Set(),
  projectCount: 0,
};
