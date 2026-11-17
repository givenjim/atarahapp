import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  Length,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import {
  ContentDelivery,
  ContentSource,
  LearningAccess,
  LearningCategoryGroup,
  LearningContentType,
  LessonProgressStatus,
  PublicationStatus,
  SkillLevel,
} from '@prisma/client';
import { PageQueryDto } from '../common/pagination';
import { ArticleBlockDto, ArticleBlockInputDto } from '../content/content.dto';

const flag = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1'
    ? true
    : value === false || value === 'false' || value === '0'
      ? false
      : value;

export const MY_LEARNING_TABS = ['active', 'completed', 'saved'] as const;
export const MAX_LESSONS = 60;
export const MAX_POSITION_SECONDS = 6 * 3600;

// ---- members: queries and bodies ----------------------------------------------------------------------------------

export class CategoryQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: LearningContentType, enumName: 'LearningContentType' })
  @IsOptional()
  @IsEnum(LearningContentType)
  type?: LearningContentType;
}

export class LearningSearchQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ enum: LearningContentType, enumName: 'LearningContentType' })
  @IsOptional()
  @IsEnum(LearningContentType)
  type?: LearningContentType;
}

export class MyLearningQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: MY_LEARNING_TABS, default: 'active' })
  @IsOptional()
  @IsIn(MY_LEARNING_TABS)
  tab?: (typeof MY_LEARNING_TABS)[number];
}

export class LessonProgressBodyDto {
  @ApiPropertyOptional({
    description: 'Where the member has got to, in seconds. Only ever moves forward.',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(MAX_POSITION_SECONDS)
  positionSeconds?: number;

  @ApiPropertyOptional({
    description: 'Mark the lesson complete (set once; repeating it changes nothing).',
  })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  completed?: boolean;

  @ApiPropertyOptional({
    description: 'Start the lesson over: position back to zero, not completed.',
  })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  restart?: boolean;
}

// ---- members: responses -------------------------------------------------------------------------------------------

export class LearningCategoryRefDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ enum: LearningCategoryGroup, enumName: 'LearningCategoryGroup' })
  group!: LearningCategoryGroup;
}

export class LearningItemProgressDto {
  @ApiProperty({ enum: LessonProgressStatus, enumName: 'LessonProgressStatus' })
  status!: LessonProgressStatus;
  @ApiProperty({ description: '0 to 100. For a course, completed lessons over all lessons.' })
  percent!: number;
}

export class LearningCardDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty({ enum: LearningContentType, enumName: 'LearningContentType' })
  type!: LearningContentType;
  @ApiProperty() title!: string;
  @ApiProperty() summary!: string;
  @ApiProperty({ type: LearningCategoryRefDto }) category!: LearningCategoryRefDto;
  @ApiProperty({ enum: SkillLevel, enumName: 'SkillLevel' }) level!: SkillLevel;
  @ApiProperty() durationMinutes!: number;
  @ApiPropertyOptional({ type: Number, nullable: true }) lessonCount!: number | null;
  @ApiProperty({ enum: ContentSource, enumName: 'ContentSource' }) source!: ContentSource;
  @ApiProperty({ enum: ContentDelivery, enumName: 'ContentDelivery' }) delivery!: ContentDelivery;
  @ApiPropertyOptional({ type: String, nullable: true }) providerName!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) coverUrl!: string | null;
  @ApiProperty({ enum: LearningAccess, enumName: 'LearningAccess' }) access!: LearningAccess;
  @ApiProperty({ description: 'Premium content the caller cannot open yet (show AtPremiumGate).' })
  premiumLocked!: boolean;
  @ApiProperty() featured!: boolean;
  @ApiProperty() saved!: boolean;
  @ApiPropertyOptional({ type: LearningItemProgressDto, nullable: true })
  progress!: LearningItemProgressDto | null;
}

export class LessonSummaryDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() sequence!: number;
  @ApiProperty() title!: string;
  @ApiProperty() durationMinutes!: number;
  @ApiProperty({ enum: ['DONE', 'CURRENT', 'LOCKED', 'AVAILABLE'] }) state!:
    'DONE' | 'CURRENT' | 'LOCKED' | 'AVAILABLE';
  @ApiProperty() hasVideo!: boolean;
  @ApiProperty() hasEmbed!: boolean;
}

export class CertificateDto {
  @ApiProperty() certificateNumber!: string;
  @ApiProperty({ type: String, format: 'date-time' }) issuedAt!: Date;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) achievementId!:
    string | null;
}

export class CourseInfoDto {
  @ApiProperty() lessonCount!: number;
  @ApiProperty() totalMinutes!: number;
  @ApiProperty() sequential!: boolean;
  @ApiProperty() enrolled!: boolean;
  @ApiProperty() completedLessons!: number;
  @ApiProperty() percent!: number;
  @ApiPropertyOptional({
    type: String,
    format: 'uuid',
    nullable: true,
    description: 'The lesson "Continue learning" opens.',
  })
  nextLessonId!: string | null;
  @ApiProperty({ type: [LessonSummaryDto] }) lessons!: LessonSummaryDto[];
  @ApiPropertyOptional({ type: CertificateDto, nullable: true })
  certificate!: CertificateDto | null;
}

export class SkillRefDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() name!: string;
}

export class LearningDetailDto extends LearningCardDto {
  @ApiProperty({ type: [String] }) whatYouLearn!: string[];
  @ApiPropertyOptional({ type: String, nullable: true }) whoItsFor!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) instructorName!: string | null;
  @ApiProperty({ type: [String], description: 'Discipline names.' }) disciplines!: string[];
  @ApiProperty({ type: [SkillRefDto] }) skills!: SkillRefDto[];
  @ApiPropertyOptional({ type: CourseInfoDto, nullable: true }) course!: CourseInfoDto | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'EXTERNAL_LINK content: where it opens.',
  })
  externalUrl!: string | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'The domain named in the leaving-Atarah sheet.',
  })
  externalDomain!: string | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'EMBEDDED single items: the player address.',
  })
  embedUrl!: string | null;
  @ApiProperty({
    enum: ['UNKNOWN', 'OK', 'BROKEN'],
    description: 'BROKEN: show "This link no longer works".',
  })
  linkStatus!: string;
  @ApiPropertyOptional({
    type: LearningItemProgressDto,
    nullable: true,
    description: 'Non-course items: started or completed.',
  })
  itemProgress!: LearningItemProgressDto | null;
  @ApiProperty() shareUrl!: string;
}

export class LessonProgressDto {
  @ApiProperty({ enum: LessonProgressStatus, enumName: 'LessonProgressStatus' })
  status!: LessonProgressStatus;
  @ApiProperty() lastPositionSeconds!: number;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  completedAt!: Date | null;
}

export class PracticeDto {
  @ApiProperty() prompt!: string;
  @ApiPropertyOptional({ type: SkillRefDto, nullable: true }) skill!: SkillRefDto | null;
}

export class LessonDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ format: 'uuid' }) courseId!: string;
  @ApiProperty() courseTitle!: string;
  @ApiProperty() sequence!: number;
  @ApiProperty() lessonCount!: number;
  @ApiProperty() title!: string;
  @ApiProperty() durationMinutes!: number;
  @ApiProperty({ type: [ArticleBlockDto] }) body!: ArticleBlockDto[];
  @ApiPropertyOptional({ type: PracticeDto, nullable: true }) practice!: PracticeDto | null;
  @ApiProperty({ description: 'Uploaded video: fetch the address from the video endpoint.' })
  hasVideo!: boolean;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Embedded player address (allow-listed host).',
  })
  embedUrl!: string | null;
  @ApiProperty({ type: LessonProgressDto }) progress!: LessonProgressDto;
  @ApiProperty({ enum: ['DONE', 'CURRENT', 'LOCKED', 'AVAILABLE'] }) state!: string;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) previousLessonId!:
    string | null;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) nextLessonId!:
    string | null;
  @ApiProperty({
    type: [Boolean],
    description: 'One flag per lesson of the course (7-segment progress bar): completed or not.',
  })
  segments!: boolean[];
}

export class LessonVideoDto {
  @ApiProperty({ description: 'Short-lived signed address of the MP4.' }) url!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) posterUrl!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) expiresAt!: Date;
  @ApiPropertyOptional({ type: Number, nullable: true }) durationSeconds!: number | null;
}

export class ProgressResultDto {
  @ApiProperty({ type: LessonProgressDto }) progress!: LessonProgressDto;
  @ApiProperty() courseCompleted!: boolean;
  @ApiProperty() percent!: number;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) nextLessonId!:
    string | null;
  @ApiPropertyOptional({
    type: CertificateDto,
    nullable: true,
    description: 'Set when this write completed the course.',
  })
  certificate!: CertificateDto | null;
}

export class EnrolmentDto {
  @ApiProperty({ format: 'uuid' }) courseId!: string;
  @ApiProperty({ type: String, format: 'date-time' }) enrolledAt!: Date;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) nextLessonId!:
    string | null;
}

export class ContinueLearningDto {
  @ApiProperty({ type: LearningCardDto }) content!: LearningCardDto;
  @ApiProperty() percent!: number;
  @ApiProperty() lessonsDone!: number;
  @ApiProperty() lessonCount!: number;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) nextLessonId!:
    string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) nextLessonTitle!: string | null;
}

export class HubCategoryDto extends LearningCategoryRefDto {
  @ApiProperty({ description: 'Published items in this category.' }) count!: number;
}

export class RecommendedDto {
  @ApiProperty({ type: LearningCardDto }) content!: LearningCardDto;
  @ApiProperty({ description: 'Why: "Because you want to develop Personal branding".' })
  reason!: string;
}

export class LearningHubDto {
  @ApiPropertyOptional({ type: ContinueLearningDto, nullable: true })
  continueLearning!: ContinueLearningDto | null;
  @ApiProperty({ type: [LearningCardDto] }) featured!: LearningCardDto[];
  @ApiProperty({ type: [HubCategoryDto] }) categories!: HubCategoryDto[];
  @ApiProperty({ type: [RecommendedDto] }) recommended!: RecommendedDto[];
}

export class CategoryTypeCountDto {
  @ApiProperty({ enum: LearningContentType, enumName: 'LearningContentType' })
  type!: LearningContentType;
  @ApiProperty() count!: number;
}

export class LearningCategoryPageDto {
  @ApiProperty({ type: LearningCategoryRefDto }) category!: LearningCategoryRefDto;
  @ApiProperty({ description: 'All published items in the category, whatever the type filter.' })
  total!: number;
  @ApiProperty({ type: [CategoryTypeCountDto] }) types!: CategoryTypeCountDto[];
}

export class MyLearningItemDto {
  @ApiProperty({ type: LearningCardDto }) content!: LearningCardDto;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  lastActivityAt!: Date | null;
}

export class LearningStatsDto {
  @ApiProperty() inProgress!: number;
  @ApiProperty() completed!: number;
  @ApiProperty() minutesThisMonth!: number;
  @ApiProperty({ description: 'minutesThisMonth as hours with one decimal.' })
  hoursThisMonth!: number;
}

// ---- staff: bodies ------------------------------------------------------------------------------------------------

export class CategoryFieldsDto {
  @ApiProperty({ minLength: 2, maxLength: 60 }) @IsString() @Length(2, 60) name!: string;
  @ApiProperty({ enum: LearningCategoryGroup, enumName: 'LearningCategoryGroup' })
  @IsEnum(LearningCategoryGroup)
  group!: LearningCategoryGroup;
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(1000)
  sortOrder?: number;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() isActive?: boolean;
}

export class UpdateCategoryDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(2, 60) name?: string;
  @ApiPropertyOptional({ enum: LearningCategoryGroup, enumName: 'LearningCategoryGroup' })
  @IsOptional()
  @IsEnum(LearningCategoryGroup)
  group?: LearningCategoryGroup;
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(1000)
  sortOrder?: number;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() isActive?: boolean;
}

const strings = ({ value }: { value: unknown }) =>
  Array.isArray(value)
    ? value.map((s) => (typeof s === 'string' ? s.trim() : s)).filter((s) => s !== '')
    : value;

export class ContentFieldsDto {
  @ApiProperty({ minLength: 3, maxLength: 140 }) @IsString() @Length(3, 140) title!: string;
  @ApiProperty({ enum: LearningContentType, enumName: 'LearningContentType' })
  @IsEnum(LearningContentType)
  type!: LearningContentType;
  @ApiProperty({ minLength: 10, maxLength: 300 }) @IsString() @Length(10, 300) summary!: string;
  @ApiProperty({ format: 'uuid' }) @IsUUID() categoryId!: string;
  @ApiPropertyOptional({ enum: SkillLevel, enumName: 'SkillLevel' })
  @IsOptional()
  @IsEnum(SkillLevel)
  level?: SkillLevel;
  @ApiPropertyOptional({
    description: 'Items that are not courses. A course takes its lessons’ total.',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(6000)
  durationMinutes?: number;
  @ApiPropertyOptional({ enum: ContentSource, enumName: 'ContentSource' })
  @IsOptional()
  @IsEnum(ContentSource)
  source?: ContentSource;
  @ApiPropertyOptional({ enum: ContentDelivery, enumName: 'ContentDelivery' })
  @IsOptional()
  @IsEnum(ContentDelivery)
  delivery?: ContentDelivery;
  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  providerName?: string;
  @ApiPropertyOptional({
    format: 'uuid',
    nullable: true,
    type: String,
    description: 'The instructor’s member account.',
  })
  @IsOptional()
  @IsUUID()
  instructorUserId?: string | null;
  @ApiPropertyOptional({ maxLength: 2048, description: 'Required for EXTERNAL_LINK. https only.' })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  externalUrl?: string;
  @ApiPropertyOptional({
    maxLength: 2048,
    description: 'Single embedded items. Host must be on the allow-list.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  embedUrl?: string;
  @ApiPropertyOptional({
    format: 'uuid',
    nullable: true,
    type: String,
    description: 'A READY public image.',
  })
  @IsOptional()
  @IsUUID()
  coverMediaId?: string | null;
  @ApiPropertyOptional({ enum: LearningAccess, enumName: 'LearningAccess' })
  @IsOptional()
  @IsEnum(LearningAccess)
  access?: LearningAccess;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() featured?: boolean;
  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @Transform(strings)
  @IsArray()
  @ArrayMaxSize(10)
  @IsString({ each: true })
  @MaxLength(160, { each: true })
  whatYouLearn?: string[];
  @ApiPropertyOptional({ maxLength: 300 })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  whoItsFor?: string;
  @ApiPropertyOptional({ type: [String], format: 'uuid' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsUUID('all', { each: true })
  disciplineIds?: string[];
  @ApiPropertyOptional({ type: [String], format: 'uuid' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsUUID('all', { each: true })
  skillIds?: string[];
  @ApiPropertyOptional({ description: 'Courses only.' })
  @IsOptional()
  @IsBoolean()
  sequential?: boolean;
}

export class UpdateContentDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(3, 140) title?: string;
  @ApiPropertyOptional({ enum: LearningContentType, enumName: 'LearningContentType' })
  @IsOptional()
  @IsEnum(LearningContentType)
  type?: LearningContentType;
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(10, 300) summary?: string;
  @ApiPropertyOptional({ format: 'uuid' }) @IsOptional() @IsUUID() categoryId?: string;
  @ApiPropertyOptional({ enum: SkillLevel, enumName: 'SkillLevel' })
  @IsOptional()
  @IsEnum(SkillLevel)
  level?: SkillLevel;
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(6000)
  durationMinutes?: number;
  @ApiPropertyOptional({ enum: ContentSource, enumName: 'ContentSource' })
  @IsOptional()
  @IsEnum(ContentSource)
  source?: ContentSource;
  @ApiPropertyOptional({ enum: ContentDelivery, enumName: 'ContentDelivery' })
  @IsOptional()
  @IsEnum(ContentDelivery)
  delivery?: ContentDelivery;
  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  providerName?: string | null;
  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  instructorUserId?: string | null;
  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  externalUrl?: string | null;
  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  embedUrl?: string | null;
  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  coverMediaId?: string | null;
  @ApiPropertyOptional({ enum: LearningAccess, enumName: 'LearningAccess' })
  @IsOptional()
  @IsEnum(LearningAccess)
  access?: LearningAccess;
  @ApiPropertyOptional() @IsOptional() @IsBoolean() featured?: boolean;
  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @Transform(strings)
  @IsArray()
  @ArrayMaxSize(10)
  @IsString({ each: true })
  @MaxLength(160, { each: true })
  whatYouLearn?: string[];
  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  whoItsFor?: string | null;
  @ApiPropertyOptional({ type: [String], format: 'uuid' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsUUID('all', { each: true })
  disciplineIds?: string[];
  @ApiPropertyOptional({ type: [String], format: 'uuid' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsUUID('all', { each: true })
  skillIds?: string[];
  @ApiPropertyOptional() @IsOptional() @IsBoolean() sequential?: boolean;
}

export class LessonFieldsDto {
  @ApiProperty({ minLength: 2, maxLength: 140 }) @IsString() @Length(2, 140) title!: string;
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(600)
  durationMinutes?: number;
  @ApiPropertyOptional({ type: [ArticleBlockInputDto] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => ArticleBlockInputDto)
  body?: ArticleBlockInputDto[];
  @ApiPropertyOptional({
    format: 'uuid',
    nullable: true,
    type: String,
    description: 'A READY video you uploaded through /media.',
  })
  @IsOptional()
  @IsUUID()
  videoMediaId?: string | null;
  @ApiPropertyOptional({
    nullable: true,
    type: String,
    description: 'Allow-listed https player address.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  embedUrl?: string | null;
  @ApiPropertyOptional({ nullable: true, type: String, maxLength: 400 })
  @IsOptional()
  @IsString()
  @MaxLength(400)
  practicePrompt?: string | null;
  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  practiceSkillId?: string | null;
}

export class UpdateLessonDto {
  @ApiPropertyOptional() @IsOptional() @IsString() @Length(2, 140) title?: string;
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(600)
  durationMinutes?: number;
  @ApiPropertyOptional({ type: [ArticleBlockInputDto] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => ArticleBlockInputDto)
  body?: ArticleBlockInputDto[];
  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  videoMediaId?: string | null;
  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  embedUrl?: string | null;
  @ApiPropertyOptional({ nullable: true, type: String })
  @IsOptional()
  @IsString()
  @MaxLength(400)
  practicePrompt?: string | null;
  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  practiceSkillId?: string | null;
}

export class ReorderLessonsDto {
  @ApiProperty({
    type: [String],
    format: 'uuid',
    description: 'Every lesson of the course, in the new order.',
  })
  @IsArray()
  @ArrayMaxSize(MAX_LESSONS)
  @IsUUID('all', { each: true })
  lessonIds!: string[];
}

export class ProgressOverrideDto {
  @ApiProperty({ format: 'uuid' }) @IsUUID() userId!: string;
  @ApiProperty({ format: 'uuid', description: 'The course (learning content id).' })
  @IsUUID()
  courseId!: string;
  @ApiPropertyOptional({ format: 'uuid', description: 'Required for the lesson actions.' })
  @IsOptional()
  @IsUUID()
  lessonId?: string;
  @ApiProperty({ enum: ['COMPLETE_LESSON', 'RESET_LESSON', 'RESET_COURSE'] })
  @IsIn(['COMPLETE_LESSON', 'RESET_LESSON', 'RESET_COURSE'])
  action!: 'COMPLETE_LESSON' | 'RESET_LESSON' | 'RESET_COURSE';
  @ApiProperty({ minLength: 10, maxLength: 400, description: 'Why. Kept with the audit entry.' })
  @IsString()
  @Length(10, 400)
  reason!: string;
}

export class AdminContentsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: PublicationStatus, enumName: 'PublicationStatus' })
  @IsOptional()
  @IsEnum(PublicationStatus)
  status?: PublicationStatus;
  @ApiPropertyOptional({ enum: LearningContentType, enumName: 'LearningContentType' })
  @IsOptional()
  @IsEnum(LearningContentType)
  type?: LearningContentType;
  @ApiPropertyOptional({ format: 'uuid' }) @IsOptional() @IsUUID() categoryId?: string;
  @ApiPropertyOptional({ maxLength: 80 }) @IsOptional() @IsString() @MaxLength(80) q?: string;
  @ApiPropertyOptional({ description: 'Only items whose link or embed was found broken.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  brokenLink?: boolean;
}

// ---- staff: responses ---------------------------------------------------------------------------------------------

export class AdminLessonDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() sequence!: number;
  @ApiProperty() title!: string;
  @ApiProperty() durationMinutes!: number;
  @ApiProperty({ type: [ArticleBlockDto] }) body!: ArticleBlockDto[];
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) videoMediaId!:
    string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) videoStatus!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) embedUrl!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) practicePrompt!: string | null;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) practiceSkillId!:
    string | null;
}

export class AdminContentDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() slug!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ enum: LearningContentType, enumName: 'LearningContentType' })
  type!: LearningContentType;
  @ApiProperty() summary!: string;
  @ApiProperty({ type: LearningCategoryRefDto }) category!: LearningCategoryRefDto;
  @ApiProperty({ enum: SkillLevel, enumName: 'SkillLevel' }) level!: SkillLevel;
  @ApiProperty() durationMinutes!: number;
  @ApiProperty({ enum: ContentSource, enumName: 'ContentSource' }) source!: ContentSource;
  @ApiProperty({ enum: ContentDelivery, enumName: 'ContentDelivery' }) delivery!: ContentDelivery;
  @ApiPropertyOptional({ type: String, nullable: true }) providerName!: string | null;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) instructorUserId!:
    string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) externalUrl!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) embedUrl!: string | null;
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) coverMediaId!:
    string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) coverUrl!: string | null;
  @ApiProperty({ enum: LearningAccess, enumName: 'LearningAccess' }) access!: LearningAccess;
  @ApiProperty({ enum: PublicationStatus, enumName: 'PublicationStatus' })
  status!: PublicationStatus;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  publishedAt!: Date | null;
  @ApiProperty() featured!: boolean;
  @ApiProperty({ type: [String] }) whatYouLearn!: string[];
  @ApiPropertyOptional({ type: String, nullable: true }) whoItsFor!: string | null;
  @ApiProperty({ type: [String], format: 'uuid' }) disciplineIds!: string[];
  @ApiProperty({ type: [String], format: 'uuid' }) skillIds!: string[];
  @ApiProperty({ enum: ['UNKNOWN', 'OK', 'BROKEN'] }) linkStatus!: string;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  lastCheckedAt!: Date | null;
  @ApiPropertyOptional({ type: Boolean, nullable: true }) sequential!: boolean | null;
  @ApiProperty({ type: [AdminLessonDto] }) lessons!: AdminLessonDto[];
  @ApiProperty() enrolmentCount!: number;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: String, format: 'date-time' }) updatedAt!: Date;
}

export class AdminCategoryDto extends LearningCategoryRefDto {
  @ApiProperty() sortOrder!: number;
  @ApiProperty() isActive!: boolean;
  @ApiProperty({ description: 'All items, whatever their status.' }) contentCount!: number;
}

export class LearningAnalyticsRowDto {
  @ApiProperty({ format: 'uuid' }) contentId!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ enum: LearningContentType, enumName: 'LearningContentType' })
  type!: LearningContentType;
  @ApiProperty() starts!: number;
  @ApiProperty() completions!: number;
  @ApiProperty({ description: 'completions over starts, 0 to 100.' }) completionRate!: number;
}

export class LearningAnalyticsDto {
  @ApiProperty() publishedItems!: number;
  @ApiProperty() totalStarts!: number;
  @ApiProperty() totalCompletions!: number;
  @ApiProperty() certificatesIssued!: number;
  @ApiProperty({ type: [LearningAnalyticsRowDto] }) items!: LearningAnalyticsRowDto[];
}
