import { Body, Controller, Get, HttpCode, Param, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import {
  GroupCardDto,
  GroupDetailDto,
  GroupMembershipStateDto,
  GroupPostBodyDto,
  GroupPostsQueryDto,
  GroupsQueryDto,
  PostViewDto,
} from './community.dto';
import { GroupsService } from './groups.service';

@ApiTags('Community')
@ApiBearerAuth('access-token')
@RequiresPermission('community.view')
@Controller('groups')
export class GroupsController {
  constructor(private readonly groups: GroupsService) {}

  @ApiEnvelope(GroupCardDto, { isArray: true })
  @Get()
  async listGroups(@CurrentAuth() auth: AuthContext, @Query() q: GroupsQueryDto) {
    const { items, meta } = await this.groups.list(auth.userId, q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(GroupDetailDto)
  @Get(':ref')
  getGroup(@CurrentAuth() auth: AuthContext, @Param('ref') ref: string) {
    return this.groups.detail(auth.userId, ref.slice(0, 80));
  }

  @HttpCode(200)
  @ApiEnvelope(GroupMembershipStateDto)
  @Post(':ref/join')
  joinGroup(@CurrentAuth() auth: AuthContext, @Param('ref') ref: string) {
    return this.groups.join(auth.userId, ref.slice(0, 80));
  }

  @HttpCode(200)
  @ApiEnvelope(GroupMembershipStateDto)
  @Post(':ref/leave')
  leaveGroup(@CurrentAuth() auth: AuthContext, @Param('ref') ref: string) {
    return this.groups.leave(auth.userId, ref.slice(0, 80));
  }

  @ApiEnvelope(PostViewDto, { isArray: true })
  @Get(':ref/posts')
  async listGroupPosts(
    @CurrentAuth() auth: AuthContext,
    @Param('ref') ref: string,
    @Query() q: GroupPostsQueryDto,
  ) {
    const { items, meta } = await this.groups.postsOf(auth.userId, ref.slice(0, 80), q);
    return new Paged(items, meta);
  }

  @RequiresPermission('community.post')
  @Throttle({ default: { limit: 10, ttl: 3_600_000 } })
  @ApiEnvelope(PostViewDto, { status: 201 })
  @Post(':ref/posts')
  createGroupPost(
    @CurrentAuth() auth: AuthContext,
    @Param('ref') ref: string,
    @Body() dto: GroupPostBodyDto,
  ) {
    return this.groups.createPost(auth.userId, ref.slice(0, 80), dto);
  }
}
