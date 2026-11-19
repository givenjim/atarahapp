import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  IsUrl,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { MentorApplicationStatus, MentorSessionFormat, MentorStatus } from '@prisma/client';
import { PageQueryDto } from '../common/pagination';

const flag = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1'
    ? true
    : value === false || value === 'false' || value === '0'
      ? false
      : value;

export const MENTOR_SORTS = ['recommended', 'soonest', 'price', 'rating'] as const;
export const MAX_TAGS = 12;
export const MAX_CREDENTIALS = 10;
export const MAX_SESSION_TYPES = 8;
/** Prices are minor units; KES 1,000,000 is a sane ceiling for one session. */
export const MAX_PRICE_MINOR = 100_000_000;

const httpsUrl = { protocols: ['https'], require_protocol: true };

// ---- shared input shapes -----------------------------------------------------------------------------------------

export class CredentialDto {
  @ApiProperty({ maxLength: 120 }) @IsString() @MinLength(2) @MaxLength(120) title!: string;
  @ApiPropertyOptional({ maxLength: 120 })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  issuer?: string;
  @ApiPropertyOptional({ minimum: 1950, maximum: 2100 })
  @IsOptional()
  @IsInt()
  @Min(1950)
  @Max(2100)
  year?: number;
}

export class SessionTypeFieldsDto {
  @ApiProperty({ maxLength: 80 }) @IsString() @MinLength(2) @MaxLength(80) name!: string;
  @ApiPropertyOptional({ maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;
  @ApiProperty({ minimum: 15, maximum: 480 }) @IsInt() @Min(15) @Max(480) durationMinutes!: number;
  @ApiProperty({ minimum: 0, description: 'Minor units (KES cents). 150000 is KES 1,500.' })
  @IsInt()
  @Min(0)
  @Max(MAX_PRICE_MINOR)
  priceMinor!: number;
  @ApiPropertyOptional({ minimum: 1, maximum: 24, default: 1 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(24)
  sessionCount?: number;
}

export class UpdateSessionTypeDto {
  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  name?: string;
  @ApiPropertyOptional({ maxLength: 500, nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string | null;
  @ApiPropertyOptional({ minimum: 15, maximum: 480 })
  @IsOptional()
  @IsInt()
  @Min(15)
  @Max(480)
  durationMinutes?: number;
  @ApiPropertyOptional({ minimum: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MAX_PRICE_MINOR)
  priceMinor?: number;
  @ApiPropertyOptional({ minimum: 1, maximum: 24 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(24)
  sessionCount?: number;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() active?: boolean;
}

export class MentorProfileFieldsDto {
  @ApiProperty({ maxLength: 140 }) @IsString() @MinLength(4) @MaxLength(140) headline!: string;
  @ApiProperty({ minimum: 0, maximum: 80 }) @IsInt() @Min(0) @Max(80) yearsExperience!: number;
  @ApiProperty({ type: [String], maxItems: MAX_TAGS })
  @IsArray()
  @ArrayMaxSize(MAX_TAGS)
  @IsString({ each: true })
  @MinLength(2, { each: true })
  @MaxLength(40, { each: true })
  expertiseTags!: string[];
  @ApiProperty({ type: [String], format: 'uuid' })
  @IsArray()
  @ArrayMaxSize(6)
  @IsUUID('all', { each: true })
  disciplineIds!: string[];
  @ApiProperty({ type: [CredentialDto], maxItems: MAX_CREDENTIALS })
  @IsArray()
  @ArrayMaxSize(MAX_CREDENTIALS)
  @ValidateNested({ each: true })
  @Type(() => CredentialDto)
  credentials!: CredentialDto[];
  @ApiProperty({ example: 'Africa/Nairobi', description: 'IANA time zone.' })
  @IsString()
  @MaxLength(64)
  timeZone!: string;
}

// ---- member queries ----------------------------------------------------------------------------------------------

export class MentorsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ maxLength: 80, description: 'Name, headline or expertise.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ format: 'uuid' }) @IsOptional() @IsUUID() disciplineId?: string;

  @ApiPropertyOptional({ description: 'Identity-verified mentors only.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  verified?: boolean;

  @ApiPropertyOptional({ description: 'Has a bookable slot in the next 7 days.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  availableThisWeek?: boolean;

  @ApiPropertyOptional({ description: 'Has a session type at or under this price (minor units).' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  maxPriceMinor?: number;

  @ApiPropertyOptional({ description: 'Offers video call sessions.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  videoCall?: boolean;

  @ApiPropertyOptional({ enum: MENTOR_SORTS, enumName: 'MentorSort', default: 'recommended' })
  @IsOptional()
  @IsIn(MENTOR_SORTS)
  sort?: (typeof MENTOR_SORTS)[number];
}

export class SlotsQueryDto {
  @ApiProperty({ format: 'uuid' }) @IsUUID() sessionTypeId!: string;
  @ApiPropertyOptional({ format: 'date-time', description: 'Defaults to now.' })
  @IsOptional()
  @IsISO8601()
  from?: string;
  @ApiPropertyOptional({
    format: 'date-time',
    description: 'Defaults to 14 days after `from`; at most 60.',
  })
  @IsOptional()
  @IsISO8601()
  to?: string;
  @ApiPropertyOptional({
    example: 'Africa/Nairobi',
    description: 'The member time zone for `localDate`.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  timeZone?: string;
}

// ---- member responses --------------------------------------------------------------------------------------------

export class CredentialOutDto {
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) issuer!: string | null;
  @ApiPropertyOptional({ type: Number, nullable: true }) year!: number | null;
}

export class SessionTypeDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) description!: string | null;
  @ApiProperty() durationMinutes!: number;
  @ApiProperty({ description: 'Minor units.' }) priceMinor!: number;
  @ApiProperty() currency!: string;
  @ApiProperty({ enum: MentorSessionFormat, enumName: 'MentorSessionFormat' })
  format!: MentorSessionFormat;
  @ApiProperty() sessionCount!: number;
  @ApiProperty() active!: boolean;
  @ApiProperty({ description: 'Staff switched it off; the mentor cannot turn it back on.' })
  disabledByStaff!: boolean;
}

export class MentorCardDto {
  @ApiProperty({ format: 'uuid', description: 'The mentor profile id.' }) id!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) handle!: string | null;
  @ApiProperty() displayName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) avatarUrl!: string | null;
  @ApiProperty() headline!: string;
  @ApiProperty({ type: [String] }) expertiseTags!: string[];
  @ApiProperty({ description: 'Identity verified by Atarah (driven by the verification status).' })
  verified!: boolean;
  @ApiProperty() featured!: boolean;
  @ApiProperty() ratingAverage!: number;
  @ApiProperty() ratingCount!: number;
  @ApiProperty() sessionsCount!: number;
  @ApiPropertyOptional({
    type: Number,
    nullable: true,
    description: 'Cheapest active session, minor units.',
  })
  fromPriceMinor!: number | null;
  @ApiProperty() currency!: string;
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description:
      'First bookable slot (UTC) from real availability minus bookings; null when none in 60 days.',
  })
  nextAvailableAt!: string | null;
  @ApiProperty() timeZone!: string;
  @ApiProperty({ description: 'Offers at least one video call session.' }) videoCall!: boolean;
}

export class DisciplineRefDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
}

export class BookingGateDto {
  @ApiProperty({
    description: 'The caller may book now (holds MENTORSHIP_BOOKING and is not this mentor).',
  })
  allowed!: boolean;
  @ApiProperty({ description: 'True when only Atarah Pro is missing: open the premium gate.' })
  requiresPro!: boolean;
  @ApiProperty({ description: 'This is the caller own profile.' }) isSelf!: boolean;
}

export class MentorDetailDto extends MentorCardDto {
  @ApiProperty() bio!: string;
  @ApiProperty() yearsExperience!: number;
  @ApiProperty({ type: [DisciplineRefDto] }) disciplines!: DisciplineRefDto[];
  @ApiProperty({ type: [CredentialOutDto] }) credentials!: CredentialOutDto[];
  @ApiProperty({ type: [SessionTypeDto], description: 'Active session types only.' })
  sessionTypes!: SessionTypeDto[];
  @ApiProperty({ type: BookingGateDto }) booking!: BookingGateDto;
}

export class NextSessionDto {
  @ApiProperty({ format: 'uuid' }) bookingId!: string;
  @ApiProperty() mentorName!: string;
  @ApiProperty() sessionName!: string;
  @ApiProperty({ format: 'date-time' }) startsAt!: string;
}

export class MentorshipHomeDto {
  @ApiProperty({ description: 'The caller holds MENTORSHIP_BOOKING (Atarah Pro).' })
  canBook!: boolean;
  @ApiProperty({ description: 'The caller is an approved, active mentor.' }) isMentor!: boolean;
  @ApiPropertyOptional({
    enum: MentorApplicationStatus,
    enumName: 'MentorApplicationStatus',
    nullable: true,
  })
  applicationStatus!: MentorApplicationStatus | null;
  @ApiPropertyOptional({
    type: NextSessionDto,
    nullable: true,
    description: 'Filled by P2-M5; null until then.',
  })
  nextSession!: NextSessionDto | null;
  @ApiProperty({ type: [MentorCardDto] }) topMentors!: MentorCardDto[];
}

export class SlotDto {
  @ApiProperty({ format: 'date-time' }) startsAt!: string;
  @ApiProperty({ format: 'date-time' }) endsAt!: string;
  @ApiProperty({ description: 'Calendar date `YYYY-MM-DD` in the member time zone.' })
  localDate!: string;
}

export class SlotsDto {
  @ApiProperty({ format: 'uuid' }) mentorId!: string;
  @ApiProperty({ format: 'uuid' }) sessionTypeId!: string;
  @ApiProperty() durationMinutes!: number;
  @ApiProperty() mentorTimeZone!: string;
  @ApiProperty() viewerTimeZone!: string;
  @ApiProperty({ type: [SlotDto] }) slots!: SlotDto[];
}

// ---- application -------------------------------------------------------------------------------------------------

export class ProposedSessionTypeDto extends SessionTypeFieldsDto {}

export class ApplyMentorDto extends MentorProfileFieldsDto {
  @ApiProperty({
    minLength: 40,
    maxLength: 3000,
    description: 'Why you want to mentor and who you can help.',
  })
  @IsString()
  @MinLength(40)
  @MaxLength(3000)
  statement!: string;

  @ApiProperty({
    type: [String],
    maxItems: 5,
    description: 'https links that back up the application.',
  })
  @IsArray()
  @ArrayMaxSize(5)
  @IsUrl(httpsUrl, { each: true })
  @MaxLength(300, { each: true })
  evidenceLinks!: string[];

  @ApiProperty({ type: [ProposedSessionTypeDto], minItems: 1, maxItems: MAX_SESSION_TYPES })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(MAX_SESSION_TYPES)
  @ValidateNested({ each: true })
  @Type(() => ProposedSessionTypeDto)
  proposedSessionTypes!: ProposedSessionTypeDto[];

  @ApiProperty({ description: 'Must be true: the member accepted the Mentor Terms.' })
  @IsBoolean()
  acceptTerms!: boolean;
}

export class MentorApplicationDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: MentorApplicationStatus, enumName: 'MentorApplicationStatus' })
  status!: MentorApplicationStatus;
  @ApiProperty() headline!: string;
  @ApiProperty() yearsExperience!: number;
  @ApiProperty() statement!: string;
  @ApiProperty({ type: [String] }) expertiseTags!: string[];
  @ApiProperty({ type: [String] }) disciplineIds!: string[];
  @ApiProperty({ type: [CredentialOutDto] }) credentials!: CredentialOutDto[];
  @ApiProperty({ type: [ProposedSessionTypeDto] }) proposedSessionTypes!: ProposedSessionTypeDto[];
  @ApiProperty({ type: [String] }) evidenceLinks!: string[];
  @ApiProperty() timeZone!: string;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Shown to the applicant when rejected.',
  })
  reviewerNotes!: string | null;
  @ApiProperty({ format: 'date-time' }) createdAt!: string;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true }) reviewedAt!:
    string | null;
}

export class ApplicationPrefillDto {
  @ApiProperty() headline!: string;
  @ApiProperty() yearsExperience!: number;
  @ApiProperty({ type: [String] }) expertiseTags!: string[];
  @ApiProperty({ type: [String] }) disciplineIds!: string[];
  @ApiProperty({ type: [CredentialOutDto] }) credentials!: CredentialOutDto[];
  @ApiProperty() statement!: string;
  @ApiProperty() timeZone!: string;
  @ApiProperty({ description: 'The member profile is complete enough to apply.' })
  profileReady!: boolean;
}

export class MyApplicationDto {
  @ApiPropertyOptional({ type: MentorApplicationDto, nullable: true })
  latest!: MentorApplicationDto | null;
  @ApiProperty({ description: 'The member may submit a new application now.' }) canApply!: boolean;
  @ApiPropertyOptional({ type: String, nullable: true }) cannotApplyReason!: string | null;
}

// ---- mentor tools ------------------------------------------------------------------------------------------------

export class UpdateMentorProfileDto {
  @ApiPropertyOptional({ maxLength: 140 })
  @IsOptional()
  @IsString()
  @MinLength(4)
  @MaxLength(140)
  headline?: string;
  @ApiPropertyOptional({ maxLength: 3000 })
  @IsOptional()
  @IsString()
  @MinLength(40)
  @MaxLength(3000)
  bio?: string;
  @ApiPropertyOptional({ minimum: 0, maximum: 80 })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(80)
  yearsExperience?: number;
  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_TAGS)
  @IsString({ each: true })
  @MinLength(2, { each: true })
  @MaxLength(40, { each: true })
  expertiseTags?: string[];
  @ApiPropertyOptional({ type: [String], format: 'uuid' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(6)
  @IsUUID('all', { each: true })
  disciplineIds?: string[];
  @ApiPropertyOptional({ type: [CredentialDto] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_CREDENTIALS)
  @ValidateNested({ each: true })
  @Type(() => CredentialDto)
  credentials?: CredentialDto[];
  @ApiPropertyOptional({ example: 'Africa/Nairobi' })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  timeZone?: string;
  @ApiPropertyOptional({ nullable: true, description: 'https meeting link; null clears it.' })
  @IsOptional()
  @IsUrl(httpsUrl)
  @MaxLength(300)
  videoCallLink?: string | null;
}

export class SetMentorPausedDto {
  @ApiProperty({
    description: 'true pauses the profile (hidden from the directory); false resumes it.',
  })
  @IsBoolean()
  paused!: boolean;
}

export class WeeklyRangeDto {
  @ApiProperty({ minimum: 1, maximum: 7, description: 'ISO weekday: 1 = Monday ... 7 = Sunday.' })
  @IsInt()
  @Min(1)
  @Max(7)
  weekday!: number;
  @ApiProperty({ minimum: 0, maximum: 1439, description: 'Minutes after local midnight.' })
  @IsInt()
  @Min(0)
  @Max(1439)
  startMinute!: number;
  @ApiProperty({ minimum: 1, maximum: 1440 }) @IsInt() @Min(1) @Max(1440) endMinute!: number;
}

export class SetWeeklyAvailabilityDto {
  @ApiPropertyOptional({
    description: 'IANA zone the ranges are in; defaults to the profile zone.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(64)
  timeZone?: string;
  @ApiProperty({ type: [WeeklyRangeDto], maxItems: 28, description: 'Replaces the whole week.' })
  @IsArray()
  @ArrayMaxSize(28)
  @ValidateNested({ each: true })
  @Type(() => WeeklyRangeDto)
  weekly!: WeeklyRangeDto[];
}

export class AddExceptionDto {
  @ApiProperty({ example: '2026-12-25', description: 'A local calendar date.' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/)
  date!: string;
  @ApiPropertyOptional({ maxLength: 120 })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  reason?: string;
}

export class ExceptionDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() date!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) reason!: string | null;
}

export class AvailabilityDto {
  @ApiProperty() timeZone!: string;
  @ApiProperty({ type: [WeeklyRangeDto] }) weekly!: WeeklyRangeDto[];
  @ApiProperty({ type: [ExceptionDto] }) exceptions!: ExceptionDto[];
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true }) nextAvailableAt!:
    string | null;
}

export class MyMentorDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: MentorStatus, enumName: 'MentorStatus' }) status!: MentorStatus;
  @ApiPropertyOptional({ type: String, nullable: true }) statusReason!: string | null;
  @ApiProperty() headline!: string;
  @ApiProperty() bio!: string;
  @ApiProperty() yearsExperience!: number;
  @ApiProperty({ type: [String] }) expertiseTags!: string[];
  @ApiProperty({ type: [DisciplineRefDto] }) disciplines!: DisciplineRefDto[];
  @ApiProperty({ type: [CredentialOutDto] }) credentials!: CredentialOutDto[];
  @ApiProperty() timeZone!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) videoCallLink!: string | null;
  @ApiProperty() verified!: boolean;
  @ApiProperty() featured!: boolean;
  @ApiProperty() ratingAverage!: number;
  @ApiProperty() ratingCount!: number;
  @ApiProperty() sessionsCount!: number;
  @ApiProperty({ type: [SessionTypeDto], description: 'Including inactive ones.' })
  sessionTypes!: SessionTypeDto[];
  @ApiProperty({ type: AvailabilityDto }) availability!: AvailabilityDto;
  @ApiProperty({ description: 'Visible in the directory right now.' }) listed!: boolean;
}

export class BookingRequestDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() menteeName!: string;
  @ApiProperty() sessionName!: string;
  @ApiProperty({ format: 'date-time' }) startsAt!: string;
  @ApiProperty({ format: 'date-time' }) endsAt!: string;
  @ApiProperty() status!: string;
}

// ---- admin -------------------------------------------------------------------------------------------------------

export class AdminApplicationsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({
    enum: MentorApplicationStatus,
    enumName: 'MentorApplicationStatus',
    default: 'PENDING',
  })
  @IsOptional()
  @IsEnum(MentorApplicationStatus)
  status?: MentorApplicationStatus;
}

export class ApplicantRefDto {
  @ApiProperty({ format: 'uuid' }) userId!: string;
  @ApiProperty() displayName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) handle!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) email!: string | null;
}

export class AdminApplicationDto extends MentorApplicationDto {
  @ApiProperty({ type: ApplicantRefDto }) applicant!: ApplicantRefDto;
  @ApiProperty({
    type: 'object',
    additionalProperties: true,
    description: 'The Passport as it was when applying.',
  })
  passportSnapshot!: Record<string, unknown>;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) reviewedById!:
    string | null;
}

export class DecideApplicationDto {
  @ApiPropertyOptional({
    maxLength: 1000,
    description: 'Required when rejecting; shown to the applicant.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  reason?: string;
}

export class AdminMentorsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: MentorStatus, enumName: 'MentorStatus' })
  @IsOptional()
  @IsEnum(MentorStatus)
  status?: MentorStatus;
  @ApiPropertyOptional({ maxLength: 80 }) @IsOptional() @IsString() @MaxLength(80) q?: string;
  @ApiPropertyOptional() @IsOptional() @Transform(flag) @IsBoolean() featured?: boolean;
}

export class AdminMentorDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ type: ApplicantRefDto }) mentor!: ApplicantRefDto;
  @ApiProperty({ enum: MentorStatus, enumName: 'MentorStatus' }) status!: MentorStatus;
  @ApiPropertyOptional({ type: String, nullable: true }) statusReason!: string | null;
  @ApiProperty() headline!: string;
  @ApiProperty() featured!: boolean;
  @ApiProperty() sessionTypeCount!: number;
  @ApiProperty() ratingAverage!: number;
  @ApiProperty() ratingCount!: number;
  @ApiProperty() sessionsCount!: number;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true }) approvedAt!:
    string | null;
}

export class MentorStatusChangeDto {
  @ApiProperty({
    maxLength: 1000,
    description: 'Why; recorded in the audit log and shown to the mentor.',
  })
  @IsString()
  @MinLength(3)
  @MaxLength(1000)
  reason!: string;
}

export class FeatureMentorDto {
  @ApiProperty() @IsBoolean() featured!: boolean;
}

export class AdminSessionTypesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ format: 'uuid' }) @IsOptional() @IsUUID() mentorId?: string;
  @ApiPropertyOptional() @IsOptional() @Transform(flag) @IsBoolean() disabledByStaff?: boolean;
}

export class AdminSessionTypeDto extends SessionTypeDto {
  @ApiProperty({ format: 'uuid' }) mentorId!: string;
  @ApiProperty() mentorName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) staffNote!: string | null;
}

export class StaffSessionTypeDto {
  @ApiProperty({
    description: 'true switches the session type off for members; false allows it again.',
  })
  @IsBoolean()
  disabled!: boolean;
  @ApiPropertyOptional({ maxLength: 500 }) @IsOptional() @IsString() @MaxLength(500) note?: string;
}
