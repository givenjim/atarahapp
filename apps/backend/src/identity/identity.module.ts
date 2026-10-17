import { Module } from '@nestjs/common';
import { AdminAuthService } from './admin-auth.service';
import { AuthService } from './auth.service';
import { CodeService } from './code.service';
import { GOOGLE_AUTH_PROVIDER, UnconfiguredGoogleAuthProvider } from './google.provider';
import { AdminAuthController, AuthController, UsersController } from './identity.controllers';
import { PasswordService } from './password.service';
import { SessionService } from './session.service';
import { UserViewService } from './user-view.service';

@Module({
  controllers: [AuthController, UsersController, AdminAuthController],
  providers: [
    AuthService,
    AdminAuthService,
    CodeService,
    PasswordService,
    SessionService,
    UserViewService,
    { provide: GOOGLE_AUTH_PROVIDER, useClass: UnconfiguredGoogleAuthProvider },
  ],
  exports: [AuthService, SessionService, PasswordService, CodeService, UserViewService],
})
export class IdentityModule {}
