import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { type AuthContext } from '../access/access.types';
import { ClientIp, CurrentAuth, RequestIdParam, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { AdminOpportunitiesService } from './admin-opportunities.service';
import {
  AdminOpportunitiesQueryDto,
  AdminOpportunityDto,
  AdminProviderDto,
  OpportunityFieldsDto,
  UpdateOpportunityDto,
} from './opportunities.dto';

/**
 * Provider endpoints (P1-M9, "for later": no screen uses them yet). A provider sees only the organisations and
 * listings they own, a submission always lands in PENDING_REVIEW with the lowest trust level, and nothing here can
 * publish a listing or set its trust badge.
 */
@ApiTags('Provider opportunities')
@ApiBearerAuth('access-token')
@Controller('provider')
export class ProviderOpportunitiesController {
  constructor(private readonly admin: AdminOpportunitiesService) {}

  @RequiresPermission('opportunity.manage.own')
  @ApiEnvelope(AdminProviderDto, { isArray: true })
  @Get('organisations')
  organisations(@CurrentAuth() auth: AuthContext) {
    return this.admin.ownProviders(auth.userId);
  }

  @RequiresPermission('opportunity.manage.own')
  @ApiEnvelope(AdminOpportunityDto, { isArray: true })
  @Get('opportunities')
  async list(@CurrentAuth() auth: AuthContext, @Query() q: AdminOpportunitiesQueryDto) {
    const { items, meta } = await this.admin.list(q, { ownerUserId: auth.userId });
    return new Paged(items, meta);
  }

  @RequiresPermission('opportunity.manage.own')
  @ApiEnvelope(AdminOpportunityDto)
  @Get('opportunities/:id')
  get(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.admin.get(id, { ownerUserId: auth.userId });
  }

  @RequiresPermission('opportunity.submit')
  @ApiEnvelope(AdminOpportunityDto, { status: 201 })
  @Post('opportunities')
  submit(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: OpportunityFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.create({ userId: auth.userId, ip, requestId }, dto, { asProvider: true });
  }

  @RequiresPermission('opportunity.manage.own')
  @ApiEnvelope(AdminOpportunityDto)
  @Patch('opportunities/:id')
  update(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateOpportunityDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.update({ userId: auth.userId, ip, requestId }, id, dto, { asProvider: true });
  }
}
