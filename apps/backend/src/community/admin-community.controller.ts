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
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { type AuthContext } from '../access/access.types';
import {
  ClientIp,
  CurrentAuth,
  RequestIdParam,
  RequiresPermission,
  RequiresRecentAuth,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { PostViewDto } from './community.dto';
import { AdminGroupsService } from './admin-groups.service';
import {
  AdminAnnouncementsQueryDto,
  AdminCaseDetailDto,
  AdminCaseDto,
  AdminCasesQueryDto,
  AdminGroupDto,
  AdminGroupsQueryDto,
  AdminReportDto,
  AdminReportsQueryDto,
  AssignCaseBodyDto,
  CreateAnnouncementDto,
  CreateGroupDto,
  GroupModeratorBodyDto,
  ModerationActionBodyDto,
  PinPostBodyDto,
  UpdateGroupDto,
} from './community-admin.dto';
import { ModerationService } from './moderation.service';

/** Moderation queue, groups and announcements under /api/v1/admin. Each route names the permission it needs. */
@ApiTags('Admin community')
@ApiBearerAuth('access-token')
@Controller('admin')
export class AdminCommunityController {
  constructor(
    private readonly moderation: ModerationService,
    private readonly groups: AdminGroupsService,
  ) {}

  // ---- reports and moderation cases ----

  @RequiresPermission('admin.access', 'report.view')
  @ApiEnvelope(AdminReportDto, { isArray: true })
  @Get('reports')
  async adminListReports(@Query() q: AdminReportsQueryDto) {
    const { items, meta } = await this.moderation.reports(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'report.view')
  @ApiEnvelope(AdminCaseDto, { isArray: true })
  @Get('moderation-cases')
  async adminListCases(@Query() q: AdminCasesQueryDto) {
    const { items, meta } = await this.moderation.cases(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'report.view')
  @ApiEnvelope(AdminCaseDetailDto)
  @Get('moderation-cases/:id')
  adminGetCase(@Param('id', ParseUUIDPipe) id: string) {
    return this.moderation.caseDetail(id);
  }

  @RequiresPermission('admin.access', 'report.resolve')
  @HttpCode(200)
  @ApiEnvelope(AdminCaseDto)
  @Post('moderation-cases/:id/assign')
  adminAssignCase(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AssignCaseBodyDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.moderation.assign({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @RequiresPermission('admin.access', 'report.resolve', 'moderation.act')
  @HttpCode(200)
  @ApiEnvelope(AdminCaseDetailDto)
  @Post('moderation-cases/:id/actions')
  adminDecideCase(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ModerationActionBodyDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.moderation.act(
      { userId: auth.userId, ip, requestId, reauthAt: auth.reauthAt },
      id,
      dto,
    );
  }

  // ---- groups ----

  @RequiresPermission('admin.access', 'community.group.manage')
  @ApiEnvelope(AdminGroupDto, { isArray: true })
  @Get('groups')
  async adminListGroups(@Query() q: AdminGroupsQueryDto) {
    const { items, meta } = await this.groups.list(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'community.group.manage')
  @ApiEnvelope(AdminGroupDto)
  @Get('groups/:id')
  adminGetGroup(@Param('id', ParseUUIDPipe) id: string) {
    return this.groups.get(id);
  }

  @RequiresPermission('admin.access', 'community.group.manage')
  @ApiEnvelope(AdminGroupDto, { status: 201 })
  @Post('groups')
  adminCreateGroup(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: CreateGroupDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.groups.create({ userId: auth.userId, ip, requestId }, dto);
  }

  @RequiresPermission('admin.access', 'community.group.manage')
  @ApiEnvelope(AdminGroupDto)
  @Patch('groups/:id')
  adminUpdateGroup(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateGroupDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.groups.update({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @RequiresPermission('admin.access', 'community.group.manage')
  @RequiresRecentAuth()
  @HttpCode(204)
  @Delete('groups/:id')
  async adminArchiveGroup(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    await this.groups.archive({ userId: auth.userId, ip, requestId }, id);
  }

  @RequiresPermission('admin.access', 'community.group.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminGroupDto)
  @Post('groups/:id/moderators')
  adminAssignGroupModerator(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: GroupModeratorBodyDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.groups.addModerator({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @RequiresPermission('admin.access', 'community.group.manage')
  @ApiEnvelope(AdminGroupDto)
  @Delete('groups/:id/moderators/:userId')
  adminRemoveGroupModerator(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('userId', ParseUUIDPipe) userId: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.groups.removeModerator({ userId: auth.userId, ip, requestId }, id, userId);
  }

  @RequiresPermission('admin.access', 'community.group.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminGroupDto)
  @Post('groups/:id/pins')
  adminPinGroupPost(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: PinPostBodyDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.groups.pin({ userId: auth.userId, ip, requestId }, id, dto.postId);
  }

  @RequiresPermission('admin.access', 'community.group.manage')
  @ApiEnvelope(AdminGroupDto)
  @Delete('groups/:id/pins/:postId')
  adminUnpinGroupPost(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('postId', ParseUUIDPipe) postId: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.groups.unpin({ userId: auth.userId, ip, requestId }, id, postId);
  }

  // ---- announcements ----

  @RequiresPermission('admin.access', 'community.announce')
  @RequiresRecentAuth()
  @ApiEnvelope(PostViewDto, { status: 201 })
  @Post('announcements')
  adminCreateAnnouncement(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: CreateAnnouncementDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.groups.announce({ userId: auth.userId, ip, requestId }, dto);
  }

  @RequiresPermission('admin.access', 'community.announce')
  @ApiEnvelope(PostViewDto, { isArray: true })
  @Get('announcements')
  async adminListAnnouncements(
    @CurrentAuth() auth: AuthContext,
    @Query() q: AdminAnnouncementsQueryDto,
  ) {
    const { items, meta } = await this.groups.announcements(auth.userId, q);
    return new Paged(items, meta);
  }
}
