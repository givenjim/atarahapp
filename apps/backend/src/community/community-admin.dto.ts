import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import {
  GroupType,
  GroupVisibility,
  ModerationAction,
  ModerationPriority,
  ReportReason,
  ReportStatus,
  ReportTargetType,
} from '@prisma/client';
import { PageQueryDto } from '../common/pagination';
import { GroupCardDto } from './community.dto';
import { MAX_POST_BODY } from './rules';

const REPORT_STATUSES = Object.values(ReportStatus);
const REPORT_TARGETS = Object.values(ReportTargetType);
const REPORT_REASONS = Object.values(ReportReason);
const PRIORITIES = Object.values(ModerationPriority);
const ACTIONS = Object.values(ModerationAction);
const GROUP_TYPES = Object.values(GroupType);
const VISIBILITIES = Object.values(GroupVisibility);

const flag = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1'
    ? true
    : value === false || value === 'false' || value === '0'
      ? false
      : value;

// ---- reports and cases ------------------------------------------------------------------------------------

export class AdminPersonRefDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() displayName!: string;
  @ApiProperty({ nullable: true, type: String }) handle!: string | null;
}

export class AdminReportsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: REPORT_STATUSES, enumName: 'ReportStatus' })
  @IsOptional()
  @IsEnum(REPORT_STATUSES)
  status?: ReportStatus;

  @ApiPropertyOptional({ enum: REPORT_TARGETS, enumName: 'ReportTargetType' })
  @IsOptional()
  @IsEnum(REPORT_TARGETS)
  targetType?: ReportTargetType;
}

export class AdminReportDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: REPORT_TARGETS, enumName: 'ReportTargetType' }) targetType!: string;
  @ApiProperty({ format: 'uuid' }) targetId!: string;
  @ApiProperty({ enum: REPORT_REASONS, enumName: 'ReportReason' }) reason!: string;
  @ApiProperty({ nullable: true, type: String }) note!: string | null;
  @ApiProperty({ enum: REPORT_STATUSES, enumName: 'ReportStatus' }) status!: string;
  @ApiProperty({ nullable: true, type: String, format: 'uuid' }) caseId!: string | null;
  @ApiProperty({ type: AdminPersonRefDto, nullable: true }) reporter!: AdminPersonRefDto | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AdminCasesQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: REPORT_STATUSES, enumName: 'ReportStatus' })
  @IsOptional()
  @IsEnum(REPORT_STATUSES)
  status?: ReportStatus;

  @ApiPropertyOptional({ enum: PRIORITIES, enumName: 'ModerationPriority' })
  @IsOptional()
  @IsEnum(PRIORITIES)
  priority?: ModerationPriority;

  @ApiPropertyOptional({ enum: REPORT_TARGETS, enumName: 'ReportTargetType' })
  @IsOptional()
  @IsEnum(REPORT_TARGETS)
  targetType?: ReportTargetType;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  assigneeId?: string;

  @ApiPropertyOptional({
    description: 'Only cases that still need a decision (not resolved or dismissed).',
  })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  open?: boolean;

  @ApiPropertyOptional({
    description: 'Only cases open for at least this many hours (the backlog view uses 48).',
  })
  @IsOptional()
  @Transform(({ value }) => (value === undefined ? undefined : Number(value)))
  @IsInt()
  @Min(1)
  @Max(24 * 365)
  olderThanHours?: number;
}

export class AdminCaseDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: REPORT_TARGETS, enumName: 'ReportTargetType' }) targetType!: string;
  @ApiProperty({ format: 'uuid' }) targetId!: string;
  @ApiProperty({ enum: REPORT_STATUSES, enumName: 'ReportStatus' }) status!: string;
  @ApiProperty({ enum: PRIORITIES, enumName: 'ModerationPriority' }) priority!: string;
  @ApiProperty() reportCount!: number;
  @ApiProperty({ enum: REPORT_REASONS, enumName: 'ReportReason' }) topReason!: string;
  @ApiProperty({ type: AdminPersonRefDto, nullable: true }) assignee!: AdminPersonRefDto | null;
  @ApiProperty({
    type: AdminPersonRefDto,
    nullable: true,
    description: 'Whose content or account is reported.',
  })
  author!: AdminPersonRefDto | null;
  @ApiProperty({
    nullable: true,
    type: String,
    description: 'A short excerpt of what was reported.',
  })
  preview!: string | null;
  @ApiProperty({ description: 'Hours since the first report.' }) ageHours!: number;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: String, format: 'date-time', nullable: true }) resolvedAt!: Date | null;
}

export class AdminCaseReportDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: REPORT_REASONS, enumName: 'ReportReason' }) reason!: string;
  @ApiProperty({ nullable: true, type: String }) note!: string | null;
  @ApiProperty({ enum: REPORT_STATUSES, enumName: 'ReportStatus' }) status!: string;
  @ApiProperty({ type: AdminPersonRefDto, nullable: true }) reporter!: AdminPersonRefDto | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AdminCaseActionDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ACTIONS, enumName: 'ModerationAction' }) action!: string;
  @ApiProperty({ nullable: true, type: String }) reason!: string | null;
  @ApiProperty({ type: AdminPersonRefDto, nullable: true }) actor!: AdminPersonRefDto | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AdminCaseContentDto {
  @ApiProperty({ description: 'False when the content has been deleted by its author.' })
  exists!: boolean;
  @ApiProperty({
    nullable: true,
    type: String,
    enum: ['VISIBLE', 'HIDDEN', 'REMOVED'],
    enumName: 'ContentStatus',
  })
  status!: string | null;
  @ApiProperty({
    nullable: true,
    type: String,
    description: 'The post or comment text, the account name, or the group name.',
  })
  text!: string | null;
  @ApiProperty({
    nullable: true,
    type: String,
    format: 'uuid',
    description: 'The post a comment belongs to.',
  })
  postId!: string | null;
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) createdAt!: Date | null;
}

export class AdminCaseDetailDto extends AdminCaseDto {
  @ApiProperty({ type: AdminCaseContentDto }) content!: AdminCaseContentDto;
  @ApiProperty({ type: [AdminCaseReportDto] }) reports!: AdminCaseReportDto[];
  @ApiProperty({ type: [AdminCaseActionDto], description: 'Oldest first. Append-only.' })
  history!: AdminCaseActionDto[];
  @ApiProperty({
    enum: ACTIONS,
    enumName: 'ModerationAction',
    isArray: true,
    description: 'The decisions that make sense for this kind of target.',
  })
  allowedActions!: string[];
}

export class ModerationActionBodyDto {
  @ApiProperty({ enum: ACTIONS, enumName: 'ModerationAction' })
  @IsEnum(ACTIONS)
  action!: ModerationAction;

  @ApiPropertyOptional({
    maxLength: 500,
    description:
      'Required for every action except NO_ACTION. Kept internal; never shown to reporters.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;

  @ApiPropertyOptional({
    minimum: 1,
    maximum: 365,
    description: 'RESTRICT_ACCOUNT only: lifts itself after this many days.',
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(365)
  restrictDays?: number;
}

export class AssignCaseBodyDto {
  @ApiPropertyOptional({
    format: 'uuid',
    nullable: true,
    type: String,
    description: 'A staff member who can resolve reports; null or omitted unassigns.',
  })
  @IsOptional()
  @IsUUID()
  assigneeId?: string | null;
}

// ---- groups and announcements -----------------------------------------------------------------------------

export class AdminGroupModeratorDto {
  @ApiProperty({ type: AdminPersonRefDto }) person!: AdminPersonRefDto;
  @ApiProperty({ enum: ['MODERATOR', 'OWNER'], enumName: 'GroupStaffRole' }) role!: string;
}

export class AdminGroupDto extends GroupCardDto {
  @ApiProperty({ enum: VISIBILITIES, enumName: 'GroupVisibility' }) visibility!: string;
  @ApiProperty({ nullable: true, type: String, format: 'uuid' }) disciplineId!: string | null;
  @ApiProperty({ nullable: true, type: String, format: 'uuid' }) countyId!: string | null;
  @ApiProperty({ nullable: true, type: String, format: 'uuid' }) coverMediaId!: string | null;
  @ApiProperty({ type: String, format: 'date-time', nullable: true }) archivedAt!: Date | null;
  @ApiProperty({ type: [AdminGroupModeratorDto] }) moderators!: AdminGroupModeratorDto[];
  @ApiProperty({ type: [String], format: 'uuid', description: 'Pinned post ids, newest first.' })
  pinnedPostIds!: string[];
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AdminGroupsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: GROUP_TYPES, enumName: 'GroupType' })
  @IsOptional()
  @IsEnum(GROUP_TYPES)
  type?: GroupType;

  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ description: 'Include archived groups.' })
  @IsOptional()
  @Transform(flag)
  @IsBoolean()
  includeArchived?: boolean;
}

export class CreateGroupDto {
  @ApiProperty({ minLength: 2, maxLength: 80 })
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  name!: string;

  @ApiPropertyOptional({ description: 'Lower-case words joined by hyphens. Defaults to the name.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  @Matches(/^[a-z0-9]+(-[a-z0-9]+)*$/, {
    message: 'slug must be lower-case words joined by hyphens',
  })
  slug?: string;

  @ApiProperty({ enum: GROUP_TYPES, enumName: 'GroupType' })
  @IsEnum(GROUP_TYPES)
  type!: GroupType;

  @ApiPropertyOptional({ maxLength: 600 })
  @IsOptional()
  @IsString()
  @MaxLength(600)
  description?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  disciplineId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  countyId?: string;

  @ApiPropertyOptional({ format: 'uuid', description: 'An uploaded image (media module).' })
  @IsOptional()
  @IsUUID()
  coverMediaId?: string;

  @ApiPropertyOptional({ default: true, description: 'Run by Atarah.' })
  @IsOptional()
  @IsBoolean()
  isOfficial?: boolean;

  @ApiPropertyOptional({ enum: VISIBILITIES, enumName: 'GroupVisibility', default: 'OPEN' })
  @IsOptional()
  @IsIn(VISIBILITIES)
  visibility?: GroupVisibility;
}

export class UpdateGroupDto {
  @ApiPropertyOptional({ minLength: 2, maxLength: 80 })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(80)
  name?: string;

  @ApiPropertyOptional({ maxLength: 600 })
  @IsOptional()
  @IsString()
  @MaxLength(600)
  description?: string;

  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  disciplineId?: string | null;

  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  countyId?: string | null;

  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  @IsOptional()
  @IsUUID()
  coverMediaId?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isOfficial?: boolean;

  @ApiPropertyOptional({ enum: VISIBILITIES, enumName: 'GroupVisibility' })
  @IsOptional()
  @IsIn(VISIBILITIES)
  visibility?: GroupVisibility;
}

export class GroupModeratorBodyDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  userId!: string;

  @ApiPropertyOptional({
    enum: ['MODERATOR', 'OWNER'],
    enumName: 'GroupStaffRole',
    default: 'MODERATOR',
  })
  @IsOptional()
  @IsIn(['MODERATOR', 'OWNER'])
  role?: 'MODERATOR' | 'OWNER';
}

export class PinPostBodyDto {
  @ApiProperty({ format: 'uuid', description: 'A post in this group.' })
  @IsUUID()
  postId!: string;
}

export class CreateAnnouncementDto {
  @ApiProperty({ minLength: 1, maxLength: MAX_POST_BODY })
  @IsString()
  @MinLength(1)
  @MaxLength(MAX_POST_BODY)
  body!: string;

  @ApiPropertyOptional({
    format: 'uuid',
    description: 'Post to one group instead of every member.',
  })
  @IsOptional()
  @IsUUID()
  groupId?: string;
}

export class AdminAnnouncementsQueryDto extends PageQueryDto {}
