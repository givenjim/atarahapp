import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { pageMeta } from '../common/pagination';
import { notBlockedWhere } from '../community-core/blocks';
import { CARD_INCLUDE, CreativesDiscoveryService } from '../discover/creatives-discovery.service';
import { PrismaService } from '../prisma/prisma.service';
import { type PeopleQueryDto, type PersonToMeetDto } from './community.dto';

const CANDIDATES = 300;

/**
 * "People to meet": members the viewer could connect with, best first, each with a reason line. Shared discipline,
 * shared skills and the same county score highest; whoever is left is the newest to join. Nobody the viewer is
 * already connected with, nobody who asked them, nobody blocked in either direction, and nobody who is not taking
 * requests. A person the viewer already asked still shows, as "Requested".
 */
@Injectable()
export class PeopleService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly creatives: CreativesDiscoveryService,
  ) {}

  async suggest(viewerId: string, q: PeopleQueryDto) {
    const me = await this.prisma.creativeProfile.findUnique({
      where: { userId: viewerId },
      select: {
        primaryDisciplineId: true,
        countyId: true,
        disciplines: { select: { disciplineId: true } },
        skills: { select: { skillId: true } },
      },
    });
    const myDisciplines = new Set(me?.disciplines.map((d) => d.disciplineId) ?? []);
    const mySkills = new Set(me?.skills.map((s) => s.skillId) ?? []);

    const where: Prisma.CreativeProfileWhereInput = {
      onboardingCompletedAt: { not: null },
      handle: { not: null },
      userId: { not: viewerId },
      acceptConnections: true,
      user: {
        status: 'ACTIVE',
        deletedAt: null,
        ...notBlockedWhere(viewerId),
        // They asked me, or we are already connected: those live in the requests and connections lists.
        connectionsSent: {
          none: { addresseeId: viewerId, status: { in: ['PENDING', 'ACCEPTED'] } },
        },
        connectionsReceived: { none: { requesterId: viewerId, status: 'ACCEPTED' } },
      },
      ...(q.disciplineId ? { disciplines: { some: { disciplineId: q.disciplineId } } } : {}),
      // A hidden county is never matched on: filtering by it would reveal it.
      ...(q.countyId ? { countyId: q.countyId, locationVisibility: { not: 'PRIVATE' } } : {}),
      ...(q.available ? { openToCommissions: true } : {}),
      ...(q.verified ? { verification: { is: { status: 'VERIFIED' } } } : {}),
    };

    const rows = await this.prisma.creativeProfile.findMany({
      where,
      include: {
        ...CARD_INCLUDE,
        disciplines: { select: { disciplineId: true } },
        user: {
          select: {
            connectionsReceived: {
              where: { requesterId: viewerId, status: 'PENDING' },
              select: { id: true },
            },
          },
        },
      },
      orderBy: [{ onboardingCompletedAt: 'desc' }, { id: 'asc' }],
      take: CANDIDATES,
    });

    const scored = rows.map((r) => {
      const skillsShown = !r.profileSectionVisibilities.some(
        (v) => v.section === 'SKILLS' && v.visibility === 'PRIVATE',
      );
      const shared = skillsShown ? r.skills.filter((s) => mySkills.has(s.skillId)).length : 0;
      const samePrimary =
        me?.primaryDisciplineId !== null &&
        me?.primaryDisciplineId !== undefined &&
        r.primaryDisciplineId === me.primaryDisciplineId;
      const sameDiscipline =
        samePrimary || r.disciplines.some((d) => myDisciplines.has(d.disciplineId));
      const sameCounty =
        me?.countyId !== null &&
        me?.countyId !== undefined &&
        r.countyId === me.countyId &&
        r.locationVisibility !== 'PRIVATE';
      const score =
        (samePrimary ? 4 : 0) +
        (sameDiscipline ? 2 : 0) +
        Math.min(shared, 3) +
        (sameCounty ? 2 : 0);
      const reason = sameDiscipline
        ? `Also works in ${samePrimary ? r.primaryDiscipline?.name : 'your field'}`
        : shared > 0
          ? `Shares ${shared} of your skills`
          : sameCounty
            ? `Also in ${r.county?.name}`
            : 'New on Atarah';
      return { r, score, reason };
    });
    scored.sort((a, b) => b.score - a.score); // stable: newest first among equals

    const start = (q.page - 1) * q.limit;
    const pageRows = scored.slice(start, start + q.limit);
    const items: PersonToMeetDto[] = [];
    for (const s of pageRows) {
      const sent = s.r.user.connectionsReceived[0];
      items.push({
        person: await this.creatives.card(s.r, s.reason),
        connectionState: sent ? 'PENDING_SENT' : 'NONE',
        connectionId: sent?.id ?? null,
      });
    }
    return { items, meta: pageMeta(q, scored.length) };
  }
}
