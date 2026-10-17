import { Injectable } from '@nestjs/common';
import { ApiException } from '../common/api.exception';
import { ErrorCode } from '../common/error-codes';
import { PrismaService } from '../prisma/prisma.service';
import { slugify } from './slug';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const ISO = /^[A-Za-z]{2}$/;

/** Pending suggestions one member may have open at once. */
export const MAX_PENDING_SUGGESTIONS = 5;

/** "Nairobi City County" and "Nairobi" compare equal; so do "Murang'a" and "Muranga". */
export function normalisePlace(raw: string): string {
  return raw
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\b(county|city|government|province|region|of)\b/g, ' ')
    .replace(/[^a-z0-9]+/g, '');
}

const pick = (t: { id: string; slug: string; name: string }) => ({
  id: t.id,
  slug: t.slug,
  name: t.name,
});

@Injectable()
export class TaxonomyService {
  constructor(private readonly prisma: PrismaService) {}

  async disciplines() {
    const rows = await this.prisma.discipline.findMany({
      where: { isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      include: {
        specialisations: {
          where: { isActive: true },
          orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
        },
      },
    });
    return rows.map((d) => ({
      ...pick(d),
      icon: d.icon,
      specialisations: d.specialisations.map(pick),
    }));
  }

  async skills(discipline?: string) {
    let disciplineId: string | null = null;
    if (discipline) {
      const d = await this.prisma.discipline.findFirst({
        where: UUID.test(discipline) ? { id: discipline } : { slug: discipline.toLowerCase() },
        select: { id: true },
      });
      if (!d) throw ApiException.notFound('We could not find that discipline.');
      disciplineId = d.id;
    }
    const rows = await this.prisma.skill.findMany({
      where: {
        isActive: true,
        OR: [{ disciplineId: null }, ...(disciplineId ? [{ disciplineId }] : [])],
      },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
    return rows.map(pick);
  }

  async interests() {
    const rows = await this.prisma.interest.findMany({
      where: { isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
    return rows.map(pick);
  }

  async developmentAreas() {
    const rows = await this.prisma.developmentArea.findMany({
      where: { isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
    return rows.map(pick);
  }

  // ---- locations ------------------------------------------------------------------------------------------

  async countries() {
    const rows = await this.prisma.country.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
    });
    return rows.map((c) => ({
      id: c.id,
      isoCode: c.isoCode,
      name: c.name,
      callingCode: c.callingCode,
    }));
  }

  private async resolveCountry(country?: string) {
    const where = !country
      ? { isActive: true }
      : UUID.test(country)
        ? { id: country, isActive: true }
        : ISO.test(country)
          ? { isoCode: country.toUpperCase(), isActive: true }
          : null;
    const found = where
      ? await this.prisma.country.findFirst({ where, orderBy: { name: 'asc' } })
      : null;
    if (!found) throw ApiException.notFound('We could not find that country.');
    return found;
  }

  async counties(country?: string) {
    const c = await this.resolveCountry(country);
    const rows = await this.prisma.county.findMany({
      where: { countryId: c.id, isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
    return rows.map((r) => ({ id: r.id, code: r.code, name: r.name }));
  }

  /**
   * Maps the place name a phone's reverse lookup returns ("Nairobi County") to one of our counties. Returns
   * `county: null` when nothing matches clearly, so the app asks the member to choose instead of guessing.
   */
  async matchCounty(q: string, country?: string) {
    const c = await this.resolveCountry(country);
    const wanted = normalisePlace(q);
    const rows = await this.prisma.county.findMany({ where: { countryId: c.id, isActive: true } });
    if (!wanted) return { county: null, countryId: c.id };
    const exact = rows.find((r) => normalisePlace(r.name) === wanted);
    const loose = rows.filter(
      (r) => wanted.includes(normalisePlace(r.name)) || normalisePlace(r.name).includes(wanted),
    );
    const hit = exact ?? (loose.length === 1 ? loose[0] : undefined);
    return {
      county: hit ? { id: hit.id, code: hit.code, name: hit.name } : null,
      countryId: c.id,
    };
  }

  // ---- specialisation suggestions -------------------------------------------------------------------------

  async suggest(userId: string, disciplineId: string, rawName: string) {
    const name = rawName.trim().replace(/\s+/g, ' ');
    if (name.length < 2) {
      throw ApiException.validation('Enter the specialisation you would like us to add.', {
        field: 'name',
      });
    }
    const discipline = await this.prisma.discipline.findFirst({
      where: { id: disciplineId, isActive: true },
    });
    if (!discipline) {
      throw ApiException.validation('That discipline is not available.', { field: 'disciplineId' });
    }
    const slug = slugify(name);
    if (!slug) {
      throw ApiException.validation('Use letters or numbers in the name.', { field: 'name' });
    }
    const existing = await this.prisma.specialisation.findFirst({
      where: {
        disciplineId,
        OR: [{ slug }, { name: { equals: name, mode: 'insensitive' } }],
      },
    });
    if (existing) {
      throw ApiException.conflict(
        `“${existing.name}” is already in the ${discipline.name} list. Pick it from the list.`,
        { field: 'name', specialisationId: existing.id },
      );
    }
    // Asking twice for the same thing is not an error: the member gets the open request back.
    const mine = await this.prisma.specialisationSuggestion.findFirst({
      where: {
        userId,
        disciplineId,
        status: 'PENDING',
        name: { equals: name, mode: 'insensitive' },
      },
    });
    if (mine) return { id: mine.id, name: mine.name, status: mine.status };

    const pending = await this.prisma.specialisationSuggestion.count({
      where: { userId, status: 'PENDING' },
    });
    if (pending >= MAX_PENDING_SUGGESTIONS) {
      throw new ApiException(
        ErrorCode.RATE_LIMITED,
        'You have a few suggestions waiting for review. We will tell you when they are decided.',
        429,
      );
    }
    const created = await this.prisma.specialisationSuggestion.create({
      data: { userId, disciplineId, name },
    });
    return { id: created.id, name: created.name, status: created.status };
  }
}
