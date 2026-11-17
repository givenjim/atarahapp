import { Body, Controller, Get, HttpCode, Param, ParseUUIDPipe, Post, Query } from '@nestjs/common';
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
import {
  AudiencePreviewDto,
  BroadcastDto,
  BroadcastFieldsDto,
  BroadcastsQueryDto,
  PrivacyRequestDto,
  PrivacyRequestsQueryDto,
} from './broadcasts.dto';
import { BroadcastsService } from './broadcasts.service';

/** Staff announcements and the privacy requests log under /api/v1/admin. */
@ApiTags('Admin notifications')
@ApiBearerAuth('access-token')
@Controller('admin')
export class BroadcastsController {
  constructor(private readonly broadcasts: BroadcastsService) {}

  @RequiresPermission('admin.access', 'notification.broadcast')
  @ApiEnvelope(BroadcastDto, { isArray: true })
  @Get('notifications/broadcasts')
  async list(@Query() q: BroadcastsQueryDto) {
    const { items, meta } = await this.broadcasts.list(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'notification.broadcast')
  @HttpCode(200)
  @ApiEnvelope(AudiencePreviewDto)
  @Post('notifications/broadcasts/preview')
  preview(@Body() dto: BroadcastFieldsDto) {
    return this.broadcasts.preview(dto.target, dto.targetValue);
  }

  @RequiresPermission('admin.access', 'notification.broadcast')
  @ApiEnvelope(BroadcastDto)
  @Get('notifications/broadcasts/:id')
  get(@Param('id', ParseUUIDPipe) id: string) {
    return this.broadcasts.get(id);
  }

  /** Messaging members is irreversible once sent, so it needs a fresh authenticator check. */
  @RequiresPermission('admin.access', 'notification.broadcast')
  @RequiresRecentAuth()
  @ApiEnvelope(BroadcastDto, { status: 201 })
  @Post('notifications/broadcasts')
  create(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: BroadcastFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.broadcasts.create({ userId: auth.userId, ip, requestId }, dto);
  }

  @RequiresPermission('admin.access', 'notification.broadcast')
  @HttpCode(200)
  @ApiEnvelope(BroadcastDto)
  @Post('notifications/broadcasts/:id/cancel')
  cancel(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.broadcasts.cancel({ userId: auth.userId, ip, requestId }, id);
  }

  @RequiresPermission('admin.access', 'user.view')
  @ApiEnvelope(PrivacyRequestDto, { isArray: true })
  @Get('privacy-requests')
  async privacyRequests(@Query() q: PrivacyRequestsQueryDto) {
    const { items, meta } = await this.broadcasts.privacyRequests(q);
    return new Paged(items, meta);
  }
}
