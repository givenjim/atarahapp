import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { PageQueryDto } from '../common/pagination';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';

const CATEGORIES = [
  'OPPORTUNITIES',
  'MENTORSHIP',
  'COMMUNITY',
  'LEARNING',
  'PROFILE',
  'MARKETPLACE',
  'SYSTEM',
] as const;
const PLATFORMS = ['ANDROID', 'IOS', 'WEB'] as const;

export class PreferenceDto {
  @ApiProperty({ enum: CATEGORIES })
  @IsEnum(CATEGORIES)
  category!: (typeof CATEGORIES)[number];

  @ApiProperty() @IsBoolean() pushEnabled!: boolean;
  @ApiProperty() @IsBoolean() emailEnabled!: boolean;
}

export class UpdatePreferencesDto {
  @ApiProperty({ type: [PreferenceDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(CATEGORIES.length)
  @ValidateNested({ each: true })
  @Type(() => PreferenceDto)
  preferences!: PreferenceDto[];
}

export class PreferencesDto {
  @ApiProperty({
    type: [PreferenceDto],
    description: 'One entry per category. Categories never changed are on.',
  })
  preferences!: PreferenceDto[];
}

export class RegisterDeviceDto {
  @ApiProperty({ description: 'FCM registration token.' })
  @IsString()
  @MinLength(10)
  @MaxLength(4096)
  token!: string;

  @ApiProperty({ enum: PLATFORMS })
  @IsEnum(PLATFORMS)
  platform!: (typeof PLATFORMS)[number];

  @ApiPropertyOptional({ example: '1.0.0+1' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  appVersion?: string;
}

export class DeviceDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
}

// ---- the notification centre (P1-M11) ----

export class NotificationsQueryDto extends PageQueryDto {
  @ApiPropertyOptional({ enum: CATEGORIES, enumName: 'NotificationCategory' })
  @IsOptional()
  @IsEnum(CATEGORIES)
  category?: (typeof CATEGORIES)[number];

  @ApiPropertyOptional({ description: 'Only the ones not read yet.' })
  @IsOptional()
  @Transform(({ value }) => value === true || value === 'true' || value === '1')
  @IsBoolean()
  unreadOnly?: boolean;
}

export class NotificationItemDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: CATEGORIES, enumName: 'NotificationCategory' }) category!: string;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Dotted key, e.g. opportunity.reminder.',
  })
  type!: string | null;
  @ApiProperty() title!: string;
  @ApiProperty() body!: string;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'An in-app path the notification opens.',
  })
  deepLink!: string | null;
  @ApiPropertyOptional({ type: 'object', additionalProperties: true, nullable: true })
  data!: Record<string, string | number | boolean | null> | null;
  @ApiProperty() read!: boolean;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ enum: ['TODAY', 'EARLIER'], description: 'By the Nairobi calendar day.' })
  group!: 'TODAY' | 'EARLIER';
}

export class UnreadCountDto {
  @ApiProperty() unread!: number;
  @ApiProperty({
    type: 'object',
    additionalProperties: { type: 'number' },
    description: 'Unread per category.',
  })
  byCategory!: Record<string, number>;
}

export class UnreadDto {
  @ApiProperty() unread!: number;
}

export class MarkAllReadDto {
  @ApiPropertyOptional({
    enum: CATEGORIES,
    enumName: 'NotificationCategory',
    description: 'Only this category.',
  })
  @IsOptional()
  @IsEnum(CATEGORIES)
  category?: (typeof CATEGORIES)[number];
}

export class MarkedReadDto extends UnreadDto {
  @ApiProperty() marked!: number;
}
