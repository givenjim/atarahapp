import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseEnumPipe,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { RoleKey } from '@prisma/client';
import { type AuthContext } from '../access/access.types';
import {
  ClientIp,
  CurrentAuth,
  RequestIdParam,
  RequiresPermission,
  RequiresRecentAuth,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { AdminUserDto } from './admin.dto';
import {
  AdminUserOverviewDto,
  AnalyticsQueryDto,
  AnalyticsSeriesDto,
  AssignRoleDto,
  DashboardDto,
  FailedJobDto,
  QueueCountsDto,
  RevokeRoleQueryDto,
  RoleDto,
} from './admin-ops.dto';
import { AdminOpsService } from './admin-ops.service';

/** Dashboard, analytics, jobs, roles and the user overview under /api/v1/admin. Each route names its permission. */
@ApiTags('Admin operations')
@ApiBearerAuth('access-token')
@Controller('admin')
export class AdminOpsController {
  constructor(private readonly ops: AdminOpsService) {}

  /** Any administrator may open it; each queue shows only if they hold the permission to act on it. */
  @RequiresPermission('admin.access')
  @ApiEnvelope(DashboardDto)
  @Get('dashboard')
  dashboard(@CurrentAuth() auth: AuthContext) {
    return this.ops.dashboard(auth);
  }

  @RequiresPermission('admin.access', 'analytics.view')
  @ApiEnvelope(AnalyticsSeriesDto)
  @Get('analytics/events')
  analytics(@Query() q: AnalyticsQueryDto) {
    return this.ops.analyticsSeries(q);
  }

  // ---- background jobs ----

  @RequiresPermission('admin.access', 'settings.manage')
  @ApiEnvelope(QueueCountsDto, { isArray: true })
  @Get('jobs')
  jobs() {
    return this.ops.queueCounts();
  }

  @RequiresPermission('admin.access', 'settings.manage')
  @ApiEnvelope(FailedJobDto, { isArray: true })
  @Get('jobs/:queue/failed')
  failedJobs(@Param('queue') queue: string) {
    return this.ops.failedJobs(queue.slice(0, 40));
  }

  @RequiresPermission('admin.access', 'settings.manage')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @HttpCode(204)
  @Post('jobs/:queue/:jobId/retry')
  async retry(
    @CurrentAuth() auth: AuthContext,
    @Param('queue') queue: string,
    @Param('jobId') jobId: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    await this.ops.retryJob(
      { userId: auth.userId, status: auth.status, ip, requestId },
      queue.slice(0, 40),
      jobId.slice(0, 80),
    );
  }

  // ---- roles and the user overview ----

  @RequiresPermission('admin.access', 'user.view')
  @ApiEnvelope(RoleDto, { isArray: true })
  @Get('roles')
  roles() {
    return this.ops.listRoles();
  }

  @RequiresPermission('admin.access', 'user.view')
  @ApiEnvelope(AdminUserOverviewDto)
  @Get('users/:id/overview')
  overview(@Param('id', ParseUUIDPipe) id: string) {
    return this.ops.userOverview(id);
  }

  @RequiresPermission('admin.access', 'role.assign')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(AdminUserDto)
  @Post('users/:id/roles')
  assignRole(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AssignRoleDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.ops.assignRole(
      { userId: auth.userId, status: auth.status, ip, requestId },
      id,
      dto.role,
      dto.reason,
    );
  }

  @RequiresPermission('admin.access', 'role.assign')
  @RequiresRecentAuth()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @ApiEnvelope(AdminUserDto)
  @Delete('users/:id/roles/:role')
  revokeRole(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Param('role', new ParseEnumPipe(RoleKey)) role: RoleKey,
    @Query() q: RevokeRoleQueryDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.ops.revokeRole(
      { userId: auth.userId, status: auth.status, ip, requestId },
      id,
      role,
      q.reason,
    );
  }
}
