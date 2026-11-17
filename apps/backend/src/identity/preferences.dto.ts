import { ApiPropertyOptional } from '@nestjs/swagger';
import { Appearance } from '@prisma/client';
import { IsBoolean, IsEnum, IsOptional, IsString, Matches, Validate } from 'class-validator';
import { ValidatorConstraint, type ValidatorConstraintInterface } from 'class-validator';

@ValidatorConstraint({ name: 'ianaTimeZone', async: false })
class IanaTimeZone implements ValidatorConstraintInterface {
  validate(value: unknown): boolean {
    if (typeof value !== 'string' || value.length === 0 || value.length > 64) return false;
    try {
      new Intl.DateTimeFormat('en', { timeZone: value });
      return true;
    } catch {
      return false;
    }
  }
  defaultMessage(): string {
    return 'timeZone must be a valid IANA time zone, for example Africa/Nairobi';
  }
}

export class UpdateAccountPreferencesDto {
  @ApiPropertyOptional({ enum: Appearance })
  @IsOptional()
  @IsEnum(Appearance)
  appearance?: Appearance;

  @ApiPropertyOptional({ example: 'en', description: 'BCP 47 language tag, e.g. en or sw.' })
  @IsOptional()
  @IsString()
  @Matches(/^[a-z]{2,3}(-[A-Za-z0-9]{2,8}){0,2}$/, {
    message: 'locale must be a language tag such as en or sw',
  })
  locale?: string;

  @ApiPropertyOptional({ example: 'Africa/Nairobi', description: 'IANA time zone.' })
  @IsOptional()
  @Validate(IanaTimeZone)
  timeZone?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  marketingOptIn?: boolean;
}
