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
} from '@nestjs/common';
import { ApiBearerAuth, ApiProperty, ApiPropertyOptional, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { IsBoolean, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';
import { type AuthContext } from '../access/access.types';
import { CurrentAuth, RequiresPermission } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import {
  CreateListingDto,
  ListingFieldsDto,
  MyListingDto,
  MyListingsDto,
  SubmitResultDto,
} from './marketplace.dto';
import { SellerListingsService } from './seller-listings.service';

export class PublishServiceDto {
  @ApiProperty({ format: 'uuid', description: 'The marketplace category for the new draft.' })
  @IsUUID()
  categoryId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  acceptTerms?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(40)
  termsVersion?: string;
}

/** A seller's own listings. Creating needs `seller.apply` (it makes the member a seller); the rest `listing.manage.own`. */
@ApiTags('Marketplace')
@ApiBearerAuth('access-token')
@Controller()
export class MyMarketplaceController {
  constructor(private readonly listings: SellerListingsService) {}

  @RequiresPermission('marketplace.browse')
  @ApiEnvelope(MyListingsDto)
  @Get('me/listings')
  mine(@CurrentAuth() auth: AuthContext) {
    return this.listings.mine(auth.userId);
  }

  @RequiresPermission('seller.apply')
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @ApiEnvelope(MyListingDto, { status: 201 })
  @Post('me/listings')
  create(@CurrentAuth() auth: AuthContext, @Body() dto: CreateListingDto) {
    return this.listings.create(auth.userId, dto);
  }

  @RequiresPermission('listing.manage.own')
  @ApiEnvelope(MyListingDto)
  @Get('me/listings/:id')
  detail(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.listings.myDetail(auth.userId, id);
  }

  @RequiresPermission('listing.manage.own')
  @Throttle({ default: { limit: 60, ttl: 60_000 } })
  @ApiEnvelope(MyListingDto)
  @Patch('me/listings/:id')
  update(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ListingFieldsDto,
  ) {
    return this.listings.update(auth.userId, id, dto);
  }

  @RequiresPermission('listing.manage.own')
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @HttpCode(200)
  @ApiEnvelope(SubmitResultDto)
  @Post('me/listings/:id/submit')
  submit(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.listings.submit(auth.userId, id);
  }

  @RequiresPermission('listing.manage.own')
  @HttpCode(200)
  @ApiEnvelope(MyListingDto)
  @Post('me/listings/:id/withdraw')
  withdraw(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.listings.withdraw(auth.userId, id);
  }

  @RequiresPermission('listing.manage.own')
  @HttpCode(200)
  @ApiEnvelope(MyListingDto)
  @Post('me/listings/:id/archive')
  archive(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.listings.archive(auth.userId, id);
  }

  @RequiresPermission('listing.manage.own')
  @HttpCode(200)
  @ApiEnvelope(MyListingDto)
  @Post('me/listings/:id/restore')
  restore(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    return this.listings.restore(auth.userId, id);
  }

  @RequiresPermission('listing.manage.own')
  @HttpCode(204)
  @Delete('me/listings/:id')
  async remove(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.listings.remove(auth.userId, id);
  }

  /** "Publish" on a profile service: makes a draft listing from it (and a seller of the member, on first use). */
  @RequiresPermission('seller.apply')
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @ApiEnvelope(MyListingDto, { status: 201 })
  @Post('me/services/:id/listing')
  fromService(
    @CurrentAuth() auth: AuthContext,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: PublishServiceDto,
  ) {
    return this.listings.fromService(auth.userId, id, dto);
  }
}
