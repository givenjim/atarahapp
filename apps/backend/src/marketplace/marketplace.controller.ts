import { Body, Controller, Get, HttpCode, Param, ParseUUIDPipe, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { Paged } from '../common/response-envelope.interceptor';
import { EnquiriesService } from './enquiries.service';
import {
  CategoryDto,
  CreateEnquiryDto,
  EnquiriesQueryDto,
  EnquiryDto,
  EnquiryThreadDto,
  ListingCardDto,
  ListingDto,
  ListingReviewDto,
  ListingsQueryDto,
  MarketplaceHomeDto,
  ReportListingDto,
  ReviewDto,
  ReviewsQueryDto,
  SellerCardDto,
  SellerProfileDto,
  SellersQueryDto,
  SellerTermsDto,
  SendEnquiryMessageDto,
} from './marketplace.dto';
import { MarketplaceService } from './marketplace.service';
import { SellerListingsService } from './seller-listings.service';

/** The marketplace for members: browse, listing and seller pages, requests and reviews. Needs `marketplace.browse`. */
@ApiTags('Marketplace')
@ApiBearerAuth('access-token')
@RequiresPermission('marketplace.browse')
@Controller('marketplace')
export class MarketplaceController {
  constructor(
    private readonly market: MarketplaceService,
    private readonly enquiries: EnquiriesService,
    private readonly sellerListings: SellerListingsService,
  ) {}

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(MarketplaceHomeDto)
  @Get('home')
  async home(@CurrentAuth() auth: AuthContext) {
    return this.market.home(auth.userId, await this.market.isSeller(auth.userId));
  }

  @ApiEnvelope(CategoryDto, { isArray: true })
  @Get('categories')
  categories() {
    return this.market.categories();
  }

  /** The seller terms shown before a member starts selling. A draft placeholder until the owner supplies the text. */
  @RequiresPermission('seller.apply')
  @ApiEnvelope(SellerTermsDto)
  @Get('seller-terms')
  terms() {
    return this.sellerListings.terms();
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(ListingCardDto, { isArray: true })
  @Get('listings')
  async listings(@CurrentAuth() auth: AuthContext, @Query() q: ListingsQueryDto) {
    const { items, meta } = await this.market.list(auth.userId, q);
    return new Paged(items, meta);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(ListingDto)
  @Get('listings/:id')
  async listing(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    const dto = await this.market.detail(auth.userId, id);
    await this.market.recordView(auth.userId, id).catch(() => undefined);
    return dto;
  }

  @ApiEnvelope(ListingReviewDto, { isArray: true })
  @Get('listings/:id/reviews')
  async reviews(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Query() q: ReviewsQueryDto,
  ) {
    const { items, meta } = await this.market.reviews(auth.userId, id, q);
    return new Paged(items, meta);
  }

  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @HttpCode(204)
  @Post('listings/:id/report')
  async report(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReportListingDto,
  ) {
    await this.market.report(auth.userId, id, dto);
  }

  /** "Request booking": sends a request to the seller. No checkout, escrow or payment happens here. */
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiEnvelope(EnquiryThreadDto, { status: 201 })
  @Post('listings/:id/enquiries')
  requestBooking(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CreateEnquiryDto,
  ) {
    return this.enquiries.create(auth.userId, id, dto);
  }

  // `sellers` is registered before `sellers/:id` so it is never read as an id.
  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(SellerCardDto, { isArray: true })
  @Get('sellers')
  async sellers(@CurrentAuth() auth: AuthContext, @Query() q: SellersQueryDto) {
    const { items, meta } = await this.market.sellers(auth.userId, q);
    return new Paged(items, meta);
  }

  @Throttle({ default: { limit: 120, ttl: 60_000 } })
  @ApiEnvelope(SellerProfileDto)
  @Get('sellers/:id')
  seller(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.market.seller(auth.userId, id);
  }

  // ---- requests and their thread: only the two parties ever see them ----

  @ApiEnvelope(EnquiryDto, { isArray: true })
  @Get('enquiries')
  async myEnquiries(@CurrentAuth() auth: AuthContext, @Query() q: EnquiriesQueryDto) {
    const { items, meta } = await this.enquiries.list(auth.userId, q);
    return new Paged(items, meta);
  }

  @ApiEnvelope(EnquiryThreadDto)
  @Get('enquiries/:id')
  thread(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.enquiries.thread(auth.userId, id);
  }

  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiEnvelope(EnquiryThreadDto, { status: 201 })
  @Post('enquiries/:id/messages')
  send(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SendEnquiryMessageDto,
  ) {
    return this.enquiries.send(auth.userId, id, dto.body);
  }

  @HttpCode(200)
  @ApiEnvelope(EnquiryThreadDto)
  @Post('enquiries/:id/close')
  close(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.enquiries.close(auth.userId, id);
  }

  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiEnvelope(EnquiryThreadDto, { status: 201 })
  @Post('enquiries/:id/review')
  review(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReviewDto,
  ) {
    return this.enquiries.review(auth.userId, id, dto);
  }
}
