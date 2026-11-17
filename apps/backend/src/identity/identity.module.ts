import { Module } from '@nestjs/common';
import { AdminAuthController, AuthController, UsersController } from './identity.controllers';
import { PreferencesService } from './preferences.service';
import { SecurityService } from './security.service';
import { SessionService } from './session.service';
import { SmsHookService } from './sms-hook.service';
import { UserViewService } from './user-view.service';

@Module({
  controllers: [AuthController, UsersController, AdminAuthController],
  providers: [PreferencesService, SessionService, SecurityService, SmsHookService, UserViewService],
  exports: [PreferencesService, SessionService, SecurityService, UserViewService],
})
export class IdentityModule {}
