import { Inject, Injectable, Logger } from '@nestjs/common';
import { type ProfileSection, type Visibility } from '@prisma/client';
import { DEFAULT_VISIBILITY } from '../creative/sections';
import { PrismaService } from '../prisma/prisma.service';
import { StorageService } from '../storage/storage.service';
import { type CvSource, type VerifiedMarks } from './cv.model';

/**
 * The read interface the CV uses for verified marks (P2-M7). It answers from real data only. P2-M6 replaces the
 * implementation with `VerificationBadge` by providing this token again; nothing else in the CV changes.
 */
export const VERIFIED_MARKS_READER = Symbol('VERIFIED_MARKS_READER');
export interface VerifiedMarksReader {
  forProfile(profileId: string): Promise<VerifiedMarks>;
}

/**
 * The reader used until the verification cases exist: a skill is verified when its source is VERIFIED and the identity
 * is verified when the creative verification status is VERIFIED. Both are empty unless an admin set them.
 */
@Injectable()
export class DbVerifiedMarksReader implements VerifiedMarksReader {
  constructor(private readonly prisma: PrismaService) {}

  async forProfile(profileId: string): Promise<VerifiedMarks> {
    const [verification, skills] = await Promise.all([
      this.prisma.creativeVerification.findUnique({
        where: { profileId },
        select: { status: true },
      }),
      this.prisma.creativeSkill.findMany({
        where: { profileId, source: 'VERIFIED' },
        select: { skillId: true },
      }),
    ]);
    return {
      identity: verification?.status === 'VERIFIED',
      skillIds: new Set(skills.map((s) => s.skillId)),
    };
  }
}

const money = (
  min: number | null,
  max: number | null,
  currency: string,
  type: string,
): string | null => {
  if (type === 'ON_REQUEST' || min === null) return type === 'ON_REQUEST' ? 'On request' : null;
  const fmt = (n: number) =>
    `${currency} ${(n / 100).toLocaleString('en-KE', { maximumFractionDigits: 0 })}`;
  return type === 'RANGE' && max !== null ? `${fmt(min)} – ${fmt(max)}` : fmt(min);
};
const iso = (d: Date | null): string | null => (d ? d.toISOString().slice(0, 10) : null);

/** Loads everything a CV may draw on for one profile, with no filtering: the visibility rule lives in `buildCvDocument`. */
@Injectable()
export class CvSourceService {
  private readonly log = new Logger(CvSourceService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
    @Inject(VERIFIED_MARKS_READER) private readonly marks: VerifiedMarksReader,
  ) {}

  verifiedMarks(profileId: string): Promise<VerifiedMarks> {
    return this.marks.forProfile(profileId);
  }

  async load(profileId: string): Promise<CvSource | null> {
    const p = await this.prisma.creativeProfile.findUnique({
      where: { id: profileId },
      include: {
        user: { select: { email: true, phone: true, status: true, deletedAt: true } },
        primaryDiscipline: { select: { name: true } },
        county: { select: { name: true } },
        skills: { include: { skill: { select: { name: true } } } },
        profileSectionVisibilities: true,
        profileLinks: { orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }] },
        projects: {
          include: {
            skills: { include: { skill: { select: { name: true } } } },
            links: { orderBy: { sortOrder: 'asc' } },
          },
          orderBy: [{ featured: 'desc' }, { projectDate: 'desc' }],
        },
        experiences: { orderBy: { startDate: 'desc' } },
        achievements: { orderBy: { achievedOn: 'desc' } },
        profileServices: { orderBy: { sortOrder: 'asc' } },
      },
    });
    if (!p || p.user.deletedAt || p.user.status !== 'ACTIVE') return null;

    const visibility: Record<ProfileSection, Visibility> = { ...DEFAULT_VISIBILITY };
    for (const row of p.profileSectionVisibilities) visibility[row.section] = row.visibility;
    visibility.LOCATION = p.locationVisibility;

    return {
      profileId: p.id,
      handle: p.handle,
      displayName: p.displayName,
      headline: p.headline,
      bio: p.bio,
      discipline: p.primaryDiscipline?.name ?? null,
      county: p.county?.name ?? null,
      town: p.town,
      openToCommissions: p.openToCommissions,
      avatarDataUri: await this.avatar(p.avatarMediaId),
      contact: {
        email: p.user.email,
        phone: p.user.phone,
        showEmail: p.contactShowEmail,
        showPhone: p.contactShowPhone,
      },
      visibility,
      skills: p.skills
        .map((s) => ({ id: s.skillId, name: s.skill.name, level: s.level }))
        .sort((a, b) => a.name.localeCompare(b.name)),
      projects: p.projects.map((x) => ({
        id: x.id,
        title: x.title,
        role: x.role,
        client: x.client,
        year: x.projectDate ? x.projectDate.getUTCFullYear() : null,
        category: x.category,
        description: x.description,
        outcome: x.outcome,
        visibility: x.visibility,
        published: x.status === 'PUBLISHED',
        hidden: x.hiddenAt !== null,
        deleted: x.deletedAt !== null,
        skills: x.skills.map((s) => s.skill.name).sort(),
        links: x.links.map((l) => ({ label: l.label, url: l.url })),
      })),
      experience: p.experiences.map((e) => ({
        title: e.title,
        organisation: e.organisation,
        location: e.location,
        start: iso(e.startDate) ?? '',
        end: iso(e.endDate),
        current: e.current,
        description: e.description,
      })),
      achievements: p.achievements.map((a) => ({
        type: a.type,
        title: a.title,
        issuer: a.issuer,
        year: a.achievedOn ? a.achievedOn.getUTCFullYear() : null,
        description: a.description,
      })),
      services: p.profileServices.map((s) => ({
        title: s.title,
        description: s.description,
        price: money(s.priceMin, s.priceMax, s.currency, s.priceType),
      })),
      links: p.profileLinks.map((l) => ({ label: l.label, url: l.url })),
    };
  }

  /** The avatar as an inline data URI so the PDF needs no network. A missing or unreadable picture is simply left out. */
  private async avatar(mediaId: string | null): Promise<string | null> {
    if (!mediaId) return null;
    try {
      const asset = await this.prisma.mediaAsset.findUnique({ where: { id: mediaId } });
      if (!asset || asset.deletedAt || asset.status !== 'READY') return null;
      const variant = (asset.variants as Record<string, string> | null)?.['200'];
      const key = variant ?? asset.objectKey;
      const bucket =
        asset.bucket === 'PUBLIC' ? 'public' : asset.bucket === 'PRIVATE' ? 'private' : 'evidence';
      const bytes = await this.storage.read(bucket, key);
      if (bytes.length > 400_000) return null;
      const mime = variant
        ? 'image/webp'
        : ['image/png', 'image/webp'].includes(asset.mimeType)
          ? asset.mimeType
          : 'image/jpeg';
      return `data:${mime};base64,${bytes.toString('base64')}`;
    } catch (e) {
      this.log.warn(`Avatar not included: ${e instanceof Error ? e.message : String(e)}`);
      return null;
    }
  }
}
