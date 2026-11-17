import {
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiPropertyOptional, ApiTags } from '@nestjs/swagger';
import { IsIn, IsOptional } from 'class-validator';
import { type AuthContext } from '../access/access.types';
import {
  ClientIp,
  CurrentAuth,
  RequestIdParam,
  RequiresPermission,
  RequiresRecentAuth,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { PageQueryDto } from '../common/pagination';
import { Paged } from '../common/response-envelope.interceptor';
import { AdminOpportunitiesService } from './admin-opportunities.service';
import {
  AdminOpportunitiesQueryDto,
  AdminOpportunityDto,
  AdminProviderDto,
  AdminProvidersQueryDto,
  FeatureOpportunityDto,
  ImportCommitResultDto,
  ImportCsvDto,
  ImportReportDto,
  LinkHealthItemDto,
  OpportunityFieldsDto,
  ProviderFieldsDto,
  RejectOpportunityDto,
  SetTrustDto,
  UpdateOpportunityDto,
  UpdateProviderDto,
  VerifyOpportunityDto,
  VerifyProviderDto,
} from './opportunities.dto';

class LinkHealthQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: ['BROKEN', 'OK', 'UNKNOWN'], default: 'BROKEN' })
  @IsOptional()
  @IsIn(['BROKEN', 'OK', 'UNKNOWN'])
  result?: 'BROKEN' | 'OK' | 'UNKNOWN';
}

/** Staff operations on opportunities under /api/v1/admin. Each route names the permission it needs. */
@ApiTags('Admin opportunities')
@ApiBearerAuth('access-token')
@Controller('admin')
export class AdminOpportunitiesController {
  constructor(private readonly admin: AdminOpportunitiesService) {}

  // ---- providers (registered first: `opportunity-providers` never collides with `opportunities/:id`) ----

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(AdminProviderDto, { isArray: true })
  @Get('opportunity-providers')
  async listProviders(@Query() q: AdminProvidersQueryDto) {
    const { items, meta } = await this.admin.listProviders(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(AdminProviderDto)
  @Get('opportunity-providers/:id')
  getProvider(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.getProvider(id);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(AdminProviderDto, { status: 201 })
  @Post('opportunity-providers')
  createProvider(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: ProviderFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.createProvider({ userId: auth.userId, ip, requestId }, dto);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(AdminProviderDto)
  @Patch('opportunity-providers/:id')
  updateProvider(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateProviderDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.updateProvider({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @RequiresPermission('admin.access', 'opportunity.verify')
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminProviderDto)
  @Post('opportunity-providers/:id/verify')
  verifyProvider(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: VerifyProviderDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.verifyProvider({ userId: auth.userId, ip, requestId }, id, dto);
  }

  // ---- import and link health (fixed paths before `opportunities/:id`) ----

  @RequiresPermission('admin.access', 'opportunity.manage')
  @HttpCode(200)
  @ApiEnvelope(ImportReportDto)
  @Post('opportunities/import/preview')
  previewImport(@Body() dto: ImportCsvDto) {
    return this.admin.previewImport(dto.csv);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @HttpCode(200)
  @ApiEnvelope(ImportCommitResultDto)
  @Post('opportunities/import')
  commitImport(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: ImportCsvDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.commitImport({ userId: auth.userId, ip, requestId }, dto.csv);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(LinkHealthItemDto, { isArray: true })
  @Get('opportunities/link-health')
  async linkHealth(@Query() q: LinkHealthQueryDto) {
    const { items, meta } = await this.admin.linkHealth(q);
    return new Paged(items, meta);
  }

  // ---- opportunities ----

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(AdminOpportunityDto, { isArray: true })
  @Get('opportunities')
  async list(@Query() q: AdminOpportunitiesQueryDto) {
    const { items, meta } = await this.admin.list(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(AdminOpportunityDto)
  @Get('opportunities/:id')
  get(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.get(id);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(AdminOpportunityDto, { status: 201 })
  @Post('opportunities')
  create(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: OpportunityFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.create({ userId: auth.userId, ip, requestId }, dto);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @ApiEnvelope(AdminOpportunityDto)
  @Patch('opportunities/:id')
  update(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateOpportunityDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.update({ userId: auth.userId, ip, requestId }, id, dto);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminOpportunityDto)
  @Post('opportunities/:id/publish')
  publish(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.transition({ userId: auth.userId, ip, requestId }, id, 'publish');
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminOpportunityDto)
  @Post('opportunities/:id/close')
  close(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.transition({ userId: auth.userId, ip, requestId }, id, 'close');
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminOpportunityDto)
  @Post('opportunities/:id/archive')
  archive(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.transition({ userId: auth.userId, ip, requestId }, id, 'archive');
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminOpportunityDto)
  @Post('opportunities/:id/remove')
  remove(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.transition({ userId: auth.userId, ip, requestId }, id, 'remove');
  }

  /** Sends a provider's submission back to DRAFT with a reason (the review queue's "request changes"). */
  @RequiresPermission('admin.access', 'opportunity.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminOpportunityDto)
  @Post('opportunities/:id/reject')
  reject(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RejectOpportunityDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.transition({ userId: auth.userId, ip, requestId }, id, 'reject', dto.reason);
  }

  @RequiresPermission('admin.access', 'opportunity.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminOpportunityDto)
  @Post('opportunities/:id/feature')
  feature(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: FeatureOpportunityDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.feature({ userId: auth.userId, ip, requestId }, id, dto);
  }

  /** SOURCE_CONFIRMED or EXTERNAL_SOURCE. Setting VERIFIED here is refused; use `verify`. */
  @RequiresPermission('admin.access', 'opportunity.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminOpportunityDto)
  @Post('opportunities/:id/set-trust')
  setTrust(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SetTrustDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.setTrust({ userId: auth.userId, ip, requestId }, id, dto.trust, dto.reason);
  }

  /** "Verified by Atarah". Needs `opportunity.verify` and a fresh authenticator check; always audited. */
  @RequiresPermission('admin.access', 'opportunity.verify')
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminOpportunityDto)
  @Post('opportunities/:id/verify')
  verify(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: VerifyOpportunityDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.setTrust({ userId: auth.userId, ip, requestId }, id, 'VERIFIED', dto.reason, {
      verify: true,
    });
  }
}
