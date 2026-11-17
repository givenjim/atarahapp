import { Injectable } from '@nestjs/common';
import { type LegalDocument, type LegalDocumentType, Prisma } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { pageMeta, toSkipTake } from '../common/pagination';
import { normaliseBlocks, readBlocks } from '../content/blocks';
import { PlatformSettingsService } from '../feature-flags/platform-settings.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  type AdminFaqDto,
  type AdminHelpArticleDto,
  type AdminLegalDto,
  type AdminListQueryDto,
  DRAFT_LABEL,
  type FaqFieldsDto,
  type HelpArticleDto,
  type HelpArticleFieldsDto,
  type HelpBlockDto,
  type HelpContactDto,
  type HelpResultDto,
  type LegalFullDto,
  type LegalSummaryDto,
  type NewLegalVersionDto,
  type UpdateFaqDto,
  type UpdateHelpArticleDto,
  type UpdateLegalDraftDto,
} from './help.dto';

export interface Actor {
  userId: string;
  ip?: string | undefined;
  requestId?: string | undefined;
}

const isUnique = (e: unknown) =>
  e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002';

const blocksOut = (body: unknown): HelpBlockDto[] =>
  readBlocks(body)
    .filter((b) => b.type !== 'image')
    .map((b) => ({
      type: b.type,
      text: 'text' in b ? b.text : null,
      title: b.type === 'callout' ? b.title : null,
      attribution: b.type === 'quote' ? b.attribution : null,
    }));

const like = (q: string) => `%${q.replace(/[\\%_]/g, (c) => `\\${c}`)}%`;

/** Help centre for members (search, FAQ, the support contact) and the legal documents. */
@Injectable()
export class HelpService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly settings: PlatformSettingsService,
  ) {}

  async search(q: string | undefined): Promise<HelpResultDto> {
    const term = q?.trim();
    if (!term) {
      const [articles, faq] = await Promise.all([
        this.prisma.helpArticle.findMany({
          where: { published: true },
          orderBy: [{ sortOrder: 'asc' }, { title: 'asc' }],
        }),
        this.prisma.faqEntry.findMany({
          where: { published: true },
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        }),
      ]);
      return {
        articles: articles.map((a) => ({
          id: a.id,
          slug: a.slug,
          title: a.title,
          summary: a.summary,
        })),
        faq: faq.map((f) => ({ id: f.id, question: f.question, answer: f.answer })),
      };
    }
    const pattern = like(term);
    const [articles, faq] = await Promise.all([
      this.prisma.$queryRaw<
        Array<{ id: string; slug: string; title: string; summary: string }>
      >(Prisma.sql`
        SELECT id, slug, title, summary FROM help_articles
        WHERE published AND (title ILIKE ${pattern} OR summary ILIKE ${pattern}
          OR "searchVector" @@ websearch_to_tsquery('simple', ${term}))
        ORDER BY "sortOrder", title LIMIT 20`),
      this.prisma.$queryRaw<Array<{ id: string; question: string; answer: string }>>(Prisma.sql`
        SELECT id, question, answer FROM faq_entries
        WHERE published AND (question ILIKE ${pattern} OR answer ILIKE ${pattern}
          OR "searchVector" @@ websearch_to_tsquery('simple', ${term}))
        ORDER BY "sortOrder", "createdAt" LIMIT 20`),
    ]);
    return { articles, faq };
  }

  async article(slug: string): Promise<HelpArticleDto> {
    const a = await this.prisma.helpArticle.findFirst({
      where: { slug: slug.toLowerCase(), published: true },
    });
    if (!a) throw ApiException.notFound('That help article is not available.');
    return {
      id: a.id,
      slug: a.slug,
      title: a.title,
      summary: a.summary,
      blocks: blocksOut(a.body),
    };
  }

  async faq() {
    const rows = await this.prisma.faqEntry.findMany({
      where: { published: true },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    return rows.map((f) => ({ id: f.id, question: f.question, answer: f.answer }));
  }

  /** "Chat with us" opens an email to this address (DEC: a support email, not an in-app form, until Phase 3). */
  async contact(): Promise<HelpContactDto> {
    return {
      email: await this.settings.get<string>('support.email', 'support@atarah.app'),
      note: 'We answer within one working day.',
    };
  }

  // ---- legal ----------------------------------------------------------------------------------------------

  /** The version to show: the latest published, or before the owner publishes one, the seeded draft (labelled). */
  private async current(type: LegalDocumentType): Promise<LegalDocument | null> {
    return (
      (await this.prisma.legalDocument.findFirst({
        where: { type, status: 'PUBLISHED' },
        orderBy: [{ effectiveAt: 'desc' }, { createdAt: 'desc' }],
      })) ??
      (await this.prisma.legalDocument.findFirst({
        where: { type },
        orderBy: { createdAt: 'desc' },
      }))
    );
  }

  private summary(d: LegalDocument): LegalSummaryDto {
    const isDraft = d.status !== 'PUBLISHED';
    return {
      type: d.type,
      title: d.title,
      version: d.version,
      effectiveAt: d.effectiveAt,
      isDraft,
      draftLabel: isDraft ? DRAFT_LABEL : null,
    };
  }

  async legalList(): Promise<LegalSummaryDto[]> {
    const types = (
      await this.prisma.legalDocument.findMany({ distinct: ['type'], select: { type: true } })
    ).map((t) => t.type);
    const out: LegalSummaryDto[] = [];
    for (const t of types) {
      const d = await this.current(t);
      if (d) out.push(this.summary(d));
    }
    return out.sort((a, b) => a.type.localeCompare(b.type));
  }

  async legalDocument(type: LegalDocumentType): Promise<LegalFullDto> {
    const d = await this.current(type);
    if (!d) throw ApiException.notFound('That document is not available yet.');
    return { ...this.summary(d), body: d.body };
  }
}

/** Staff: help articles, FAQ and versioned legal documents. Every change is audited. */
@Injectable()
export class AdminHelpService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  private rec(
    actor: Actor,
    action: string,
    entityType: string,
    entityId: string,
    before?: unknown,
    after?: unknown,
  ) {
    return this.audit.record({
      actorType: 'ADMIN',
      actorId: actor.userId,
      action,
      entityType,
      entityId,
      before,
      after,
      ip: actor.ip ?? null,
      requestId: actor.requestId ?? null,
    });
  }

  // ---- articles ----

  private articleDto(a: {
    id: string;
    slug: string;
    title: string;
    summary: string;
    body: unknown;
    sortOrder: number;
    published: boolean;
    updatedAt: Date;
  }): AdminHelpArticleDto {
    return {
      id: a.id,
      slug: a.slug,
      title: a.title,
      summary: a.summary,
      blocks: blocksOut(a.body),
      sortOrder: a.sortOrder,
      published: a.published,
      updatedAt: a.updatedAt,
    };
  }

  private noImages(blocks: NonNullable<HelpArticleFieldsDto['blocks']>) {
    if (blocks.some((b) => b.type === 'image')) {
      throw ApiException.validation('Help articles cannot contain pictures.', { field: 'blocks' });
    }
    return normaliseBlocks(blocks);
  }

  async listArticles(q: AdminListQueryDto) {
    const where: Prisma.HelpArticleWhereInput = q.q
      ? {
          OR: [
            { title: { contains: q.q, mode: 'insensitive' } },
            { slug: { contains: q.q.toLowerCase() } },
          ],
        }
      : {};
    const [total, rows] = await Promise.all([
      this.prisma.helpArticle.count({ where }),
      this.prisma.helpArticle.findMany({
        where,
        orderBy: [{ sortOrder: 'asc' }, { title: 'asc' }],
        ...toSkipTake(q),
      }),
    ]);
    return { items: rows.map((a) => this.articleDto(a)), meta: pageMeta(q, total) };
  }

  async getArticle(id: string): Promise<AdminHelpArticleDto> {
    const a = await this.prisma.helpArticle.findUnique({ where: { id } });
    if (!a) throw ApiException.notFound('That help article does not exist.');
    return this.articleDto(a);
  }

  async createArticle(actor: Actor, dto: HelpArticleFieldsDto): Promise<AdminHelpArticleDto> {
    try {
      const a = await this.prisma.helpArticle.create({
        data: {
          slug: dto.slug,
          title: dto.title.trim(),
          summary: dto.summary?.trim() ?? '',
          body: this.noImages(dto.blocks ?? []),
          sortOrder: dto.sortOrder ?? 0,
          published: dto.published ?? false,
        },
      });
      await this.rec(actor, 'help_article.create', 'help_article', a.id, undefined, {
        slug: a.slug,
        published: a.published,
      });
      return this.articleDto(a);
    } catch (e) {
      if (isUnique(e))
        throw ApiException.conflict('An article with that address already exists.', {
          field: 'slug',
        });
      throw e;
    }
  }

  async updateArticle(
    actor: Actor,
    id: string,
    dto: UpdateHelpArticleDto,
  ): Promise<AdminHelpArticleDto> {
    const before = await this.prisma.helpArticle.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That help article does not exist.');
    const a = await this.prisma.helpArticle.update({
      where: { id },
      data: {
        ...(dto.title !== undefined ? { title: dto.title.trim() } : {}),
        ...(dto.summary !== undefined ? { summary: dto.summary.trim() } : {}),
        ...(dto.blocks !== undefined ? { body: this.noImages(dto.blocks) } : {}),
        ...(dto.sortOrder !== undefined ? { sortOrder: dto.sortOrder } : {}),
        ...(dto.published !== undefined ? { published: dto.published } : {}),
      },
    });
    await this.rec(
      actor,
      'help_article.update',
      'help_article',
      id,
      { title: before.title, published: before.published },
      { fields: Object.keys(dto) },
    );
    return this.articleDto(a);
  }

  async deleteArticle(actor: Actor, id: string): Promise<void> {
    const before = await this.prisma.helpArticle.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That help article does not exist.');
    await this.prisma.helpArticle.delete({ where: { id } });
    await this.rec(actor, 'help_article.delete', 'help_article', id, { slug: before.slug });
  }

  // ---- FAQ ----

  private faqDto(f: {
    id: string;
    question: string;
    answer: string;
    sortOrder: number;
    published: boolean;
  }): AdminFaqDto {
    return {
      id: f.id,
      question: f.question,
      answer: f.answer,
      sortOrder: f.sortOrder,
      published: f.published,
    };
  }

  async listFaq(q: AdminListQueryDto) {
    const where: Prisma.FaqEntryWhereInput = q.q
      ? { question: { contains: q.q, mode: 'insensitive' } }
      : {};
    const [total, rows] = await Promise.all([
      this.prisma.faqEntry.count({ where }),
      this.prisma.faqEntry.findMany({
        where,
        orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        ...toSkipTake(q),
      }),
    ]);
    return { items: rows.map((f) => this.faqDto(f)), meta: pageMeta(q, total) };
  }

  async createFaq(actor: Actor, dto: FaqFieldsDto): Promise<AdminFaqDto> {
    const f = await this.prisma.faqEntry.create({
      data: {
        question: dto.question.trim(),
        answer: dto.answer.trim(),
        sortOrder: dto.sortOrder ?? 0,
        published: dto.published ?? false,
      },
    });
    await this.rec(actor, 'faq.create', 'faq_entry', f.id, undefined, { question: f.question });
    return this.faqDto(f);
  }

  async updateFaq(actor: Actor, id: string, dto: UpdateFaqDto): Promise<AdminFaqDto> {
    const before = await this.prisma.faqEntry.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That question does not exist.');
    const f = await this.prisma.faqEntry.update({
      where: { id },
      data: {
        ...(dto.question !== undefined ? { question: dto.question.trim() } : {}),
        ...(dto.answer !== undefined ? { answer: dto.answer.trim() } : {}),
        ...(dto.sortOrder !== undefined ? { sortOrder: dto.sortOrder } : {}),
        ...(dto.published !== undefined ? { published: dto.published } : {}),
      },
    });
    await this.rec(
      actor,
      'faq.update',
      'faq_entry',
      id,
      { question: before.question, published: before.published },
      { fields: Object.keys(dto) },
    );
    return this.faqDto(f);
  }

  async deleteFaq(actor: Actor, id: string): Promise<void> {
    const before = await this.prisma.faqEntry.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That question does not exist.');
    await this.prisma.faqEntry.delete({ where: { id } });
    await this.rec(actor, 'faq.delete', 'faq_entry', id, { question: before.question });
  }

  // ---- legal documents (versioned) ----

  private legalDto(d: LegalDocument): AdminLegalDto {
    const isDraft = d.status !== 'PUBLISHED';
    return {
      id: d.id,
      type: d.type,
      title: d.title,
      version: d.version,
      effectiveAt: d.effectiveAt,
      isDraft,
      draftLabel: isDraft ? DRAFT_LABEL : null,
      body: d.body,
      status: d.status,
      updatedAt: d.updatedAt,
    };
  }

  async listLegal(type?: LegalDocumentType) {
    const rows = await this.prisma.legalDocument.findMany({
      where: type ? { type } : {},
      orderBy: [{ type: 'asc' }, { createdAt: 'desc' }],
    });
    return rows.map((d) => this.legalDto(d));
  }

  /** A new version always starts as a draft. Published versions are never edited: the next change is a new version. */
  async newLegalVersion(actor: Actor, dto: NewLegalVersionDto): Promise<AdminLegalDto> {
    try {
      const d = await this.prisma.legalDocument.create({
        data: {
          type: dto.type,
          version: dto.version,
          title: dto.title.trim(),
          body: dto.body,
          status: 'DRAFT',
        },
      });
      await this.rec(actor, 'legal_document.create', 'legal_document', d.id, undefined, {
        type: d.type,
        version: d.version,
      });
      return this.legalDto(d);
    } catch (e) {
      if (isUnique(e))
        throw ApiException.conflict('That version already exists for this document.', {
          field: 'version',
        });
      throw e;
    }
  }

  async updateLegalDraft(
    actor: Actor,
    id: string,
    dto: UpdateLegalDraftDto,
  ): Promise<AdminLegalDto> {
    const before = await this.prisma.legalDocument.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That document does not exist.');
    if (before.status !== 'DRAFT') {
      throw ApiException.invalidState(
        'A published version cannot be edited. Create a new version instead.',
      );
    }
    const d = await this.prisma.legalDocument.update({
      where: { id },
      data: {
        ...(dto.title !== undefined ? { title: dto.title.trim() } : {}),
        ...(dto.body !== undefined ? { body: dto.body } : {}),
      },
    });
    await this.rec(
      actor,
      'legal_document.update',
      'legal_document',
      id,
      { version: before.version },
      { fields: Object.keys(dto) },
    );
    return this.legalDto(d);
  }

  /** Publishing makes this the version members see; the previously published one is archived (kept for consent history). */
  async publishLegal(actor: Actor, id: string, effectiveAt?: string): Promise<AdminLegalDto> {
    const before = await this.prisma.legalDocument.findUnique({ where: { id } });
    if (!before) throw ApiException.notFound('That document does not exist.');
    if (before.status !== 'DRAFT' && before.status !== 'IN_REVIEW') {
      throw ApiException.invalidState('Only a draft can be published.');
    }
    const when = effectiveAt ? new Date(effectiveAt) : new Date();
    if (Number.isNaN(when.getTime()))
      throw ApiException.validation('That date is not valid.', { field: 'effectiveAt' });
    const d = await this.prisma.$transaction(async (tx) => {
      await tx.legalDocument.updateMany({
        where: { type: before.type, status: 'PUBLISHED' },
        data: { status: 'ARCHIVED' },
      });
      const out = await tx.legalDocument.update({
        where: { id },
        data: { status: 'PUBLISHED', effectiveAt: when },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.userId,
          action: 'legal_document.publish',
          entityType: 'legal_document',
          entityId: id,
          after: { type: before.type, version: before.version, effectiveAt: when },
          ip: actor.ip ?? null,
          requestId: actor.requestId ?? null,
        },
        tx,
      );
      return out;
    });
    return this.legalDto(d);
  }
}
