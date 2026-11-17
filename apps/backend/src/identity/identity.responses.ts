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
  @ApiProperty({ enum: ['LIGHT', 'DARK'] }) appearance!: string;
  @ApiProperty() marketingOptIn!: boolean;
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
  @ApiProperty({
    type: String,
    format: 'date-time',
    nullable: true,
    description:
      'Set while the account is scheduled for deletion: the date the data is purged. Sign-in then offers Restore account.',
  })
  deletionScheduledFor!: Date | null;
}

export class AccountPreferencesDto {
  @ApiProperty({ enum: ['LIGHT', 'DARK'] }) appearance!: string;
  @ApiProperty({ example: 'en' }) locale!: string;
  @ApiProperty({ example: 'Africa/Nairobi' }) timeZone!: string;
  @ApiProperty() marketingOptIn!: boolean;
}

export class AdminMeDto extends MeDto {
  @ApiProperty({ type: [String], description: 'Effective permissions, for the console sidebar.' })
  permissions!: string[];
}

export class RevokedDto {
  @ApiProperty() revoked!: boolean;
}

export class SessionViewDto {
  @ApiProperty({
    format: 'uuid',
    description: 'Supabase Auth session id; stable across token refreshes.',
  })
  id!: string;
  @ApiProperty({ enum: ['ANDROID', 'IOS', 'WEB', 'UNKNOWN'] }) client!: string;
  @ApiProperty({ nullable: true, type: String }) deviceName!: string | null;
  @ApiProperty({ nullable: true, type: String }) approxLocation!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) lastActiveAt!: Date;
  @ApiProperty() current!: boolean;
}

export class SessionsRevokedDto {
  @ApiProperty() sessionsRevoked!: number;
}

export class DeviceRegisteredDto {
  @ApiProperty({ description: 'True the first time this device signs in to the account.' })
  newDevice!: boolean;
  @ApiProperty({
    description:
      'False when two-step is on and this new device has not passed the second step yet: the app must run the challenge.',
  })
  verified!: boolean;
}

export class HookAckDto {}

export class MfaFactorDto {
  @ApiProperty({ format: 'uuid' }) id!: string;
  @ApiProperty({ enum: ['totp', 'phone'] }) type!: string;
  @ApiProperty({ enum: ['verified', 'unverified'] }) status!: string;
  @ApiProperty({ nullable: true, type: String }) friendlyName!: string | null;
  @ApiProperty({ type: String, format: 'date-time' }) createdAt!: Date;
}

export class SecurityDto {
  @ApiProperty({ type: [MfaFactorDto] }) factors!: MfaFactorDto[];
  @ApiProperty({
    description: 'The member turned two-step sign-in on (new devices need the second step).',
  })
  twoStepEnabled!: boolean;
  @ApiProperty({
    description: 'A verified second factor is enrolled, so two-step can be switched on.',
  })
  hasVerifiedFactor!: boolean;
  @ApiProperty() activeSessions!: number;
  @ApiProperty({ description: 'Devices that have signed in.' }) deviceCount!: number;
}
