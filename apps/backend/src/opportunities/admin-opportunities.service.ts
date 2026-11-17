import { randomBytes } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import {
  type ApplicationMethod,
  type LinkStatus,
  type OpportunityStatus,
  type OpportunityTrust,
  Prisma,
  type WorkMode,
} from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { DomainEventBus } from '../community-core/domain-events';
import { pageMeta, toSkipTake } from '../common/pagination';
import { PrismaService, type TxClient } from '../prisma/prisma.service';
import {
  type AdminOpportunitiesQueryDto,
  type AdminOpportunityDto,
  type AdminProviderDto,
  type AdminProvidersQueryDto,
  type FeatureOpportunityDto,
  type ImportCommitResultDto,
  type ImportReportDto,
  type OpportunityFieldsDto,
  type ProviderFieldsDto,
  type RuleInputDto,
  type UpdateOpportunityDto,
  type UpdateProviderDto,
  type VerifyProviderDto,
} from './opportunities.dto';
import {
  validateImport,
  type ImportIssue,
  type ImportRow,
  MAX_IMPORT_BYTES,
} from './opportunity-csv';
import {
  applicationDomain,
  assertTransition,
  parseApplicationUrl,
  slugify,
  STAFF_TRUST_VALUES,
  type TransitionName,
} from './opportunity-logic';
import { parseRuleParams } from './opportunity-rules';

export interface AdminActor {
  userId: string;
  ip?: string | undefined;
  requestId?: string | undefined;
}

/** The columns a request can set on a listing, usable for both create and update. */
interface Columns {
  about?: string;
  requirements?: string[];
  benefits?: string[];
  workMode?: WorkMode;
  valueText?: string | null;
  valueMinMinor?: bigint | null;
  valueMaxMinor?: bigint | null;
  valueCurrency?: string;
  deadlineAt?: Date | null;
  countyId?: string | null;
  countryId?: string | null;
  sourceUrl?: string | null;
  applicationMethod?: ApplicationMethod;
  applicationUrl?: string | null;
  applicationEmail?: string | null;
  applicationDomain?: string | null;
  linkStatus?: LinkStatus;
  lastCheckedAt?: Date | null;
}

const isUnique = (err: unknown) =>
  err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';

const FULL_INCLUDE = {
  provider: true,
  county: { select: { name: true } },
  disciplines: { select: { disciplineId: true } },
  rules: { orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }] },
  _count: { select: { trackings: true } },
} satisfies Prisma.OpportunityInclude;

type FullRow = Prisma.OpportunityGetPayload<{ include: typeof FULL_INCLUDE }>;

const toMinor = (major: number | null | undefined): bigint | null | undefined =>
  major === undefined ? undefined : major === null ? null : BigInt(Math.round(major * 100));
const toMajor = (minor: bigint | null): number | null =>
  minor === null ? null : Number(minor) / 100;

export const providerDto = (p: {
  id: string;
  name: string;
  type: AdminProviderDto['type'];
  website: string | null;
  verificationStatus: AdminProviderDto['verificationStatus'];
  ownerUserId: string | null;
  opportunitiesCount: number;
  createdAt: Date;
}): AdminProviderDto => ({
  id: p.id,
  name: p.name,
  type: p.type,
  website: p.website,
  verificationStatus: p.verificationStatus,
  ownerUserId: p.ownerUserId,
  opportunitiesCount: p.opportunitiesCount,
  createdAt: p.createdAt,
});

export const adminOpportunityDto = (r: FullRow): AdminOpportunityDto => ({
  id: r.id,
  slug: r.slug,
  title: r.title,
  type: r.type,
  status: r.status,
  trust: r.trust,
  provider: providerDto(r.provider),
  summary: r.summary,
  about: r.about,
  requirements: Array.isArray(r.requirements) ? (r.requirements as string[]) : [],
  benefits: Array.isArray(r.benefits) ? (r.benefits as string[]) : [],
  valueMin: toMajor(r.valueMinMinor),
  valueMax: toMajor(r.valueMaxMinor),
  valueCurrency: r.valueCurrency,
  valueText: r.valueText,
  deadlineAt: r.deadlineAt,
  countyId: r.countyId,
  countyName: r.county?.name ?? null,
  workMode: r.workMode,
  applicationMethod: r.applicationMethod,
  applicationUrl: r.applicationUrl,
  applicationEmail: r.applicationEmail,
  applicationDomain: r.applicationDomain,
  sourceUrl: r.sourceUrl,
  featuredUntil: r.featuredUntil,
  linkStatus: r.linkStatus,
  lastCheckedAt: r.lastCheckedAt,
  publishedAt: r.publishedAt,
  disciplineIds: r.disciplines.map((d) => d.disciplineId),
  rules: r.rules.map((x) => ({
    id: x.id,
    ruleType: x.ruleType,
    params: (x.params ?? {}) as Record<string, unknown>,
    label: x.label,
    isBlocking: x.isBlocking,
    sortOrder: x.sortOrder,
  })),
  trackerCount: r._count.trackings,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
});

/** Recomputes `opportunitiesCount` (published, not past the deadline) for some providers, or for all of them. */
export async function refreshProviderCounts(
  db: Pick<TxClient, '$executeRaw'>,
  providerIds?: string[],
): Promise<number> {
  const only = providerIds ? Prisma.sql`AND p.id = ANY(${providerIds}::uuid[])` : Prisma.empty;
  return db.$executeRaw(Prisma.sql`
    UPDATE opportunity_providers p SET "opportunitiesCount" = s.n
    FROM (
      SELECT p2.id, (
        SELECT count(*) FROM opportunities o
        WHERE o."providerId" = p2.id AND o.status::text = 'PUBLISHED'
          AND (o."deadlineAt" IS NULL OR o."deadlineAt" > now())
      )::int AS n FROM opportunity_providers p2) s
    WHERE s.id = p.id AND p."opportunitiesCount" <> s.n ${only}`);
}

/**
 * Opportunity operations for staff and for providers (P1-M9). Staff publish and badge listings; a provider's own
 * submission always lands in PENDING_REVIEW with the lowest trust level, and only `opportunity.verify` can set VERIFIED.
 * Every change is audited.
 */
@Injectable()
export class AdminOpportunitiesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly bus: DomainEventBus,
  ) {}

  // ---- reads --------------------------------------------------------------------------------------------------

  async list(q: AdminOpportunitiesQueryDto, scope: { ownerUserId?: string } = {}) {
    const where: Prisma.OpportunityWhereInput = {
      ...(q.status ? { status: q.status } : {}),
      ...(q.type ? { type: q.type } : {}),
      ...(q.providerId ? { providerId: q.providerId } : {}),
      ...(q.brokenLink ? { linkStatus: 'BROKEN' } : {}),
      ...(q.q
        ? {
            OR: [
              { title: { contains: q.q.trim(), mode: 'insensitive' } },
              { provider: { name: { contains: q.q.trim(), mode: 'insensitive' } } },
            ],
          }
        : {}),
      ...(scope.ownerUserId ? { provider: { ownerUserId: scope.ownerUserId } } : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.opportunity.count({ where }),
      this.prisma.opportunity.findMany({
        where,
        include: FULL_INCLUDE,
        orderBy: [{ updatedAt: 'desc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
    ]);
    return { items: rows.map(adminOpportunityDto), meta: pageMeta(q, total) };
  }

  async get(id: string, scope: { ownerUserId?: string } = {}): Promise<AdminOpportunityDto> {
    return adminOpportunityDto(await this.load(id, scope));
  }

  private async load(id: string, scope: { ownerUserId?: string } = {}): Promise<FullRow> {
    const row = await this.prisma.opportunity.findFirst({
      where: { id, ...(scope.ownerUserId ? { provider: { ownerUserId: scope.ownerUserId } } : {}) },
      include: FULL_INCLUDE,
    });
    if (!row) throw ApiException.notFound('That opportunity does not exist.');
    return row;
  }

  // ---- create and update --------------------------------------------------------------------------------------

  /**
   * Creates a listing. Staff create DRAFTs; a provider's submission (`asProvider`) is PENDING_REVIEW. The trust level
   * is never taken from the request: it starts as EXTERNAL_SOURCE and changes only through the trust endpoints.
   */
  async create(
    actor: AdminActor,
    dto: OpportunityFieldsDto,
    opts: { asProvider?: boolean } = {},
  ): Promise<AdminOpportunityDto> {
    const provider = await this.prisma.opportunityProvider.findUnique({
      where: { id: dto.providerId },
    });
    if (!provider)
      throw ApiException.validation('That provider does not exist.', { field: 'providerId' });
    if (opts.asProvider && provider.ownerUserId !== actor.userId) {
      throw ApiException.forbidden('You can only submit for your own organisation.');
    }
    const data = await this.fields(dto, null);
    const created = await this.withUniqueSlug(dto.title, async (slug) =>
      this.prisma.$transaction(async (tx) => {
        const row = await tx.opportunity.create({
          data: {
            ...data,
            slug,
            providerId: dto.providerId,
            type: dto.type,
            title: dto.title.trim(),
            summary: dto.summary.trim(),
            status: opts.asProvider ? 'PENDING_REVIEW' : 'DRAFT',
            trust: 'EXTERNAL_SOURCE',
            createdById: actor.userId,
          },
        });
        await this.writeRelations(tx, row.id, dto);
        await this.audit.record(
          {
            actorType: opts.asProvider ? 'USER' : 'ADMIN',
            actorId: actor.userId,
            action: 'opportunity.create',
            entityType: 'opportunity',
            entityId: row.id,
            after: {
              title: row.title,
              type: row.type,
              providerId: row.providerId,
              status: row.status,
            },
            ip: actor.ip ?? null,
            requestId: actor.requestId ?? null,
          },
          tx,
        );
        return row;
      }),
    );
    return this.get(created.id);
  }

  async update(
    actor: AdminActor,
    id: string,
    dto: UpdateOpportunityDto,
    opts: { asProvider?: boolean } = {},
  ): Promise<AdminOpportunityDto> {
    const before = await this.load(id, opts.asProvider ? { ownerUserId: actor.userId } : {});
    if (opts.asProvider && !['DRAFT', 'PENDING_REVIEW'].includes(before.status)) {
      throw ApiException.invalidState('A published listing can only be changed by Atarah staff.');
    }
    if (opts.asProvider && dto.providerId && dto.providerId !== before.providerId) {
      throw ApiException.forbidden('You cannot move a listing to another organisation.');
    }
    if (dto.providerId && dto.providerId !== before.providerId) {
      const exists = await this.prisma.opportunityProvider.count({ where: { id: dto.providerId } });
      if (!exists)
        throw ApiException.validation('That provider does not exist.', { field: 'providerId' });
    }
    const data = await this.fields(dto, before);
    await this.prisma.$transaction(async (tx) => {
      await tx.opportunity.update({
        where: { id },
        data: {
          ...data,
          ...(dto.title !== undefined ? { title: dto.title.trim() } : {}),
          ...(dto.summary !== undefined ? { summary: dto.summary.trim() } : {}),
          ...(dto.type !== undefined ? { type: dto.type } : {}),
          ...(dto.providerId !== undefined ? { providerId: dto.providerId } : {}),
        },
      });
      await this.writeRelations(tx, id, dto);
      if (dto.providerId && dto.providerId !== before.providerId) {
        await refreshProviderCounts(tx, [before.providerId, dto.providerId]);
      }
      await this.audit.record(
        {
          actorType: opts.asProvider ? 'USER' : 'ADMIN',
          actorId: actor.userId,
          action: 'opportunity.update',
          entityType: 'opportunity',
          entityId: id,
          before: { title: before.title, status: before.status, deadlineAt: before.deadlineAt },
          after: { fields: Object.keys(dto) },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
    });
    return this.get(id);
  }

  /** Turns the request into column values. Only fields that were sent are returned (PATCH semantics). */
  private async fields(dto: UpdateOpportunityDto, before: FullRow | null): Promise<Columns> {
    const out: Columns = {};
    if (dto.about !== undefined) out.about = dto.about.trim();
    if (dto.requirements !== undefined) out.requirements = dto.requirements;
    if (dto.benefits !== undefined) out.benefits = dto.benefits;
    if (dto.workMode !== undefined) out.workMode = dto.workMode;
    if (dto.valueText !== undefined) out.valueText = dto.valueText?.trim() || null;
    if (dto.valueMin !== undefined) out.valueMinMinor = toMinor(dto.valueMin);
    if (dto.valueMax !== undefined) out.valueMaxMinor = toMinor(dto.valueMax);
    if (dto.valueCurrency !== undefined) out.valueCurrency = dto.valueCurrency.toUpperCase();
    const min =
      out.valueMinMinor !== undefined ? out.valueMinMinor : (before?.valueMinMinor ?? null);
    const max =
      out.valueMaxMinor !== undefined ? out.valueMaxMinor : (before?.valueMaxMinor ?? null);
    if (min !== null && max !== null && min > max) {
      throw ApiException.validation('The smallest amount is above the largest.', {
        field: 'valueMin',
      });
    }
    if (
      (min !== null || max !== null) &&
      out.valueCurrency === undefined &&
      !before?.valueCurrency
    ) {
      out.valueCurrency = 'KES';
    }
    if (dto.deadlineAt !== undefined) {
      out.deadlineAt = dto.deadlineAt === null ? null : new Date(dto.deadlineAt);
    }
    if (dto.countyId !== undefined) {
      if (dto.countyId !== null) {
        const county = await this.prisma.county.findUnique({ where: { id: dto.countyId } });
        if (!county)
          throw ApiException.validation('That county does not exist.', { field: 'countyId' });
        out.countryId = county.countryId;
      } else {
        out.countryId = null;
      }
      out.countyId = dto.countyId;
    }
    if (dto.sourceUrl !== undefined) {
      out.sourceUrl = dto.sourceUrl ? parseApplicationUrl(dto.sourceUrl).href : null;
    }

    // Application method, address and the derived domain move together.
    const method = dto.applicationMethod ?? before?.applicationMethod ?? 'EXTERNAL_WEBSITE';
    let url = before?.applicationUrl ?? null;
    let email = before?.applicationEmail ?? null;
    if (dto.applicationUrl !== undefined) url = parseApplicationUrl(dto.applicationUrl).href;
    if (dto.applicationEmail !== undefined) email = dto.applicationEmail.trim().toLowerCase();
    if (
      dto.applicationMethod !== undefined ||
      dto.applicationUrl !== undefined ||
      dto.applicationEmail !== undefined
    ) {
      if (method === 'EXTERNAL_WEBSITE' && !url && !before) {
        throw ApiException.validation('Give the web address where members apply.', {
          field: 'applicationUrl',
        });
      }
      if (method === 'EMAIL' && !email) {
        throw ApiException.validation('Give the email address where members apply.', {
          field: 'applicationEmail',
        });
      }
      out.applicationMethod = method;
      out.applicationUrl = method === 'EXTERNAL_WEBSITE' ? url : null;
      out.applicationEmail = method === 'EMAIL' ? email : null;
      out.applicationDomain = applicationDomain(
        method,
        out.applicationUrl ?? null,
        out.applicationEmail ?? null,
      );
      if (out.applicationUrl !== before?.applicationUrl) {
        out.linkStatus = 'UNKNOWN';
        out.lastCheckedAt = null;
      }
    }
    return out;
  }

  /** Replaces disciplines and rules when the request carries them. Rule params are validated per type. */
  private async writeRelations(
    tx: TxClient,
    id: string,
    dto: { disciplineIds?: string[] | undefined; rules?: RuleInputDto[] | undefined },
  ): Promise<void> {
    if (dto.disciplineIds !== undefined) {
      const unique = [...new Set(dto.disciplineIds)];
      const found = await tx.discipline.count({ where: { id: { in: unique } } });
      if (found !== unique.length) {
        throw ApiException.validation('One of those disciplines does not exist.', {
          field: 'disciplineIds',
        });
      }
      await tx.opportunityDiscipline.deleteMany({ where: { opportunityId: id } });
      if (unique.length > 0) {
        await tx.opportunityDiscipline.createMany({
          data: unique.map((disciplineId) => ({ opportunityId: id, disciplineId })),
        });
      }
    }
    if (dto.rules !== undefined) {
      const rules = dto.rules.map((r, i) => ({
        opportunityId: id,
        ruleType: r.ruleType,
        params: parseRuleParams(r.ruleType, r.params) as Prisma.InputJsonValue,
        label: r.label.trim(),
        isBlocking: r.isBlocking ?? true,
        sortOrder: i,
      }));
      await tx.opportunityRequirementRule.deleteMany({ where: { opportunityId: id } });
      if (rules.length > 0) await tx.opportunityRequirementRule.createMany({ data: rules });
    }
  }

  private async withUniqueSlug<T>(
    title: string,
    attempt: (slug: string) => Promise<T>,
  ): Promise<T> {
    for (let i = 0; i < 5; i += 1) {
      try {
        return await attempt(`${slugify(title)}-${randomBytes(3).toString('hex')}`);
      } catch (e) {
        if (!isUnique(e)) throw e;
      }
    }
    throw ApiException.conflict('Could not create a unique address for that listing. Try again.');
  }

  // ---- lifecycle ----------------------------------------------------------------------------------------------

  async transition(
    actor: AdminActor,
    id: string,
    name: TransitionName,
    reason?: string,
  ): Promise<AdminOpportunityDto> {
    const before = await this.load(id);
    const to: OpportunityStatus = assertTransition(name, before.status);
    if (name === 'publish') this.assertPublishable(before);
    await this.prisma.$transaction(async (tx) => {
      await tx.opportunity.update({
        where: { id },
        data: {
          status: to,
          ...(name === 'publish' && !before.publishedAt ? { publishedAt: new Date() } : {}),
          ...(name === 'publish' ? { isPublic: false } : {}),
          ...(name === 'archive' || name === 'remove' ? { featuredUntil: null } : {}),
        },
      });
      await refreshProviderCounts(tx, [before.providerId]);
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: `opportunity.${name}`,
          entityType: 'opportunity',
          entityId: id,
          before: { status: before.status },
          after: { status: to, ...(reason ? { reason } : {}) },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
    });
    if (name === 'publish') {
      await this.bus.emit({
        type: 'OpportunityPublished',
        opportunityId: id,
        actorId: actor.userId,
      });
    } else if (name === 'reject') {
      await this.bus.emit({
        type: 'OpportunityRejected',
        opportunityId: id,
        actorId: actor.userId,
        reason: reason ?? '',
      });
    }
    return this.get(id);
  }

  /** A listing cannot go live half-written: it needs a way to apply and a future (or no) deadline. */
  private assertPublishable(r: FullRow): void {
    if (r.deadlineAt && r.deadlineAt <= new Date()) {
      throw ApiException.validation('The deadline has already passed. Move it before publishing.', {
        field: 'deadlineAt',
      });
    }
    if (r.applicationMethod === 'EXTERNAL_WEBSITE' && !r.applicationUrl) {
      throw ApiException.validation('Add the web address where members apply before publishing.', {
        field: 'applicationUrl',
      });
    }
    if (r.applicationMethod === 'EMAIL' && !r.applicationEmail) {
      throw ApiException.validation(
        'Add the email address where members apply before publishing.',
        {
          field: 'applicationEmail',
        },
      );
    }
    if (r.applicationMethod === 'IN_APP') {
      throw ApiException.validation('In-app applications are not available yet.', {
        field: 'applicationMethod',
      });
    }
  }

  async feature(
    actor: AdminActor,
    id: string,
    dto: FeatureOpportunityDto,
  ): Promise<AdminOpportunityDto> {
    const before = await this.load(id);
    const until = dto.until ? new Date(dto.until) : null;
    if (until && until <= new Date()) {
      throw ApiException.validation('Pick a time in the future.', { field: 'until' });
    }
    if (until && before.status !== 'PUBLISHED') {
      throw ApiException.invalidState('Only a published listing can be featured.');
    }
    await this.prisma.$transaction(async (tx) => {
      await tx.opportunity.update({ where: { id }, data: { featuredUntil: until } });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: until ? 'opportunity.feature' : 'opportunity.unfeature',
          entityType: 'opportunity',
          entityId: id,
          before: { featuredUntil: before.featuredUntil },
          after: { featuredUntil: until },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
    });
    return this.get(id);
  }

  /**
   * Trust badge. `VERIFIED` ("Verified by Atarah") is reachable only through `verify`, which needs the
   * `opportunity.verify` permission; `setTrust` handles the two lower levels and refuses VERIFIED.
   */
  async setTrust(
    actor: AdminActor,
    id: string,
    trust: OpportunityTrust,
    reason: string | undefined,
    opts: { verify?: boolean } = {},
  ): Promise<AdminOpportunityDto> {
    if (trust === 'VERIFIED' && !opts.verify) {
      throw ApiException.forbidden('Only a verifier can mark a listing as Verified by Atarah.');
    }
    if (trust !== 'VERIFIED' && !(STAFF_TRUST_VALUES as readonly string[]).includes(trust)) {
      throw ApiException.validation('That trust level is not valid.', { field: 'trust' });
    }
    const before = await this.load(id);
    await this.prisma.$transaction(async (tx) => {
      await tx.opportunity.update({ where: { id }, data: { trust } });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: trust === 'VERIFIED' ? 'opportunity.verify' : 'opportunity.trust.set',
          entityType: 'opportunity',
          entityId: id,
          before: { trust: before.trust },
          after: { trust, ...(reason ? { reason } : {}) },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
    });
    return this.get(id);
  }

  // ---- providers ----------------------------------------------------------------------------------------------

  async listProviders(q: AdminProvidersQueryDto) {
    const where: Prisma.OpportunityProviderWhereInput = {
      ...(q.q ? { name: { contains: q.q.trim(), mode: 'insensitive' } } : {}),
      ...(q.verification ? { verificationStatus: q.verification } : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.opportunityProvider.count({ where }),
      this.prisma.opportunityProvider.findMany({
        where,
        orderBy: [{ name: 'asc' }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
    ]);
    return { items: rows.map(providerDto), meta: pageMeta(q, total) };
  }

  async getProvider(id: string): Promise<AdminProviderDto> {
    const p = await this.prisma.opportunityProvider.findUnique({ where: { id } });
    if (!p) throw ApiException.notFound('That provider does not exist.');
    return providerDto(p);
  }

  async createProvider(actor: AdminActor, dto: ProviderFieldsDto): Promise<AdminProviderDto> {
    const website = dto.website ? parseApplicationUrl(dto.website).href : null;
    await this.assertOwner(dto.ownerUserId ?? null);
    const row = await this.prisma.$transaction(async (tx) => {
      const p = await tx.opportunityProvider.create({
        data: {
          name: dto.name.trim(),
          type: dto.type ?? 'OTHER',
          website,
          ownerUserId: dto.ownerUserId ?? null,
        },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'opportunity-provider.create',
          entityType: 'opportunity_provider',
          entityId: p.id,
          after: { name: p.name, type: p.type, ownerUserId: p.ownerUserId },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
      return p;
    });
    return providerDto(row);
  }

  async updateProvider(
    actor: AdminActor,
    id: string,
    dto: UpdateProviderDto,
  ): Promise<AdminProviderDto> {
    const before = await this.prisma.opportunityProvider.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That provider does not exist.');
    if (dto.ownerUserId) await this.assertOwner(dto.ownerUserId);
    const row = await this.prisma.$transaction(async (tx) => {
      const p = await tx.opportunityProvider.update({
        where: { id },
        data: {
          ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
          ...(dto.type !== undefined ? { type: dto.type } : {}),
          ...(dto.website !== undefined
            ? { website: dto.website ? parseApplicationUrl(dto.website).href : null }
            : {}),
          ...(dto.ownerUserId !== undefined ? { ownerUserId: dto.ownerUserId } : {}),
        },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'opportunity-provider.update',
          entityType: 'opportunity_provider',
          entityId: id,
          before: { name: before.name, type: before.type, ownerUserId: before.ownerUserId },
          after: { fields: Object.keys(dto) },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
      return p;
    });
    return providerDto(row);
  }

  async verifyProvider(
    actor: AdminActor,
    id: string,
    dto: VerifyProviderDto,
  ): Promise<AdminProviderDto> {
    const before = await this.prisma.opportunityProvider.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That provider does not exist.');
    const row = await this.prisma.$transaction(async (tx) => {
      const p = await tx.opportunityProvider.update({
        where: { id },
        data: { verificationStatus: dto.status },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'opportunity-provider.verify',
          entityType: 'opportunity_provider',
          entityId: id,
          before: { verificationStatus: before.verificationStatus },
          after: { verificationStatus: dto.status, ...(dto.reason ? { reason: dto.reason } : {}) },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
      return p;
    });
    return providerDto(row);
  }

  /** The signed-in provider's own organisations (the providers they own). */
  async ownProviders(userId: string): Promise<AdminProviderDto[]> {
    const rows = await this.prisma.opportunityProvider.findMany({
      where: { ownerUserId: userId },
      orderBy: { name: 'asc' },
    });
    return rows.map(providerDto);
  }

  private async assertOwner(userId: string | null): Promise<void> {
    if (!userId) return;
    const user = await this.prisma.user.count({ where: { id: userId, deletedAt: null } });
    if (!user)
      throw ApiException.validation('That account does not exist.', { field: 'ownerUserId' });
  }

  // ---- CSV import ---------------------------------------------------------------------------------------------

  /** Parse, validate and resolve every row without writing anything. */
  async previewImport(csv: string): Promise<ImportReportDto> {
    const { report, resolved } = await this.resolveImport(csv);
    return {
      totalCount: report.totalCount,
      validCount: resolved.length,
      issues: report.issues,
      preview: resolved.slice(0, 100).map((r) => ({
        line: r.row.line,
        title: r.row.title,
        provider: r.row.provider,
        type: r.row.type,
        deadlineAt: r.row.deadlineAt,
        providerExists: r.providerId !== null,
      })),
    };
  }

  /** Creates the valid rows as DRAFT. An import never publishes, and rows that duplicate a listing are skipped. */
  async commitImport(actor: AdminActor, csv: string): Promise<ImportCommitResultDto> {
    const { report, resolved } = await this.resolveImport(csv);
    let created = 0;
    let skipped = 0;
    const issues: ImportIssue[] = [...report.issues];
    for (const r of resolved) {
      const duplicate = await this.prisma.opportunity.count({
        where: {
          title: { equals: r.row.title, mode: 'insensitive' },
          provider: { name: { equals: r.row.provider, mode: 'insensitive' } },
          status: { notIn: ['REMOVED', 'ARCHIVED'] },
        },
      });
      if (duplicate > 0) {
        skipped += 1;
        issues.push({
          line: r.row.line,
          column: 'title',
          message: 'Already exists for this provider. Skipped.',
        });
        continue;
      }
      await this.withUniqueSlug(r.row.title, (slug) =>
        this.prisma.$transaction(async (tx) => {
          const providerId =
            r.providerId ??
            (
              await tx.opportunityProvider.create({
                data: { name: r.row.provider, type: 'OTHER' },
              })
            ).id;
          const row = await tx.opportunity.create({
            data: {
              slug,
              providerId,
              type: r.row.type,
              title: r.row.title,
              summary: r.row.summary,
              about: r.row.about,
              requirements: r.row.requirements,
              benefits: r.row.benefits,
              valueMinMinor: r.row.valueMinMinor,
              valueMaxMinor: r.row.valueMaxMinor,
              valueCurrency: r.row.valueCurrency,
              valueText: r.row.valueText,
              deadlineAt: r.row.deadlineAt,
              countyId: r.countyId,
              countryId: r.countryId,
              workMode: r.row.workMode,
              applicationMethod: 'EXTERNAL_WEBSITE',
              applicationUrl: r.row.applicationUrl,
              applicationDomain: applicationDomain('EXTERNAL_WEBSITE', r.row.applicationUrl, null),
              sourceUrl: r.row.sourceUrl,
              importedAt: new Date(),
              // Imported rows are never trusted or published automatically.
              trust: 'EXTERNAL_SOURCE',
              status: 'DRAFT',
              createdById: actor.userId,
            },
          });
          if (r.disciplineIds.length > 0) {
            await tx.opportunityDiscipline.createMany({
              data: r.disciplineIds.map((disciplineId) => ({
                opportunityId: row.id,
                disciplineId,
              })),
            });
          }
          return row;
        }),
      );
      created += 1;
    }
    await this.audit.record({
      actorType: 'ADMIN',
      actorId: actor.userId,
      action: 'opportunity.import',
      entityType: 'opportunity',
      after: { created, skipped, rejected: report.totalCount - resolved.length },
      ip: actor.ip ?? null,
      requestId: actor.requestId ?? null,
    });
    return { created, skipped, status: 'DRAFT', issues };
  }

  private async resolveImport(csv: string) {
    if (Buffer.byteLength(csv, 'utf8') > MAX_IMPORT_BYTES) {
      throw ApiException.validation('That file is too large (1 MB at most).', { field: 'csv' });
    }
    const report = validateImport(csv);
    const [counties, disciplines, providers] = await Promise.all([
      this.prisma.county.findMany({
        select: { id: true, name: true, code: true, countryId: true },
      }),
      this.prisma.discipline.findMany({ select: { id: true, name: true, slug: true } }),
      this.prisma.opportunityProvider.findMany({ select: { id: true, name: true } }),
    ]);
    const issues = [...report.issues];
    const resolved: Array<{
      row: ImportRow;
      providerId: string | null;
      countyId: string | null;
      countryId: string | null;
      disciplineIds: string[];
    }> = [];
    for (const row of report.rows) {
      let ok = true;
      let county: (typeof counties)[number] | null = null;
      if (row.county) {
        const key = row.county.toLowerCase();
        county =
          counties.find((c) => c.name.toLowerCase() === key || c.code.toLowerCase() === key) ??
          null;
        if (!county) {
          issues.push({
            line: row.line,
            column: 'county',
            message: `County "${row.county}" is not in the list.`,
          });
          ok = false;
        }
      }
      const disciplineIds: string[] = [];
      for (const d of row.disciplines) {
        const key = d.toLowerCase();
        const found = disciplines.find((x) => x.name.toLowerCase() === key || x.slug === key);
        if (!found) {
          issues.push({
            line: row.line,
            column: 'disciplines',
            message: `Discipline "${d}" is not in the list.`,
          });
          ok = false;
        } else disciplineIds.push(found.id);
      }
      if (!ok) continue;
      resolved.push({
        row,
        providerId:
          providers.find((p) => p.name.toLowerCase() === row.provider.toLowerCase())?.id ?? null,
        countyId: county?.id ?? null,
        countryId: county?.countryId ?? null,
        disciplineIds,
      });
    }
    issues.sort((a, b) => a.line - b.line);
    return { report: { ...report, issues }, resolved };
  }

  // ---- link health --------------------------------------------------------------------------------------------

  async linkHealth(q: { page: number; limit: number; result?: 'BROKEN' | 'OK' | 'UNKNOWN' }) {
    const where: Prisma.OpportunityWhereInput = {
      status: { in: ['PUBLISHED', 'PENDING_REVIEW', 'DRAFT'] },
      applicationMethod: 'EXTERNAL_WEBSITE',
      linkStatus: q.result ?? 'BROKEN',
    };
    const [total, rows, broken, ok, unknown] = await Promise.all([
      this.prisma.opportunity.count({ where }),
      this.prisma.opportunity.findMany({
        where,
        include: {
          provider: { select: { name: true } },
          linkChecks: { orderBy: { checkedAt: 'desc' }, take: 1 },
        },
        orderBy: [{ lastCheckedAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }],
        ...toSkipTake(q),
      }),
      this.prisma.opportunity.count({ where: { ...where, linkStatus: 'BROKEN' } }),
      this.prisma.opportunity.count({ where: { ...where, linkStatus: 'OK' } }),
      this.prisma.opportunity.count({ where: { ...where, linkStatus: 'UNKNOWN' } }),
    ]);
    return {
      items: rows.map((r) => ({
        opportunityId: r.id,
        title: r.title,
        provider: r.provider.name,
        status: r.status,
        applicationUrl: r.applicationUrl,
        linkStatus: r.linkStatus,
        httpStatus: r.linkChecks[0]?.httpStatus ?? null,
        error: r.linkChecks[0]?.error ?? null,
        checkedAt: r.linkChecks[0]?.checkedAt ?? r.lastCheckedAt,
      })),
      meta: { ...pageMeta(q, total), counts: { broken, ok, unknown } },
    };
  }
}
