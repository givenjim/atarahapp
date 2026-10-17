import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { AllowPending, ClientIp, CurrentAuth, Public, UserAgent } from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { type AuthContext } from '../access/access.types';
import { AdminAuthService } from './admin-auth.service';
import { AuthService } from './auth.service';
import {
  AdminLoginDto,
  AdminReauthDto,
  AdminTotpVerifyDto,
  ChallengeDto,
  GoogleSignInDto,
  IdentifierDto,
  LoginDto,
  RefreshDto,
  RegisterDto,
  ResetPasswordDto,
  VerifyDto,
} from './identity.dto';
import {
  AdminAuthSessionDto,
  AdminLoginStepDto,
  AdminMeDto,
  AuthSessionDto,
  LoggedOutDto,
  MeDto,
  ReauthDto,
  RegisterResultDto,
  ResendResultDto,
  ResetDto,
  RevokedDto,
  SentDto,
  SessionViewDto,
  SessionsRevokedDto,
  TotpSetupDto,
} from './identity.responses';
import { SessionService } from './session.service';
import { UserViewService } from './user-view.service';

const perMinute = (limit: number) => Throttle({ default: { limit, ttl: 60_000 } });

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly sessions: SessionService,
  ) {}

  @Public()
  @perMinute(5)
  @ApiEnvelope(RegisterResultDto, { status: 201 })
  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  @Public()
  @perMinute(10)
  @HttpCode(200)
  @ApiEnvelope(AuthSessionDto)
  @Post('verify')
  verify(@Body() dto: VerifyDto, @ClientIp() ip?: string, @UserAgent() userAgent?: string) {
    return this.auth.verify(dto, { ip, userAgent });
  }

  @Public()
  @perMinute(3)
  @HttpCode(200)
  @ApiEnvelope(ResendResultDto)
  @Post('resend-code')
  resend(@Body() dto: IdentifierDto) {
    return this.auth.resendVerification(dto.identifier);
  }

  @Public()
  @perMinute(10)
  @HttpCode(200)
  @ApiEnvelope(AuthSessionDto)
  @Post('login')
  login(@Body() dto: LoginDto, @ClientIp() ip?: string, @UserAgent() userAgent?: string) {
    return this.auth.login(dto, { ip, userAgent });
  }

  @Public()
  @perMinute(30)
  @HttpCode(200)
  @ApiEnvelope(AuthSessionDto)
  @Post('refresh')
  refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  @ApiBearerAuth('access-token')
  @HttpCode(200)
  @ApiEnvelope(LoggedOutDto)
  @Post('logout')
  async logout(@CurrentAuth() auth: AuthContext) {
    await this.auth.logout(auth.familyId);
    return { loggedOut: true };
  }

  @ApiBearerAuth('access-token')
  @HttpCode(200)
  @ApiEnvelope(SessionsRevokedDto)
  @Post('logout-all')
  async logoutAll(@CurrentAuth() auth: AuthContext) {
    return { sessionsRevoked: await this.auth.logoutAll(auth.userId) };
  }

  @Public()
  @perMinute(3)
  @HttpCode(200)
  @ApiEnvelope(SentDto)
  @Post('password/forgot')
  forgot(@Body() dto: IdentifierDto) {
    return this.auth.forgotPassword(dto.identifier);
  }

  @Public()
  @perMinute(5)
  @HttpCode(200)
  @ApiEnvelope(ResetDto)
  @Post('password/reset')
  reset(@Body() dto: ResetPasswordDto) {
    return this.auth.resetPassword(dto);
  }

  @Public()
  @perMinute(10)
  @HttpCode(200)
  @ApiEnvelope(AuthSessionDto)
  @Post('google')
  google(@Body() dto: GoogleSignInDto, @ClientIp() ip?: string, @UserAgent() userAgent?: string) {
    return this.auth.googleSignIn(dto.idToken, dto.client, { ip, userAgent });
  }

  @ApiBearerAuth('access-token')
  @ApiEnvelope(SessionViewDto, { isArray: true })
  @Get('sessions')
  list(@CurrentAuth() auth: AuthContext) {
    return this.sessions.list(auth.userId, auth.familyId);
  }

  @ApiBearerAuth('access-token')
  @HttpCode(200)
  @ApiEnvelope(RevokedDto)
  @Delete('sessions/:id')
  async revoke(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.sessions.revokeOwn(auth.userId, id);
    return { revoked: true };
  }
}

@ApiTags('Users')
@Controller('users')
export class UsersController {
  constructor(private readonly views: UserViewService) {}

  @ApiBearerAuth('access-token')
  @AllowPending()
  @ApiEnvelope(MeDto)
  @Get('me')
  currentUser(@CurrentAuth() auth: AuthContext) {
    return this.views.me(auth.userId);
  }
}

@ApiTags('Admin auth')
@Controller('admin/auth')
export class AdminAuthController {
  constructor(private readonly admin: AdminAuthService) {}

  @Public()
  @perMinute(10)
  @HttpCode(200)
  @ApiEnvelope(AdminLoginStepDto)
  @Post('login')
  adminLogin(@Body() dto: AdminLoginDto, @ClientIp() ip?: string, @UserAgent() userAgent?: string) {
    return this.admin.login(dto.email, dto.password, { ip, userAgent });
  }

  @Public()
  @perMinute(10)
  @HttpCode(200)
  @ApiEnvelope(TotpSetupDto)
  @Post('totp/setup')
  totpSetup(@Body() dto: ChallengeDto) {
    return this.admin.totpSetup(dto.challengeToken);
  }

  @Public()
  @perMinute(10)
  @HttpCode(200)
  @ApiEnvelope(AdminAuthSessionDto)
  @Post('totp/verify')
  totpVerify(
    @Body() dto: AdminTotpVerifyDto,
    @ClientIp() ip?: string,
    @UserAgent() userAgent?: string,
  ) {
    return this.admin.totpVerify(
      dto.challengeToken,
      { code: dto.code, recoveryCode: dto.recoveryCode },
      { ip, userAgent },
    );
  }

  @Public()
  @perMinute(30)
  @HttpCode(200)
  @ApiEnvelope(AuthSessionDto)
  @Post('refresh')
  adminRefresh(@Body() dto: RefreshDto) {
    return this.admin.refresh(dto.refreshToken);
  }

  @ApiBearerAuth('access-token')
  @HttpCode(200)
  @ApiEnvelope(ReauthDto)
  @Post('reauth')
  adminReauth(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: AdminReauthDto,
    @ClientIp() ip?: string,
  ) {
    return this.admin.reauth(auth.userId, auth.familyId, dto, { ip });
  }

  @ApiBearerAuth('access-token')
  @HttpCode(200)
  @ApiEnvelope(LoggedOutDto)
  @Post('logout')
  async adminLogout(@CurrentAuth() auth: AuthContext) {
    await this.admin.logout(auth.familyId);
    return { loggedOut: true };
  }

  @ApiBearerAuth('access-token')
  @ApiEnvelope(AdminMeDto)
  @Get('me')
  adminMe(@CurrentAuth() auth: AuthContext) {
    return this.admin.profile(auth.userId);
  }
}
