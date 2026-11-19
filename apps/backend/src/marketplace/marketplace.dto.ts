import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import {
  EnquiryStatus,
  ListingReportStatus,
  ListingStatus,
  ListingType,
  PricingType,
  ReportReason,
  ReviewVisibility,
  SellerStatus,
  VerificationStatus,
  WorkMode,
} from '@prisma/client';
import { PageQueryDto } from '../common/pagination';
import {
  MAX_DESCRIPTION,
  MAX_ENQUIRY_MESSAGE,
  MAX_INCLUDED,
  MAX_INCLUDED_LENGTH,
  MAX_LISTING_MEDIA,
  MAX_LISTING_PROJECTS,
  MAX_TITLE,
} from './marketplace-logic';

const flag = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1'
    ? true
    : value === false || value === 'false' || value === '0'
      ? false
      : value;

export const LISTING_SORTS = [
  'recommended',
  'price_low',
  'price_high',
  'rating',
  'newest',
] as const;
export type ListingSort = (typeof LISTING_SORTS)[number];
export const SELLER_SORTS = ['popular', 'rating', 'newest'] as const;

// ---- shared shapes ----------------------------------------------------------------------------------------------

export class CategoryDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ description: 'Lucide icon name.' }) icon!: string;
  @ApiProperty({ description: 'Design-token tone.' }) tone!: string;
  @ApiProperty({ description: 'Published listings in this category.' }) count!: number;
}

export class SellerCardDto {
  @ApiProperty({ format: 'uuid', description: 'The seller profile id.' }) id!: string;
  @ApiProperty() displayName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) handle!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) headline!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) avatarUrl!: string | null;
  @ApiPropertyOptional({ type: Number, nullable: true }) ratingAverage!: number | null;
  @ApiProperty() ratingCount!: number;
  @ApiProperty() completedCount!: number;
  @ApiProperty({ description: 'Published listings.' }) listingCount!: number;
  @ApiProperty({
    description: 'True only when the seller is verified by Atarah (written by P2-M6).',
  })
  verified!: boolean;
}

export class ListingCardDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ListingType, enumName: 'ListingType' }) type!: ListingType;
  @ApiProperty() title!: string;
  @ApiProperty() categoryName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) coverUrl!: string | null;
  @ApiProperty({ enum: PricingType, enumName: 'PricingType' }) pricingType!: PricingType;
  @ApiProperty({
    description: 'Ready to show: "KES 5,000", "KES 5,000 to KES 9,000", "Price on request".',
  })
  priceLabel!: string;
  @ApiPropertyOptional({ type: String, nullable: true, description: '"From KES 5,000".' })
  fromLabel!: string | null;
  @ApiProperty({ type: SellerCardDto }) seller!: SellerCardDto;
  @ApiPropertyOptional({ type: Number, nullable: true }) ratingAverage!: number | null;
  @ApiProperty() ratingCount!: number;
  @ApiProperty() featured!: boolean;
  @ApiProperty({ description: 'The member saved it.' }) saved!: boolean;
  @ApiProperty({ enum: ListingStatus, enumName: 'ListingStatus' }) status!: ListingStatus;
}

export class ListingMediaDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ['IMAGE', 'VIDEO', 'AUDIO'] }) kind!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) url!: string | null;
}

export class ListingPortfolioProjectDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) coverUrl!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) category!: string | null;
}

export class ListingReviewDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ minimum: 1, maximum: 5 }) rating!: number;
  @ApiPropertyOptional({ type: String, nullable: true }) body!: string | null;
  @ApiProperty() reviewerName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) reviewerAvatarUrl!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class ListingDto extends ListingCardDto {
  @ApiProperty() description!: string;
  @ApiProperty({ type: [String] }) includedItems!: string[];
  @ApiPropertyOptional({ type: Number, nullable: true }) deliveryDays!: number | null;
  @ApiProperty({ enum: WorkMode, enumName: 'WorkMode' }) workMode!: WorkMode;
  @ApiPropertyOptional({ type: String, nullable: true }) locationText!: string | null;
  @ApiProperty({ description: 'Ready to show: "Remote", "Nairobi", "Hybrid · Nairobi".' })
  locationLabel!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) audienceText!: string | null;
  @ApiPropertyOptional({ type: Number, nullable: true, description: 'Whole shillings.' })
  priceMin!: number | null;
  @ApiPropertyOptional({ type: Number, nullable: true, description: 'Whole shillings (RANGE).' })
  priceMax!: number | null;
  @ApiProperty({ format: 'uuid' }) categoryId!: string;
  @ApiProperty({ type: [ListingMediaDto] }) media!: ListingMediaDto[];
  @ApiProperty({ type: [ListingPortfolioProjectDto] }) portfolio!: ListingPortfolioProjectDto[];
  @ApiProperty({
    type: [ListingReviewDto],
    description: 'The latest few. The full list has its own endpoint.',
  })
  reviews!: ListingReviewDto[];
  @ApiPropertyOptional({ type: String, nullable: true }) rejectionReason!: string | null;
  @ApiProperty({ description: 'The viewer owns the listing.' }) isOwner!: boolean;
  @ApiPropertyOptional({
    type: String,
    format: 'uuid',
    nullable: true,
    description: 'The viewer already has an open request on this listing.',
  })
  openEnquiryId!: string | null;
  @ApiProperty({ description: 'The one-line note shown under the request button.' })
  requestNote!: string;
  @ApiProperty({ description: 'Public share address.' }) shareUrl!: string;
}

export class SellerProfileDto extends SellerCardDto {
  @ApiProperty({ format: 'uuid' }) userId!: string;
  @ApiPropertyOptional({
    type: Number,
    nullable: true,
    description: 'Median first reply, in minutes.',
  })
  medianReplyMinutes!: number | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Ready to show: "Replies within 3 hours".',
  })
  replyLabel!: string | null;
  @ApiProperty({
    type: [String],
    description:
      'Only real trust lines, for example "Identity verified by Atarah". Empty when there are none.',
  })
  trustLines!: string[];
  @ApiPropertyOptional({ type: String, nullable: true }) bio!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) location!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) memberSince!: Date;
  @ApiProperty({ type: [ListingCardDto], description: 'Services and products that are live.' })
  listings!: ListingCardDto[];
  @ApiProperty({ description: 'Public creative profile handle exists and can be opened.' })
  hasProfile!: boolean;
}

export class MarketplaceHomeDto {
  @ApiProperty({ description: 'The member holds the seller role (shows "My listings").' })
  isSeller!: boolean;
  @ApiProperty({ type: [CategoryDto] }) categories!: CategoryDto[];
  @ApiProperty({ type: [ListingCardDto] }) featured!: ListingCardDto[];
  @ApiProperty({ type: [SellerCardDto] }) popularSellers!: SellerCardDto[];
  @ApiProperty({ type: [ListingCardDto], description: 'Newest live listings.' })
  recent!: ListingCardDto[];
}

export class SellerTermsDto {
  @ApiProperty() version!: string;
  @ApiProperty({
    description: 'True while the text is the placeholder, not the owner-approved terms.',
  })
  isDraft!: boolean;
  @ApiProperty() title!: string;
  @ApiProperty() body!: string;
}

// ---- browse queries ---------------------------------------------------------------------------------------------

export class ListingsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: ListingType, enumName: 'ListingType' })
  @IsOptional()
  @IsEnum(ListingType)
  type?: ListingType;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  categoryId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  sellerId?: string;

  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ enum: LISTING_SORTS, enumName: 'ListingSort', default: 'recommended' })
  @IsOptional()
  @IsIn(LISTING_SORTS)
  sort?: ListingSort;

  @ApiPropertyOptional({ description: 'Whole shillings; listings from this price up.' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  minPrice?: number;

  @ApiPropertyOptional({
    description: 'Whole shillings; listings whose lowest price is at most this.',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  maxPrice?: number;

  @ApiPropertyOptional({ description: 'Only remote listings.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  remote?: boolean;

  @ApiPropertyOptional({ description: 'Only listings with a price (not "on request").' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  priced?: boolean;
}

export class SellersQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ enum: SELLER_SORTS, default: 'popular' })
  @IsOptional()
  @IsIn(SELLER_SORTS)
  sort?: (typeof SELLER_SORTS)[number];
}

// ---- seller: creating and editing -------------------------------------------------------------------------------

export class ListingFieldsDto {
  @ApiPropertyOptional({ nullable: true, enum: ListingType, enumName: 'ListingType' })
  @IsOptional()
  @IsEnum(ListingType)
  type?: ListingType;

  @ApiPropertyOptional({ nullable: true, maxLength: MAX_TITLE })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_TITLE)
  title?: string;

  @ApiPropertyOptional({ nullable: true, format: 'uuid' })
  @IsOptional()
  @IsUUID()
  categoryId?: string;

  @ApiPropertyOptional({ nullable: true, maxLength: MAX_DESCRIPTION })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_DESCRIPTION)
  description?: string;

  @ApiPropertyOptional({ nullable: true, type: [String], maxItems: MAX_INCLUDED })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_INCLUDED)
  @IsString({ each: true })
  @MaxLength(MAX_INCLUDED_LENGTH, { each: true })
  includedItems?: string[];

  @ApiPropertyOptional({
    nullable: true,
    minimum: 0,
    maximum: 365,
    description: 'Delivery time in days; 0 clears it.',
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(365)
  deliveryDays?: number;

  @ApiPropertyOptional({ nullable: true, enum: WorkMode, enumName: 'WorkMode' })
  @IsOptional()
  @IsEnum(WorkMode)
  workMode?: WorkMode;

  @ApiPropertyOptional({ nullable: true, maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  locationText?: string;

  @ApiPropertyOptional({ nullable: true, maxLength: 240, description: 'Who it is for.' })
  @IsOptional()
  @IsString()
  @MaxLength(240)
  audienceText?: string;

  @ApiPropertyOptional({ nullable: true, enum: PricingType, enumName: 'PricingType' })
  @IsOptional()
  @IsEnum(PricingType)
  pricingType?: PricingType;

  @ApiPropertyOptional({ nullable: true, description: 'Whole shillings. FIXED and RANGE.' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100_000_000)
  priceMin?: number;

  @ApiPropertyOptional({ nullable: true, description: 'Whole shillings. RANGE only.' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100_000_000)
  priceMax?: number;

  @ApiPropertyOptional({
    nullable: true,
    type: [String],
    format: 'uuid',
    maxItems: MAX_LISTING_MEDIA,
    description: 'Uploaded public images, in order. The first is the cover.',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_LISTING_MEDIA)
  @IsUUID('all', { each: true })
  mediaIds?: string[];

  @ApiPropertyOptional({
    nullable: true,
    type: [String],
    format: 'uuid',
    maxItems: MAX_LISTING_PROJECTS,
    description: 'The member’s own published projects to show as examples.',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_LISTING_PROJECTS)
  @IsUUID('all', { each: true })
  projectIds?: string[];
}

export class CreateListingDto extends ListingFieldsDto {
  @ApiPropertyOptional({
    nullable: true,
    description:
      'Required for a member who is not a seller yet: accepts the seller terms and makes them a seller.',
  })
  @IsOptional()
  @IsBoolean()
  acceptTerms?: boolean;

  @ApiPropertyOptional({ nullable: true, description: 'The version of the terms that was shown.' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  termsVersion?: string;
}

export class MyListingDto extends ListingDto {
  @ApiProperty({ description: 'Open and unread requests.' }) newInterest!: number;
  @ApiProperty({ description: 'Distinct viewers in the last 30 days.' }) views30d!: number;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) profileServiceId!:
    string | null;
  @ApiProperty({
    description: 'What the listing still needs before it can be submitted.',
    type: [String],
  })
  missing!: string[];
}

export class MyListingsStatsDto {
  @ApiProperty() live!: number;
  @ApiProperty() newInterest!: number;
  @ApiProperty() views30d!: number;
}

export class MyListingsDto {
  @ApiProperty() isSeller!: boolean;
  @ApiPropertyOptional({ enum: SellerStatus, enumName: 'SellerStatus', nullable: true })
  sellerStatus!: SellerStatus | null;
  @ApiProperty({ type: MyListingsStatsDto }) stats!: MyListingsStatsDto;
  @ApiProperty({ type: [ListingCardDto] }) listings!: ListingCardDto[];
}

export class SubmitResultDto {
  @ApiProperty({ type: ListingDto }) listing!: ListingDto;
  @ApiProperty({
    description: 'True when it went live straight away; false when it is waiting for review.',
  })
  published!: boolean;
}

// ---- reporting --------------------------------------------------------------------------------------------------

export class ReportListingDto {
  @ApiProperty({ enum: ReportReason, enumName: 'ReportReason' })
  @IsEnum(ReportReason)
  reason!: ReportReason;

  @ApiPropertyOptional({ maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}

// ---- enquiries --------------------------------------------------------------------------------------------------

export class CreateEnquiryDto {
  @ApiProperty({ description: 'What you need.', maxLength: MAX_ENQUIRY_MESSAGE })
  @IsString()
  @MinLength(10)
  @MaxLength(MAX_ENQUIRY_MESSAGE)
  message!: string;

  @ApiPropertyOptional({ description: 'Whole shillings.' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100_000_000)
  budget?: number;

  @ApiPropertyOptional({
    maxLength: 120,
    description: 'For example "Next month" or "By 15 December".',
  })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  preferredTiming?: string;
}

export class SendEnquiryMessageDto {
  @ApiProperty({ maxLength: MAX_ENQUIRY_MESSAGE })
  @IsString()
  @MinLength(1)
  @MaxLength(MAX_ENQUIRY_MESSAGE)
  body!: string;
}

export class ReviewDto {
  @ApiProperty({ minimum: 1, maximum: 5 })
  @IsInt()
  @Min(1)
  @Max(5)
  rating!: number;

  @ApiPropertyOptional({ maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  body?: string;
}

export class EnquiryPartyDto {
  @ApiProperty({ format: 'uuid' }) userId!: string;
  @ApiProperty() displayName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) handle!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) avatarUrl!: string | null;
}

export class EnquiryMessageDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ format: 'uuid' }) senderId!: string;
  @ApiProperty() body!: string;
  @ApiProperty({ description: 'Sent by the person asking.' }) fromMe!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class EnquiryDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ format: 'uuid' }) listingId!: string;
  @ApiProperty() listingTitle!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) listingCoverUrl!: string | null;
  @ApiProperty({ enum: EnquiryStatus, enumName: 'EnquiryStatus' }) status!: EnquiryStatus;
  @ApiProperty({ enum: ['BUYER', 'SELLER'], description: 'Which side the viewer is.' })
  role!: 'BUYER' | 'SELLER';
  @ApiProperty({ type: EnquiryPartyDto, description: 'The other person.' })
  counterpart!: EnquiryPartyDto;
  @ApiProperty() message!: string;
  @ApiPropertyOptional({ type: Number, nullable: true, description: 'Whole shillings.' })
  budget!: number | null;
  @ApiPropertyOptional({ type: String, nullable: true }) preferredTiming!: string | null;
  @ApiProperty({ description: 'There is something the viewer has not read.' }) unread!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) lastMessageAt!: Date;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  closedAt!: Date | null;
  @ApiProperty({ description: 'The buyer may leave a review now.' }) canReview!: boolean;
  @ApiProperty({ description: 'The viewer may close it now.' }) canClose!: boolean;
  @ApiProperty({ description: 'A review has been left.' }) reviewed!: boolean;
}

export class EnquiryThreadDto extends EnquiryDto {
  @ApiProperty({ type: [EnquiryMessageDto] }) messages!: EnquiryMessageDto[];
}

export class EnquiriesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    enum: ['buyer', 'seller'],
    description: 'Requests you sent, or requests on your listings.',
  })
  @IsOptional()
  @IsIn(['buyer', 'seller'])
  as?: 'buyer' | 'seller';

  @ApiPropertyOptional({ enum: EnquiryStatus, enumName: 'EnquiryStatus' })
  @IsOptional()
  @IsEnum(EnquiryStatus)
  status?: EnquiryStatus;

  @ApiPropertyOptional({ format: 'uuid', description: 'Only requests on this listing.' })
  @IsOptional()
  @IsUUID()
  listingId?: string;
}

export class ReviewsQueryDto extends PageQueryDto {}

// ---- admin ------------------------------------------------------------------------------------------------------

export class AdminSellersQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ maxLength: 80, description: 'Name, handle or email.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ enum: SellerStatus, enumName: 'SellerStatus' })
  @IsOptional()
  @IsEnum(SellerStatus)
  status?: SellerStatus;
}

export class AdminSellerDto extends SellerCardDto {
  @ApiProperty({ format: 'uuid' }) userId!: string;
  @ApiProperty() email!: string;
  @ApiProperty({ enum: SellerStatus, enumName: 'SellerStatus' }) status!: SellerStatus;
  @ApiProperty({ enum: VerificationStatus, enumName: 'VerificationStatus' })
  verificationStatus!: VerificationStatus;
  @ApiProperty() canPublishDirectly!: boolean;
  @ApiProperty() termsVersion!: string;
  @ApiProperty({ type: String, format: 'date-time' }) termsAcceptedAt!: Date;
  @ApiPropertyOptional({ type: String, nullable: true }) suspendedReason!: string | null;
  @ApiProperty() liveListings!: number;
  @ApiProperty() underReviewListings!: number;
  @ApiProperty() openReports!: number;
}

export class ReasonDto {
  @ApiProperty({
    minLength: 5,
    maxLength: 500,
    description: 'Recorded in the audit log; the member sees it for rejections.',
  })
  @IsString()
  @MinLength(5)
  @MaxLength(500)
  reason!: string;
}

export class SetDirectPublishDto {
  @ApiProperty()
  @IsBoolean()
  canPublishDirectly!: boolean;
}

export class AdminListingsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: ListingStatus, enumName: 'ListingStatus' })
  @IsOptional()
  @IsEnum(ListingStatus)
  status?: ListingStatus;

  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ description: 'Only listings with open reports.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  reported?: boolean;
}

export class AdminListingDto extends ListingCardDto {
  @ApiProperty() description!: string;
  @ApiProperty({ type: [String] }) includedItems!: string[];
  @ApiProperty({ type: [ListingMediaDto] }) media!: ListingMediaDto[];
  @ApiPropertyOptional({ type: String, nullable: true }) rejectionReason!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) suspendedReason!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  featuredUntil!: Date | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  publishedAt!: Date | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty() openReports!: number;
  @ApiProperty({ enum: SellerStatus, enumName: 'SellerStatus' }) sellerStatus!: SellerStatus;
  @ApiProperty() sellerApprovedBefore!: number;
}

export class FeatureListingDto {
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description: 'Null un-features.',
  })
  @IsOptional()
  @IsISO8601()
  until?: string | null;
}

export class AdminListingReportsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    enum: ListingReportStatus,
    enumName: 'ListingReportStatus',
    default: 'OPEN',
  })
  @IsOptional()
  @IsEnum(ListingReportStatus)
  status?: ListingReportStatus;
}

export class AdminListingReportDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ format: 'uuid' }) listingId!: string;
  @ApiProperty() listingTitle!: string;
  @ApiProperty({ enum: ListingStatus, enumName: 'ListingStatus' }) listingStatus!: ListingStatus;
  @ApiProperty() sellerName!: string;
  @ApiProperty() reporterName!: string;
  @ApiProperty({ enum: ReportReason, enumName: 'ReportReason' }) reason!: ReportReason;
  @ApiPropertyOptional({ type: String, nullable: true }) note!: string | null;
  @ApiProperty({ enum: ListingReportStatus, enumName: 'ListingReportStatus' })
  status!: ListingReportStatus;
  @ApiPropertyOptional({ type: String, nullable: true }) resolution!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class ResolveReportDto {
  @ApiProperty({ enum: ['DISMISS', 'SUSPEND_LISTING'] })
  @IsIn(['DISMISS', 'SUSPEND_LISTING'])
  action!: 'DISMISS' | 'SUSPEND_LISTING';

  @ApiProperty({ minLength: 5, maxLength: 500 })
  @IsString()
  @MinLength(5)
  @MaxLength(500)
  note!: string;
}

export class MarketplaceCategoryFieldsDto {
  @ApiProperty({ maxLength: 60 })
  @IsString()
  @MinLength(2)
  @MaxLength(60)
  name!: string;

  @ApiProperty({ maxLength: 40, description: 'Lucide icon name.' })
  @IsString()
  @MinLength(2)
  @MaxLength(40)
  icon!: string;

  @ApiProperty({ enum: ['violet', 'pink', 'orange', 'green', 'blue', 'purple', 'amber'] })
  @IsIn(['violet', 'pink', 'orange', 'green', 'blue', 'purple', 'amber'])
  tone!: string;

  @ApiPropertyOptional({ minimum: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateMarketplaceCategoryDto {
  @ApiPropertyOptional({ nullable: true, maxLength: 60 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(60)
  name?: string;

  @ApiPropertyOptional({ nullable: true, maxLength: 40 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(40)
  icon?: string;

  @ApiPropertyOptional({
    nullable: true,
    enum: ['violet', 'pink', 'orange', 'green', 'blue', 'purple', 'amber'],
  })
  @IsOptional()
  @IsIn(['violet', 'pink', 'orange', 'green', 'blue', 'purple', 'amber'])
  tone?: string;

  @ApiPropertyOptional({ nullable: true, minimum: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @ApiPropertyOptional({ nullable: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class AdminMarketplaceCategoryDto extends CategoryDto {
  @ApiProperty() sortOrder!: number;
  @ApiProperty() isActive!: boolean;
}

export class AdminReviewsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: ReviewVisibility, enumName: 'ReviewVisibility' })
  @IsOptional()
  @IsEnum(ReviewVisibility)
  status?: ReviewVisibility;
}

export class AdminReviewDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ format: 'uuid' }) listingId!: string;
  @ApiProperty() listingTitle!: string;
  @ApiProperty() reviewerName!: string;
  @ApiProperty({ minimum: 1, maximum: 5 }) rating!: number;
  @ApiPropertyOptional({ type: String, nullable: true }) body!: string | null;
  @ApiProperty({ enum: ReviewVisibility, enumName: 'ReviewVisibility' }) status!: ReviewVisibility;
  @ApiPropertyOptional({ type: String, nullable: true }) hiddenReason!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}
