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
  AdminMarketplaceCategoryDto,
  AdminListingDto,
  AdminListingReportDto,
  AdminListingsQueryDto,
  AdminListingReportsQueryDto,
  AdminReviewDto,
  AdminReviewsQueryDto,
  AdminSellerDto,
  AdminSellersQueryDto,
  MarketplaceCategoryFieldsDto,
  FeatureListingDto,
  ReasonDto,
  ResolveReportDto,
  SetDirectPublishDto,
  UpdateMarketplaceCategoryDto,
} from './marketplace.dto';
import { type Actor, MarketplaceAdminService } from './marketplace-admin.service';

const actorOf = (auth: AuthContext, ip?: string, requestId?: string): Actor => ({
  userId: auth.userId,
  ip,
  requestId,
});

/** Staff operations on the marketplace under /api/v1/admin/marketplace. Each route names the permission it needs. */
@ApiTags('Admin marketplace')
@ApiBearerAuth('access-token')
@Controller('admin/marketplace')
export class MarketplaceAdminController {
  constructor(private readonly admin: MarketplaceAdminService) {}

  // ---- sellers ----

  @RequiresPermission('seller.manage')
  @ApiEnvelope(AdminSellerDto, { isArray: true })
  @Get('sellers')
  async sellers(@Query() q: AdminSellersQueryDto) {
    const { items, meta } = await this.admin.sellers(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('seller.manage')
  @ApiEnvelope(AdminSellerDto)
  @Get('sellers/:id')
  seller(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.seller(id);
  }

  @RequiresPermission('seller.manage')
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminSellerDto)
  @Post('sellers/:id/suspend')
  suspendSeller(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.suspendSeller(actorOf(auth, ip, requestId), id, dto.reason);
  }

  @RequiresPermission('seller.manage')
  @RequiresRecentAuth()
  @HttpCode(200)
  @ApiEnvelope(AdminSellerDto)
  @Post('sellers/:id/reinstate')
  reinstateSeller(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.reinstateSeller(actorOf(auth, ip, requestId), id, dto.reason);
  }

  @RequiresPermission('seller.manage')
  @ApiEnvelope(AdminSellerDto)
  @Patch('sellers/:id/direct-publish')
  directPublish(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SetDirectPublishDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.setDirectPublish(actorOf(auth, ip, requestId), id, dto.canPublishDirectly);
  }

  // ---- listings: the review queue and everything else ----

  @RequiresPermission('marketplace.manage')
  @ApiEnvelope(AdminListingDto, { isArray: true })
  @Get('listings')
  async listings(@CurrentAuth() auth: AuthContext, @Query() q: AdminListingsQueryDto) {
    const { items, meta } = await this.admin.listings(auth.userId, q);
    return new Paged(items, meta);
  }

  @RequiresPermission('marketplace.manage')
  @ApiEnvelope(AdminListingDto)
  @Get('listings/:id')
  listing(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.admin.listing(auth.userId, id);
  }

  @RequiresPermission('marketplace.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminListingDto)
  @Post('listings/:id/approve')
  approve(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.approve(actorOf(auth, ip, requestId), auth.userId, id);
  }

  @RequiresPermission('marketplace.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminListingDto)
  @Post('listings/:id/reject')
  reject(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.reject(actorOf(auth, ip, requestId), auth.userId, id, dto.reason);
  }

  @RequiresPermission('marketplace.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminListingDto)
  @Post('listings/:id/suspend')
  suspend(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.suspend(actorOf(auth, ip, requestId), auth.userId, id, dto.reason);
  }

  @RequiresPermission('marketplace.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminListingDto)
  @Post('listings/:id/reinstate')
  reinstate(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.reinstate(actorOf(auth, ip, requestId), auth.userId, id, dto.reason);
  }

  @RequiresPermission('marketplace.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminListingDto)
  @Post('listings/:id/feature')
  feature(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: FeatureListingDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.feature(
      actorOf(auth, ip, requestId),
      auth.userId,
      id,
      dto.until ? new Date(dto.until) : null,
    );
  }

  // ---- reported listings ----

  @RequiresPermission('marketplace.manage')
  @ApiEnvelope(AdminListingReportDto, { isArray: true })
  @Get('reports')
  async reports(@Query() q: AdminListingReportsQueryDto) {
    const { items, meta } = await this.admin.reports(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('marketplace.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminListingReportDto)
  @Post('reports/:id/resolve')
  resolveReport(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ResolveReportDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.resolveReport(actorOf(auth, ip, requestId), id, dto);
  }

  // ---- categories ----

  @RequiresPermission('category.manage')
  @ApiEnvelope(AdminMarketplaceCategoryDto, { isArray: true })
  @Get('categories')
  categories() {
    return this.admin.categories();
  }

  @RequiresPermission('category.manage')
  @ApiEnvelope(AdminMarketplaceCategoryDto, { status: 201 })
  @Post('categories')
  createCategory(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: MarketplaceCategoryFieldsDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.createCategory(actorOf(auth, ip, requestId), dto);
  }

  @RequiresPermission('category.manage')
  @ApiEnvelope(AdminMarketplaceCategoryDto)
  @Patch('categories/:id')
  updateCategory(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateMarketplaceCategoryDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.updateCategory(actorOf(auth, ip, requestId), id, dto);
  }

  // ---- review moderation ----

  @RequiresPermission('marketplace.manage')
  @ApiEnvelope(AdminReviewDto, { isArray: true })
  @Get('reviews')
  async reviews(@Query() q: AdminReviewsQueryDto) {
    const { items, meta } = await this.admin.reviews(q);
    return new Paged(items, meta);
  }

  @RequiresPermission('marketplace.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminReviewDto)
  @Post('reviews/:id/hide')
  hideReview(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.hideReview(actorOf(auth, ip, requestId), id, dto.reason);
  }

  @RequiresPermission('marketplace.manage')
  @HttpCode(200)
  @ApiEnvelope(AdminReviewDto)
  @Post('reviews/:id/restore')
  restoreReview(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @ClientIp() ip?: string,
    @RequestIdParam() requestId?: string,
  ) {
    return this.admin.restoreReview(actorOf(auth, ip, requestId), id, dto.reason);
  }
}
