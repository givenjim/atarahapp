import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEmail,
  IsEnum,
  IsIn,
  IsISO8601,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  Length,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';
import {
  ApplicationMethod,
  OpportunityOutcome,
  OpportunityProviderType,
  OpportunityRuleType,
  OpportunityStatus,
  OpportunityTrackingStatus,
  OpportunityTrust,
  OpportunityType,
  VerificationStatus,
  WorkMode,
} from '@prisma/client';
import { PageQueryDto } from '../common/pagination';

const flag = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1'
    ? true
    : value === false || value === 'false' || value === '0'
      ? false
      : value;

export const OPPORTUNITY_SORTS = ['deadline', 'recent', 'relevance'] as const;
export const DEADLINE_WINDOWS = ['7d', '14d', '30d'] as const;
export const MY_TABS = ['all', 'closing', 'applied', 'completed', 'saved'] as const;
export const MAX_TITLE = 140;
export const MAX_SUMMARY = 300;
export const MAX_ABOUT = 8_000;
export const MAX_LIST_ITEMS = 20;
export const MAX_LIST_ITEM_LENGTH = 200;

// ---- members: queries -------------------------------------------------------------------------------------------

export class OpportunitiesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: OpportunityType, enumName: 'OpportunityType' })
  @IsOptional()
  @IsEnum(OpportunityType)
  type?: OpportunityType;

  @ApiPropertyOptional({ maxLength: 80, description: 'Title, summary or provider.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  disciplineId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  countyId?: string;

  @ApiPropertyOptional({ description: 'Only remote opportunities.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  remote?: boolean;

  @ApiPropertyOptional({ enum: DEADLINE_WINDOWS, description: 'Closing within 7, 14 or 30 days.' })
  @IsOptional()
  @IsIn(DEADLINE_WINDOWS)
  deadline?: (typeof DEADLINE_WINDOWS)[number];

  @ApiPropertyOptional({ enum: OpportunityTrust, enumName: 'OpportunityTrust' })
  @IsOptional()
  @IsEnum(OpportunityTrust)
  trust?: OpportunityTrust;

  @ApiPropertyOptional({ enum: OPPORTUNITY_SORTS, default: 'deadline' })
  @IsOptional()
  @IsIn(OPPORTUNITY_SORTS)
  sort?: (typeof OPPORTUNITY_SORTS)[number];
}

export class OpportunityDetailQueryDto {
  @ApiPropertyOptional({
    description: 'Skip the 5 minute cache of the profile check (after editing a profile).',
  })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  refresh?: boolean;
}

export class MyOpportunitiesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: MY_TABS, default: 'all' })
  @IsOptional()
  @IsIn(MY_TABS)
  tab?: (typeof MY_TABS)[number];
}

export class TrackOpportunityDto {
  @ApiProperty({ enum: OpportunityTrackingStatus, enumName: 'OpportunityTrackingStatus' })
  @IsEnum(OpportunityTrackingStatus)
  status!: OpportunityTrackingStatus;

  @ApiPropertyOptional({
    enum: OpportunityOutcome,
    enumName: 'OpportunityOutcome',
    description: 'Only with COMPLETED. Defaults to UNKNOWN.',
  })
  @IsOptional()
  @IsEnum(OpportunityOutcome)
  outcome?: OpportunityOutcome;

  @ApiPropertyOptional({ maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}

// ---- members: responses -----------------------------------------------------------------------------------------

export class OpportunityProviderLiteDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ enum: OpportunityProviderType, enumName: 'OpportunityProviderType' })
  type!: OpportunityProviderType;
  @ApiProperty() verified!: boolean;
  @ApiPropertyOptional({ type: String, nullable: true }) logoUrl!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) website!: string | null;
}

export class TrackingStateDto {
  @ApiProperty({ enum: OpportunityTrackingStatus, enumName: 'OpportunityTrackingStatus' })
  status!: OpportunityTrackingStatus;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true }) savedAt!: Date | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  appliedAt!: Date | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  completedAt!: Date | null;
  @ApiPropertyOptional({ enum: OpportunityOutcome, enumName: 'OpportunityOutcome', nullable: true })
  outcome!: OpportunityOutcome | null;
}

export class OpportunityCardDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty({ enum: OpportunityType, enumName: 'OpportunityType' }) type!: OpportunityType;
  @ApiProperty() title!: string;
  @ApiProperty() summary!: string;
  @ApiProperty({ enum: OpportunityTrust, enumName: 'OpportunityTrust' }) trust!: OpportunityTrust;
  @ApiProperty({ type: OpportunityProviderLiteDto }) provider!: OpportunityProviderLiteDto;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Ready to show: "KES 500,000".',
  })
  valueLabel!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  deadlineAt!: Date | null;
  @ApiPropertyOptional({
    type: Number,
    nullable: true,
    description: 'Whole days left; null for a rolling deadline.',
  })
  daysLeft!: number | null;
  @ApiPropertyOptional({
    enum: ['URGENT', 'SOON'],
    nullable: true,
    description: 'Closing soon: URGENT is 7 days or fewer (Coral), SOON is 8 to 14 (Tangerine).',
  })
  urgency!: 'URGENT' | 'SOON' | null;
  @ApiProperty({ enum: WorkMode, enumName: 'WorkMode' }) workMode!: WorkMode;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'County name, "Remote" or "Hybrid".',
  })
  locationLabel!: string | null;
  @ApiProperty() featured!: boolean;
  @ApiProperty({ description: 'The member has it in their saved list (SAVED or IN_PROGRESS).' })
  saved!: boolean;
  @ApiPropertyOptional({ type: TrackingStateDto, nullable: true })
  tracking!: TrackingStateDto | null;
  @ApiProperty({
    description: 'The deadline has passed or the listing closed; only tracked items stay visible.',
  })
  closed!: boolean;
}

export class RuleFixDto {
  @ApiProperty() label!: string;
  @ApiProperty({ description: 'An in-app path.' }) path!: string;
}

export class RuleResultDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: OpportunityRuleType, enumName: 'OpportunityRuleType' })
  ruleType!: OpportunityRuleType;
  @ApiProperty() label!: string;
  @ApiProperty() isBlocking!: boolean;
  @ApiProperty({ enum: ['MET', 'MISSING', 'UNKNOWN'] }) state!: 'MET' | 'MISSING' | 'UNKNOWN';
  @ApiPropertyOptional({ type: String, nullable: true }) detail!: string | null;
  @ApiPropertyOptional({ type: RuleFixDto, nullable: true }) fix!: RuleFixDto | null;
}

export class ProfileGapDto {
  @ApiProperty({ enum: ['READY', 'MISSING', 'UNCHECKED', 'NO_RULES'] })
  verdict!: 'READY' | 'MISSING' | 'UNCHECKED' | 'NO_RULES';
  @ApiProperty() metCount!: number;
  @ApiProperty() missingCount!: number;
  @ApiProperty() unknownCount!: number;
  @ApiProperty() blockingMissingCount!: number;
  @ApiProperty({ type: [RuleResultDto] }) rules!: RuleResultDto[];
}

export class OpportunityDto extends OpportunityCardDto {
  @ApiProperty() about!: string;
  @ApiProperty({ type: [String] }) requirements!: string[];
  @ApiProperty({ type: [String] }) benefits!: string[];
  @ApiProperty({ enum: ApplicationMethod, enumName: 'ApplicationMethod' })
  applicationMethod!: ApplicationMethod;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'The https address the app opens.',
  })
  applicationUrl!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) applicationEmail!: string | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Named in the "Leaving Atarah" modal.',
  })
  applicationDomain!: string | null;
  @ApiPropertyOptional({ type: [String], description: 'Discipline names.' }) disciplines!: string[];
  @ApiProperty({ type: ProfileGapDto }) profileGap!: ProfileGapDto;
  @ApiProperty() shareUrl!: string;
}

export class OpportunityCategoryCountDto {
  @ApiProperty({ enum: OpportunityType, enumName: 'OpportunityType' }) type!: OpportunityType;
  @ApiProperty() count!: number;
}

export class OpportunitiesHomeDto {
  @ApiProperty({ description: 'Saved list size, for the badge on the saved button.' })
  savedCount!: number;
  @ApiProperty({ type: [OpportunityCategoryCountDto] }) categories!: OpportunityCategoryCountDto[];
  @ApiProperty({ type: [OpportunityCardDto] }) featured!: OpportunityCardDto[];
  @ApiProperty({ type: [OpportunityCardDto] }) closingSoon!: OpportunityCardDto[];
  @ApiProperty({ type: [OpportunityCardDto] }) recent!: OpportunityCardDto[];
}

export class MyOpportunityDto {
  @ApiProperty({ type: OpportunityCardDto }) opportunity!: OpportunityCardDto;
  @ApiProperty({ type: TrackingStateDto }) tracking!: TrackingStateDto;
}

export class MyOpportunityCountsDto {
  @ApiProperty() all!: number;
  @ApiProperty() closing!: number;
  @ApiProperty() applied!: number;
  @ApiProperty() completed!: number;
  @ApiProperty() saved!: number;
}

// ---- staff: write bodies ----------------------------------------------------------------------------------------

const stringList = (v: unknown): unknown =>
  Array.isArray(v)
    ? v.map((s) => (typeof s === 'string' ? s.trim() : s)).filter((s) => s !== '')
    : v;

export class RuleInputDto {
  @ApiProperty({ enum: OpportunityRuleType, enumName: 'OpportunityRuleType' })
  @IsEnum(OpportunityRuleType)
  ruleType!: OpportunityRuleType;

  @ApiProperty({
    type: 'object',
    additionalProperties: true,
    description: 'Validated per rule type.',
  })
  @IsObject()
  params!: Record<string, unknown>;

  @ApiProperty({
    minLength: 3,
    maxLength: 140,
    description: 'What the member reads: "At least 3 published projects".',
  })
  @IsString()
  @Length(3, 140)
  label!: string;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  isBlocking?: boolean;
}

export class OpportunityFieldsDto {
  @ApiProperty({ minLength: 3, maxLength: MAX_TITLE })
  @IsString()
  @Length(3, MAX_TITLE)
  title!: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  providerId!: string;

  @ApiProperty({ enum: OpportunityType, enumName: 'OpportunityType' })
  @IsEnum(OpportunityType)
  type!: OpportunityType;

  @ApiProperty({ minLength: 10, maxLength: MAX_SUMMARY })
  @IsString()
  @Length(10, MAX_SUMMARY)
  summary!: string;

  @ApiPropertyOptional({ maxLength: MAX_ABOUT })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_ABOUT)
  about?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @Transform(({ value }) => stringList(value))
  @IsArray()
  @ArrayMaxSize(MAX_LIST_ITEMS)
  @IsString({ each: true })
  @MaxLength(MAX_LIST_ITEM_LENGTH, { each: true })
  requirements?: string[];

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @Transform(({ value }) => stringList(value))
  @IsArray()
  @ArrayMaxSize(MAX_LIST_ITEMS)
  @IsString({ each: true })
  @MaxLength(MAX_LIST_ITEM_LENGTH, { each: true })
  benefits?: string[];

  @ApiPropertyOptional({
    type: Number,
    description: 'Smallest amount in major units (KES), e.g. 100000.',
  })
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  @Max(10_000_000_000)
  valueMin?: number;

  @ApiPropertyOptional({ type: Number })
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  @Max(10_000_000_000)
  valueMax?: number;

  @ApiPropertyOptional({
    minLength: 3,
    maxLength: 3,
    description: 'Defaults to KES when an amount is given.',
  })
  @IsOptional()
  @Matches(/^[A-Za-z]{3}$/)
  valueCurrency?: string;

  @ApiPropertyOptional({
    maxLength: 80,
    description: 'Shown when there is no plain amount: "Paid stipend".',
  })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  valueText?: string;

  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description: 'Null means a rolling deadline.',
  })
  @IsOptional()
  @IsISO8601()
  deadlineAt?: string | null;

  @ApiPropertyOptional({ format: 'uuid', nullable: true })
  @IsOptional()
  @IsUUID()
  countyId?: string | null;

  @ApiPropertyOptional({ enum: WorkMode, enumName: 'WorkMode' })
  @IsOptional()
  @IsEnum(WorkMode)
  workMode?: WorkMode;

  @ApiPropertyOptional({
    enum: ['EXTERNAL_WEBSITE', 'EMAIL'],
    description: 'IN_APP is reserved for Phase 3.',
  })
  @IsOptional()
  @IsIn(['EXTERNAL_WEBSITE', 'EMAIL'])
  applicationMethod?: 'EXTERNAL_WEBSITE' | 'EMAIL';

  @ApiPropertyOptional({ maxLength: 2048, description: 'https only.' })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  applicationUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsEmail()
  applicationEmail?: string;

  @ApiPropertyOptional({ maxLength: 2048 })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  sourceUrl?: string;

  @ApiPropertyOptional({ type: [String], format: 'uuid' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsUUID('all', { each: true })
  disciplineIds?: string[];

  @ApiPropertyOptional({ type: [RuleInputDto], description: 'Replaces every rule when given.' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(12)
  @ValidateNested({ each: true })
  @Type(() => RuleInputDto)
  rules?: RuleInputDto[];
}

export class UpdateOpportunityDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(3, MAX_TITLE) title?: string;
  @ApiPropertyOptional({ format: 'uuid' }) @IsOptional() @IsUUID() providerId?: string;
  @ApiPropertyOptional({ enum: OpportunityType, enumName: 'OpportunityType' })
  @IsOptional()
  @IsEnum(OpportunityType)
  type?: OpportunityType;
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(10, MAX_SUMMARY) summary?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(MAX_ABOUT) about?: string;
  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @Transform(({ value }) => stringList(value))
  @IsArray()
  @ArrayMaxSize(MAX_LIST_ITEMS)
  @IsString({ each: true })
  @MaxLength(MAX_LIST_ITEM_LENGTH, { each: true })
  requirements?: string[];
  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @Transform(({ value }) => stringList(value))
  @IsArray()
  @ArrayMaxSize(MAX_LIST_ITEMS)
  @IsString({ each: true })
  @MaxLength(MAX_LIST_ITEM_LENGTH, { each: true })
  benefits?: string[];
  @ApiPropertyOptional({ type: Number, nullable: true })
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  @Max(10_000_000_000)
  valueMin?: number | null;
  @ApiPropertyOptional({ type: Number, nullable: true })
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  @Max(10_000_000_000)
  valueMax?: number | null;
  @ApiPropertyOptional() @IsOptional() @Matches(/^[A-Za-z]{3}$/) valueCurrency?: string;
  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  valueText?: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  @IsOptional()
  @IsISO8601()
  deadlineAt?: string | null;
  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  countyId?: string | null;
  @ApiPropertyOptional({ enum: WorkMode, enumName: 'WorkMode' })
  @IsOptional()
  @IsEnum(WorkMode)
  workMode?: WorkMode;
  @ApiPropertyOptional({ enum: ['EXTERNAL_WEBSITE', 'EMAIL'] })
  @IsOptional()
  @IsIn(['EXTERNAL_WEBSITE', 'EMAIL'])
  applicationMethod?: 'EXTERNAL_WEBSITE' | 'EMAIL';
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(2048) applicationUrl?: string;
  @ApiPropertyOptional() @IsOptional() @IsEmail() applicationEmail?: string;
  @ApiPropertyOptional() @IsOptional() @IsString() @MaxLength(2048) sourceUrl?: string;
  @ApiPropertyOptional({ type: [String], format: 'uuid' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsUUID('all', { each: true })
  disciplineIds?: string[];
  @ApiPropertyOptional({ type: [RuleInputDto] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(12)
  @ValidateNested({ each: true })
  @Type(() => RuleInputDto)
  rules?: RuleInputDto[];
}

export class SetTrustDto {
  @ApiProperty({ enum: OpportunityTrust, enumName: 'OpportunityTrust' })
  @IsEnum(OpportunityTrust)
  trust!: OpportunityTrust;

  @ApiPropertyOptional({ maxLength: 300, description: 'Why, for the audit trail.' })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  reason?: string;
}

export class VerifyOpportunityDto {
  @ApiPropertyOptional({ maxLength: 300, description: 'Why, for the audit trail.' })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  reason?: string;
}

export class FeatureOpportunityDto {
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description: 'Feature until this time. Null (or omitted) removes the feature.',
  })
  @IsOptional()
  @IsISO8601()
  until?: string | null;
}

export class RejectOpportunityDto {
  @ApiProperty({ minLength: 3, maxLength: 500, description: 'Told to the provider.' })
  @IsString()
  @Length(3, 500)
  reason!: string;
}

export class ProviderFieldsDto {
  @ApiProperty({ minLength: 2, maxLength: 120 }) @IsString() @Length(2, 120) name!: string;
  @ApiPropertyOptional({ enum: OpportunityProviderType, enumName: 'OpportunityProviderType' })
  @IsOptional()
  @IsEnum(OpportunityProviderType)
  type?: OpportunityProviderType;
  @ApiPropertyOptional({ maxLength: 2048 })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  website?: string;
  @ApiPropertyOptional({
    format: 'uuid',
    nullable: true,
    type: String,
    description: 'The provider account that may submit listings.',
  })
  @IsOptional()
  @IsUUID()
  ownerUserId?: string | null;
}

export class UpdateProviderDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(2, 120) name?: string;
  @ApiPropertyOptional({ enum: OpportunityProviderType, enumName: 'OpportunityProviderType' })
  @IsOptional()
  @IsEnum(OpportunityProviderType)
  type?: OpportunityProviderType;
  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  website?: string | null;
  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  ownerUserId?: string | null;
}

export class VerifyProviderDto {
  @ApiProperty({ enum: ['VERIFIED', 'REJECTED', 'REVOKED'] })
  @IsIn(['VERIFIED', 'REJECTED', 'REVOKED'])
  status!: Extract<VerificationStatus, 'VERIFIED' | 'REJECTED' | 'REVOKED'>;

  @ApiPropertyOptional({ maxLength: 300 })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  reason?: string;
}

export class ImportCsvDto {
  @ApiProperty({ description: 'The whole CSV file as text (UTF-8).' })
  @IsString()
  @MinLength(10)
  @MaxLength(1_000_000)
  csv!: string;
}

// ---- staff: queries and responses -------------------------------------------------------------------------------

export class AdminOpportunitiesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: OpportunityStatus, enumName: 'OpportunityStatus' })
  @IsOptional()
  @IsEnum(OpportunityStatus)
  status?: OpportunityStatus;

  @ApiPropertyOptional({ enum: OpportunityType, enumName: 'OpportunityType' })
  @IsOptional()
  @IsEnum(OpportunityType)
  type?: OpportunityType;

  @ApiPropertyOptional({ format: 'uuid' }) @IsOptional() @IsUUID() providerId?: string;

  @ApiPropertyOptional({ maxLength: 80 }) @IsOptional() @IsString() @MaxLength(80) q?: string;

  @ApiPropertyOptional({ description: 'Only listings whose link was found broken.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  brokenLink?: boolean;
}

export class AdminProvidersQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ maxLength: 80 }) @IsOptional() @IsString() @MaxLength(80) q?: string;
  @ApiPropertyOptional({ enum: VerificationStatus, enumName: 'VerificationStatus' })
  @IsOptional()
  @IsEnum(VerificationStatus)
  verification?: VerificationStatus;
}

export class AdminRuleDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: OpportunityRuleType, enumName: 'OpportunityRuleType' })
  ruleType!: OpportunityRuleType;
  @ApiProperty({ type: 'object', additionalProperties: true }) params!: Record<string, unknown>;
  @ApiProperty() label!: string;
  @ApiProperty() isBlocking!: boolean;
  @ApiProperty() sortOrder!: number;
}

export class AdminProviderDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ enum: OpportunityProviderType, enumName: 'OpportunityProviderType' })
  type!: OpportunityProviderType;
  @ApiPropertyOptional({ type: String, nullable: true }) website!: string | null;
  @ApiProperty({ enum: VerificationStatus, enumName: 'VerificationStatus' })
  verificationStatus!: VerificationStatus;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) ownerUserId!:
    string | null;
  @ApiProperty() opportunitiesCount!: number;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AdminOpportunityDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ enum: OpportunityType, enumName: 'OpportunityType' }) type!: OpportunityType;
  @ApiProperty({ enum: OpportunityStatus, enumName: 'OpportunityStatus' })
  status!: OpportunityStatus;
  @ApiProperty({ enum: OpportunityTrust, enumName: 'OpportunityTrust' }) trust!: OpportunityTrust;
  @ApiProperty({ type: AdminProviderDto }) provider!: AdminProviderDto;
  @ApiProperty() summary!: string;
  @ApiProperty() about!: string;
  @ApiProperty({ type: [String] }) requirements!: string[];
  @ApiProperty({ type: [String] }) benefits!: string[];
  @ApiPropertyOptional({ type: Number, nullable: true }) valueMin!: number | null;
  @ApiPropertyOptional({ type: Number, nullable: true }) valueMax!: number | null;
  @ApiPropertyOptional({ type: String, nullable: true }) valueCurrency!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) valueText!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  deadlineAt!: Date | null;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) countyId!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) countyName!: string | null;
  @ApiProperty({ enum: WorkMode, enumName: 'WorkMode' }) workMode!: WorkMode;
  @ApiProperty({ enum: ApplicationMethod, enumName: 'ApplicationMethod' })
  applicationMethod!: ApplicationMethod;
  @ApiPropertyOptional({ type: String, nullable: true }) applicationUrl!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) applicationEmail!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) applicationDomain!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) sourceUrl!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  featuredUntil!: Date | null;
  @ApiProperty({ enum: ['UNKNOWN', 'OK', 'BROKEN'] }) linkStatus!: string;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  lastCheckedAt!: Date | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  publishedAt!: Date | null;
  @ApiProperty({ type: [String], format: 'uuid' }) disciplineIds!: string[];
  @ApiProperty({ type: [AdminRuleDto] }) rules!: AdminRuleDto[];
  @ApiProperty({ description: 'Members who saved or are tracking it.' }) trackerCount!: number;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: String, format: 'date-time' }) updatedAt!: Date;
}

export class ImportIssueDto {
  @ApiProperty() line!: number;
  @ApiPropertyOptional({ type: String, nullable: true }) column!: string | null;
  @ApiProperty() message!: string;
}

export class ImportPreviewRowDto {
  @ApiProperty() line!: number;
  @ApiProperty() title!: string;
  @ApiProperty() provider!: string;
  @ApiProperty({ enum: OpportunityType, enumName: 'OpportunityType' }) type!: OpportunityType;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  deadlineAt!: Date | null;
  @ApiProperty({ description: 'The provider already exists; otherwise a new one is created.' })
  providerExists!: boolean;
}

export class ImportReportDto {
  @ApiProperty() totalCount!: number;
  @ApiProperty() validCount!: number;
  @ApiProperty({ type: [ImportIssueDto] }) issues!: ImportIssueDto[];
  @ApiProperty({ type: [ImportPreviewRowDto] }) preview!: ImportPreviewRowDto[];
}

export class ImportCommitResultDto {
  @ApiProperty() created!: number;
  @ApiProperty() skipped!: number;
  @ApiProperty({ description: 'Always DRAFT: an import never publishes.' }) status!: 'DRAFT';
  @ApiProperty({ type: [ImportIssueDto] }) issues!: ImportIssueDto[];
}

export class LinkHealthItemDto {
  @ApiProperty({ format: 'uuid' }) opportunityId!: string;
  @ApiProperty() title!: string;
  @ApiProperty() provider!: string;
  @ApiProperty({ enum: OpportunityStatus, enumName: 'OpportunityStatus' })
  status!: OpportunityStatus;
  @ApiPropertyOptional({ type: String, nullable: true }) applicationUrl!: string | null;
  @ApiProperty({ enum: ['UNKNOWN', 'OK', 'BROKEN'] }) linkStatus!: string;
  @ApiPropertyOptional({ type: Number, nullable: true }) httpStatus!: number | null;
  @ApiPropertyOptional({ type: String, nullable: true }) error!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  checkedAt!: Date | null;
}
