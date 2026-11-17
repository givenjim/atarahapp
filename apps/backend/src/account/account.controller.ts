import { Body, Controller, Get, HttpCode, Patch, Post, Put } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { type AuthContext } from '../access/access.types';
import {
  AllowDeactivated,
  BearerToken,
  ClientIp,
  CurrentAuth,
  RequiresPermission,
} from '../access/decorators';
import { ApiEnvelope } from '../common/api-envelope';
import {
  AccountDto,
  ChangeEmailDto,
  ChangePasswordDto,
  ChangePhoneDto,
  ContactChangeStartedDto,
  DeleteAccountDto,
  DeletionStateDto,
  ExportStateDto,
  MembershipViewDto,
  PasswordChangedDto,
  PrivacyDto,
  RestoredDto,
  SetTwoStepDto,
  TwoStepDto,
  UpdateAccountDto,
  UpdatePrivacyDto,
  VerifyPhoneChangeDto,
} from './account.dto';
import { AccountService } from './account.service';
import { DeletionService } from './deletion.service';
import { ExportService } from './export.service';
import {
  MembershipViewService,
  PrivacyService,
  TwoStepService,
} from './privacy-twostep-membership.service';

const perHour = (limit: number) => Throttle({ default: { limit, ttl: 3_600_000 } });

/** Settings: account, privacy, security, data export, deleting the account, and the read-only membership view. */
@ApiTags('Account')
@ApiBearerAuth('access-token')
@Controller('me')
export class AccountController {
  constructor(
    private readonly account: AccountService,
    private readonly privacy: PrivacyService,
    private readonly twoStep: TwoStepService,
    private readonly exports: ExportService,
    private readonly deletion: DeletionService,
    private readonly membership: MembershipViewService,
  ) {}

  // ---- account ----

  @ApiEnvelope(AccountDto)
  @Get('account')
  getAccount(@CurrentAuth() auth: AuthContext) {
    return this.account.get(auth.userId, auth.sessionId);
  }

  @ApiEnvelope(AccountDto)
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Patch('account')
  updateAccount(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: UpdateAccountDto,
    @ClientIp() ip?: string,
  ) {
    return this.account.update(auth.userId, dto, { ip });
  }

  /** Starts the change: Supabase emails a confirmation to both addresses. The old address is told. */
  @perHour(5)
  @HttpCode(200)
  @ApiEnvelope(ContactChangeStartedDto)
  @Post('email/change')
  changeEmail(
    @CurrentAuth() auth: AuthContext,
    @BearerToken() token: string,
    @Body() dto: ChangeEmailDto,
  ) {
    return this.account.startEmailChange(auth.userId, token, dto);
  }

  @perHour(5)
  @HttpCode(200)
  @ApiEnvelope(ContactChangeStartedDto)
  @Post('phone/change')
  changePhone(
    @CurrentAuth() auth: AuthContext,
    @BearerToken() token: string,
    @Body() dto: ChangePhoneDto,
  ) {
    return this.account.startPhoneChange(auth.userId, token, dto);
  }

  @perHour(10)
  @HttpCode(200)
  @ApiEnvelope(AccountDto)
  @Post('phone/verify')
  verifyPhone(
    @CurrentAuth() auth: AuthContext,
    @BearerToken() token: string,
    @Body() dto: VerifyPhoneChangeDto,
  ) {
    return this.account.verifyPhoneChange(auth.userId, token, auth.sessionId, dto);
  }

  @perHour(5)
  @HttpCode(200)
  @ApiEnvelope(PasswordChangedDto)
  @Post('password')
  changePassword(
    @CurrentAuth() auth: AuthContext,
    @BearerToken() token: string,
    @Body() dto: ChangePasswordDto,
  ) {
    return this.account.changePassword(auth.userId, auth.sessionId, token, dto);
  }

  // ---- privacy ----

  @RequiresPermission('profile.view')
  @ApiEnvelope(PrivacyDto)
  @Get('privacy')
  getPrivacy(@CurrentAuth() auth: AuthContext) {
    return this.privacy.get(auth.userId);
  }

  @RequiresPermission('profile.edit')
  @ApiEnvelope(PrivacyDto)
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Patch('privacy')
  updatePrivacy(@CurrentAuth() auth: AuthContext, @Body() dto: UpdatePrivacyDto) {
    return this.privacy.update(auth.userId, dto);
  }

  // ---- two-step ----

  @ApiEnvelope(TwoStepDto)
  @Get('two-step')
  getTwoStep(@CurrentAuth() auth: AuthContext) {
    return this.twoStep.get(auth.userId);
  }

  @HttpCode(200)
  @ApiEnvelope(TwoStepDto)
  @Put('two-step')
  setTwoStep(@CurrentAuth() auth: AuthContext, @Body() dto: SetTwoStepDto) {
    return this.twoStep.set(auth.userId, dto.enabled, auth.aal);
  }

  // ---- export and deletion ----

  @ApiEnvelope(ExportStateDto)
  @Get('export')
  exportState(@CurrentAuth() auth: AuthContext) {
    return this.exports.state(auth.userId);
  }

  /** One per 24 hours. The ZIP is built in the background; the link arrives as a notification. */
  @perHour(3)
  @HttpCode(202)
  @ApiEnvelope(ExportStateDto)
  @Post('export')
  requestExport(@CurrentAuth() auth: AuthContext) {
    return this.exports.request(auth.userId);
  }

  @perHour(5)
  @HttpCode(200)
  @ApiEnvelope(DeletionStateDto)
  @Post('delete')
  deleteAccount(
    @CurrentAuth() auth: AuthContext,
    @Body() dto: DeleteAccountDto,
    @ClientIp() ip?: string,
  ) {
    return this.deletion.request(auth.userId, dto, { ip });
  }

  /** Works for an account in its deletion grace period (otherwise a deactivated account cannot call anything). */
  @AllowDeactivated()
  @perHour(10)
  @HttpCode(200)
  @ApiEnvelope(RestoredDto)
  @Post('restore')
  restore(@CurrentAuth() auth: AuthContext) {
    return this.deletion.restore(auth.userId);
  }

  // ---- membership ----

  @ApiEnvelope(MembershipViewDto)
  @Get('membership')
  getMembership(@CurrentAuth() auth: AuthContext) {
    return this.membership.get(auth.userId);
  }
}
