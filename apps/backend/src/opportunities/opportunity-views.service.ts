import { Injectable } from '@nestjs/common';
import { type Opportunity, type OpportunityTracking, Prisma } from '@prisma/client';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type OpportunityCardDto,
  type OpportunityProviderLiteDto,
  type TrackingStateDto,
} from './opportunities.dto';
import { daysLeft, urgencyFor, valueLabel } from './opportunity-logic';

export const CARD_INCLUDE = {
  provider: true,
  county: { select: { name: true } },
} satisfies Prisma.OpportunityInclude;

export type CardRow = Prisma.OpportunityGetPayload<{ include: typeof CARD_INCLUDE }>;

/** What members may list: published and not past its deadline. */
export const openWhere = (now: Date): Prisma.OpportunityWhereInput => ({
  status: 'PUBLISHED',
  OR: [{ deadlineAt: null }, { deadlineAt: { gt: now } }],
});

export const trackingState = (t: OpportunityTracking): TrackingStateDto => ({
  status: t.status,
  savedAt: t.savedAt,
  appliedAt: t.appliedAt,
  completedAt: t.completedAt,
  outcome: t.outcome,
});

/** "Saved" in the app means on the member's shortlist: saved, or started but not yet applied. */
export const isSavedStatus = (s: OpportunityTracking['status']): boolean =>
  s === 'SAVED' || s === 'IN_PROGRESS';

/** Builds the card shape shared by lists, Home, My opportunities and search. */
@Injectable()
export class OpportunityViewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
  ) {}

  async cards(rows: CardRow[], viewerId: string, now = new Date()): Promise<OpportunityCardDto[]> {
    if (rows.length === 0) return [];
    const trackings = await this.prisma.opportunityTracking.findMany({
      where: { userId: viewerId, opportunityId: { in: rows.map((r) => r.id) } },
    });
    const byId = new Map(trackings.map((t) => [t.opportunityId, t]));
    const logos = new Map<string, string | null>();
    for (const p of new Map(rows.map((r) => [r.providerId, r.provider])).values()) {
      logos.set(p.id, await this.media.imageUrl(p.logoMediaId, 200));
    }
    return rows.map((r) =>
      this.card(r, byId.get(r.id) ?? null, logos.get(r.providerId) ?? null, now),
    );
  }

  card(
    r: CardRow,
    tracking: OpportunityTracking | null,
    logoUrl: string | null,
    now: Date,
  ): OpportunityCardDto {
    return {
      id: r.id,
      slug: r.slug,
      type: r.type,
      title: r.title,
      summary: r.summary,
      trust: r.trust,
      provider: this.provider(r.provider, logoUrl),
      valueLabel: valueLabel(r),
      deadlineAt: r.deadlineAt,
      daysLeft: daysLeft(r.deadlineAt, now),
      urgency: urgencyFor(r.deadlineAt, now, tracking?.status ?? null),
      workMode: r.workMode,
      locationLabel: this.location(r),
      featured: r.featuredUntil !== null && r.featuredUntil > now,
      saved: tracking !== null && isSavedStatus(tracking.status),
      tracking: tracking ? trackingState(tracking) : null,
      closed: r.status !== 'PUBLISHED' || (r.deadlineAt !== null && r.deadlineAt <= now),
    };
  }

  provider(p: CardRow['provider'], logoUrl: string | null): OpportunityProviderLiteDto {
    return {
      id: p.id,
      name: p.name,
      type: p.type,
      verified: p.verificationStatus === 'VERIFIED',
      logoUrl,
      website: p.website,
    };
  }

  private location(
    r: Pick<Opportunity, 'workMode'> & { county: { name: string } | null },
  ): string | null {
    if (r.workMode === 'REMOTE') return 'Remote';
    if (r.workMode === 'HYBRID') return r.county ? `Hybrid · ${r.county.name}` : 'Hybrid';
    return r.county?.name ?? null;
  }
}
