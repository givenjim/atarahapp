import { Inject, Injectable } from '@nestjs/common';
import { type ProfileSection, type Visibility } from '@prisma/client';
import { type Redis } from 'ioredis';
import { ApiException } from '../common/api.exception';
import { DEFAULT_VISIBILITY } from '../creative/sections';
import { ProfileService } from '../creative/profile.service';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { SecurityService } from '../identity/security.service';
import { UserViewService } from '../identity/user-view.service';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';
import {
  type MembershipViewDto,
  type PrivacyDto,
  type PrivacyFieldKey,
  type TwoStepDto,
  type UpdatePrivacyDto,
} from './account.dto';

const LABELS: Record<PrivacyFieldKey, string> = {
  CONTACT: 'Contact details',
  LOCATION: 'Location',
  PORTFOLIO: 'Portfolio',
  EXPERIENCE: 'Experience',
  ACTIVITY: 'Activity',
};
const ORDER: PrivacyFieldKey[] = ['CONTACT', 'LOCATION', 'PORTFOLIO', 'EXPERIENCE', 'ACTIVITY'];
/** Master Prompt 6.2: activity is private until the member says otherwise. */
const ACTIVITY_DEFAULT: Visibility = 'PRIVATE';

/**
 * The Privacy & visibility screen: one control per field. Contact, location, portfolio and experience are the profile
 * sections of the same name, so this writes the very rows the public profile, search and "People to meet" already read
 * (one source of truth, so a change applies everywhere at once). Activity has no section and is stored on its own.
 */
@Injectable()
export class PrivacyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly profiles: ProfileService,
  ) {}

  async get(userId: string): Promise<PrivacyDto> {
    const profile = await this.prisma.creativeProfile.findUnique({
      where: { userId },
      select: { locationVisibility: true, profileSectionVisibilities: true },
    });
    if (!profile) {
      throw ApiException.invalidState('Finish setting up your profile to choose who sees what.');
    }
    const section = (s: ProfileSection): Visibility =>
      s === 'LOCATION'
        ? profile.locationVisibility
        : (profile.profileSectionVisibilities.find((v) => v.section === s)?.visibility ??
          DEFAULT_VISIBILITY[s]);
    const activity = await this.prisma.profileFieldVisibility.findUnique({
      where: { userId_field: { userId, field: 'ACTIVITY' } },
    });
    const value = (f: PrivacyFieldKey): Visibility =>
      f === 'ACTIVITY' ? (activity?.visibility ?? ACTIVITY_DEFAULT) : section(f);
    return {
      fields: ORDER.map((field) => ({
        field,
        label: LABELS[field],
        visibility: value(field),
        defaultVisibility: field === 'ACTIVITY' ? ACTIVITY_DEFAULT : DEFAULT_VISIBILITY[field],
      })),
    };
  }

  async update(userId: string, dto: UpdatePrivacyDto): Promise<PrivacyDto> {
    if (dto.field === 'ACTIVITY') {
      await this.get(userId); // the profile must exist
      await this.prisma.profileFieldVisibility.upsert({
        where: { userId_field: { userId, field: 'ACTIVITY' } },
        create: { userId, field: 'ACTIVITY', visibility: dto.visibility },
        update: { visibility: dto.visibility },
      });
    } else {
      await this.profiles.setVisibility(userId, dto.field, dto.visibility);
    }
    return this.get(userId);
  }
}

/**
 * Two-step sign-in on new devices. The switch lives here; the second factor is a Supabase MFA factor the app enrols
 * with Auth directly. Turning it on needs a verified factor; turning it off needs a session that passed the second
 * step (AAL2) so a stolen password cannot switch protection off.
 */
@Injectable()
export class TwoStepService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly security: SecurityService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async get(userId: string): Promise<TwoStepDto> {
    const o = await this.security.overview(userId);
    return { enabled: o.twoStepEnabled, hasVerifiedFactor: o.hasVerifiedFactor };
  }

  async set(userId: string, enabled: boolean, aal: 'aal1' | 'aal2'): Promise<TwoStepDto> {
    const o = await this.security.overview(userId);
    if (enabled && !o.hasVerifiedFactor) {
      throw ApiException.invalidState('Set up your second step first, then turn two-step on.', {
        reason: 'FACTOR_REQUIRED',
      });
    }
    if (!enabled && o.twoStepEnabled && o.hasVerifiedFactor && aal !== 'aal2') {
      throw ApiException.forbidden('Confirm it is you with your second step to turn this off.', {
        reason: 'MFA_REQUIRED',
      });
    }
    await this.prisma.twoStepSetting.upsert({
      where: { userId },
      create: { userId, enabled, enabledAt: enabled ? new Date() : null },
      update: { enabled, enabledAt: enabled ? new Date() : null },
    });
    if (enabled) {
      // The devices the member is signed in on right now are theirs: they stay trusted.
      await this.prisma.userDevice.updateMany({
        where: { userId, verifiedAt: null },
        data: { verifiedAt: new Date() },
      });
    }
    await this.redis.del(`2fa:on:${userId}`).catch(() => undefined);
    return this.get(userId);
  }
}

/** The six rows of the Free versus Pro table (prototype). */
const COMPARISON: MembershipViewDto['comparison'] = [
  { label: 'Creative Passport & portfolio', free: true, pro: true },
  { label: 'Opportunities & Skill Labs', free: true, pro: true },
  { label: 'Community & groups', free: true, pro: true },
  { label: 'Mentorship booking', free: false, pro: true },
  { label: 'Verified Creative', free: false, pro: true },
  { label: 'Reduced marketplace fees', free: false, pro: true },
];

/** Read-only in Phase 1: the current plan, the price and what Pro adds. Upgrading is Phase 2. */
@Injectable()
export class MembershipViewService {
  constructor(
    private readonly views: UserViewService,
    private readonly settings: PlatformSettingsService,
  ) {}

  async get(userId: string): Promise<MembershipViewDto> {
    const [me, minor, currency] = await Promise.all([
      this.views.me(userId),
      this.settings.get<number>('membership.pro.price_minor', 120_000),
      this.settings.get<string>('membership.pro.currency', 'KES'),
    ]);
    const price = (minor / 100).toLocaleString('en-KE', { maximumFractionDigits: 0 });
    return {
      plan: me.membership.plan,
      status: me.membership.status,
      currentPeriodEnd: me.membership.currentPeriodEnd,
      proPriceLabel: `${currency} ${price} a month`,
      comparison: COMPARISON,
      scholarshipNote: 'Students and programme participants may qualify for free Pro access.',
    };
  }
}
