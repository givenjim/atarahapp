import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsEmail,
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  Length,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import { Visibility } from '@prisma/client';

export const E164 = /^\+[1-9]\d{7,14}$/;
export const PRIVACY_FIELDS = [
  'CONTACT',
  'LOCATION',
  'PORTFOLIO',
  'EXPERIENCE',
  'ACTIVITY',
] as const;
export type PrivacyFieldKey = (typeof PRIVACY_FIELDS)[number];

// ---- account ---------------------------------------------------------------------------------------------

export class AccountDto {
  @ApiProperty() fullName!: string;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'The public username (handle).',
  })
  handle!: string | null;
  @ApiPropertyOptional({ type: String, nullable: true }) email!: string | null;
  @ApiProperty() emailVerified!: boolean;
  @ApiPropertyOptional({ type: String, nullable: true, description: 'E.164' }) phone!:
    string | null;
  @ApiProperty() phoneVerified!: boolean;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'A new email waiting for confirmation.',
  })
  pendingEmail!: string | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'A new phone waiting for its code.',
  })
  pendingPhone!: string | null;
}

export class UpdateAccountDto {
  @ApiPropertyOptional({ minLength: 2, maxLength: 60 })
  @IsOptional()
  @IsString()
  @Length(2, 60)
  fullName?: string;

  @ApiPropertyOptional({
    description: 'Lower-case letters, digits and underscores, 3 to 30 characters.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  handle?: string;
}

export class ChangeEmailDto {
  @ApiProperty() @IsEmail() @MaxLength(254) email!: string;
}

export class ChangePhoneDto {
  @ApiProperty({ example: '+254712345678' })
  @IsString()
  @Matches(E164, { message: 'Enter the number in international format, like +254712345678.' })
  phone!: string;
}

export class VerifyPhoneChangeDto {
  @ApiProperty({ example: '+254712345678' }) @IsString() @Matches(E164) phone!: string;
  @ApiProperty({ minLength: 4, maxLength: 10 }) @IsString() @Length(4, 10) code!: string;
}

export class ContactChangeStartedDto {
  @ApiProperty({ enum: ['EMAIL', 'PHONE'] }) kind!: 'EMAIL' | 'PHONE';
  @ApiProperty({ description: 'Where the code or confirmation link was sent.' }) sentTo!: string;
}

export class ChangePasswordDto {
  @ApiProperty() @IsString() @MinLength(1) @MaxLength(200) currentPassword!: string;
  @ApiProperty({ minLength: 8 }) @IsString() @MinLength(8) @MaxLength(200) newPassword!: string;
}

export class PasswordChangedDto {
  @ApiProperty({ description: 'Other devices that were signed out.' }) sessionsRevoked!: number;
}

// ---- privacy ---------------------------------------------------------------------------------------------

export class PrivacyFieldDto {
  @ApiProperty({ enum: PRIVACY_FIELDS, enumName: 'PrivacyField' }) field!: PrivacyFieldKey;
  @ApiProperty() label!: string;
  @ApiProperty({ enum: ['PUBLIC', 'MEMBERS', 'PRIVATE'], enumName: 'Visibility' })
  visibility!: Visibility;
  @ApiProperty({ enum: ['PUBLIC', 'MEMBERS', 'PRIVATE'], enumName: 'Visibility' })
  defaultVisibility!: Visibility;
}

export class PrivacyDto {
  @ApiProperty({ type: [PrivacyFieldDto] }) fields!: PrivacyFieldDto[];
}

export class UpdatePrivacyDto {
  @ApiProperty({ enum: PRIVACY_FIELDS, enumName: 'PrivacyField' })
  @IsIn(PRIVACY_FIELDS)
  field!: PrivacyFieldKey;

  @ApiProperty({ enum: ['PUBLIC', 'MEMBERS', 'PRIVATE'], enumName: 'Visibility' })
  @IsEnum(Visibility)
  visibility!: Visibility;
}

// ---- two-step --------------------------------------------------------------------------------------------

export class SetTwoStepDto {
  @ApiProperty() @IsBoolean() enabled!: boolean;
}

export class TwoStepDto {
  @ApiProperty() enabled!: boolean;
  @ApiProperty() hasVerifiedFactor!: boolean;
}

// ---- export and deletion ----------------------------------------------------------------------------------

export class ExportStateDto {
  @ApiProperty({ enum: ['NONE', 'QUEUED', 'PROCESSING', 'READY', 'FAILED', 'EXPIRED'] })
  status!: 'NONE' | 'QUEUED' | 'PROCESSING' | 'READY' | 'FAILED' | 'EXPIRED';
  @ApiPropertyOptional({ type: String, format: 'uuid', nullable: true }) id!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  requestedAt!: Date | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  expiresAt!: Date | null;
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    description: 'Signed download link, only while READY.',
  })
  downloadUrl!: string | null;
  @ApiPropertyOptional({
    type: String,
    format: 'date-time',
    nullable: true,
    description: 'When another export can be asked for.',
  })
  nextAllowedAt!: Date | null;
}

export class DeleteAccountDto {
  @ApiProperty({ description: 'Must be the word DELETE.' })
  @IsString()
  @IsIn(['DELETE'], { message: 'Type DELETE to confirm.' })
  confirm!: string;

  @ApiPropertyOptional({
    description:
      'Your password, to prove it is you. Not needed when you signed in within the last 5 minutes.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  password?: string;
}

export class DeletionStateDto {
  @ApiProperty({
    type: String,
    format: 'date-time',
    description: 'Personal data is deleted after this.',
  })
  purgeAfter!: Date;
  @ApiProperty() sessionsRevoked!: number;
}

export class RestoredDto {
  @ApiProperty() restored!: boolean;
}

// ---- membership ------------------------------------------------------------------------------------------

export class PlanRowDto {
  @ApiProperty() label!: string;
  @ApiProperty({ description: 'Included in the Free plan.' }) free!: boolean;
  @ApiProperty({ description: 'Included in Pro.' }) pro!: boolean;
}

export class MembershipViewDto {
  @ApiProperty({ enum: ['FREE', 'PRO'] }) plan!: 'FREE' | 'PRO';
  @ApiPropertyOptional({ type: String, nullable: true }) status!: string | null;
  @ApiPropertyOptional({ type: String, format: 'date-time', nullable: true })
  currentPeriodEnd!: Date | null;
  @ApiProperty({ description: 'Pro monthly price, ready to show: "KES 1,200 a month".' })
  proPriceLabel!: string;
  @ApiProperty({ type: [PlanRowDto], description: 'The Free versus Pro table.' })
  comparison!: PlanRowDto[];
  @ApiProperty({ description: 'The scholarship note shown under the table.' })
  scholarshipNote!: string;
}
