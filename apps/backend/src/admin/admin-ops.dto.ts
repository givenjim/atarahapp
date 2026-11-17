import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsArray, IsEnum, IsOptional, IsString, Matches, MaxLength } from 'class-validator';
import { RoleKey } from '@prisma/client';
import { AdminUserDto } from './admin.dto';

// ---- dashboard ------------------------------------------------------------------------------------------------

export const ATTENTION_PRIORITIES = ['LOW', 'NORMAL', 'HIGH', 'URGENT'] as const;

export class AttentionQueueDto {
  @ApiProperty({ example: 'reports' }) key!: string;
  @ApiProperty({ example: 'Reports waiting' }) label!: string;
  @ApiProperty() count!: number;
  @ApiProperty({ enum: ATTENTION_PRIORITIES }) priority!: (typeof ATTENTION_PRIORITIES)[number];
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description: 'The oldest item waiting.',
  })
  oldestAt!: Date | null;
  @ApiProperty({ description: 'Console path that opens the queue.' }) path!: string;
}

export class DashboardCountsDto {
  @ApiProperty({ description: 'Accounts created in the last 7 days.' }) newMembers7d!: number;
  @ApiProperty({ description: 'Accounts created in the last 30 days.' }) newMembers30d!: number;
  @ApiProperty({
    description: "Share (0 to 100) of the last 30 days' sign-ups that finished onboarding.",
  })
  onboardingCompletionRate30d!: number;
  @ApiProperty({ description: 'Members who signed in during the last 7 days.' })
  activeMembers7d!: number;
  @ApiProperty({ description: 'Members who signed in during the last 30 days.' })
  activeMembers30d!: number;
  @ApiProperty() posts7d!: number;
  @ApiProperty() opportunitiesSaved7d!: number;
  @ApiProperty() opportunitiesApplied7d!: number;
  @ApiProperty({
    description: 'Courses completed in the last 30 days (0 until Skill Labs is installed).',
  })
  courseCompletions30d!: number;
}

export class DashboardDto {
  @ApiProperty({ type: String, format: 'date-time' }) generatedAt!: Date;
  @ApiProperty({
    type: [AttentionQueueDto],
    description: 'Only the queues the signed-in admin may act on, most urgent first.',
  })
  queues!: AttentionQueueDto[];
  @ApiProperty({ type: DashboardCountsDto }) counts!: DashboardCountsDto;
}

// ---- analytics ------------------------------------------------------------------------------------------------

export class AnalyticsQueryDto {
  @ApiPropertyOptional({
    example: '2026-10-01',
    description: 'First Nairobi date. Default: 29 days ago.',
  })
  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/)
  from?: string;

  @ApiPropertyOptional({
    example: '2026-10-30',
    description: 'Last Nairobi date. Default: today. At most 120 days.',
  })
  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/)
  to?: string;

  @ApiPropertyOptional({
    type: [String],
    description: 'Event names (comma separated). Default: all.',
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.split(',').filter(Boolean) : value))
  @IsArray()
  @IsString({ each: true })
  @MaxLength(64, { each: true })
  names?: string[];
}

export class AnalyticsPointDto {
  @ApiProperty({ example: '2026-10-24' }) day!: string;
  @ApiProperty() name!: string;
  @ApiProperty() events!: number;
  @ApiProperty({
    description: 'Distinct members that day (privacy-safe hashes, never identities).',
  })
  actors!: number;
}

export class AnalyticsTotalDto {
  @ApiProperty() name!: string;
  @ApiProperty() events!: number;
  @ApiProperty({ description: "Sum of each day's distinct members." }) activeMemberDays!: number;
}

export class AnalyticsSeriesDto {
  @ApiProperty() from!: string;
  @ApiProperty() to!: string;
  @ApiProperty({ type: [AnalyticsPointDto] }) series!: AnalyticsPointDto[];
  @ApiProperty({ type: [AnalyticsTotalDto] }) totals!: AnalyticsTotalDto[];
}

// ---- jobs -----------------------------------------------------------------------------------------------------

export class QueueCountsDto {
  @ApiProperty() queue!: string;
  @ApiProperty() waiting!: number;
  @ApiProperty() active!: number;
  @ApiProperty() delayed!: number;
  @ApiProperty() failed!: number;
  @ApiProperty() completed!: number;
}

export class FailedJobDto {
  @ApiProperty() id!: string;
  @ApiProperty() name!: string;
  @ApiProperty() failedReason!: string;
  @ApiProperty() attemptsMade!: number;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true }) failedAt!:
    string | null;
}

// ---- users ----------------------------------------------------------------------------------------------------

export class RoleDto {
  @ApiProperty({ enum: Object.values(RoleKey), enumName: 'RoleKey' }) key!: string;
  @ApiProperty() name!: string;
  @ApiProperty() description!: string;
  @ApiProperty({
    description: 'Administrative roles need an authenticator code and a super admin to assign.',
  })
  isStaff!: boolean;
  @ApiProperty({ type: [String] }) permissions!: string[];
}

export class AssignRoleDto {
  @ApiProperty({ enum: Object.values(RoleKey), enumName: 'RoleKey' })
  @IsEnum(RoleKey)
  role!: RoleKey;

  @ApiPropertyOptional({ maxLength: 300, description: 'Why. Kept in the audit log.' })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  reason?: string;
}

export class RevokeRoleQueryDto {
  @ApiPropertyOptional({ maxLength: 300 })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  reason?: string;
}

export class UserRoleGrantDto {
  @ApiProperty({ enum: Object.values(RoleKey), enumName: 'RoleKey' }) key!: string;
  @ApiProperty() name!: string;
  @ApiProperty() isStaff!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) grantedAt!: Date;
  @ApiPropertyOptional({ type: String, nullable: true, description: 'Name of whoever granted it.' })
  grantedBy!: string | null;
}

export class UserProfileSummaryDto {
  @ApiPropertyOptional({ type: String, nullable: true }) handle!: string | null;
  @ApiProperty() displayName!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) headline!: string | null;
  @ApiProperty() completionPercent!: number;
  @ApiProperty() onboardingCompleted!: boolean;
  @ApiPropertyOptional({ type: String, nullable: true }) county!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) discipline!: string | null;
  @ApiProperty() publishedProjects!: number;
}

export class UserMembershipDto {
  @ApiProperty() plan!: string;
  @ApiProperty() status!: string;
  @ApiProperty() source!: string;
  @ApiProperty({ type: String, format: 'date-time' }) startsAt!: Date;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  currentPeriodEnd!: Date | null;
}

export class StatusHistoryEntryDto {
  @ApiProperty({ example: 'user.suspend' }) action!: string;
  @ApiProperty({ type: String, format: 'date-time' }) at!: Date;
  @ApiPropertyOptional({ type: String, nullable: true }) actorName!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) reason!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) from!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) to!: string | null;
}

export class UserSessionDto {
  @ApiProperty() id!: string;
  @ApiProperty() client!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) deviceName!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) lastActiveAt!: Date;
}

export class UserReportDto {
  @ApiProperty({ format: 'uuid' }) caseId!: string;
  @ApiProperty() targetType!: string;
  @ApiProperty() topReason!: string;
  @ApiProperty() status!: string;
  @ApiProperty() priority!: string;
  @ApiProperty() reportCount!: number;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class UserReportsDto {
  @ApiProperty({
    description: 'Cases about this member or their content (reporters are never shown).',
  })
  about!: number;
  @ApiProperty({ description: 'Reports this member has made.' }) made!: number;
  @ApiProperty({ type: [UserReportDto] }) recent!: UserReportDto[];
}

export class AdminUserOverviewDto {
  @ApiProperty({ type: AdminUserDto }) user!: AdminUserDto;
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description: 'A temporary suspension ends here.',
  })
  suspendedUntil!: Date | null;
  @ApiPropertyOptional({ type: UserProfileSummaryDto, nullable: true })
  profile!: UserProfileSummaryDto | null;
  @ApiProperty({ type: [UserRoleGrantDto] }) roleGrants!: UserRoleGrantDto[];
  @ApiPropertyOptional({ type: UserMembershipDto, nullable: true })
  membership!: UserMembershipDto | null;
  @ApiProperty({ type: [StatusHistoryEntryDto] }) statusHistory!: StatusHistoryEntryDto[];
  @ApiProperty({ type: [UserSessionDto] }) sessions!: UserSessionDto[];
  @ApiProperty({ type: UserReportsDto }) reports!: UserReportsDto;
}
