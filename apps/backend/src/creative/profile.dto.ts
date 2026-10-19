import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  IsUrl,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { CompletionDto, DisciplineLite, TaxonomyItemDto, VISIBILITIES } from './creative.dto';

export const SECTION_VALUES = [
  'BIO',
  'LOCATION',
  'PORTFOLIO',
  'SKILLS',
  'EXPERIENCE',
  'SERVICES',
  'LINKS',
  'CONTACT',
] as const;
export const RELATIONS = ['OWNER', 'CONNECTION', 'MEMBER', 'ANONYMOUS'] as const;
export const CONNECTION_STATES = ['NONE', 'PENDING_SENT', 'PENDING_RECEIVED', 'CONNECTED'] as const;

export const MAX_HEADLINE = 80;
export const MAX_LINKS = 8;

// ---- requests ---------------------------------------------------------------------------------------------

export class ProfileLinkInputDto {
  @ApiProperty({ example: 'Instagram', maxLength: 30 })
  @IsString()
  @MinLength(1)
  @MaxLength(30)
  label!: string;

  @ApiProperty({ example: 'https://instagram.com/nia', description: 'An https address.' })
  @IsString()
  @MaxLength(300)
  @IsUrl({ protocols: ['https'], require_protocol: true, require_tld: true })
  url!: string;
}

export class UpdateProfileDto {
  @ApiPropertyOptional({ minLength: 2, maxLength: 60 })
  @IsOptional()
  @IsString()
  @MaxLength(60)
  displayName?: string;

  @ApiPropertyOptional({
    maxLength: MAX_HEADLINE,
    description: 'Send an empty string to clear it.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_HEADLINE)
  headline?: string;

  @ApiPropertyOptional({ maxLength: 160, description: 'Send an empty string to clear it.' })
  @IsOptional()
  @IsString()
  @MaxLength(160)
  bio?: string;

  @ApiPropertyOptional({
    type: [ProfileLinkInputDto],
    description: 'Replaces all links. At most 8.',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_LINKS)
  @ValidateNested({ each: true })
  @Type(() => ProfileLinkInputDto)
  links?: ProfileLinkInputDto[];

  @ApiPropertyOptional() @IsOptional() @IsBoolean() openToCommissions?: boolean;
  @ApiPropertyOptional({ description: 'Show the email when the contact section is visible.' })
  @IsOptional()
  @IsBoolean()
  contactShowEmail?: boolean;
  @ApiPropertyOptional({
    description: 'Show the phone number when the contact section is visible.',
  })
  @IsOptional()
  @IsBoolean()
  contactShowPhone?: boolean;
  @ApiPropertyOptional({
    description: 'Accepted connections see contact details even when the section is private.',
  })
  @IsOptional()
  @IsBoolean()
  contactForConnections?: boolean;
  @ApiPropertyOptional({ description: 'When false nobody can send a connection request.' })
  @IsOptional()
  @IsBoolean()
  acceptConnections?: boolean;
}

export class SetSectionVisibilityDto {
  @ApiProperty({ enum: SECTION_VALUES })
  @IsEnum(SECTION_VALUES)
  section!: (typeof SECTION_VALUES)[number];

  @ApiProperty({ enum: VISIBILITIES })
  @IsIn(VISIBILITIES)
  visibility!: (typeof VISIBILITIES)[number];
}

export class PublicProfileQueryDto {
  @ApiPropertyOptional({
    enum: ['PUBLIC', 'MEMBERS'],
    description: 'Owner only: see the profile as the public or as other members do.',
  })
  @IsOptional()
  @IsIn(['PUBLIC', 'MEMBERS'])
  previewAs?: 'PUBLIC' | 'MEMBERS';
}

// ---- responses --------------------------------------------------------------------------------------------

export class ProfileLinkDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() label!: string;
  @ApiProperty() url!: string;
}

export class SectionVisibilityDto {
  @ApiProperty({ enum: SECTION_VALUES }) section!: string;
  @ApiProperty({ enum: VISIBILITIES }) visibility!: string;
}

export class ContactDetailsDto {
  @ApiProperty({ nullable: true, type: String }) email!: string | null;
  @ApiProperty({ nullable: true, type: String }) phone!: string | null;
}

export class OwnContactDto extends ContactDetailsDto {
  @ApiProperty() showEmail!: boolean;
  @ApiProperty() showPhone!: boolean;
  @ApiProperty() forConnections!: boolean;
}

export class LocationDto {
  @ApiProperty({ nullable: true, type: String }) countryName!: string | null;
  @ApiProperty({ nullable: true, type: String }) countyName!: string | null;
  @ApiProperty({ nullable: true, type: String }) town!: string | null;
}

export class PassportSummaryDto {
  @ApiProperty({ example: 'ATR-NBI-0042' }) passportNumber!: string;
  @ApiProperty({ type: String, format: 'date-time' }) issuedAt!: Date;
}

export class OwnCountsDto {
  @ApiProperty() skills!: number;
  @ApiProperty({ description: 'Accepted connections.' }) connections!: number;
  @ApiProperty({ description: 'Requests waiting for the member to answer.' })
  pendingRequests!: number;
}

export class OwnProfileDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ nullable: true, type: String }) handle!: string | null;
  @ApiProperty() displayName!: string;
  @ApiProperty({ nullable: true, type: String }) headline!: string | null;
  @ApiProperty({ nullable: true, type: String }) bio!: string | null;
  @ApiProperty({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiProperty({ type: DisciplineLite, nullable: true }) discipline!: DisciplineLite | null;
  @ApiProperty({ type: [TaxonomyItemDto] }) specialisations!: TaxonomyItemDto[];
  @ApiProperty({ type: [TaxonomyItemDto] }) skills!: TaxonomyItemDto[];
  @ApiProperty({ type: LocationDto }) location!: LocationDto;
  @ApiProperty() openToCommissions!: boolean;
  @ApiProperty() acceptConnections!: boolean;
  @ApiProperty({ type: OwnContactDto }) contact!: OwnContactDto;
  @ApiProperty({ type: [ProfileLinkDto] }) links!: ProfileLinkDto[];
  @ApiProperty({ type: [SectionVisibilityDto] }) sections!: SectionVisibilityDto[];
  @ApiProperty({ type: CompletionDto }) completion!: CompletionDto;
  @ApiProperty({ type: PassportSummaryDto, nullable: true }) passport!: PassportSummaryDto | null;
  @ApiProperty() onboardingCompleted!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) memberSince!: Date;
  @ApiProperty({ type: OwnCountsDto }) counts!: OwnCountsDto;
  @ApiProperty({ nullable: true, type: String, description: 'https://atarah.app/{handle}' })
  shareUrl!: string | null;
}

export class GrowthBarDto {
  @ApiProperty() key!: string;
  @ApiProperty() label!: string;
  @ApiProperty({ minimum: 0, maximum: 100 }) percent!: number;
}

export class GrowthDto {
  @ApiProperty({ minimum: 0, maximum: 100 }) score!: number;
  @ApiProperty({ enum: ['EARLY', 'GROWING', 'ACTIVE', 'STRONG'] }) strength!: string;
  @ApiProperty({ type: [GrowthBarDto] }) bars!: GrowthBarDto[];
}

export class PassportDto {
  @ApiProperty({ example: 'ATR-NBI-0042' }) passportNumber!: string;
  @ApiProperty({ type: String, format: 'date-time' }) issuedAt!: Date;
  @ApiProperty() displayName!: string;
  @ApiProperty() handle!: string;
  @ApiProperty({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiProperty({ nullable: true, type: String }) discipline!: string | null;
  @ApiProperty({ nullable: true, type: String }) specialisation!: string | null;
  @ApiProperty({ type: LocationDto }) location!: LocationDto;
  @ApiProperty({ type: String, format: 'date-time' }) memberSince!: Date;
  @ApiProperty({
    type: [String],
    description: 'Trust pills. Empty until real verification exists.',
  })
  trust!: string[];
  @ApiProperty({ type: GrowthDto }) growth!: GrowthDto;
  @ApiProperty({ type: CompletionDto }) completion!: CompletionDto;
  @ApiProperty({ type: [SectionVisibilityDto] }) sections!: SectionVisibilityDto[];
  @ApiProperty() shareUrl!: string;
}

export class ConnectionStateDto {
  @ApiProperty({ nullable: true, type: String, format: 'uuid' }) id!: string | null;
  @ApiProperty({ enum: CONNECTION_STATES }) state!: string;
  @ApiProperty({ description: 'Whether a request can be sent right now.' }) canConnect!: boolean;
  @ApiPropertyOptional({
    nullable: true,
    type: String,
    description: 'Why a request cannot be sent.',
  })
  reason?: string | null;
}

export class PublicProfileDto {
  @ApiProperty() handle!: string;
  @ApiProperty() displayName!: string;
  @ApiProperty({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiProperty({ nullable: true, type: String }) headline!: string | null;
  @ApiProperty({ type: DisciplineLite, nullable: true }) discipline!: DisciplineLite | null;
  @ApiProperty({ type: [TaxonomyItemDto] }) specialisations!: TaxonomyItemDto[];
  @ApiProperty() openToCommissions!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) memberSince!: Date;
  @ApiProperty({
    enum: RELATIONS,
    description: 'How the caller relates to this profile (or the preview they asked for).',
  })
  relation!: string;
  @ApiProperty({
    type: ConnectionStateDto,
    nullable: true,
    description: 'Null for the owner, in a preview and when signed out.',
  })
  connection!: ConnectionStateDto | null;
  @ApiProperty({ nullable: true, type: String }) bio!: string | null;
  @ApiProperty({ type: LocationDto, nullable: true }) location!: LocationDto | null;
  @ApiProperty({ type: [TaxonomyItemDto], nullable: true }) skills!: TaxonomyItemDto[] | null;
  @ApiProperty({ type: [ProfileLinkDto], nullable: true }) links!: ProfileLinkDto[] | null;
  @ApiProperty({ type: ContactDetailsDto, nullable: true }) contact!: ContactDetailsDto | null;
  @ApiPropertyOptional({
    nullable: true,
    type: Number,
    description:
      'Projects this viewer can open. Null while the Portfolio section is hidden from them.',
  })
  portfolioCount!: number | null;
  @ApiPropertyOptional({
    nullable: true,
    type: Number,
    description: 'Null while the Services section is hidden from this viewer.',
  })
  serviceCount!: number | null;
  @ApiProperty({
    enum: SECTION_VALUES,
    isArray: true,
    description: 'Sections the caller may see (some have no content yet).',
  })
  visibleSections!: string[];
  @ApiProperty({
    enum: SECTION_VALUES,
    isArray: true,
    description: 'Sections hidden from the caller.',
  })
  lockedSections!: string[];
  @ApiProperty({ nullable: true, type: Number, description: 'Accepted connections; members only.' })
  connectionCount!: number | null;
  @ApiProperty({ type: String }) shareUrl!: string;
}

// ---- connections ------------------------------------------------------------------------------------------

export class ConnectionPersonDto {
  @ApiProperty() handle!: string;
  @ApiProperty() displayName!: string;
  @ApiProperty({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiProperty({ nullable: true, type: String }) headline!: string | null;
  @ApiProperty({ nullable: true, type: String }) discipline!: string | null;
}

export class ConnectionListItemDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: CONNECTION_STATES }) state!: string;
  @ApiProperty({ type: ConnectionPersonDto }) person!: ConnectionPersonDto;
  @ApiProperty({ type: String, format: 'date-time' }) since!: Date;
}

export class ConnectionsQueryDto {
  @ApiPropertyOptional({
    enum: ['CONNECTED', 'PENDING_RECEIVED', 'PENDING_SENT'],
    default: 'CONNECTED',
  })
  @IsOptional()
  @IsIn(['CONNECTED', 'PENDING_RECEIVED', 'PENDING_SENT'])
  listState: 'CONNECTED' | 'PENDING_RECEIVED' | 'PENDING_SENT' = 'CONNECTED';

  @ApiPropertyOptional({ minimum: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  page: number = 1;

  @ApiPropertyOptional({ minimum: 1, maximum: 100, default: 20 })
  @IsOptional()
  @Type(() => Number)
  limit: number = 20;
}
