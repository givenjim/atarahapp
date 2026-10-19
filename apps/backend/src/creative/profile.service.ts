import { Injectable } from '@nestjs/common';
import { type ProfileSection, type Visibility, Prisma } from '@prisma/client';
import { type AuthContext } from '../access/access.types';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';
import { MediaService } from '../media/media.service';
import { PrismaService } from '../prisma/prisma.service';
import { computeCompletion, identityPercent } from './completion';
import { ConnectionsService } from './connections.service';
import { CreativeProfileService } from './creative-profile.service';
import { computeGrowth, type GrowthFacts } from './growth';
import { MAX_HEADLINE, MAX_LINKS, type UpdateProfileDto } from './profile.dto';
import {
  canSeeContact,
  DEFAULT_VISIBILITY,
  PROFILE_SECTIONS,
  relationCanSee,
  type ViewerRelation,
  visibilitiesFor,
} from './sections';
import { MAX_BIO } from './creative.dto';

const FULL_INCLUDE = {
  user: { select: { email: true, phone: true, createdAt: true, status: true, deletedAt: true } },
  primaryDiscipline: { select: { id: true, name: true, icon: true } },
  country: { select: { name: true } },
  county: { select: { name: true } },
  specialisations: { include: { specialisation: true } },
  skills: { include: { skill: true } },
  passport: true,
  profileSectionVisibilities: true,
  profileLinks: { orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }] },
} satisfies Prisma.CreativeProfileInclude;

type Full = Prisma.CreativeProfileGetPayload<{ include: typeof FULL_INCLUDE }>;

const item = (t: { id: string; slug: string; name: string }) => ({
  id: t.id,
  slug: t.slug,
  name: t.name,
});
const byName = <T extends { name: string }>(a: T, b: T) => a.name.localeCompare(b.name);

@Injectable()
export class ProfileService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
    private readonly config: AppConfigService,
    private readonly profiles: CreativeProfileService,
    private readonly connections: ConnectionsService,
  ) {}

  private async load(userId: string): Promise<Full> {
    const { id } = await this.profiles.ensureProfile(userId);
    return this.prisma.creativeProfile.findUniqueOrThrow({
      where: { id },
      include: FULL_INCLUDE,
    });
  }

  private shareUrl(handle: string | null): string | null {
    return handle ? `${this.config.appLinkBaseUrl.replace(/\/$/, '')}/${handle}` : null;
  }

  /** Every section's audience: the member's choice, or the default. Location is stored on the profile. */
  sectionVisibility(p: Full): Record<ProfileSection, Visibility> {
    const out = { ...DEFAULT_VISIBILITY };
    for (const row of p.profileSectionVisibilities) out[row.section] = row.visibility;
    out.LOCATION = p.locationVisibility;
    return out;
  }

  private sectionList(p: Full) {
    const map = this.sectionVisibility(p);
    return PROFILE_SECTIONS.map((section) => ({ section, visibility: map[section] }));
  }

  private locationOf(p: Full) {
    return {
      countryName: p.country?.name ?? null,
      countyName: p.county?.name ?? null,
      town: p.town,
    };
  }

  // ---- own profile -----------------------------------------------------------------------------------------

  async me(userId: string) {
    const p = await this.load(userId);
    const completion = computeCompletion(await this.profiles.facts(p.id));
    const [connections, pendingRequests] = await Promise.all([
      this.connections.countAccepted(userId),
      this.connections.countPendingReceived(userId),
    ]);
    return {
      id: p.id,
      handle: p.handle,
      displayName: p.displayName,
      headline: p.headline,
      bio: p.bio,
      avatarUrl: await this.media.imageUrl(p.avatarMediaId, 600),
      discipline: p.primaryDiscipline,
      specialisations: p.specialisations.map((s) => item(s.specialisation)).sort(byName),
      skills: p.skills.map((s) => item(s.skill)).sort(byName),
      location: this.locationOf(p),
      openToCommissions: p.openToCommissions,
      acceptConnections: p.acceptConnections,
      contact: {
        email: p.user.email,
        phone: p.user.phone,
        showEmail: p.contactShowEmail,
        showPhone: p.contactShowPhone,
        forConnections: p.contactForConnections,
      },
      links: p.profileLinks.map((l) => ({ id: l.id, label: l.label, url: l.url })),
      sections: this.sectionList(p),
      completion,
      passport: p.passport
        ? { passportNumber: p.passport.passportNumber, issuedAt: p.passport.createdAt }
        : null,
      onboardingCompleted: p.onboardingCompletedAt !== null,
      memberSince: p.user.createdAt,
      counts: { skills: p.skills.length, connections, pendingRequests },
      shareUrl: this.shareUrl(p.handle),
    };
  }

  async update(userId: string, dto: UpdateProfileDto) {
    const p = await this.load(userId);
    const data: Prisma.CreativeProfileUpdateInput = {};

    if (dto.displayName !== undefined) {
      const name = dto.displayName.trim().replace(/\s+/g, ' ');
      if (name.length < 2) {
        throw ApiException.validation('Enter the name you want people to see.', {
          field: 'displayName',
        });
      }
      data.displayName = name;
    }
    if (dto.headline !== undefined) {
      const headline = dto.headline.trim().replace(/\s+/g, ' ');
      if (headline.length > MAX_HEADLINE) {
        throw ApiException.validation(`Keep your headline to ${MAX_HEADLINE} characters.`, {
          field: 'headline',
        });
      }
      data.headline = headline || null;
    }
    if (dto.bio !== undefined) {
      const bio = dto.bio.trim();
      if (bio.length > MAX_BIO) {
        throw ApiException.validation(`Keep your bio to ${MAX_BIO} characters.`, { field: 'bio' });
      }
      data.bio = bio || null;
    }
    for (const key of [
      'openToCommissions',
      'contactShowEmail',
      'contactShowPhone',
      'contactForConnections',
      'acceptConnections',
    ] as const) {
      if (dto[key] !== undefined) data[key] = dto[key];
    }

    let links: Array<{ label: string; url: string }> | undefined;
    if (dto.links !== undefined) {
      if (dto.links.length > MAX_LINKS) {
        throw ApiException.validation(`You can add up to ${MAX_LINKS} links.`, { field: 'links' });
      }
      const seen = new Set<string>();
      links = [];
      for (const l of dto.links) {
        const url = l.url.trim();
        const key = url.toLowerCase();
        if (!/^https:\/\//i.test(url)) {
          throw ApiException.validation('Links must start with https://', { field: 'links' });
        }
        if (seen.has(key)) continue; // the same address twice is one link
        seen.add(key);
        links.push({ label: l.label.trim(), url });
      }
    }

    await this.prisma.transaction(async (tx) => {
      if (Object.keys(data).length) {
        await tx.creativeProfile.update({ where: { id: p.id }, data });
      }
      if (links) {
        await tx.profileLink.deleteMany({ where: { profileId: p.id } });
        await tx.profileLink.createMany({
          data: links.map((l, i) => ({
            profileId: p.id,
            label: l.label,
            url: l.url,
            sortOrder: i,
          })),
        });
      }
    });
    await this.profiles.refreshCompletion(p.id);
    return this.me(userId);
  }

  // ---- Passport --------------------------------------------------------------------------------------------

  async growthFacts(p: Full): Promise<GrowthFacts> {
    const facts = await this.profiles.facts(p.id);
    return {
      identityPercent: identityPercent(facts),
      publishedProjects: facts.projectCount,
      skills: p.skills.length,
      verifiedSkills: p.skills.filter((s) => s.source === 'VERIFIED').length,
      completedCourses: 0, // Skill Labs arrives in P1-M8
      enrolledCourses: 0,
      acceptedConnections: await this.connections.countAccepted(p.userId),
      services: await this.prisma.profileService.count({ where: { profileId: p.id } }),
      experiences: facts.experienceCount,
      achievements: await this.prisma.achievement.count({ where: { profileId: p.id } }),
      verifiedIdentity: false, // verification arrives in P2-M6
    };
  }

  async growth(userId: string) {
    const p = await this.load(userId);
    return computeGrowth(await this.growthFacts(p));
  }

  async passport(userId: string) {
    const p = await this.load(userId);
    if (!p.passport || !p.handle) {
      throw ApiException.invalidState(
        'Finish setting up your profile to get your Creative Passport.',
      );
    }
    const completion = computeCompletion(await this.profiles.facts(p.id));
    return {
      passportNumber: p.passport.passportNumber,
      issuedAt: p.passport.createdAt,
      displayName: p.displayName,
      handle: p.handle,
      avatarUrl: await this.media.imageUrl(p.avatarMediaId, 600),
      discipline: p.primaryDiscipline?.name ?? null,
      specialisation:
        p.specialisations.map((s) => s.specialisation.name).sort((a, b) => a.localeCompare(b))[0] ??
        null,
      location: this.locationOf(p),
      memberSince: p.user.createdAt,
      trust: [] as string[], // trust pills appear only when real verification exists (P2-M6)
      growth: computeGrowth(await this.growthFacts(p)),
      completion,
      sections: this.sectionList(p),
      shareUrl: this.shareUrl(p.handle)!,
    };
  }

  async setVisibility(userId: string, section: ProfileSection, visibility: Visibility) {
    const p = await this.load(userId);
    await this.prisma.transaction(async (tx) => {
      if (section === 'LOCATION') {
        await tx.creativeProfile.update({
          where: { id: p.id },
          data: { locationVisibility: visibility },
        });
      } else {
        await tx.profileSectionVisibility.upsert({
          where: { profileId_section: { profileId: p.id, section } },
          create: { profileId: p.id, section, visibility },
          update: { visibility },
        });
      }
    });
    return this.sectionList(await this.load(userId));
  }

  // ---- someone's profile -----------------------------------------------------------------------------------

  /**
   * Who is asking and what they may see of [handle]'s profile. Throws the same 404 for "no such handle" and "not
   * visible", so a profile that cannot be seen does not exist. Shared by the profile and the portfolio endpoints.
   */
  async audience(handle: string, viewer?: AuthContext, preview?: 'PUBLIC' | 'MEMBERS') {
    const p = await this.prisma.creativeProfile.findUnique({
      where: { handle: handle.trim().toLowerCase() },
      include: FULL_INCLUDE,
    });
    const isOwner = !!viewer && !!p && p.userId === viewer.userId;
    const showable =
      !!p &&
      p.onboardingCompletedAt !== null &&
      p.user.status === 'ACTIVE' &&
      p.user.deletedAt === null;
    if (!p || (!showable && !isOwner))
      throw ApiException.notFound('We could not find that creative.');
    if (preview && !isOwner) {
      throw ApiException.forbidden('Only the owner can preview their profile.');
    }

    const relation: ViewerRelation = await this.relationFor(p, viewer, isOwner, preview);
    const vis = this.sectionVisibility(p);
    const see = (s: ProfileSection) =>
      s === 'CONTACT'
        ? canSeeContact(vis.CONTACT, relation, p.contactForConnections)
        : relationCanSee(vis[s], relation);
    return { p, isOwner, relation, vis, see };
  }

  async publicProfile(handle: string, viewer?: AuthContext, preview?: 'PUBLIC' | 'MEMBERS') {
    const { p, isOwner, relation, see } = await this.audience(handle, viewer, preview);

    const visibleSections = PROFILE_SECTIONS.filter(see);
    const lockedSections = PROFILE_SECTIONS.filter((s) => !see(s));

    let connection = null;
    if (viewer && !isOwner && !preview) {
      connection = this.connections.viewOf(
        viewer.userId,
        await this.connections.between(viewer.userId, p.userId),
        p,
      );
    }

    return {
      handle: p.handle!,
      displayName: p.displayName,
      avatarUrl: await this.media.imageUrl(p.avatarMediaId, 600),
      headline: p.headline,
      discipline: p.primaryDiscipline,
      specialisations: p.specialisations.map((s) => item(s.specialisation)).sort(byName),
      openToCommissions: p.openToCommissions,
      memberSince: p.user.createdAt,
      relation,
      connection,
      bio: see('BIO') ? p.bio : null,
      location: see('LOCATION') ? this.locationOf(p) : null,
      skills: see('SKILLS') ? p.skills.map((s) => item(s.skill)).sort(byName) : null,
      links: see('LINKS')
        ? p.profileLinks.map((l) => ({ id: l.id, label: l.label, url: l.url }))
        : null,
      contact: see('CONTACT')
        ? {
            email: p.contactShowEmail ? p.user.email : null,
            phone: p.contactShowPhone ? p.user.phone : null,
          }
        : null,
      portfolioCount: see('PORTFOLIO')
        ? await this.prisma.project.count({
            where: {
              profileId: p.id,
              status: 'PUBLISHED',
              deletedAt: null,
              hiddenAt: null,
              visibility: { in: visibilitiesFor(relation) },
            },
          })
        : null,
      serviceCount: see('SERVICES')
        ? await this.prisma.profileService.count({ where: { profileId: p.id } })
        : null,
      visibleSections,
      lockedSections,
      connectionCount:
        relation === 'ANONYMOUS' ? null : await this.connections.countAccepted(p.userId),
      shareUrl: this.shareUrl(p.handle)!,
    };
  }

  private async relationFor(
    p: Full,
    viewer: AuthContext | undefined,
    isOwner: boolean,
    preview?: 'PUBLIC' | 'MEMBERS',
  ): Promise<ViewerRelation> {
    if (isOwner) {
      if (preview === 'PUBLIC') return 'ANONYMOUS';
      if (preview === 'MEMBERS') return 'MEMBER';
      return 'OWNER';
    }
    if (!viewer) return 'ANONYMOUS';
    return (await this.connections.areConnected(viewer.userId, p.userId)) ? 'CONNECTION' : 'MEMBER';
  }
}
