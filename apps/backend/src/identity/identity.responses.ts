import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/** Response models. They mirror the service return types and exist so the OpenAPI contract is fully typed. */

export class MembershipSummaryDto {
  @ApiProperty({ enum: ['FREE', 'PRO'] })
  plan!: 'FREE' | 'PRO';

  @ApiPropertyOptional({ nullable: true, type: String })
  status!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' })
  currentPeriodEnd!: Date | null;
}

export class MeDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty() fullName!: string;
  @ApiProperty({ nullable: true, type: String }) email!: string | null;
  @ApiProperty({ nullable: true, type: String, description: 'E.164' }) phone!: string | null;
  @ApiProperty() emailVerified!: boolean;
  @ApiProperty() phoneVerified!: boolean;
  @ApiProperty({ enum: ['PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED', 'DEACTIVATED', 'DELETED'] })
  status!: string;
  @ApiProperty({ example: 'Africa/Nairobi' }) timeZone!: string;
  @ApiProperty({ example: 'en' }) locale!: string;
  @ApiProperty({
    type: [String],
    enum: [
      'MENTOR',
      'SELLER',
      'OPPORTUNITY_PROVIDER',
      'INSTRUCTOR',
      'MODERATOR',
      'CONTENT_ADMIN',
      'PLATFORM_ADMIN',
      'SUPER_ADMIN',
    ],
  })
  roles!: string[];
  @ApiProperty({
    type: [String],
    description: 'Hints for showing or hiding controls. The server decides every action.',
  })
  entitlements!: string[];
  @ApiProperty({ type: MembershipSummaryDto }) membership!: MembershipSummaryDto;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class AdminMeDto extends MeDto {
  @ApiProperty({ type: [String], description: 'Effective permissions, for the console sidebar.' })
  permissions!: string[];
}

export class AuthSessionDto {
  @ApiProperty() accessToken!: string;
  @ApiProperty({ type: String, format: 'date-time' }) accessTokenExpiresAt!: Date;
  @ApiProperty() refreshToken!: string;
  @ApiProperty({ type: String, format: 'date-time' }) refreshTokenExpiresAt!: Date;
  @ApiProperty({ type: MeDto }) user!: MeDto;
}

export class AdminAuthSessionDto extends AuthSessionDto {
  @ApiPropertyOptional({ type: [String], description: 'Shown once, on first TOTP enrolment.' })
  recoveryCodes?: string[];
}

export class VerificationSentDto {
  @ApiProperty({ enum: ['EMAIL', 'SMS'] }) channel!: 'EMAIL' | 'SMS';
  @ApiProperty({ description: 'Masked destination, e.g. n***@gmail.com' }) destination!: string;
  @ApiProperty({ type: String, format: 'date-time' }) expiresAt!: Date;
  @ApiProperty({ type: String, format: 'date-time' }) resendAvailableAt!: Date;
}

export class RegisterResultDto {
  @ApiProperty({ type: VerificationSentDto }) verification!: VerificationSentDto;
}

export class ResendResultDto {
  @ApiProperty({ nullable: true, type: String, format: 'date-time' })
  resendAvailableAt!: Date | null;
}

export class LoggedOutDto {
  @ApiProperty() loggedOut!: boolean;
}
export class SessionsRevokedDto {
  @ApiProperty() sessionsRevoked!: number;
}
export class SentDto {
  @ApiProperty() sent!: boolean;
}
export class ResetDto {
  @ApiProperty() reset!: boolean;
}
export class RevokedDto {
  @ApiProperty() revoked!: boolean;
}

export class SessionViewDto {
  @ApiProperty({
    format: 'uuid',
    description: 'Session family id; stable across refresh rotations.',
  })
  id!: string;
  @ApiProperty({ enum: ['ANDROID', 'IOS', 'WEB', 'ADMIN'] }) client!: string;
  @ApiProperty({ nullable: true, type: String }) deviceName!: string | null;
  @ApiProperty({ nullable: true, type: String }) approxLocation!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) lastActiveAt!: Date;
  @ApiProperty() current!: boolean;
}

export class AdminLoginStepDto {
  @ApiProperty({ enum: ['TOTP_ENROLMENT_REQUIRED', 'TOTP_REQUIRED'] }) step!: string;
  @ApiProperty() challengeToken!: string;
}

export class TotpSetupDto {
  @ApiProperty({ description: 'Base32 secret. Shown once.' }) secret!: string;
  @ApiProperty({ description: 'otpauth:// URL for QR codes.' }) otpauthUrl!: string;
}

export class ReauthDto {
  @ApiProperty({ type: String, format: 'date-time' }) reauthenticatedUntil!: Date;
}
