import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
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
  ValidateNested,
} from 'class-validator';
import { DisciplineLite, TaxonomyItemDto, VISIBILITIES } from './creative.dto';
import { ProfileLinkInputDto } from './profile.dto';

export const PROJECT_CATEGORIES = ['PROJECT', 'MEDIA', 'PUBLICATION', 'PERFORMANCE'] as const;
export const COLLABORATOR_STATUSES = ['PENDING', 'ACCEPTED', 'REMOVED'] as const;
export const ACHIEVEMENT_TYPES = [
  'AWARD',
  'CERTIFICATE',
  'FEATURE',
  'SELECTION',
  'NOMINATION',
] as const;
export const SKILL_LEVELS = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT'] as const;
export const PRICING_TYPES = ['FIXED', 'RANGE', 'ON_REQUEST'] as const;
export const OWN_PROJECT_FILTERS = ['ALL', 'DRAFTS', 'PUBLISHED'] as const;

export const MAX_PROJECTS = 100;
export const MAX_PROJECT_MEDIA = 10;
export const MAX_PROJECT_SKILLS = 10;
export const MAX_PROJECT_LINKS = 5;
export const MAX_COLLABORATORS = 10;
export const MAX_EXPERIENCES = 30;
export const MAX_ACHIEVEMENTS = 50;
export const MAX_SERVICES = 12;
export const MAX_TITLE = 120;
export const MAX_PROJECT_TEXT = 2000;
export const MAX_OUTCOME = 500;

const DATE_DESCRIPTION = 'A calendar date, YYYY-MM-DD.';

// ---- requests: projects -----------------------------------------------------------------------------------

export class CreateProjectDto {
  @ApiPropertyOptional({ maxLength: MAX_TITLE, description: 'A draft may have no title yet.' })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_TITLE)
  title?: string;
}

export class UpdateProjectDto {
  @ApiPropertyOptional({ maxLength: MAX_TITLE })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_TITLE)
  title?: string;

  @ApiPropertyOptional({ maxLength: 80, description: 'Your role on the project. Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  role?: string;

  @ApiPropertyOptional({ maxLength: 80, description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  client?: string;

  @ApiPropertyOptional({ description: `${DATE_DESCRIPTION} Empty clears it.` })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  projectDate?: string;

  @ApiPropertyOptional({ enum: PROJECT_CATEGORIES })
  @IsOptional()
  @IsEnum(PROJECT_CATEGORIES)
  category?: (typeof PROJECT_CATEGORIES)[number];

  @ApiPropertyOptional({ format: 'uuid', nullable: true })
  @IsOptional()
  @IsUUID()
  disciplineId?: string | null;

  @ApiPropertyOptional({ maxLength: MAX_PROJECT_TEXT })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_PROJECT_TEXT)
  description?: string;

  @ApiPropertyOptional({ maxLength: MAX_OUTCOME, description: 'What the work achieved.' })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_OUTCOME)
  outcome?: string;

  @ApiPropertyOptional() @IsOptional() @IsBoolean() featured?: boolean;

  @ApiPropertyOptional({ enum: VISIBILITIES })
  @IsOptional()
  @IsEnum(VISIBILITIES)
  visibility?: (typeof VISIBILITIES)[number];

  @ApiPropertyOptional({
    type: [String],
    description: `Your uploaded files in display order; the first is the cover. Replaces the list. At most ${MAX_PROJECT_MEDIA}.`,
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_PROJECT_MEDIA)
  @IsUUID('all', { each: true })
  mediaIds?: string[];

  @ApiPropertyOptional({
    type: [String],
    description: `Skills used. Replaces the list. At most ${MAX_PROJECT_SKILLS}.`,
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_PROJECT_SKILLS)
  @IsUUID('all', { each: true })
  skillIds?: string[];

  @ApiPropertyOptional({
    type: [ProfileLinkInputDto],
    description: `External links. Replaces the list. At most ${MAX_PROJECT_LINKS}.`,
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(MAX_PROJECT_LINKS)
  @ValidateNested({ each: true })
  @Type(() => ProfileLinkInputDto)
  links?: ProfileLinkInputDto[];
}

export class AddCollaboratorDto {
  @ApiPropertyOptional({ format: 'uuid', description: 'An Atarah member. They must accept.' })
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional({ maxLength: 60, description: 'Someone who is not on Atarah.' })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(60)
  name?: string;

  @ApiPropertyOptional({ maxLength: 60 })
  @IsOptional()
  @IsString()
  @MaxLength(60)
  role?: string;
}

export class OwnProjectsQueryDto {
  @ApiPropertyOptional({ enum: OWN_PROJECT_FILTERS, default: 'ALL' })
  @IsOptional()
  @IsIn(OWN_PROJECT_FILTERS)
  listFilter: (typeof OWN_PROJECT_FILTERS)[number] = 'ALL';
}

export class PublicProjectsQueryDto {
  @ApiPropertyOptional({
    enum: ['PUBLIC', 'MEMBERS'],
    description: 'Owner only: see the portfolio as the public or as other members do.',
  })
  @IsOptional()
  @IsIn(['PUBLIC', 'MEMBERS'])
  previewAs?: 'PUBLIC' | 'MEMBERS';

  @ApiPropertyOptional({ enum: PROJECT_CATEGORIES })
  @IsOptional()
  @IsEnum(PROJECT_CATEGORIES)
  category?: (typeof PROJECT_CATEGORIES)[number];

  @ApiPropertyOptional({ description: 'Only featured projects.' })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  featuredOnly?: boolean;
}

export class MemberSearchQueryDto {
  @ApiProperty({ minLength: 2, maxLength: 60 })
  @IsString()
  @MinLength(2)
  @MaxLength(60)
  q!: string;

  @ApiPropertyOptional({ minimum: 1, maximum: 20, default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(20)
  limit: number = 10;
}

// ---- requests: skills, experience, achievements, services -------------------------------------------------

export class SetSkillDto {
  @ApiProperty({ enum: SKILL_LEVELS })
  @IsEnum(SKILL_LEVELS)
  level!: (typeof SKILL_LEVELS)[number];
}

export class ExperienceInputDto {
  @ApiProperty({ maxLength: 80 })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  title!: string;

  @ApiProperty({ maxLength: 80, description: 'Company, studio, school or "Freelance".' })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  organisation!: string;

  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  location?: string;

  @ApiProperty({ description: DATE_DESCRIPTION })
  @IsISO8601({ strict: true })
  startDate!: string;

  @ApiPropertyOptional({ description: `${DATE_DESCRIPTION} Leave out while you still work there.` })
  @IsOptional()
  @IsISO8601({ strict: true })
  endDate?: string;

  @ApiProperty({ description: 'You still work there. Cannot be combined with an end date.' })
  @IsBoolean()
  current!: boolean;

  @ApiPropertyOptional({ maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  description?: string;
}

export class UpdateExperienceDto {
  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  title?: string;

  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  organisation?: string;

  @ApiPropertyOptional({ maxLength: 80, description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  location?: string;

  @ApiPropertyOptional() @IsOptional() @IsISO8601({ strict: true }) startDate?: string;

  @ApiPropertyOptional({ description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  endDate?: string;

  @ApiPropertyOptional() @IsOptional() @IsBoolean() current?: boolean;

  @ApiPropertyOptional({ maxLength: 1000, description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  description?: string;
}

export class AchievementInputDto {
  @ApiProperty({ enum: ACHIEVEMENT_TYPES })
  @IsEnum(ACHIEVEMENT_TYPES)
  type!: (typeof ACHIEVEMENT_TYPES)[number];

  @ApiProperty({ maxLength: 100 })
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  title!: string;

  @ApiPropertyOptional({ maxLength: 80, description: 'Who gave it.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  issuer?: string;

  @ApiPropertyOptional({ description: DATE_DESCRIPTION })
  @IsOptional()
  @IsISO8601({ strict: true })
  achievedOn?: string;

  @ApiPropertyOptional({ maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @ApiPropertyOptional({ description: 'An https link to proof or coverage.' })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  url?: string;
}

export class UpdateAchievementDto {
  @ApiPropertyOptional({ enum: ACHIEVEMENT_TYPES })
  @IsOptional()
  @IsEnum(ACHIEVEMENT_TYPES)
  type?: (typeof ACHIEVEMENT_TYPES)[number];

  @ApiPropertyOptional({ maxLength: 100 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  title?: string;

  @ApiPropertyOptional({ maxLength: 80, description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  issuer?: string;

  @ApiPropertyOptional({ description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  achievedOn?: string;

  @ApiPropertyOptional({ maxLength: 500, description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @ApiPropertyOptional({ description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  url?: string;
}

export class ServiceInputDto {
  @ApiProperty({ maxLength: 80 })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  title!: string;

  @ApiPropertyOptional({ maxLength: 600 })
  @IsOptional()
  @IsString()
  @MaxLength(600)
  description?: string;

  @ApiProperty({ enum: PRICING_TYPES })
  @IsEnum(PRICING_TYPES)
  priceType!: (typeof PRICING_TYPES)[number];

  @ApiPropertyOptional({ description: 'Whole Kenya shillings. FIXED and RANGE only.' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100_000_000)
  priceMin?: number;

  @ApiPropertyOptional({ description: 'Whole Kenya shillings. RANGE only, at least the minimum.' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100_000_000)
  priceMax?: number;
}

export class UpdateServiceDto {
  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  title?: string;

  @ApiPropertyOptional({ maxLength: 600, description: 'Empty clears it.' })
  @IsOptional()
  @IsString()
  @MaxLength(600)
  description?: string;

  @ApiPropertyOptional({ enum: PRICING_TYPES })
  @IsOptional()
  @IsEnum(PRICING_TYPES)
  priceType?: (typeof PRICING_TYPES)[number];

  @ApiPropertyOptional({ nullable: true, type: Number })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100_000_000)
  priceMin?: number | null;

  @ApiPropertyOptional({ nullable: true, type: Number })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100_000_000)
  priceMax?: number | null;
}

// ---- responses --------------------------------------------------------------------------------------------

export class ProjectMediaDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ['IMAGE', 'VIDEO', 'AUDIO', 'DOCUMENT'] }) kind!: string;
  @ApiProperty() mimeType!: string;
  @ApiProperty({
    enum: ['PENDING_UPLOAD', 'UPLOADED', 'PROCESSING', 'READY', 'REJECTED', 'DELETED'],
  })
  status!: string;
  @ApiPropertyOptional({ nullable: true, type: String, description: 'Signed URL; READY only.' })
  url!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, description: '600 px image rendition.' })
  thumbnailUrl!: string | null;
  @ApiPropertyOptional({ nullable: true, type: Number }) width!: number | null;
  @ApiPropertyOptional({ nullable: true, type: Number }) height!: number | null;
  @ApiPropertyOptional({ nullable: true, type: String }) caption!: string | null;
}

export class ProjectLinkDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() label!: string;
  @ApiProperty() url!: string;
  @ApiPropertyOptional({
    nullable: true,
    type: String,
    description: 'Set for YouTube and Vimeo links: the address of the embedded player.',
  })
  embedUrl!: string | null;
}

export class CollaboratorDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ description: 'A member’s display name, or the name typed in.' }) name!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) role!: string | null;
  @ApiProperty({ enum: COLLABORATOR_STATUSES }) status!: string;
  @ApiPropertyOptional({
    nullable: true,
    type: String,
    description: 'Set when the collaborator is a member, so the app can open their profile.',
  })
  handle!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) avatarUrl!: string | null;
}

export class ProjectCardDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) role!: string | null;
  @ApiProperty({ enum: PROJECT_CATEGORIES }) category!: string;
  @ApiPropertyOptional({ nullable: true, type: String, description: DATE_DESCRIPTION })
  projectDate!: string | null;
  @ApiProperty() featured!: boolean;
  @ApiProperty({ enum: ['DRAFT', 'PUBLISHED'] }) status!: string;
  @ApiProperty({ enum: VISIBILITIES }) visibility!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) coverUrl!: string | null;
  @ApiProperty() mediaCount!: number;
  @ApiProperty({ description: 'Hidden by a moderator. Only the owner ever sees a hidden project.' })
  hidden!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) updatedAt!: Date;
}

export class ProjectDto extends ProjectCardDto {
  @ApiPropertyOptional({ nullable: true, type: String }) client!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) description!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) outcome!: string | null;
  @ApiPropertyOptional({ nullable: true, type: DisciplineLite }) discipline!: DisciplineLite | null;
  @ApiProperty({ type: [TaxonomyItemDto] }) skills!: TaxonomyItemDto[];
  @ApiProperty({ type: [ProjectMediaDto] }) media!: ProjectMediaDto[];
  @ApiProperty({ type: [ProjectLinkDto] }) links!: ProjectLinkDto[];
  @ApiProperty({ type: [CollaboratorDto] }) collaborators!: CollaboratorDto[];
  @ApiPropertyOptional({
    nullable: true,
    type: String,
    description: 'Owner only: why a moderator hid the project.',
  })
  hiddenReason!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' })
  publishedAt!: Date | null;
}

export class MemberHitDto {
  @ApiProperty({ format: 'uuid' }) userId!: string;
  @ApiProperty() displayName!: string;
  @ApiProperty() handle!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) avatarUrl!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) discipline!: string | null;
}

export class CollaborationDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: COLLABORATOR_STATUSES }) status!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) role!: string | null;
  @ApiProperty({ format: 'uuid' }) projectId!: string;
  @ApiProperty() projectTitle!: string;
  @ApiProperty() ownerName!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) ownerHandle!: string | null;
}

export class SkillEntryDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() name!: string;
  @ApiPropertyOptional({ enum: SKILL_LEVELS, nullable: true }) level!: string | null;
  @ApiProperty({ enum: ['SELF_DECLARED', 'LEARNING', 'VERIFIED'] }) source!: string;
  @ApiProperty({ description: 'Published projects of yours that use this skill.' })
  projectCount!: number;
}

export class ExperienceDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() title!: string;
  @ApiProperty() organisation!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) location!: string | null;
  @ApiProperty({ description: DATE_DESCRIPTION }) startDate!: string;
  @ApiPropertyOptional({ nullable: true, type: String, description: DATE_DESCRIPTION })
  endDate!: string | null;
  @ApiProperty() current!: boolean;
  @ApiPropertyOptional({ nullable: true, type: String }) description!: string | null;
}

export class AchievementDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ACHIEVEMENT_TYPES }) type!: string;
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) issuer!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, description: DATE_DESCRIPTION })
  achievedOn!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) description!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) url!: string | null;
  @ApiProperty({ enum: ['MANUAL', 'SYSTEM'] }) source!: string;
}

export class ServiceDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() title!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) description!: string | null;
  @ApiProperty({ enum: PRICING_TYPES }) priceType!: string;
  @ApiPropertyOptional({ nullable: true, type: Number, description: 'Whole Kenya shillings.' })
  priceMin!: number | null;
  @ApiPropertyOptional({ nullable: true, type: Number, description: 'Whole Kenya shillings.' })
  priceMax!: number | null;
  @ApiProperty({ enum: ['PROFILE_ONLY', 'ON_MARKETPLACE'] }) status!: string;
}

// ---- admin moderation -------------------------------------------------------------------------------------

export class AdminProjectsQueryDto {
  @ApiPropertyOptional({
    maxLength: 80,
    description: 'Matches the title, the owner’s name or handle.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ description: 'Only projects a moderator has hidden.' })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  hiddenOnly?: boolean;

  @ApiPropertyOptional({ minimum: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @ApiPropertyOptional({ minimum: 1, maximum: 100, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit: number = 20;
}

export class HideProjectDto {
  @ApiProperty({ minLength: 5, maxLength: 300, description: 'Shown to the owner.' })
  @IsString()
  @MinLength(5)
  @MaxLength(300)
  reason!: string;
}

export class AdminProjectDto extends ProjectCardDto {
  @ApiProperty({ format: 'uuid' }) ownerUserId!: string;
  @ApiProperty() ownerName!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) ownerHandle!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String }) hiddenReason!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' })
  hiddenAt!: Date | null;
}

export class AdminProjectDetailDto extends ProjectDto {
  @ApiProperty({ format: 'uuid' }) ownerUserId!: string;
  @ApiProperty() ownerName!: string;
  @ApiPropertyOptional({ nullable: true, type: String }) ownerHandle!: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' })
  hiddenAt!: Date | null;
}
