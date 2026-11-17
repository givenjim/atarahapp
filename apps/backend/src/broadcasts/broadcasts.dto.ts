import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsISO8601,
  IsOptional,
  IsString,
  Length,
  Matches,
  MaxLength,
} from 'class-validator';
import { BroadcastStatus, BroadcastTarget, NotificationCategory } from '@prisma/client';
import { PageQueryDto } from '../common/pagination';

export class BroadcastFieldsDto {
  @ApiProperty({ maxLength: 80 }) @IsString() @Length(3, 80) title!: string;
  @ApiProperty({ maxLength: 400 }) @IsString() @Length(3, 400) body!: string;

  @ApiPropertyOptional({
    description: 'An in-app path the notification opens, e.g. /opportunities.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  @Matches(/^\/(?!\/)[^\s\\]*$/, { message: 'Use an in-app path that starts with a single slash.' })
  deepLink?: string;

  @ApiPropertyOptional({
    enum: NotificationCategory,
    enumName: 'NotificationCategory',
    default: 'SYSTEM',
  })
  @IsOptional()
  @IsEnum(NotificationCategory)
  category?: NotificationCategory;

  @ApiProperty({ enum: BroadcastTarget, enumName: 'BroadcastTarget' })
  @IsEnum(BroadcastTarget)
  target!: BroadcastTarget;

  @ApiPropertyOptional({
    description: 'The role key, discipline id or county id, by `target`. Not used for ALL.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  targetValue?: string;

  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    description: 'Send then. Omit to send right away.',
  })
  @IsOptional()
  @IsISO8601()
  scheduledAt?: string;
}

export class BroadcastsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: BroadcastStatus, enumName: 'BroadcastStatus' })
  @IsOptional()
  @IsEnum(BroadcastStatus)
  status?: BroadcastStatus;
}

export class BroadcastDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() title!: string;
  @ApiProperty() body!: string;
  @ApiPropertyOptional({ type: String, nullable: true }) deepLink!: string | null;
  @ApiProperty({ enum: NotificationCategory, enumName: 'NotificationCategory' })
  category!: NotificationCategory;
  @ApiProperty({ enum: BroadcastTarget, enumName: 'BroadcastTarget' }) target!: BroadcastTarget;
  @ApiPropertyOptional({ type: String, nullable: true }) targetValue!: string | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Readable target: the role, discipline or county name.',
  })
  targetLabel!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  scheduledAt!: Date | null;
  @ApiProperty({ enum: BroadcastStatus, enumName: 'BroadcastStatus' }) status!: BroadcastStatus;
  @ApiProperty() recipientCount!: number;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true }) sentAt!: Date | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AudiencePreviewDto {
  @ApiProperty({ description: 'How many members would receive it.' }) recipients!: number;
}

export class PrivacyRequestsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: ['EXPORT', 'DELETION'] })
  @IsOptional()
  @IsEnum({ EXPORT: 'EXPORT', DELETION: 'DELETION' })
  kind?: 'EXPORT' | 'DELETION';

  @ApiPropertyOptional({ description: 'A status of either kind, e.g. READY, PENDING, PURGED.' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  status?: string;
}

export class PrivacyRequestDto {
  @ApiProperty({ enum: ['EXPORT', 'DELETION'] }) kind!: 'EXPORT' | 'DELETION';
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({
    format: 'uuid',
    description: 'The member (a non-personal id; the account may be gone).',
  })
  userId!: string;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Empty once the account was purged.',
  })
  memberName!: string | null;
  @ApiProperty() status!: string;
  @ApiProperty({ type: String, format: 'date-time' }) requestedAt!: Date;
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description: 'Export link expiry or the purge date.',
  })
  dueAt!: Date | null;
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description: 'When it was finished, cancelled or purged.',
  })
  completedAt!: Date | null;
}
