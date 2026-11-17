import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { CommentsService } from './comments.service';
import {
  CommentsQueryDto,
  CommentViewDto,
  CreateCommentDto,
  CreatePostDto,
  FeedQueryDto,
  PostViewDto,
  ReactionStateDto,
  SavedPostsQueryDto,
  SavedStateDto,
  UpdateCommentDto,
  UpdatePostDto,
} from './community.dto';
import { FeedService } from './feed.service';
import { PostsService } from './posts.service';

const HOUR = 3_600_000;

@ApiTags('Community')
@ApiBearerAuth('access-token')
@RequiresPermission('community.view')
@Controller()
export class CommunityController {
  constructor(
    private readonly feed: FeedService,
    private readonly posts: PostsService,
    private readonly comments: CommentsService,
  ) {}

  // ---- feed ----

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(PostViewDto, { isArray: true })
  @Get('community/feed')
  async communityFeed(@CurrentAuth() auth: AuthContext, @Query() q: FeedQueryDto) {
    const { items, meta } = await this.feed.feed(auth.userId, q);
    return new Paged(items, meta);
  }

  // ---- posts ----

  @RequiresPermission('community.post')
  @Throttle({ default: { limit: 10, ttl: HOUR } })
  @ApiEnvelope(PostViewDto, { status: 201 })
  @Post('posts')
  createPost(@CurrentAuth() auth: AuthContext, @Body() dto: CreatePostDto) {
    return this.posts.create(auth.userId, dto);
  }

  @ApiEnvelope(PostViewDto)
  @Get('posts/:id')
  getPost(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.posts.get(auth.userId, id);
  }

  @RequiresPermission('community.post')
  @ApiEnvelope(PostViewDto)
  @Patch('posts/:id')
  updatePost(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePostDto,
  ) {
    return this.posts.update(auth.userId, id, dto.body);
  }

  @RequiresPermission('community.post')
  @HttpCode(204)
  @Delete('posts/:id')
  async deletePost(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.posts.remove(auth.userId, id);
  }

  // ---- comments ----

  @ApiEnvelope(CommentViewDto, { isArray: true })
  @Get('posts/:id/comments')
  async listPostComments(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Query() q: CommentsQueryDto,
  ) {
    const { items, meta } = await this.comments.list(auth.userId, id, q);
    return new Paged(items, meta);
  }

  @RequiresPermission('community.comment')
  @Throttle({ default: { limit: 60, ttl: HOUR } })
  @ApiEnvelope(CommentViewDto, { status: 201 })
  @Post('posts/:id/comments')
  createPostComment(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CreateCommentDto,
  ) {
    return this.comments.create(auth.userId, id, dto);
  }

  @RequiresPermission('community.comment')
  @ApiEnvelope(CommentViewDto)
  @Patch('comments/:id')
  updateComment(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCommentDto,
  ) {
    return this.comments.update(auth.userId, id, dto.body);
  }

  @RequiresPermission('community.comment')
  @HttpCode(204)
  @Delete('comments/:id')
  async deleteComment(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.comments.remove(auth.userId, id);
  }

  // ---- reactions ----

  @RequiresPermission('community.comment')
  @Throttle({ default: { limit: 300, ttl: HOUR } })
  @ApiEnvelope(ReactionStateDto)
  @Put('posts/:id/reactions')
  reactToPost(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.posts.react(auth.userId, id);
  }

  @RequiresPermission('community.comment')
  @Throttle({ default: { limit: 300, ttl: HOUR } })
  @ApiEnvelope(ReactionStateDto)
  @Delete('posts/:id/reactions')
  unreactToPost(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.posts.unreact(auth.userId, id);
  }

  // ---- saved posts ----

  @RequiresPermission('saved.manage.own')
  @ApiEnvelope(SavedStateDto)
  @Put('posts/:id/save')
  savePost(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.posts.save(auth.userId, id);
  }

  @RequiresPermission('saved.manage.own')
  @ApiEnvelope(SavedStateDto)
  @Delete('posts/:id/save')
  unsavePost(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.posts.unsave(auth.userId, id);
  }

  @RequiresPermission('saved.manage.own')
  @ApiEnvelope(PostViewDto, { isArray: true })
  @Get('me/saved-posts')
  async listSavedPosts(@CurrentAuth() auth: AuthContext, @Query() q: SavedPostsQueryDto) {
    const { items, meta } = await this.posts.savedPosts(auth.userId, q);
    return new Paged(items, meta);
  }
}
