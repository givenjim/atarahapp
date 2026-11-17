import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  HttpCode,
  Param,
  Patch,
  ParseUUIDPipe,
  Post,
  Put,
  Req,
} from '@nestjs/common';
import { ApiBearerAuth, ApiExcludeEndpoint, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { Request } from 'express';
import { type AuthContext } from '../access/access.types';
import { AccessService } from '../access/access.service';
import {
  AllowDeactivated,
  AllowPending,
  AllowTwoStepPending,
  CurrentAuth,
  Public,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import { RegisterSessionDeviceDto } from './identity.dto';
import { UpdateAccountPreferencesDto } from './preferences.dto';
import { PreferencesService } from './preferences.service';
import {
  AdminMeDto,
  DeviceRegisteredDto,
  MeDto,
  AccountPreferencesDto,
  RevokedDto,
  SecurityDto,
  SessionViewDto,
  SessionsRevokedDto,
} from './identity.responses';
import { SecurityService } from './security.service';
import { SessionService } from './session.service';
import { SmsHookService, type SendSmsPayload } from './sms-hook.service';
import { UserViewService } from './user-view.service';

const perMinute = (limit: number) => Throttle({ default: { limit, ttl: 60_000 } });

/**
 * Sign-up, code verification, sign-in, token refresh, recovery and MFA go straight from the apps to Supabase
 * Auth (section 5.5). The backend owns only what Supabase cannot: the sessions list, the SMS hook and security.
 */
@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(
    private readonly sessions: SessionService,
    private readonly smsHook: SmsHookService,
  ) {}

  @ApiBearerAuth('access-token')
  @AllowTwoStepPending()
  @ApiEnvelope(SessionViewDto, { isArray: true })
  @Get('sessions')
  list(@CurrentAuth() auth: AuthContext) {
    return this.sessions.list(auth.userId, auth.sessionId);
  }

  @ApiBearerAuth('access-token')
  @AllowTwoStepPending()
  @HttpCode(200)
  @ApiEnvelope(RevokedDto)
  @perMinute(30)
  @Delete('sessions/:id')
  async revoke(@CurrentAuth() auth: AuthContext, @Param('id', ParseUUIDPipe) id: string) {
    await this.sessions.revokeOwn(auth.userId, id);
    return { revoked: true };
  }

  @ApiBearerAuth('access-token')
  @HttpCode(200)
  @ApiEnvelope(SessionsRevokedDto)
  @perMinute(10)
  @Post('sessions/revoke-others')
  async revokeOthers(@CurrentAuth() auth: AuthContext) {
    return { sessionsRevoked: await this.sessions.revokeAllForUser(auth.userId, auth.sessionId) };
  }

  /** Called by Supabase Auth, not by apps. Authenticated by the Standard Webhooks signature. */
  @Public()
  @ApiExcludeEndpoint()
  @perMinute(600)
  @HttpCode(200)
  @Post('hooks/send-sms')
  async sendSmsHook(
    @Req() req: Request & { rawBody?: Buffer },
    @Body() body: SendSmsPayload,
    @Headers('webhook-id') id?: string,
    @Headers('webhook-timestamp') timestamp?: string,
    @Headers('webhook-signature') signature?: string,
  ) {
    this.smsHook.verifySignature(req.rawBody, { id, timestamp, signature });
    await this.smsHook.send(body);
    return {};
  }
}

@ApiTags('Users')
@Controller()
export class UsersController {
  constructor(
    private readonly views: UserViewService,
    private readonly security: SecurityService,
    private readonly preferences: PreferencesService,
  ) {}

  @ApiBearerAuth('access-token')
  @AllowPending()
  @AllowDeactivated()
  @AllowTwoStepPending()
  @ApiEnvelope(MeDto)
  @Get('users/me')
  currentUser(@CurrentAuth() auth: AuthContext) {
    return this.views.me(auth.userId);
  }

  @ApiBearerAuth('access-token')
  @ApiEnvelope(AccountPreferencesDto)
  @Get('me/preferences')
  getPreferences(@CurrentAuth() auth: AuthContext) {
    return this.preferences.get(auth.userId);
  }

  /** Appearance, language, time zone and marketing consent. Only ever the caller's own row. */
  @ApiBearerAuth('access-token')
  @ApiEnvelope(AccountPreferencesDto)
  @Patch('me/preferences')
  updatePreferences(@CurrentAuth() auth: AuthContext, @Body() dto: UpdateAccountPreferencesDto) {
    return this.preferences.update(auth.userId, dto);
  }

  @ApiBearerAuth('access-token')
  @AllowTwoStepPending()
  @ApiEnvelope(SecurityDto)
  @Get('me/security')
  securityOverview(@CurrentAuth() auth: AuthContext) {
    return this.security.overview(auth.userId);
  }

  /** The app calls this after every sign-in so the account knows its devices (new-device detection). */
  @ApiBearerAuth('access-token')
  @AllowTwoStepPending()
  @perMinute(30)
  @HttpCode(200)
  @ApiEnvelope(DeviceRegisteredDto)
  @Put('me/device')
  registerDevice(@CurrentAuth() auth: AuthContext, @Body() dto: RegisterSessionDeviceDto) {
    return this.security.registerDevice(auth.userId, auth.sessionId, dto, auth.aal);
  }
}

@ApiTags('Admin auth')
@Controller('admin/auth')
export class AdminAuthController {
  constructor(
    private readonly views: UserViewService,
    private readonly access: AccessService,
  ) {}

  /** The signed-in staff member and their effective permissions. The token must be AAL2 (checked by the guard). */
  @ApiBearerAuth('access-token')
  @ApiEnvelope(AdminMeDto)
  @Get('me')
  async adminMe(@CurrentAuth() auth: AuthContext) {
    const me = await this.views.me(auth.userId);
    const access = await this.access.effectiveAccess(auth.userId, auth.status);
    return { ...me, permissions: [...access.permissions].sort() };
  }
}
