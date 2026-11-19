import { Injectable } from '@nestjs/common';
import { Prisma, type MentorApplication } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { PrismaService } from '../prisma/prisma.service';
import { isValidTimeZone } from './availability';
import {
  type ApplicationPrefillDto,
  type ApplyMentorDto,
  type MentorApplicationDto,
  type MyApplicationDto,
  type ProposedSessionTypeDto,
} from './mentorship.dto';
import { credentialsOf } from './mentor-views.service';

/** A rejected applicant may try again after this long (DEC-130). */
export const REAPPLY_COOLDOWN_DAYS = 7;
const DAY_MS = 86_400_000;
const DEFAULT_ZONE = 'Africa/Nairobi';

export function proposedTypesOf(json: Prisma.JsonValue): ProposedSessionTypeDto[] {
  if (!Array.isArray(json)) return [];
  return json.flatMap((t) => {
    if (!t || typeof t !== 'object' || Array.isArray(t)) return [];
    if (typeof t.name !== 'string' || typeof t.durationMinutes !== 'number') return [];
    if (typeof t.priceMinor !== 'number') return [];
    return [
      {
        name: t.name,
        description: typeof t.description === 'string' ? t.description : undefined,
        durationMinutes: t.durationMinutes,
        priceMinor: t.priceMinor,
        sessionCount: typeof t.sessionCount === 'number' ? t.sessionCount : 1,
      },
    ];
  });
}

export function applicationDto(a: MentorApplication): MentorApplicationDto {
  return {
    id: a.id,
    status: a.status,
    headline: a.headline,
    yearsExperience: a.yearsExperience,
    statement: a.statement,
    expertiseTags: a.expertiseTags,
    disciplineIds: a.disciplineIds,
    credentials: credentialsOf(a.credentials),
    proposedSessionTypes: proposedTypesOf(a.proposedSessionTypes),
    evidenceLinks: a.evidenceLinks,
    timeZone: a.timeZone,
    reviewerNotes: a.reviewerNotes,
    createdAt: a.createdAt.toISOString(),
    reviewedAt: a.reviewedAt ? a.reviewedAt.toISOString() : null,
  };
}

/** The member side of "Become a mentor": prefill from the Passport, apply, check status, withdraw. */
@Injectable()
export class MentorApplicationService {
  constructor(private readonly prisma: PrismaService) {}

  private async profileFor(userId: string) {
    return this.prisma.creativeProfile.findUnique({
      where: { userId },
      include: {
        disciplines: { select: { disciplineId: true, discipline: { select: { name: true } } } },
        skills: { include: { skill: { select: { name: true } } }, take: 40 },
        experiences: { orderBy: { startDate: 'asc' }, take: 20 },
        achievements: { orderBy: { achievedOn: 'desc' }, take: 10 },
        county: { select: { name: true } },
        passport: { select: { passportNumber: true } },
      },
    });
  }

  /** Starting values for the form, built from the member's profile and Creative Passport. Nothing is invented. */
  async prefill(userId: string): Promise<ApplicationPrefillDto> {
    const p = await this.profileFor(userId);
    if (!p) {
      return {
        headline: '',
        yearsExperience: 0,
        expertiseTags: [],
        disciplineIds: [],
        credentials: [],
        statement: '',
        timeZone: DEFAULT_ZONE,
        profileReady: false,
      };
    }
    const earliest = p.experiences[0]?.startDate;
    const years = earliest
      ? Math.max(0, Math.min(80, Math.floor((Date.now() - earliest.getTime()) / (365.25 * DAY_MS))))
      : 0;
    return {
      headline: p.headline ?? '',
      yearsExperience: years,
      expertiseTags: p.skills.slice(0, 8).map((s) => s.skill.name),
      disciplineIds: p.disciplines.map((d) => d.disciplineId).slice(0, 6),
      credentials: p.achievements.slice(0, 5).map((a) => ({
        title: a.title,
        issuer: a.issuer ?? null,
        year: a.achievedOn ? a.achievedOn.getUTCFullYear() : null,
      })),
      statement: p.bio ?? '',
      timeZone: DEFAULT_ZONE,
      profileReady: p.onboardingCompletedAt !== null,
    };
  }

  async mine(userId: string): Promise<MyApplicationDto> {
    const [latest, profile] = await Promise.all([
      this.prisma.mentorApplication.findFirst({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.mentorProfile.findUnique({ where: { userId }, select: { status: true } }),
    ]);
    const reason = this.blockReason(latest, profile?.status ?? null);
    return {
      latest: latest ? applicationDto(latest) : null,
      canApply: reason === null,
      cannotApplyReason: reason,
    };
  }

  private blockReason(
    latest: MentorApplication | null,
    profileStatus: string | null,
  ): string | null {
    if (profileStatus === 'APPROVED' || profileStatus === 'PAUSED')
      return 'You are already a mentor on Atarah.';
    if (latest?.status === 'PENDING') return 'Your application is being reviewed.';
    if (latest?.status === 'REJECTED' && latest.reviewedAt) {
      const wait = latest.reviewedAt.getTime() + REAPPLY_COOLDOWN_DAYS * DAY_MS - Date.now();
      if (wait > 0)
        return `You can apply again in ${Math.ceil(wait / DAY_MS)} day${Math.ceil(wait / DAY_MS) === 1 ? '' : 's'}.`;
    }
    return null;
  }

  async apply(userId: string, dto: ApplyMentorDto): Promise<MentorApplicationDto> {
    if (!dto.acceptTerms)
      throw ApiException.validation('Accept the Mentor Terms to apply.', { field: 'acceptTerms' });
    if (!isValidTimeZone(dto.timeZone))
      throw ApiException.validation('That time zone is not valid.', { field: 'timeZone' });
    const profile = await this.profileFor(userId);
    if (!profile?.onboardingCompletedAt)
      throw ApiException.invalidState('Finish your creative profile before you apply to mentor.', {
        reason: 'PROFILE_INCOMPLETE',
      });
    const [latest, mentor] = await Promise.all([
      this.prisma.mentorApplication.findFirst({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.mentorProfile.findUnique({ where: { userId }, select: { status: true } }),
    ]);
    const blocked = this.blockReason(latest, mentor?.status ?? null);
    if (blocked) throw ApiException.conflict(blocked);

    const ids = [...new Set(dto.disciplineIds)];
    if (ids.length) {
      const found = await this.prisma.discipline.count({ where: { id: { in: ids } } });
      if (found !== ids.length)
        throw ApiException.validation('One of the disciplines is not valid.', {
          field: 'disciplineIds',
        });
    }
    const snapshot = {
      displayName: profile.displayName,
      handle: profile.handle,
      headline: profile.headline,
      bio: profile.bio,
      county: profile.county?.name ?? null,
      passportNumber: profile.passport?.passportNumber ?? null,
      disciplines: profile.disciplines.map((d) => d.discipline.name),
      skills: profile.skills.slice(0, 20).map((s) => s.skill.name),
      experiences: profile.experiences.slice(-5).map((e) => ({
        title: e.title,
        organisation: e.organisation,
      })),
      capturedAt: new Date().toISOString(),
    };
    try {
      const row = await this.prisma.mentorApplication.create({
        data: {
          userId,
          headline: dto.headline.trim(),
          yearsExperience: dto.yearsExperience,
          statement: dto.statement.trim(),
          expertiseTags: dedupe(dto.expertiseTags),
          disciplineIds: ids,
          credentials: dto.credentials.map(trimCredential) as unknown as Prisma.InputJsonValue,
          proposedSessionTypes: dto.proposedSessionTypes.map((t) => ({
            name: t.name.trim(),
            description: t.description?.trim() || null,
            durationMinutes: t.durationMinutes,
            priceMinor: t.priceMinor,
            sessionCount: t.sessionCount ?? 1,
          })) as unknown as Prisma.InputJsonValue,
          evidenceLinks: dto.evidenceLinks,
          timeZone: dto.timeZone,
          passportSnapshot: snapshot as unknown as Prisma.InputJsonValue,
          termsAcceptedAt: new Date(),
        },
      });
      return applicationDto(row);
    } catch (e) {
      // The partial unique index allows one PENDING application per member.
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002')
        throw ApiException.conflict('Your application is being reviewed.');
      throw e;
    }
  }

  async withdraw(userId: string): Promise<MentorApplicationDto> {
    const pending = await this.prisma.mentorApplication.findFirst({
      where: { userId, status: 'PENDING' },
    });
    if (!pending) throw ApiException.notFound('You have no application to withdraw.');
    const res = await this.prisma.mentorApplication.updateMany({
      where: { id: pending.id, status: 'PENDING' },
      data: { status: 'WITHDRAWN' },
    });
    if (res.count !== 1) throw ApiException.invalidState('That application was already decided.');
    return applicationDto({ ...pending, status: 'WITHDRAWN' });
  }
}

export const dedupe = (tags: string[]): string[] => [
  ...new Map(tags.map((t) => [t.trim().toLowerCase(), t.trim()] as const)).values(),
];

export const trimCredential = (c: {
  title: string;
  issuer?: string | undefined;
  year?: number | undefined;
}) => ({
  title: c.title.trim(),
  issuer: c.issuer?.trim() || null,
  year: c.year ?? null,
});
