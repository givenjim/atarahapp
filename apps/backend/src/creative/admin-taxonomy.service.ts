import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService, type TxClient } from '../prisma/prisma.service';
import {
  type AdminSuggestionsQueryDto,
  type AdminTaxonomyQueryDto,
  type CreateTaxonomyItemDto,
  type TaxonomyKind,
  type UpdateTaxonomyItemDto,
} from './creative.dto';
import { CreativeProfileService } from './creative-profile.service';
import { slugify } from './slug';

export interface Actor {
  userId: string;
  ip?: string;
  requestId?: string;
}

/** The few fields every taxonomy table shares, so one implementation can serve all five. */
interface Row {
  id: string;
  slug: string;
  name: string;
  sortOrder: number;
  isActive: boolean;
  icon?: string;
  disciplineId?: string | null;
  discipline?: { name: string } | null;
}

interface Table {
  findMany(args: Record<string, unknown>): Promise<Row[]>;
  findUnique(args: Record<string, unknown>): Promise<Row | null>;
  create(args: Record<string, unknown>): Promise<Row>;
  update(args: Record<string, unknown>): Promise<Row>;
  aggregate(args: Record<string, unknown>): Promise<{ _max: { sortOrder: number | null } }>;
}

interface KindConfig {
  table: (db: TxClient | PrismaService) => Table;
  entity: string;
  /** How many members use each entry. */
  usage: (db: TxClient | PrismaService) => Promise<Map<string, number>>;
  scoped: boolean;
  disciplineRequired?: boolean;
  hasIcon?: boolean;
}

const counts = (rows: Array<{ id: string; n: number }>) => new Map(rows.map((r) => [r.id, r.n]));

const KINDS: Record<TaxonomyKind, KindConfig> = {
  disciplines: {
    table: (db) => db.discipline as unknown as Table,
    entity: 'Discipline',
    scoped: false,
    hasIcon: true,
    usage: async (db) =>
      counts(
        (await db.creativeDiscipline.groupBy({ by: ['disciplineId'], _count: { _all: true } })).map(
          (g) => ({ id: g.disciplineId, n: g._count._all }),
        ),
      ),
  },
  specialisations: {
    table: (db) => db.specialisation as unknown as Table,
    entity: 'Specialisation',
    scoped: true,
    disciplineRequired: true,
    usage: async (db) =>
      counts(
        (
          await db.creativeSpecialisation.groupBy({
            by: ['specialisationId'],
            _count: { _all: true },
          })
        ).map((g) => ({ id: g.specialisationId, n: g._count._all })),
      ),
  },
  skills: {
    table: (db) => db.skill as unknown as Table,
    entity: 'Skill',
    scoped: true,
    usage: async (db) =>
      counts(
        (await db.creativeSkill.groupBy({ by: ['skillId'], _count: { _all: true } })).map((g) => ({
          id: g.skillId,
          n: g._count._all,
        })),
      ),
  },
  interests: {
    table: (db) => db.interest as unknown as Table,
    entity: 'Interest',
    scoped: false,
    usage: async (db) =>
      counts(
        (await db.creativeInterest.groupBy({ by: ['interestId'], _count: { _all: true } })).map(
          (g) => ({ id: g.interestId, n: g._count._all }),
        ),
      ),
  },
  'development-areas': {
    table: (db) => db.developmentArea as unknown as Table,
    entity: 'DevelopmentArea',
    scoped: false,
    usage: async (db) =>
      counts(
        (
          await db.creativeDevelopmentArea.groupBy({
            by: ['developmentAreaId'],
            _count: { _all: true },
          })
        ).map((g) => ({ id: g.developmentAreaId, n: g._count._all })),
      ),
  },
};

const view = (r: Row, usage: Map<string, number>) => ({
  id: r.id,
  slug: r.slug,
  name: r.name,
  icon: r.icon ?? null,
  disciplineId: r.disciplineId ?? null,
  disciplineName: r.discipline?.name ?? null,
  sortOrder: r.sortOrder,
  isActive: r.isActive,
  usage: usage.get(r.id) ?? 0,
});

const isUnique = (err: unknown) =>
  err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';

@Injectable()
export class AdminTaxonomyService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly notifications: NotificationsService,
    private readonly profiles: CreativeProfileService,
  ) {}

  async list(kind: TaxonomyKind, q: AdminTaxonomyQueryDto) {
    const cfg = KINDS[kind];
    const rows = await cfg.table(this.prisma).findMany({
      where: {
        ...(q.includeArchived === false ? { isActive: true } : {}),
        ...(cfg.scoped && q.disciplineId ? { disciplineId: q.disciplineId } : {}),
      },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      ...(cfg.scoped ? { include: { discipline: { select: { name: true } } } } : {}),
    });
    const usage = await cfg.usage(this.prisma);
    return rows.map((r) => view(r, usage));
  }

  async create(actor: Actor, kind: TaxonomyKind, dto: CreateTaxonomyItemDto) {
    const cfg = KINDS[kind];
    const name = dto.name.trim().replace(/\s+/g, ' ');
    const slug = slugify(name);
    if (!slug)
      throw ApiException.validation('Use letters or numbers in the name.', { field: 'name' });
    if (cfg.disciplineRequired && !dto.disciplineId) {
      throw ApiException.validation('Choose the discipline it belongs to.', {
        field: 'disciplineId',
      });
    }
    if (cfg.hasIcon && !dto.icon?.trim()) {
      throw ApiException.validation('Add a Lucide icon name.', { field: 'icon' });
    }
    if (cfg.scoped && dto.disciplineId) await this.requireDiscipline(dto.disciplineId);

    try {
      const created = await this.prisma.transaction(async (tx) => {
        const table = cfg.table(tx);
        const max = await table.aggregate({
          _max: { sortOrder: true },
          where: cfg.scoped ? { disciplineId: dto.disciplineId ?? null } : {},
        });
        const row = await table.create({
          data: {
            slug,
            name,
            sortOrder: (max._max.sortOrder ?? 0) + 1,
            ...(cfg.hasIcon ? { icon: dto.icon!.trim() } : {}),
            ...(cfg.scoped ? { disciplineId: dto.disciplineId ?? null } : {}),
          },
        });
        await this.audit.record(
          {
            actorType: 'ADMIN',
            actorId: actor.userId,
            action: 'taxonomy.create',
            entityType: cfg.entity,
            entityId: row.id,
            after: { kind, name, slug, disciplineId: dto.disciplineId ?? null },
            ip: actor.ip,
            requestId: actor.requestId,
          },
          tx,
        );
        return row;
      });
      return view(await this.reload(kind, created.id), new Map());
    } catch (err) {
      if (isUnique(err)) {
        throw ApiException.conflict(`“${name}” already exists here.`, { field: 'name' });
      }
      throw err;
    }
  }

  async update(actor: Actor, kind: TaxonomyKind, id: string, dto: UpdateTaxonomyItemDto) {
    const cfg = KINDS[kind];
    const before = await this.reload(kind, id);
    const data: Record<string, unknown> = {};
    if (dto.name !== undefined) {
      const name = dto.name.trim().replace(/\s+/g, ' ');
      if (name.length < 2) throw ApiException.validation('Enter a name.', { field: 'name' });
      data.name = name; // the slug stays: it is the stable key other systems use
    }
    if (dto.icon !== undefined && cfg.hasIcon) data.icon = dto.icon.trim();
    if (dto.isActive !== undefined) data.isActive = dto.isActive;
    if (!Object.keys(data).length) return view(before, await cfg.usage(this.prisma));

    try {
      await this.prisma.transaction(async (tx) => {
        await cfg.table(tx).update({ where: { id }, data });
        const archived = dto.isActive !== undefined && dto.isActive !== before.isActive;
        await this.audit.record(
          {
            actorType: 'ADMIN',
            actorId: actor.userId,
            action: archived
              ? dto.isActive
                ? 'taxonomy.restore'
                : 'taxonomy.archive'
              : 'taxonomy.update',
            entityType: cfg.entity,
            entityId: id,
            before: { name: before.name, icon: before.icon ?? null, isActive: before.isActive },
            after: data,
            ip: actor.ip,
            requestId: actor.requestId,
          },
          tx,
        );
      });
    } catch (err) {
      if (isUnique(err))
        throw ApiException.conflict('That name is already in use.', { field: 'name' });
      throw err;
    }
    return view(await this.reload(kind, id), await cfg.usage(this.prisma));
  }

  /** Saves the order of a list. Ids must all belong to the same list (the same discipline). */
  async reorder(actor: Actor, kind: TaxonomyKind, ids: string[]) {
    const cfg = KINDS[kind];
    const rows = await cfg.table(this.prisma).findMany({ where: { id: { in: ids } } });
    if (rows.length !== ids.length) {
      throw ApiException.validation(
        'Some of those entries no longer exist. Refresh and try again.',
      );
    }
    if (cfg.scoped && new Set(rows.map((r) => r.disciplineId ?? null)).size > 1) {
      throw ApiException.validation('Reorder one discipline’s list at a time.');
    }
    await this.prisma.transaction(async (tx) => {
      for (const [i, id] of ids.entries()) {
        await cfg.table(tx).update({ where: { id }, data: { sortOrder: i + 1 } });
      }
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'taxonomy.reorder',
          entityType: cfg.entity,
          after: { kind, ids },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
    });
    return this.list(kind, {
      includeArchived: true,
      ...(cfg.scoped && rows[0]?.disciplineId ? { disciplineId: rows[0].disciplineId } : {}),
    });
  }

  // ---- specialisation suggestion queue --------------------------------------------------------------------

  async listSuggestions(q: AdminSuggestionsQueryDto) {
    const where: Prisma.SpecialisationSuggestionWhereInput = q.status ? { status: q.status } : {};
    const paging = { page: Math.max(1, q.page), limit: Math.min(100, Math.max(1, q.limit)) };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.specialisationSuggestion.findMany({
        where,
        include: {
          discipline: { select: { name: true } },
          user: { select: { fullName: true } },
        },
        orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
        ...toSkipTake(paging),
      }),
      this.prisma.specialisationSuggestion.count({ where }),
    ]);
    return {
      items: rows.map((s) => ({
        id: s.id,
        name: s.name,
        disciplineId: s.disciplineId,
        disciplineName: s.discipline.name,
        status: s.status,
        suggestedById: s.userId,
        suggestedByName: s.user.fullName,
        specialisationId: s.specialisationId,
        resolutionNote: s.resolutionNote,
        resolvedAt: s.resolvedAt,
        createdAt: s.createdAt,
      })),
      meta: pageMeta(paging, total),
    };
  }

  async approve(actor: Actor, id: string, name?: string) {
    const suggestion = await this.pending(id);
    const finalName = (name ?? suggestion.name).trim().replace(/\s+/g, ' ');
    const slug = slugify(finalName);
    if (!slug)
      throw ApiException.validation('Use letters or numbers in the name.', { field: 'name' });
    try {
      await this.prisma.transaction(async (tx) => {
        const max = await tx.specialisation.aggregate({
          _max: { sortOrder: true },
          where: { disciplineId: suggestion.disciplineId },
        });
        const created = await tx.specialisation.create({
          data: {
            disciplineId: suggestion.disciplineId,
            name: finalName,
            slug,
            sortOrder: (max._max.sortOrder ?? 0) + 1,
          },
        });
        await this.resolve(tx, actor, suggestion.id, 'APPROVED', created.id, null, {
          action: 'specialisation_suggestion.approve',
          name: finalName,
        });
        await this.attachToAuthor(tx, suggestion.userId, suggestion.disciplineId, created.id);
      });
    } catch (err) {
      if (isUnique(err)) {
        throw ApiException.conflict(
          `“${finalName}” is already in that discipline. Merge the suggestion into it instead.`,
        );
      }
      throw err;
    }
    await this.tell(suggestion.userId, suggestion.name, 'APPROVED');
    return this.suggestionView(id);
  }

  async merge(actor: Actor, id: string, specialisationId: string) {
    const suggestion = await this.pending(id);
    const target = await this.prisma.specialisation.findUnique({ where: { id: specialisationId } });
    if (!target || target.disciplineId !== suggestion.disciplineId) {
      throw ApiException.validation('Choose a specialisation from the same discipline.', {
        field: 'specialisationId',
      });
    }
    await this.prisma.transaction(async (tx) => {
      await this.resolve(tx, actor, id, 'MERGED', target.id, null, {
        action: 'specialisation_suggestion.merge',
        mergedInto: target.name,
      });
      await this.attachToAuthor(tx, suggestion.userId, suggestion.disciplineId, target.id);
    });
    await this.tell(suggestion.userId, suggestion.name, 'MERGED', target.name);
    return this.suggestionView(id);
  }

  async reject(actor: Actor, id: string, note?: string) {
    const suggestion = await this.pending(id);
    await this.prisma.transaction(async (tx) => {
      await this.resolve(tx, actor, id, 'REJECTED', null, note?.trim() || null, {
        action: 'specialisation_suggestion.reject',
      });
    });
    await this.tell(suggestion.userId, suggestion.name, 'REJECTED');
    return this.suggestionView(id);
  }

  // ---- helpers --------------------------------------------------------------------------------------------

  private async pending(id: string) {
    const s = await this.prisma.specialisationSuggestion.findUnique({ where: { id } });
    if (!s) throw ApiException.notFound('We could not find that suggestion.');
    if (s.status !== 'PENDING') {
      throw ApiException.invalidState('That suggestion has already been decided.');
    }
    return s;
  }

  private async resolve(
    tx: TxClient,
    actor: Actor,
    id: string,
    status: 'APPROVED' | 'MERGED' | 'REJECTED',
    specialisationId: string | null,
    note: string | null,
    audit: { action: string } & Record<string, unknown>,
  ) {
    // The status check inside the update makes a double click or two admins at once safe.
    const { count } = await tx.specialisationSuggestion.updateMany({
      where: { id, status: 'PENDING' },
      data: {
        status,
        specialisationId,
        resolutionNote: note,
        resolvedById: actor.userId,
        resolvedAt: new Date(),
      },
    });
    if (count !== 1) throw ApiException.invalidState('That suggestion has already been decided.');
    const { action, ...rest } = audit;
    await this.audit.record(
      {
        actorType: 'ADMIN',
        actorId: actor.userId,
        action,
        entityType: 'SpecialisationSuggestion',
        entityId: id,
        after: { status, specialisationId, note, ...rest },
        ip: actor.ip,
        requestId: actor.requestId,
      },
      tx,
    );
  }

  /** The member who asked for it gets it on their profile, if they still practise that discipline. */
  private async attachToAuthor(
    tx: TxClient,
    userId: string,
    disciplineId: string,
    specialisationId: string,
  ) {
    const profile = await tx.creativeProfile.findUnique({ where: { userId } });
    if (!profile || profile.primaryDisciplineId !== disciplineId) return;
    await tx.creativeSpecialisation.createMany({
      data: [{ profileId: profile.id, specialisationId }],
      skipDuplicates: true,
    });
    await this.profiles.refreshCompletion(profile.id).catch(() => undefined);
  }

  private async tell(
    userId: string,
    suggested: string,
    outcome: 'APPROVED' | 'MERGED' | 'REJECTED',
    mergedInto?: string,
  ) {
    const body = {
      APPROVED: `“${suggested}” is now in the list, and we added it to your profile.`,
      MERGED: `“${suggested}” was already covered by “${mergedInto}”, which is now on your profile.`,
      REJECTED: `We could not add “${suggested}” to the list this time. Pick the closest match for now.`,
    }[outcome];
    // A notification failing must never undo the admin's decision.
    await this.notifications
      .notify({ userId, category: 'PROFILE', title: 'Your specialisation suggestion', body })
      .catch(() => undefined);
  }

  private async suggestionView(id: string) {
    const s = await this.prisma.specialisationSuggestion.findUniqueOrThrow({
      where: { id },
      include: { discipline: { select: { name: true } }, user: { select: { fullName: true } } },
    });
    return {
      id: s.id,
      name: s.name,
      disciplineId: s.disciplineId,
      disciplineName: s.discipline.name,
      status: s.status,
      suggestedById: s.userId,
      suggestedByName: s.user.fullName,
      specialisationId: s.specialisationId,
      resolutionNote: s.resolutionNote,
      resolvedAt: s.resolvedAt,
      createdAt: s.createdAt,
    };
  }

  private async requireDiscipline(id: string) {
    const d = await this.prisma.discipline.findUnique({ where: { id } });
    if (!d)
      throw ApiException.validation('That discipline does not exist.', { field: 'disciplineId' });
  }

  private async reload(kind: TaxonomyKind, id: string): Promise<Row> {
    const cfg = KINDS[kind];
    const row = await cfg.table(this.prisma).findUnique({
      where: { id },
      ...(cfg.scoped ? { include: { discipline: { select: { name: true } } } } : {}),
    });
    if (!row) throw ApiException.notFound('We could not find that entry.');
    return row;
  }
}
