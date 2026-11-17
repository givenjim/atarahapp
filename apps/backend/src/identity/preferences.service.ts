import { Injectable } from '@nestjs/common';
import { type Appearance } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { type UpdateAccountPreferencesDto } from './preferences.dto';

export interface PreferencesView {
  appearance: Appearance;
  locale: string;
  timeZone: string;
  marketingOptIn: boolean;
}

const select = { appearance: true, locale: true, timeZone: true, marketingOptIn: true } as const;

/** Member preferences. One row per user, created lazily on first read or patch (a missing row means the defaults). */
@Injectable()
export class PreferencesService {
  constructor(private readonly prisma: PrismaService) {}

  /** Read-through: creates the row with defaults if the member has none yet. */
  async get(userId: string): Promise<PreferencesView> {
    return this.prisma.memberPreference.upsert({
      where: { userId },
      create: { userId },
      update: {},
      select,
    });
  }

  async update(userId: string, dto: UpdateAccountPreferencesDto): Promise<PreferencesView> {
    const data = {
      ...(dto.appearance !== undefined && { appearance: dto.appearance }),
      ...(dto.locale !== undefined && { locale: dto.locale }),
      ...(dto.timeZone !== undefined && { timeZone: dto.timeZone }),
      ...(dto.marketingOptIn !== undefined && { marketingOptIn: dto.marketingOptIn }),
    };
    return this.prisma.memberPreference.upsert({
      where: { userId },
      create: { userId, ...data },
      update: data,
      select,
    });
  }
}
