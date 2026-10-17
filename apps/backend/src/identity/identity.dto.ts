import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  Equals,
  IsBoolean,
  IsDefined,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  Length,
  Matches,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { PASSWORD_PATTERN, PASSWORD_RULE_MESSAGE } from './password.service';

export const MEMBER_CLIENTS = ['ANDROID', 'IOS', 'WEB'] as const;
export type MemberClient = (typeof MEMBER_CLIENTS)[number];

const CODE = /^\d{6}$/;
const CODE_MESSAGE = 'Enter the 6-digit code.';

const IDENTIFIER_DESC = 'Email address or phone number (Kenyan local formats are accepted).';

export class ConsentDto {
  @ApiProperty({ description: 'Terms of Service accepted. Must be true.' })
  @IsBoolean()
  @Equals(true, { message: 'You need to accept the Terms to create an account.' })
  terms!: boolean;

  @ApiProperty({ description: 'Privacy Policy accepted. Must be true.' })
  @IsBoolean()
  @Equals(true, { message: 'You need to accept the Privacy Policy to create an account.' })
  privacy!: boolean;
}

export class RegisterDto {
  @ApiProperty({ minLength: 2, maxLength: 100 })
  @IsString()
  @Length(2, 100)
  fullName!: string;

  @ApiProperty({ description: IDENTIFIER_DESC, maxLength: 254 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  identifier!: string;

  @ApiProperty({
    description: 'At least 8 characters including a number.',
    minLength: 8,
    maxLength: 128,
  })
  @IsString()
  @Matches(PASSWORD_PATTERN, { message: PASSWORD_RULE_MESSAGE })
  password!: string;

  @ApiProperty({ type: ConsentDto })
  @IsDefined({ message: 'You need to accept the Terms and Privacy Policy to create an account.' })
  @ValidateNested()
  @Type(() => ConsentDto)
  consent!: ConsentDto;

  @ApiPropertyOptional({ enum: MEMBER_CLIENTS })
  @IsOptional()
  @IsIn(MEMBER_CLIENTS)
  client?: MemberClient;
}

export class VerifyDto {
  @ApiProperty({ description: IDENTIFIER_DESC })
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  identifier!: string;

  @ApiProperty({ description: 'Six-digit one-time code.', example: '482913' })
  @IsString()
  @Matches(CODE, { message: CODE_MESSAGE })
  code!: string;

  @ApiPropertyOptional({ enum: MEMBER_CLIENTS })
  @IsOptional()
  @IsIn(MEMBER_CLIENTS)
  client?: MemberClient;

  @ApiPropertyOptional({ maxLength: 80 })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  deviceName?: string;
}

export class IdentifierDto {
  @ApiProperty({ description: IDENTIFIER_DESC })
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  identifier!: string;
}

export class LoginDto {
  @ApiProperty({ description: IDENTIFIER_DESC })
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  identifier!: string;

  @ApiProperty({ maxLength: 128 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  password!: string;

  @ApiProperty({ enum: MEMBER_CLIENTS })
  @IsIn(MEMBER_CLIENTS)
  client!: MemberClient;

  @ApiPropertyOptional({
    maxLength: 80,
    description: 'Shown in Settings > Security > Active sessions.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  deviceName?: string;
}

export class RefreshDto {
  @ApiProperty({ description: 'Opaque refresh token from the last sign-in or refresh.' })
  @IsString()
  @MinLength(20)
  @MaxLength(200)
  refreshToken!: string;
}

export class ResetPasswordDto {
  @ApiProperty({ description: IDENTIFIER_DESC })
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  identifier!: string;

  @ApiProperty({ description: 'Six-digit recovery code.' })
  @IsString()
  @Matches(CODE, { message: CODE_MESSAGE })
  code!: string;

  @ApiProperty({ minLength: 8, maxLength: 128 })
  @IsString()
  @Matches(PASSWORD_PATTERN, { message: PASSWORD_RULE_MESSAGE })
  newPassword!: string;
}

export class GoogleSignInDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  idToken!: string;

  @ApiProperty({ enum: MEMBER_CLIENTS })
  @IsIn(MEMBER_CLIENTS)
  client!: MemberClient;
}

// ---- admin ----

export class AdminLoginDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(254)
  email!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  password!: string;
}

export class ChallengeDto {
  @ApiProperty({ description: 'Short-lived token returned by POST /admin/auth/login.' })
  @IsString()
  @IsNotEmpty()
  challengeToken!: string;
}

export class AdminTotpVerifyDto extends ChallengeDto {
  @ApiPropertyOptional({ description: 'Authenticator code. Omit when using a recovery code.' })
  @IsOptional()
  @Matches(CODE, { message: CODE_MESSAGE })
  code?: string;

  @ApiPropertyOptional({ description: 'One-time recovery code (XXXX-XXXX-XXXX).' })
  @IsOptional()
  @Matches(/^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$/, { message: 'Enter a valid recovery code.' })
  recoveryCode?: string;
}

export class AdminReauthDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  password!: string;

  @ApiProperty()
  @Matches(CODE, { message: CODE_MESSAGE })
  code!: string;
}
