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
  AdminAuditQueryDto,
  AdminUserDto,
  AdminUsersQueryDto,
  AuditLogEntryDto,
  ReactivateUserDto,
  SuspendUserDto,
} from './admin.dto';
import { AdminService } from './admin.service';

@ApiTags('Admin')
@ApiBearerAuth('access-token')
@Controller('admin')
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @RequiresPermission('admin.access', 'user.view')
  @ApiEnvelope(AdminUserDto, { isArray: true })
  @Get('users')
  async users(@Query() q: AdminUsersQueryDto) {
    const { items, meta } = await this.admin.listUsers(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'user.view')
  @ApiEnvelope(AdminUserDto)
  @Get('users/:id')
  user(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.getUser(id);
  }

  @RequiresPermission('admin.access', 'user.suspend')
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminUserDto)
  @Post('users/:id/suspend')
  suspend(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SuspendUserDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.suspend({ userId: auth.userId, ip, requestId }, id, dto.reason);
  }

  @RequiresPermission('admin.access', 'user.suspend')
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminUserDto)
  @Post('users/:id/reactivate')
  reactivate(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReactivateUserDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.reactivate({ userId: auth.userId, ip, requestId }, id, dto.reason);
  }

  @RequiresPermission('admin.access', 'audit.view')
  @ApiEnvelope(AuditLogEntryDto, { isArray: true })
  @Get('audit-logs')
  async audit(@Query() q: AdminAuditQueryDto) {
    const { items, meta } = await this.admin.listAudit(q);
    return new Paged(items, meta);
  }
}
