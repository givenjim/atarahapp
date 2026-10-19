import { Body, Controller, Get, HttpCode, Param, ParseUUIDPipe, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { type AuthContext } from '../access/access.types';
import { ClientIp, CurrentAuth, RequestIdParam, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { AdminPortfolioService } from './admin-portfolio.service';
import {
  AdminProjectDetailDto,
  AdminProjectDto,
  AdminProjectsQueryDto,
  HideProjectDto,
} from './portfolio.dto';

@ApiTags('Admin Portfolio')
@ApiBearerAuth('access-token')
@RequiresPermission('admin.access', 'moderation.act')
@Controller('admin/projects')
export class AdminPortfolioController {
  constructor(private readonly admin: AdminPortfolioService) {}

  @ApiEnvelope(AdminProjectDto, { isArray: true })
  @Get()
  async list(@Query() q: AdminProjectsQueryDto) {
    const { items, meta } = await this.admin.list(q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(AdminProjectDetailDto)
  @Get(':id')
  get(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.get(id);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminProjectDetailDto)
  @Post(':id/hide')
  hide(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: HideProjectDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.hide({ userId: auth.userId, ip, requestId }, id, dto.reason);
  }

  @HttpCode(200)
  @ApiEnvelope(AdminProjectDetailDto)
  @Post(':id/restore')
  restore(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.restore({ userId: auth.userId, ip, requestId }, id);
  }
}
