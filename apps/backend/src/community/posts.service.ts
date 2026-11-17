import { InjectQueue } from '@nestjs/bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { type PostAudience, type PostType, Prisma } from '@prisma/client';
import { type Queue } from 'bullmq';
import { AccessService } from '../access/access.service';
import { ApiException } from '../common/api.exception';
import { cursorPage, decodeCursor } from '../common/pagination';
import { DomainEventBus } from '../community-core/domain-events';
import { ParticipationService } from '../community-core/participation.service';
import { PrismaService } from '../prisma/prisma.service';
import { type CreatePostDto, type PostViewDto, type SavedPostsQueryDto } from './community.dto';
import { LINK_PREVIEW_JOB } from './jobs/job-names';
import { PostViewsService } from './post-views.service';
import { cleanText, MAX_POST_MEDIA, parseSafeLink } from './rules';

const isUnique = (err: unknown) =>
  err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';

export interface NewPost {
  type: PostType;
  body?: string;
  audience?: PostAudience;
  groupId?: string;
  mediaIds?: string[];
  linkUrl?: string;
}

/** Writing and acting on posts: create, edit, delete, react, save. Reading lives in FeedService and PostViewsService. */
@Injectable()
export class PostsService {
  private readonly logger = new Logger(PostsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly views: PostViewsService,
    private readonly participation: ParticipationService,
    private readonly access: AccessService,
    private readonly events: DomainEventBus,
    @InjectQueue('maintenance') private readonly queue: Queue,
  ) {}

  async create(userId: string, dto: NewPost | CreatePostDto): Promise<PostViewDto> {
    await this.participation.assertCanParticipate(userId);

    let isAnnouncement = false;
    if (dto.type === 'ANNOUNCEMENT') {
      const user = await this.prisma.user.findUniqueOrThrow({
        where: { id: userId },
        select: { status: true },
      });
      if (!(await this.access.hasPermission(userId, user.status, 'community.announce'))) {
        throw ApiException.forbidden('Only Atarah staff can post announcements.', {
          missing: ['community.announce'],
        });
      }
      isAnnouncement = true;
    }

    const body = cleanText(dto.body ?? '');
    const link = dto.linkUrl ? parseSafeLink(dto.linkUrl) : null;
    const mediaIds = [...new Set(dto.mediaIds ?? [])];
    if ((dto.mediaIds?.length ?? 0) > MAX_POST_MEDIA) {
      throw ApiException.validation(`A post can have at most ${MAX_POST_MEDIA} photos or videos.`, {
        field: 'mediaIds',
      });
    }
    if (!body && mediaIds.length === 0 && !link) {
      throw ApiException.validation('Write something, or add a photo, video or link.', {
        field: 'body',
      });
    }

    let audience: PostAudience = dto.audience ?? 'MEMBERS';
    let groupId: string | null = null;
    if (dto.groupId) {
      if (dto.audience && dto.audience !== 'GROUP') {
        throw ApiException.validation('A group post is shown to the group.', { field: 'audience' });
      }
      // Staff holding community.announce may announce in a group without joining it.
      if (isAnnouncement) await this.assertGroupExists(dto.groupId);
      else await this.assertMember(userId, dto.groupId);
      audience = 'GROUP';
      groupId = dto.groupId;
    } else if (audience === 'GROUP') {
      throw ApiException.validation('Choose which group to post in.', { field: 'groupId' });
    }

    await this.assertMedia(userId, mediaIds);

    const post = await this.prisma.$transaction(async (tx) => {
      const created = await tx.post.create({
        data: {
          authorId: userId,
          type: dto.type,
          body,
          audience,
          groupId,
          isStaffAnnouncement: isAnnouncement,
        },
        select: { id: true },
      });
      if (mediaIds.length > 0) {
        await tx.postMedia.createMany({
          data: mediaIds.map((mediaAssetId, i) => ({
            postId: created.id,
            mediaAssetId,
            sortOrder: i,
          })),
        });
      }
      if (link) await tx.postLink.create({ data: { postId: created.id, url: link.href } });
      return created;
    });

    if (link) {
      // A queue problem must not undo the post: the post simply shows the bare link.
      await this.queue
        .add(LINK_PREVIEW_JOB, { postId: post.id }, { jobId: `link-preview-${post.id}` })
        .catch((e: unknown) => this.logger.warn(`Could not queue the link preview: ${String(e)}`));
    }
    await this.events.emit({
      type: 'PostCreated',
      postId: post.id,
      authorId: userId,
      groupId,
      audience,
    });
    return this.views.view(userId, post.id);
  }

  async get(viewerId: string, id: string): Promise<PostViewDto> {
    await this.views.visiblePost(viewerId, id, { ownHiddenVisible: true });
    return this.views.view(viewerId, id);
  }

  /** Authors edit their own words; everybody else gets the same 404 as for a post that does not exist. */
  async update(userId: string, id: string, body: string): Promise<PostViewDto> {
    const post = await this.ownPost(userId, id);
    if (post.status !== 'VISIBLE') {
      throw ApiException.invalidState('This post can no longer be edited.');
    }
    const clean = cleanText(body);
    if (!clean) throw ApiException.validation('A post needs some words.', { field: 'body' });
    await this.prisma.post.update({ where: { id }, data: { body: clean, editedAt: new Date() } });
    return this.views.view(userId, id);
  }

  async remove(userId: string, id: string): Promise<void> {
    await this.ownPost(userId, id);
    await this.prisma.post.update({ where: { id }, data: { deletedAt: new Date() } });
  }

  // ---- reactions: idempotent, counter in the same transaction --------------------------------------------

  async react(
    userId: string,
    postId: string,
  ): Promise<{ reacted: boolean; reactionCount: number }> {
    await this.views.visiblePost(userId, postId);
    const inserted = await this.prisma.$transaction(async (tx) => {
      const res = await tx.reaction.createMany({
        data: [{ postId, userId }],
        skipDuplicates: true,
      });
      if (res.count === 1) {
        await tx.post.update({ where: { id: postId }, data: { reactionCount: { increment: 1 } } });
      }
      return res.count === 1;
    });
    if (inserted) await this.events.emit({ type: 'ReactionAdded', postId, userId });
    return this.reactionState(postId, true);
  }

  async unreact(
    userId: string,
    postId: string,
  ): Promise<{ reacted: boolean; reactionCount: number }> {
    await this.views.visiblePost(userId, postId);
    await this.prisma.$transaction(async (tx) => {
      const res = await tx.reaction.deleteMany({ where: { postId, userId } });
      if (res.count === 1) {
        await tx.post.update({ where: { id: postId }, data: { reactionCount: { decrement: 1 } } });
      }
    });
    return this.reactionState(postId, false);
  }

  private async reactionState(postId: string, reacted: boolean) {
    const post = await this.prisma.post.findUniqueOrThrow({
      where: { id: postId },
      select: { reactionCount: true },
    });
    return { reacted, reactionCount: post.reactionCount };
  }

  // ---- saved posts (the existing saved_items table) -------------------------------------------------------

  async save(userId: string, postId: string): Promise<{ saved: boolean }> {
    await this.views.visiblePost(userId, postId);
    try {
      await this.prisma.savedItem.upsert({
        where: { userId_type_targetId: { userId, type: 'POST', targetId: postId } },
        create: { userId, type: 'POST', targetId: postId },
        update: {},
      });
    } catch (err) {
      if (!isUnique(err)) throw err; // two taps at once: it is saved either way
    }
    return { saved: true };
  }

  async unsave(userId: string, postId: string): Promise<{ saved: boolean }> {
    await this.prisma.savedItem.deleteMany({ where: { userId, type: 'POST', targetId: postId } });
    return { saved: false };
  }

  /** Saved posts, newest save first. Posts that are gone or no longer visible are left out of the page. */
  async savedPosts(userId: string, q: SavedPostsQueryDto) {
    const c = q.cursor ? decodeCursor<{ t: string; id: string }>(q.cursor) : null;
    const rows = await this.prisma.savedItem.findMany({
      where: {
        userId,
        type: 'POST',
        ...(c
          ? {
              OR: [
                { createdAt: { lt: new Date(c.t) } },
                { createdAt: new Date(c.t), id: { lt: c.id } },
              ],
            }
          : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: q.limit + 1,
    });
    const { items, meta } = cursorPage(rows, q.limit, (r) => ({
      t: r.createdAt.toISOString(),
      id: r.id,
    }));
    const visible = await this.views.filterVisible(
      userId,
      items.map((r) => r.targetId),
    );
    const posts = await this.views.views(
      userId,
      items.map((r) => r.targetId).filter((id) => visible.has(id)),
    );
    return { items: posts, meta };
  }

  // ---- helpers -----------------------------------------------------------------------------------------------

  private async ownPost(userId: string, id: string) {
    const post = await this.prisma.post.findFirst({
      where: { id, authorId: userId, deletedAt: null, status: { not: 'REMOVED' } },
      select: { id: true, status: true },
    });
    if (!post) throw ApiException.notFound('We could not find that post.');
    return post;
  }

  private async assertGroupExists(groupId: string): Promise<void> {
    const g = await this.prisma.group.count({ where: { id: groupId, archivedAt: null } });
    if (!g) throw ApiException.notFound('We could not find that group.');
  }

  private async assertMember(userId: string, groupId: string): Promise<void> {
    const m = await this.prisma.groupMembership.findFirst({
      where: { userId, groupId, group: { archivedAt: null } },
      select: { id: true },
    });
    if (!m) {
      throw ApiException.forbidden('Join this group to post in it.', { reason: 'NOT_A_MEMBER' });
    }
  }

  private async assertMedia(userId: string, ids: string[]): Promise<void> {
    if (ids.length === 0) return;
    const assets = await this.prisma.mediaAsset.findMany({
      where: { id: { in: ids }, ownerId: userId, deletedAt: null },
      select: { kind: true, status: true },
    });
    // The same answer for "not yours" and "does not exist".
    if (assets.length !== ids.length) {
      throw ApiException.validation('One of those files could not be found.', {
        field: 'mediaIds',
      });
    }
    for (const a of assets) {
      if (a.kind !== 'IMAGE' && a.kind !== 'VIDEO') {
        throw ApiException.validation('Posts take photos and videos.', { field: 'mediaIds' });
      }
      if (a.status === 'PENDING_UPLOAD' || a.status === 'REJECTED' || a.status === 'DELETED') {
        throw ApiException.validation('Finish uploading your files before posting.', {
          field: 'mediaIds',
        });
      }
    }
  }
}
