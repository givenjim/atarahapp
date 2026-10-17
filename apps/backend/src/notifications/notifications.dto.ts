import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
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
