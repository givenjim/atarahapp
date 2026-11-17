import { ApiProperty } from '@nestjs/swagger';
import { DevicePlatform } from '@prisma/client';
import { IsEnum, IsString, Length, Matches } from 'class-validator';

export class RegisterSessionDeviceDto {
  @ApiProperty({
    description: 'Random id the app generates once per install. Never a hardware identifier.',
    minLength: 16,
    maxLength: 64,
  })
  @IsString()
  @Length(16, 64)
  @Matches(/^[A-Za-z0-9_-]+$/)
  deviceHash!: string;

  @ApiProperty({ description: 'Shown in Active sessions, e.g. "Pixel 6".', maxLength: 80 })
  @IsString()
  @Length(1, 80)
  name!: string;

  @ApiProperty({ enum: DevicePlatform })
  @IsEnum(DevicePlatform)
  platform!: DevicePlatform;
}
