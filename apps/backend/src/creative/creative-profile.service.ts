import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { MediaService } from '../media/media.service';
import { PrismaService, type TxClient } from '../prisma/prisma.service';
import { type CompletionResult, computeCompletion, type ProfileFacts } from './completion';
import {
  MAX_BIO,
  type OnboardingStepValue,
  ONBOARDING_STEPS,
  type SaveOnboardingStepDto,
} from './creative.dto';
import { handleBase, handleCandidates, handleProblem, normaliseHandle } from './handle';

/** Country code used in a Passport number when the member never set a county. Cannot collide with a county code. */
export const PASSPORT_FALLBACK_CODE = 'GEN';

const PROFILE_INCLUDE = {
  user: { select: { emailVerifiedAt: true, phoneVerifiedAt: true } },
  primaryDiscipline: { select: { id: true, name: true, icon: true } },
  country: { select: { id: true, name: true } },
  county: { select: { id: true, name: true, code: true } },
  specialisations: { include: { specialisation: true } },
  skills: { include: { skill: true } },
  interests: { include: { interest: true } },
  developmentAreas: { include: { developmentArea: true } },
  passport: true,
} satisfies Prisma.CreativeProfileInclude;

type ProfileRow = Prisma.CreativeProfileGetPayload<{ include: typeof PROFILE_INCLUDE }>;

const item = (t: { id: string; slug: string; name: string }) => ({
  id: t.id,
  slug: t.slug,
  name: t.name,
});
const byName = <T extends { name: string }>(a: T, b: T) => a.name.localeCompare(b.name);

const stepIndex = (s: OnboardingStepValue) => ONBOARDING_STEPS.indexOf(s);
const nextStep = (s: OnboardingStepValue): OnboardingStepValue =>
  ONBOARDING_STEPS[Math.min(stepIndex(s) + 1, ONBOARDING_STEPS.length - 1)]!;

const isUnique = (err: unknown, field?: string): boolean =>
  err instanceof Prisma.PrismaClientKnownRequestError &&
  err.code === 'P2002' &&
  (field === undefined || String(err.meta?.target ?? '').includes(field));

@Injectable()
export class CreativeProfileService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly media: MediaService,
  ) {}

  /** The member's profile row, created on first use with their sign-up name. */
  async ensureProfile(userId: string): Promise<{ id: string }> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { fullName: true },
    });
    if (!user) throw ApiException.notFound('That account does not exist.');
    return this.prisma.creativeProfile.upsert({
      where: { userId },
      create: { userId, displayName: user.fullName.slice(0, 60) },
      update: {},
      select: { id: true },
    });
  }

  async state(userId: string) {
    const { id } = await this.ensureProfile(userId);
    return this.view(await this.load(id));
  }

  // ---- onboarding -----------------------------------------------------------------------------------------

  async saveStep(userId: string, dto: SaveOnboardingStepDto) {
    const { id } = await this.ensureProfile(userId);
    const profile = await this.load(id);
    if (profile.onboardingCompletedAt) {
      throw ApiException.invalidState(
        'Your profile setup is finished. You can edit your profile from the Profile tab.',
      );
    }
    if (!dto.skipped) await this.saveFields(profile, dto);

    // Resume where the member got to: saving an earlier step again never moves the resume point back.
    const reached = nextStep(dto.step);
    if (stepIndex(reached) > stepIndex(profile.onboardingStep)) {
      await this.prisma.creativeProfile.update({
        where: { id },
        data: { onboardingStep: reached },
      });
    }
    await this.refreshCompletion(id);
    return this.view(await this.load(id));
  }

  private async saveFields(profile: ProfileRow, dto: SaveOnboardingStepDto): Promise<void> {
    switch (dto.step) {
      case 'INTRO':
      case 'PHOTO':
        return; // nothing to store: the photo is attached through POST /me/avatar
      case 'DISCIPLINE':
        return this.saveDiscipline(profile, dto);
      case 'SPECIALISATION':
        return this.saveSpecialisations(profile, dto);
      case 'SKILLS':
        return this.saveSkills(profile, dto);
      case 'LOCATION':
        return this.saveLocation(profile, dto);
      case 'BASICS':
        return this.saveBasics(profile, dto);
    }
  }

  private async saveDiscipline(profile: ProfileRow, dto: SaveOnboardingStepDto) {
    if (!dto.disciplineId) {
      throw ApiException.validation('Choose what you create.', { field: 'disciplineId' });
    }
    const discipline = await this.prisma.discipline.findFirst({
      where: { id: dto.disciplineId, isActive: true },
    });
    if (!discipline) {
      throw ApiException.validation('That discipline is not available.', { field: 'disciplineId' });
    }
    if (profile.primaryDisciplineId === discipline.id) return;
    await this.prisma.transaction(async (tx) => {
      // Changing discipline clears specialisations and skills that belonged to the old one.
      await tx.creativeSpecialisation.deleteMany({ where: { profileId: profile.id } });
      await tx.creativeSkill.deleteMany({
        where: { profileId: profile.id, skill: { disciplineId: { not: null } } },
      });
      await tx.creativeDiscipline.deleteMany({ where: { profileId: profile.id } });
      await tx.creativeDiscipline.create({
        data: { profileId: profile.id, disciplineId: discipline.id, isPrimary: true },
      });
      await tx.creativeProfile.update({
        where: { id: profile.id },
        data: { primaryDisciplineId: discipline.id },
      });
    });
  }

  private async saveSpecialisations(profile: ProfileRow, dto: SaveOnboardingStepDto) {
    const ids = dto.specialisationIds ?? [];
    if (!profile.primaryDisciplineId) {
      throw ApiException.invalidState('Choose your discipline first.');
    }
    if (ids.length) {
      const ok = await this.prisma.specialisation.count({
        where: { id: { in: ids }, isActive: true, disciplineId: profile.primaryDisciplineId },
      });
      if (ok !== ids.length) {
        throw ApiException.validation('Pick specialisations from your discipline’s list.', {
          field: 'specialisationIds',
        });
      }
    }
    await this.prisma.transaction(async (tx) => {
      await tx.creativeSpecialisation.deleteMany({ where: { profileId: profile.id } });
      await tx.creativeSpecialisation.createMany({
        data: ids.map((specialisationId) => ({ profileId: profile.id, specialisationId })),
      });
    });
  }

  private async saveSkills(profile: ProfileRow, dto: SaveOnboardingStepDto) {
    const { skillIds, interestIds, developmentAreaIds } = dto;
    if (skillIds?.length) {
      const ok = await this.prisma.skill.count({
        where: {
          id: { in: skillIds },
          isActive: true,
          OR: [
            { disciplineId: null },
            ...(profile.primaryDisciplineId ? [{ disciplineId: profile.primaryDisciplineId }] : []),
          ],
        },
      });
      if (ok !== skillIds.length) {
        throw ApiException.validation('Pick skills from the list.', { field: 'skillIds' });
      }
    }
    if (interestIds?.length) {
      const ok = await this.prisma.interest.count({
        where: { id: { in: interestIds }, isActive: true },
      });
      if (ok !== interestIds.length) {
        throw ApiException.validation('Pick interests from the list.', { field: 'interestIds' });
      }
    }
    if (developmentAreaIds?.length) {
      const ok = await this.prisma.developmentArea.count({
        where: { id: { in: developmentAreaIds }, isActive: true },
      });
      if (ok !== developmentAreaIds.length) {
        throw ApiException.validation('Pick areas to develop from the list.', {
          field: 'developmentAreaIds',
        });
      }
    }
    // A list that is not sent is left alone; a list that is sent (even empty) replaces what was there.
    await this.prisma.transaction(async (tx) => {
      const profileId = profile.id;
      if (skillIds) {
        await tx.creativeSkill.deleteMany({ where: { profileId, skillId: { notIn: skillIds } } });
        await tx.creativeSkill.createMany({
          data: skillIds.map((skillId) => ({ profileId, skillId })),
          skipDuplicates: true,
        });
      }
      if (interestIds) {
        await tx.creativeInterest.deleteMany({
          where: { profileId, interestId: { notIn: interestIds } },
        });
        await tx.creativeInterest.createMany({
          data: interestIds.map((interestId) => ({ profileId, interestId })),
          skipDuplicates: true,
        });
      }
      if (developmentAreaIds) {
        await tx.creativeDevelopmentArea.deleteMany({
          where: { profileId, developmentAreaId: { notIn: developmentAreaIds } },
        });
        await tx.creativeDevelopmentArea.createMany({
          data: developmentAreaIds.map((developmentAreaId) => ({ profileId, developmentAreaId })),
          skipDuplicates: true,
        });
      }
    });
  }

  private async saveLocation(profile: ProfileRow, dto: SaveOnboardingStepDto) {
    let countryId: string | null = dto.countryId ?? null;
    let countyId: string | null = null;
    if (dto.countyId) {
      const county = await this.prisma.county.findFirst({
        where: { id: dto.countyId, isActive: true, country: { isActive: true } },
      });
      if (!county || (countryId && county.countryId !== countryId)) {
        throw ApiException.validation('Choose a county from the list.', { field: 'countyId' });
      }
      countyId = county.id;
      countryId = county.countryId;
    } else if (countryId) {
      const country = await this.prisma.country.findFirst({
        where: { id: countryId, isActive: true },
      });
      if (!country) {
        throw ApiException.validation('Choose a country from the list.', { field: 'countryId' });
      }
    }
    const town = dto.town?.trim().replace(/\s+/g, ' ') || null;
    await this.prisma.creativeProfile.update({
      where: { id: profile.id },
      data: {
        countryId,
        countyId,
        town: countyId ? town : null,
        ...(dto.locationVisibility ? { locationVisibility: dto.locationVisibility } : {}),
      },
    });
  }

  private async saveBasics(profile: ProfileRow, dto: SaveOnboardingStepDto) {
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
    if (dto.bio !== undefined) {
      const bio = dto.bio.trim();
      if (bio.length > MAX_BIO) {
        throw ApiException.validation(`Keep your bio to ${MAX_BIO} characters.`, { field: 'bio' });
      }
      data.bio = bio || null;
    }
    if (dto.handle !== undefined) {
      const handle = normaliseHandle(dto.handle);
      const problem = handleProblem(handle);
      if (problem) throw await this.handleError(problem, handle, profile.id);
      data.handle = handle;
    }
    try {
      await this.prisma.creativeProfile.update({ where: { id: profile.id }, data });
    } catch (err) {
      // Two members chose the same handle at the same moment: the database constraint decides.
      if (isUnique(err, 'handle'))
        throw await this.handleError('TAKEN', String(data.handle), profile.id);
      throw err;
    }
  }

  // ---- handle ---------------------------------------------------------------------------------------------

  async handleAvailability(userId: string, raw: string) {
    const handle = normaliseHandle(raw);
    const problem = handleProblem(handle);
    const { id } = await this.ensureProfile(userId);
    if (problem) {
      return {
        handle,
        available: false,
        reason: problem,
        suggestions: problem === 'RESERVED' ? await this.suggestions(handle, id) : [],
      };
    }
    const owner = await this.prisma.creativeProfile.findUnique({
      where: { handle },
      select: { id: true },
    });
    if (!owner || owner.id === id) {
      return { handle, available: true, reason: null, suggestions: [] };
    }
    return {
      handle,
      available: false,
      reason: 'TAKEN' as const,
      suggestions: await this.suggestions(handle, id),
    };
  }

  /** Up to three free alternatives built from the wanted handle. */
  private async suggestions(handle: string, profileId: string): Promise<string[]> {
    const pool = handleCandidates(handle.replace(/[^a-z0-9]/g, '') || 'creative', 12);
    const taken = await this.prisma.creativeProfile.findMany({
      where: { handle: { in: pool }, NOT: { id: profileId } },
      select: { handle: true },
    });
    const takenSet = new Set(taken.map((t) => t.handle));
    return pool.filter((c) => !takenSet.has(c)).slice(0, 3);
  }

  private async handleError(
    reason: 'INVALID' | 'RESERVED' | 'TAKEN',
    handle: string,
    profileId: string,
  ) {
    const message = {
      INVALID: 'Use 3 to 30 letters, numbers or underscores.',
      RESERVED: 'That link is reserved. Try another.',
      TAKEN: 'That profile link is taken.',
    }[reason];
    const suggestions = reason === 'INVALID' ? [] : await this.suggestions(handle, profileId);
    return reason === 'TAKEN'
      ? ApiException.conflict(message, { field: 'handle', reason, suggestions })
      : ApiException.validation(message, { field: 'handle', reason, suggestions });
  }

  // ---- avatar ---------------------------------------------------------------------------------------------

  async setAvatar(userId: string, mediaId: string) {
    const { id } = await this.ensureProfile(userId);
    const asset = await this.prisma.mediaAsset.findFirst({
      where: { id: mediaId, ownerId: userId, deletedAt: null },
    });
    // Same answer for "not yours" and "does not exist".
    if (!asset) throw ApiException.notFound('We could not find that photo.');
    if (asset.kind !== 'IMAGE' || asset.bucket !== 'PUBLIC') {
      throw ApiException.validation('Choose an image to use as your photo.', { field: 'mediaId' });
    }
    if (asset.status !== 'READY') {
      throw ApiException.invalidState(
        asset.status === 'REJECTED'
          ? (asset.rejectionReason ?? 'That photo could not be used.')
          : 'Your photo is still being processed. Try again in a moment.',
      );
    }
    const previous = (await this.prisma.creativeProfile.findUniqueOrThrow({ where: { id } }))
      .avatarMediaId;
    await this.prisma.creativeProfile.update({ where: { id }, data: { avatarMediaId: mediaId } });
    if (previous && previous !== mediaId)
      await this.media.remove(userId, previous).catch(() => undefined);
    await this.refreshCompletion(id);
    return this.view(await this.load(id));
  }

  async removeAvatar(userId: string) {
    const { id } = await this.ensureProfile(userId);
    const profile = await this.prisma.creativeProfile.findUniqueOrThrow({ where: { id } });
    if (profile.avatarMediaId) {
      await this.prisma.creativeProfile.update({ where: { id }, data: { avatarMediaId: null } });
      await this.media.remove(userId, profile.avatarMediaId).catch(() => undefined);
    }
    await this.refreshCompletion(id);
    return this.view(await this.load(id));
  }

  // ---- completion and the Passport ------------------------------------------------------------------------

  async complete(userId: string) {
    const { id } = await this.ensureProfile(userId);
    let profile = await this.load(id);
    if (!profile.onboardingCompletedAt || !profile.passport) {
      await this.finish(id);
      profile = await this.load(id);
    }
    const state = await this.view(profile);
    return {
      state,
      passport: {
        passportNumber: profile.passport!.passportNumber,
        issuedAt: profile.passport!.createdAt,
      },
    };
  }

  private async finish(profileId: string): Promise<void> {
    await this.ensureHandle(profileId);
    try {
      await this.prisma.transaction(async (tx) => {
        const profile = await tx.creativeProfile.findUniqueOrThrow({
          where: { id: profileId },
          include: { county: true, passport: true },
        });
        if (!profile.passport) {
          const countyCode = profile.county?.code ?? PASSPORT_FALLBACK_CODE;
          const sequence = await this.nextSequence(tx, countyCode);
          await tx.creativePassport.create({
            data: {
              profileId,
              countyCode,
              sequence,
              passportNumber: `ATR-${countyCode}-${String(sequence).padStart(4, '0')}`,
            },
          });
        }
        await tx.creativeProfile.update({
          where: { id: profileId },
          data: {
            onboardingStep: 'DONE',
            onboardingCompletedAt: profile.onboardingCompletedAt ?? new Date(),
          },
        });
      });
    } catch (err) {
      // A second "Finish" tap raced the first: the Passport exists already and the transaction rolled back,
      // including its counter increment, so no number is wasted.
      if (!isUnique(err, 'profileId')) throw err;
      await this.prisma.creativeProfile.update({
        where: { id: profileId },
        data: { onboardingStep: 'DONE', onboardingCompletedAt: new Date() },
      });
    }
    await this.refreshCompletion(profileId);
  }

  /** Atomic per-county counter: concurrent completions never receive the same number. */
  private async nextSequence(tx: TxClient, countyCode: string): Promise<number> {
    const rows = await tx.$queryRaw<Array<{ lastValue: number }>>`
      INSERT INTO "passport_counters" ("countyCode", "lastValue", "updatedAt")
      VALUES (${countyCode}, 1, now())
      ON CONFLICT ("countyCode")
      DO UPDATE SET "lastValue" = "passport_counters"."lastValue" + 1, "updatedAt" = now()
      RETURNING "lastValue"`;
    return Number(rows[0]!.lastValue);
  }

  /** Members who skipped the basics step still get a link: built from their name, first free one wins. */
  private async ensureHandle(profileId: string): Promise<void> {
    const profile = await this.prisma.creativeProfile.findUniqueOrThrow({
      where: { id: profileId },
    });
    if (profile.handle) return;
    const root = handleBase(profile.displayName);
    const tries = [root, ...handleCandidates(root, 40)].filter((c) => handleProblem(c) === null);
    for (const handle of tries) {
      try {
        await this.prisma.creativeProfile.update({ where: { id: profileId }, data: { handle } });
        return;
      } catch (err) {
        if (!isUnique(err, 'handle')) throw err;
      }
    }
    throw ApiException.external('We could not create your profile link. Please try again.');
  }

  /** Recompute and store the completion percentage. Call after every write to a profile. */
  async refreshCompletion(profileId: string): Promise<CompletionResult> {
    const result = computeCompletion(await this.facts(profileId));
    await this.prisma.creativeProfile.update({
      where: { id: profileId },
      data: { completionPercent: result.percent },
    });
    return result;
  }

  async facts(profileId: string): Promise<ProfileFacts> {
    const p = await this.prisma.creativeProfile.findUniqueOrThrow({
      where: { id: profileId },
      select: {
        avatarMediaId: true,
        bio: true,
        headline: true,
        primaryDisciplineId: true,
        countyId: true,
        user: { select: { emailVerifiedAt: true, phoneVerifiedAt: true } },
        _count: { select: { specialisations: true, skills: true, experiences: true } },
      },
    });
    return {
      hasAvatar: p.avatarMediaId !== null,
      bio: p.bio,
      headline: p.headline,
      hasDiscipline: p.primaryDisciplineId !== null,
      specialisationCount: p._count.specialisations,
      skillCount: p._count.skills,
      hasLocation: p.countyId !== null,
      projectCount: await this.prisma.project.count({
        where: { profileId, status: 'PUBLISHED', deletedAt: null, hiddenAt: null },
      }),
      experienceCount: p._count.experiences,
      contactVerified: p.user.emailVerifiedAt !== null || p.user.phoneVerifiedAt !== null,
    };
  }

  // ---- view -----------------------------------------------------------------------------------------------

  private async load(profileId: string): Promise<ProfileRow> {
    return this.prisma.creativeProfile.findUniqueOrThrow({
      where: { id: profileId },
      include: PROFILE_INCLUDE,
    });
  }

  private async view(p: ProfileRow) {
    const completion = computeCompletion(await this.facts(p.id));
    return {
      step: p.onboardingStep,
      completed: p.onboardingCompletedAt !== null,
      profile: {
        id: p.id,
        displayName: p.displayName,
        handle: p.handle,
        bio: p.bio,
        headline: p.headline,
        discipline: p.primaryDiscipline,
        specialisations: p.specialisations.map((s) => item(s.specialisation)).sort(byName),
        skills: p.skills.map((s) => item(s.skill)).sort(byName),
        interests: p.interests.map((s) => item(s.interest)).sort(byName),
        developmentAreas: p.developmentAreas.map((s) => item(s.developmentArea)).sort(byName),
        countryId: p.country?.id ?? null,
        countryName: p.country?.name ?? null,
        countyId: p.county?.id ?? null,
        countyName: p.county?.name ?? null,
        town: p.town,
        locationVisibility: p.locationVisibility,
        avatarUrl: await this.media.imageUrl(p.avatarMediaId, 600),
      },
      completion,
      passportNumber: p.passport?.passportNumber ?? null,
    };
  }
}
