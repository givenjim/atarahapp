import { Injectable } from '@nestjs/common';
import { type MentorProfile, type MentorSessionType, type Prisma } from '@prisma/client';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import { AvailabilityService } from './availability.service';
import { type CredentialOutDto, type MentorCardDto, type SessionTypeDto } from './mentorship.dto';

export type MentorWithTypes = MentorProfile & { sessionTypes: MentorSessionType[] };

export interface PersonRef {
  userId: string;
  handle: string | null;
  displayName: string;
  avatarUrl: string | null;
  email: string | null;
  active: boolean;
}

/** Session types members may see and book: on, and not switched off by staff. */
export const isBookable = (t: Pick<MentorSessionType, 'active' | 'disabledByStaff'>): boolean =>
  t.active && !t.disabledByStaff;

export const sessionTypeDto = (t: MentorSessionType): SessionTypeDto => ({
  id: t.id,
  name: t.name,
  description: t.description,
  durationMinutes: t.durationMinutes,
  priceMinor: t.priceMinor,
  currency: t.currency,
  format: t.format,
  sessionCount: t.sessionCount,
  active: t.active,
  disabledByStaff: t.disabledByStaff,
});

export function credentialsOf(json: Prisma.JsonValue): CredentialOutDto[] {
  if (!Array.isArray(json)) return [];
  const out: CredentialOutDto[] = [];
  for (const c of json) {
    if (c && typeof c === 'object' && !Array.isArray(c) && typeof c.title === 'string') {
      out.push({
        title: c.title,
        issuer: typeof c.issuer === 'string' ? c.issuer : null,
        year: typeof c.year === 'number' ? c.year : null,
      });
    }
  }
  return out;
}

/** Builds mentor cards and person references in batches (no query per card). */
@Injectable()
export class MentorViewsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
    private readonly availability: AvailabilityService,
  ) {}

  async people(userIds: string[]): Promise<Map<string, PersonRef>> {
    const out = new Map<string, PersonRef>();
    if (userIds.length === 0) return out;
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: {
        id: true,
        fullName: true,
        email: true,
        status: true,
        deletedAt: true,
        creativeProfile: { select: { handle: true, displayName: true, avatarMediaId: true } },
      },
    });
    for (const u of users) {
      const p = u.creativeProfile;
      out.set(u.id, {
        userId: u.id,
        handle: p?.handle ?? null,
        displayName: p?.displayName ?? u.fullName,
        avatarUrl: await this.media.imageUrl(p?.avatarMediaId ?? null, 200),
        email: u.email ?? null,
        active: u.status === 'ACTIVE' && !u.deletedAt,
      });
    }
    return out;
  }

  /** Cards for members. `people` may be passed when already loaded. */
  async cards(
    rows: MentorWithTypes[],
    now = new Date(),
    people?: Map<string, PersonRef>,
  ): Promise<MentorCardDto[]> {
    if (rows.length === 0) return [];
    const refs = people ?? (await this.people(rows.map((r) => r.userId)));
    const schedules = await this.availability.schedules(
      rows.map((r) => ({ id: r.id, timeZone: r.timeZone })),
      now,
    );
    return Promise.all(
      rows.map(async (r) => {
        const types = r.sessionTypes.filter(isBookable);
        const shortest = types.length ? Math.min(...types.map((t) => t.durationMinutes)) : null;
        const next = await this.availability.nextAvailableAt(
          r.id,
          schedules.get(r.id)!,
          shortest,
          now,
        );
        const person = refs.get(r.userId);
        return {
          id: r.id,
          handle: person?.handle ?? null,
          displayName: person?.displayName ?? 'Mentor',
          avatarUrl: person?.avatarUrl ?? null,
          headline: r.headline,
          expertiseTags: r.expertiseTags,
          verified: r.verificationStatus === 'VERIFIED',
          featured: r.featured,
          ratingAverage: r.ratingAverage,
          ratingCount: r.ratingCount,
          sessionsCount: r.sessionsCount,
          fromPriceMinor: types.length ? Math.min(...types.map((t) => t.priceMinor)) : null,
          currency: types[0]?.currency ?? 'KES',
          nextAvailableAt: next ? next.toISOString() : null,
          timeZone: r.timeZone,
          videoCall: types.some((t) => t.format === 'VIDEO_CALL'),
        };
      }),
    );
  }
}
