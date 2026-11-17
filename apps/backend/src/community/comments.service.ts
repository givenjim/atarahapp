import { Injectable } from '@nestjs/common';
import { type Comment, Prisma } from '@prisma/client';
import { ApiException } from '../common/api.exception';
import { cursorPage, decodeCursor } from '../common/pagination';
import { notBlockedWhere } from '../community-core/blocks';
import { DomainEventBus } from '../community-core/domain-events';
import { ParticipationService } from '../community-core/participation.service';
import { PrismaService, type TxClient } from '../prisma/prisma.service';
import {
  type CommentsQueryDto,
  type CommentViewDto,
  type CreateCommentDto,
  type ReplyViewDto,
} from './community.dto';
import { PostViewsService } from './post-views.service';
import { cleanText } from './rules';

const MAX_REPLIES_PER_COMMENT = 50;

/** What counts toward a post's reply counter: visible comments whose thread is visible too. */
export async function recountReplies(tx: TxClient, postId: string): Promise<void> {
  await tx.$executeRaw(Prisma.sql`
    UPDATE posts SET "replyCount" = (
      SELECT count(*) FROM comments c
      LEFT JOIN comments pc ON pc.id = c."parentCommentId"
      WHERE c."postId" = ${postId}::uuid AND c.status::text = 'VISIBLE' AND c."deletedAt" IS NULL
        AND (c."parentCommentId" IS NULL
             OR (pc.status::text = 'VISIBLE' AND pc."deletedAt" IS NULL)))
    WHERE id = ${postId}::uuid`);
}

/** Threaded comments, one reply level. Blocked members (either direction) never appear and cannot be answered. */
@Injectable()
export class CommentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly views: PostViewsService,
    private readonly participation: ParticipationService,
    private readonly events: DomainEventBus,
  ) {}

  async list(viewerId: string, postId: string, q: CommentsQueryDto) {
    await this.views.visiblePost(viewerId, postId, { ownHiddenVisible: true });
    const c = q.cursor ? decodeCursor<{ t: string; id: string }>(q.cursor) : null;
    const visibleComment: Prisma.CommentWhereInput = {
      postId,
      status: 'VISIBLE',
      deletedAt: null,
      author: { is: { status: 'ACTIVE', deletedAt: null, ...notBlockedWhere(viewerId) } },
    };
    const tops = await this.prisma.comment.findMany({
      where: {
        ...visibleComment,
        parentCommentId: null,
        ...(c
          ? {
              OR: [
                { createdAt: { gt: new Date(c.t) } },
                { createdAt: new Date(c.t), id: { gt: c.id } },
              ],
            }
          : {}),
      },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
      take: q.limit + 1,
    });
    const { items, meta } = cursorPage(tops, q.limit, (r) => ({
      t: r.createdAt.toISOString(),
      id: r.id,
    }));
    const replies = items.length
      ? await this.prisma.comment.findMany({
          where: { ...visibleComment, parentCommentId: { in: items.map((t) => t.id) } },
          orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
        })
      : [];
    const authors = await this.views.authors([
      ...new Set([...items, ...replies].map((r) => r.authorId)),
    ]);
    const asReply = (r: Comment): ReplyViewDto | null => {
      const author = authors.get(r.authorId);
      return author
        ? {
            id: r.id,
            postId: r.postId,
            parentCommentId: r.parentCommentId!,
            body: r.body,
            author,
            isMine: r.authorId === viewerId,
            createdAt: r.createdAt,
            editedAt: r.editedAt,
          }
        : null;
    };
    const out: CommentViewDto[] = [];
    for (const t of items) {
      const author = authors.get(t.authorId);
      if (!author) continue;
      out.push({
        id: t.id,
        postId: t.postId,
        parentCommentId: null,
        body: t.body,
        author,
        isMine: t.authorId === viewerId,
        createdAt: t.createdAt,
        editedAt: t.editedAt,
        replies: replies
          .filter((r) => r.parentCommentId === t.id)
          .slice(0, MAX_REPLIES_PER_COMMENT)
          .flatMap((r) => asReply(r) ?? []),
      });
    }
    return { items: out, meta };
  }

  async create(userId: string, postId: string, dto: CreateCommentDto): Promise<CommentViewDto> {
    await this.participation.assertCanParticipate(userId);
    // A post the member cannot see (including its author blocking them, or them blocking the author) is a 404.
    await this.views.visiblePost(userId, postId);
    const body = cleanText(dto.body);
    if (!body) throw ApiException.validation('Write a comment first.', { field: 'body' });

    if (dto.parentCommentId) {
      const parent = await this.prisma.comment.findFirst({
        where: {
          id: dto.parentCommentId,
          postId,
          status: 'VISIBLE',
          deletedAt: null,
          author: { is: { deletedAt: null, ...notBlockedWhere(userId) } },
        },
        select: { id: true, parentCommentId: true },
      });
      if (!parent)
        throw ApiException.notFound('We could not find the comment you are replying to.');
      if (parent.parentCommentId) {
        throw ApiException.validation('Replies go to the top-level comment.', {
          field: 'parentCommentId',
        });
      }
    }

    const created = await this.prisma.$transaction(async (tx) => {
      const row = await tx.comment.create({
        data: { postId, authorId: userId, parentCommentId: dto.parentCommentId ?? null, body },
      });
      await tx.post.update({ where: { id: postId }, data: { replyCount: { increment: 1 } } });
      return row;
    });
    await this.events.emit({
      type: 'CommentCreated',
      commentId: created.id,
      postId,
      authorId: userId,
      parentCommentId: created.parentCommentId,
    });
    const author = (await this.views.authors([userId])).get(userId)!;
    return {
      id: created.id,
      postId,
      parentCommentId: created.parentCommentId,
      body: created.body,
      author,
      isMine: true,
      createdAt: created.createdAt,
      editedAt: null,
      replies: [],
    };
  }

  async update(userId: string, id: string, body: string) {
    const own = await this.own(userId, id);
    const clean = cleanText(body);
    if (!clean) throw ApiException.validation('Write a comment first.', { field: 'body' });
    const row = await this.prisma.comment.update({
      where: { id: own.id },
      data: { body: clean, editedAt: new Date() },
    });
    const author = (await this.views.authors([userId])).get(userId)!;
    return {
      id: row.id,
      postId: row.postId,
      parentCommentId: row.parentCommentId,
      body: row.body,
      author,
      isMine: true,
      createdAt: row.createdAt,
      editedAt: row.editedAt,
      replies: [] as ReplyViewDto[],
    };
  }

  async remove(userId: string, id: string): Promise<void> {
    const own = await this.own(userId, id);
    await this.prisma.$transaction(async (tx) => {
      await tx.comment.update({ where: { id: own.id }, data: { deletedAt: new Date() } });
      await recountReplies(tx, own.postId);
    });
  }

  private async own(userId: string, id: string) {
    const row = await this.prisma.comment.findFirst({
      where: { id, authorId: userId, deletedAt: null, status: 'VISIBLE' },
      select: { id: true, postId: true },
    });
    // Same answer for "not yours" and "does not exist".
    if (!row) throw ApiException.notFound('We could not find that comment.');
    return row;
  }
}
