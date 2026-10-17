import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { PageQueryDto } from '../common/pagination';

const STATUSES = ['PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED', 'DELETED'] as const;

export class AdminUsersQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ description: 'Matches name, email or phone.' })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  q?: string;

  @ApiPropertyOptional({ enum: STATUSES })
  @IsOptional()
  @IsEnum(STATUSES)
  status?: (typeof STATUSES)[number];
}

export class AdminAuditQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ description: 'Exact action, e.g. user.suspend.' })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  action?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(60)
  entityType?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(80)
  entityId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsString()
  @MaxLength(36)
  actorId?: string;
}

export class SuspendUserDto {
  @ApiProperty({ description: 'Why the account is being suspended. Kept in the audit log.' })
  @IsString()
  @MinLength(5)
  @MaxLength(500)
  reason!: string;
}

export class ReactivateUserDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;
}

export class AdminUserDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() fullName!: string;
  @ApiProperty({ nullable: true, type: String }) email!: string | null;
  @ApiProperty({ nullable: true, type: String }) phone!: string | null;
  @ApiProperty({ enum: STATUSES }) status!: string;
  @ApiProperty({ nullable: true, type: String }) statusReason!: string | null;
  @ApiProperty({ type: [String] }) roles!: string[];
  @ApiProperty({ nullable: true, type: String, format: 'date-time' }) lastLoginAt!: Date | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AuditLogEntryDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ['USER', 'ADMIN', 'SYSTEM'] }) actorType!: string;
  @ApiProperty({ nullable: true, type: String }) actorId!: string | null;
  @ApiProperty({ nullable: true, type: String, description: 'Name of the actor, when known.' })
  actorName!: string | null;
  @ApiProperty() action!: string;
  @ApiProperty() entityType!: string;
  @ApiProperty({ nullable: true, type: String }) entityId!: string | null;
  @ApiProperty({ nullable: true, type: 'object', additionalProperties: true }) before!: unknown;
  @ApiProperty({ nullable: true, type: 'object', additionalProperties: true }) after!: unknown;
  @ApiProperty({ nullable: true, type: String }) ip!: string | null;
  @ApiProperty({ nullable: true, type: String }) requestId!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class PageMetaDto {
  @ApiProperty() page!: number;
  @ApiProperty() limit!: number;
  @ApiProperty() total!: number;
}
