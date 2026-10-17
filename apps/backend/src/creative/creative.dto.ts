import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayUnique,
  IsArray,
  IsBoolean,
  IsEnum,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';

export const ONBOARDING_STEPS = [
  'INTRO',
  'DISCIPLINE',
  'SPECIALISATION',
  'SKILLS',
  'LOCATION',
  'BASICS',
  'PHOTO',
  'DONE',
] as const;
export type OnboardingStepValue = (typeof ONBOARDING_STEPS)[number];
/** Steps a member can save (DONE is reached through /me/onboarding/complete). */
export const SAVEABLE_STEPS = ONBOARDING_STEPS.filter((s) => s !== 'DONE');

export const VISIBILITIES = ['PUBLIC', 'MEMBERS', 'PRIVATE'] as const;

export const MAX_SPECIALISATIONS = 10;
export const MAX_SKILLS = 20;
export const MAX_INTERESTS = 10;
export const MAX_DEVELOPMENT_AREAS = 10;
export const MAX_BIO = 160;
export const MAX_TOWN = 80;

// ---- taxonomy and locations -------------------------------------------------------------------------------

export class SpecialisationDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() name!: string;
}

export class DisciplineDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ description: 'Lucide icon name.' }) icon!: string;
  @ApiProperty({ type: [SpecialisationDto] }) specialisations!: SpecialisationDto[];
}

export class TaxonomyItemDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() name!: string;
}

export class SkillsQueryDto {
  @ApiPropertyOptional({
    description: 'Discipline id or slug. Returns general skills plus that discipline’s skills.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  discipline?: string;
}

export class CountryDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ example: 'KE' }) isoCode!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ example: '+254' }) callingCode!: string;
}

export class CountyDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ example: 'NBI' }) code!: string;
  @ApiProperty() name!: string;
}

export class CountiesQueryDto {
  @ApiPropertyOptional({
    example: 'KE',
    description: 'ISO country code or country id. Defaults to the first active country.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  country?: string;
}

export class CountyMatchQueryDto {
  @ApiProperty({
    example: 'Nairobi County',
    description: 'A place name from the device’s reverse lookup.',
  })
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  q!: string;

  @ApiPropertyOptional({ example: 'KE' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  country?: string;
}

export class CountyMatchDto {
  @ApiProperty({ type: CountyDto, nullable: true }) county!: CountyDto | null;
  @ApiProperty({ format: 'uuid', nullable: true, type: String }) countryId!: string | null;
}

export class SuggestSpecialisationDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  disciplineId!: string;

  @ApiProperty({ example: 'Puppetry', minLength: 2, maxLength: 60 })
  @IsString()
  @MinLength(2)
  @MaxLength(60)
  name!: string;
}

export class SuggestionReceiptDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ enum: ['PENDING', 'APPROVED', 'MERGED', 'REJECTED'] }) status!: string;
}

// ---- onboarding -------------------------------------------------------------------------------------------

/**
 * One request per onboarding step. `step` names the screen being saved; only that step's fields are read,
 * and each is validated on the server whatever the app already checked. `skipped` saves nothing and moves on.
 */
export class SaveOnboardingStepDto {
  @ApiProperty({ enum: SAVEABLE_STEPS })
  @IsEnum(SAVEABLE_STEPS)
  step!: Exclude<OnboardingStepValue, 'DONE'>;

  @ApiPropertyOptional({ description: 'Skip this step: nothing is saved, the member moves on.' })
  @IsOptional()
  @IsBoolean()
  skipped?: boolean;

  // DISCIPLINE
  @ApiPropertyOptional({
    format: 'uuid',
    description: 'DISCIPLINE. Changing it clears specialisations.',
  })
  @IsOptional()
  @IsUUID()
  disciplineId?: string;

  // SPECIALISATION
  @ApiPropertyOptional({
    type: [String],
    description: 'SPECIALISATION. Must belong to the chosen discipline.',
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_SPECIALISATIONS)
  @ArrayUnique()
  @IsUUID(undefined, { each: true })
  specialisationIds?: string[];

  // SKILLS
  @ApiPropertyOptional({ type: [String], description: 'SKILLS.' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_SKILLS)
  @ArrayUnique()
  @IsUUID(undefined, { each: true })
  skillIds?: string[];

  @ApiPropertyOptional({ type: [String], description: 'SKILLS.' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_INTERESTS)
  @ArrayUnique()
  @IsUUID(undefined, { each: true })
  interestIds?: string[];

  @ApiPropertyOptional({ type: [String], description: 'SKILLS (areas to develop).' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_DEVELOPMENT_AREAS)
  @ArrayUnique()
  @IsUUID(undefined, { each: true })
  developmentAreaIds?: string[];

  // LOCATION
  @ApiPropertyOptional({ format: 'uuid', description: 'LOCATION.' })
  @IsOptional()
  @IsUUID()
  countryId?: string;

  @ApiPropertyOptional({ format: 'uuid', description: 'LOCATION. Must belong to the country.' })
  @IsOptional()
  @IsUUID()
  countyId?: string;

  @ApiPropertyOptional({
    maxLength: MAX_TOWN,
    description: 'LOCATION. Optional town or neighbourhood.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_TOWN)
  town?: string;

  @ApiPropertyOptional({ enum: VISIBILITIES, description: 'LOCATION. Who can see the county.' })
  @IsOptional()
  @IsIn(VISIBILITIES)
  locationVisibility?: (typeof VISIBILITIES)[number];

  // BASICS
  @ApiPropertyOptional({ minLength: 2, maxLength: 60, description: 'BASICS.' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(60)
  displayName?: string;

  @ApiPropertyOptional({
    description: 'BASICS. Lower-case letters, digits and underscores, 3 to 30 characters.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(31)
  handle?: string;

  @ApiPropertyOptional({
    maxLength: MAX_BIO,
    description: 'BASICS. Short bio, up to 160 characters.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_BIO)
  bio?: string;
}

export class SetAvatarDto {
  @ApiProperty({
    format: 'uuid',
    description: 'A READY image the member uploaded through /media (PUBLIC).',
  })
  @Type(() => String)
  @IsUUID()
  mediaId!: string;
}

export class CompletionItemDto {
  @ApiProperty() key!: string;
  @ApiProperty() label!: string;
  @ApiProperty() weight!: number;
  @ApiProperty() done!: boolean;
}

export class CompletionDto {
  @ApiProperty({ minimum: 0, maximum: 100 }) percent!: number;
  @ApiProperty({ type: [CompletionItemDto] }) items!: CompletionItemDto[];
  @ApiProperty({
    type: [CompletionItemDto],
    description: 'The most valuable missing items, heaviest first.',
  })
  next!: CompletionItemDto[];
}

export class DisciplineLite {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiProperty() icon!: string;
}

export class OnboardingProfileDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() displayName!: string;
  @ApiProperty({ nullable: true, type: String }) handle!: string | null;
  @ApiProperty({ nullable: true, type: String }) bio!: string | null;
  @ApiProperty({ nullable: true, type: String }) headline!: string | null;
  @ApiProperty({ type: DisciplineLite, nullable: true }) discipline!: DisciplineLite | null;
  @ApiProperty({ type: [TaxonomyItemDto] }) specialisations!: TaxonomyItemDto[];
  @ApiProperty({ type: [TaxonomyItemDto] }) skills!: TaxonomyItemDto[];
  @ApiProperty({ type: [TaxonomyItemDto] }) interests!: TaxonomyItemDto[];
  @ApiProperty({ type: [TaxonomyItemDto] }) developmentAreas!: TaxonomyItemDto[];
  @ApiProperty({ nullable: true, type: String }) countryId!: string | null;
  @ApiProperty({ nullable: true, type: String }) countryName!: string | null;
  @ApiProperty({ nullable: true, type: String }) countyId!: string | null;
  @ApiProperty({ nullable: true, type: String }) countyName!: string | null;
  @ApiProperty({ nullable: true, type: String }) town!: string | null;
  @ApiProperty({ enum: VISIBILITIES }) locationVisibility!: string;
  @ApiProperty({
    nullable: true,
    type: String,
    description: 'Signed avatar URL (600 px), when a photo is set.',
  })
  avatarUrl!: string | null;
}

export class OnboardingStateDto {
  @ApiProperty({ enum: ONBOARDING_STEPS, description: 'The step to show next (the resume point).' })
  step!: OnboardingStepValue;
  @ApiProperty({ description: 'True once the member finished onboarding and holds a Passport.' })
  completed!: boolean;
  @ApiProperty({ type: OnboardingProfileDto }) profile!: OnboardingProfileDto;
  @ApiProperty({ type: CompletionDto }) completion!: CompletionDto;
  @ApiProperty({ nullable: true, type: String, example: 'ATR-NBI-0042' }) passportNumber!:
    string | null;
}

export class PassportPreviewDto {
  @ApiProperty({ example: 'ATR-NBI-0042' }) passportNumber!: string;
  @ApiProperty({ type: String, format: 'date-time' }) issuedAt!: Date;
}

export class OnboardingCompleteDto {
  @ApiProperty({ type: OnboardingStateDto }) state!: OnboardingStateDto;
  @ApiProperty({ type: PassportPreviewDto }) passport!: PassportPreviewDto;
}

export class HandleAvailabilityDto {
  @ApiProperty() handle!: string;
  @ApiProperty() available!: boolean;
  @ApiProperty({ enum: ['INVALID', 'RESERVED', 'TAKEN'], nullable: true, type: String })
  reason!: 'INVALID' | 'RESERVED' | 'TAKEN' | null;
  @ApiProperty({
    type: [String],
    description: 'Free alternatives when the handle is taken or reserved.',
  })
  suggestions!: string[];
}

// ---- admin ------------------------------------------------------------------------------------------------

export const TAXONOMY_KINDS = [
  'disciplines',
  'specialisations',
  'skills',
  'interests',
  'development-areas',
] as const;
export type TaxonomyKind = (typeof TAXONOMY_KINDS)[number];

export class AdminTaxonomyQueryDto {
  @ApiPropertyOptional({ description: 'Specialisations and skills: only this discipline (id).' })
  @IsOptional()
  @IsUUID()
  disciplineId?: string;

  @ApiPropertyOptional({ description: 'Include archived entries. Default true for admins.' })
  @IsOptional()
  @Transform(({ value }) => (value === 'false' ? false : value === 'true' ? true : value))
  @IsBoolean()
  includeArchived?: boolean;
}

export class AdminTaxonomyItemDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ nullable: true, type: String, description: 'Disciplines only.' }) icon!:
    string | null;
  @ApiProperty({
    nullable: true,
    type: String,
    format: 'uuid',
    description: 'Specialisations and skills.',
  })
  disciplineId!: string | null;
  @ApiProperty({ nullable: true, type: String }) disciplineName!: string | null;
  @ApiProperty() sortOrder!: number;
  @ApiProperty() isActive!: boolean;
  @ApiProperty({ description: 'How many members currently use it.' }) usage!: number;
}

export class CreateTaxonomyItemDto {
  @ApiProperty({ minLength: 2, maxLength: 60 })
  @IsString()
  @MinLength(2)
  @MaxLength(60)
  name!: string;

  @ApiPropertyOptional({ description: 'Disciplines only: a Lucide icon name.' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  icon?: string;

  @ApiPropertyOptional({
    format: 'uuid',
    description: 'Required for specialisations; optional for skills (blank = general).',
  })
  @IsOptional()
  @IsUUID()
  disciplineId?: string;
}

export class UpdateTaxonomyItemDto {
  @ApiPropertyOptional({ minLength: 2, maxLength: 60 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(60)
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(40)
  icon?: string;

  @ApiPropertyOptional({
    description:
      'false archives the entry (hidden from new selections, kept on existing profiles).',
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class ReorderTaxonomyDto {
  @ApiProperty({
    type: [String],
    description: 'Ids in the new order. Applies within the same list (discipline) only.',
  })
  @IsArray()
  @ArrayUnique()
  @IsUUID(undefined, { each: true })
  ids!: string[];
}

export class AdminSuggestionsQueryDto {
  @ApiPropertyOptional({ enum: ['PENDING', 'APPROVED', 'MERGED', 'REJECTED'] })
  @IsOptional()
  @IsEnum(['PENDING', 'APPROVED', 'MERGED', 'REJECTED'])
  status?: 'PENDING' | 'APPROVED' | 'MERGED' | 'REJECTED';

  @ApiPropertyOptional({ minimum: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  page: number = 1;

  @ApiPropertyOptional({ minimum: 1, maximum: 100, default: 20 })
  @IsOptional()
  @Type(() => Number)
  limit: number = 20;
}

export class AdminSuggestionDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ format: 'uuid' }) disciplineId!: string;
  @ApiProperty() disciplineName!: string;
  @ApiProperty({ enum: ['PENDING', 'APPROVED', 'MERGED', 'REJECTED'] }) status!: string;
  @ApiProperty({ format: 'uuid' }) suggestedById!: string;
  @ApiProperty() suggestedByName!: string;
  @ApiProperty({ nullable: true, type: String, format: 'uuid' }) specialisationId!: string | null;
  @ApiProperty({ nullable: true, type: String }) resolutionNote!: string | null;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) resolvedAt!: Date | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class ApproveSuggestionDto {
  @ApiPropertyOptional({ description: 'Publish it under a corrected name.' })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(60)
  name?: string;
}

export class MergeSuggestionDto {
  @ApiProperty({
    format: 'uuid',
    description: 'The existing specialisation this suggestion duplicates.',
  })
  @IsUUID()
  specialisationId!: string;
}

export class RejectSuggestionDto {
  @ApiPropertyOptional({ maxLength: 300 })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  note?: string;
}
