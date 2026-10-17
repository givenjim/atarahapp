import { Global, Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AccessService } from './access.service';
import { EntitlementsGuard, JwtAuthGuard, PermissionsGuard, RecentAuthGuard } from './guards';
import { TokenService } from './token.service';

/**
 * Global guard chain, in order: authenticate -> permissions -> entitlements -> recent re-auth.
 * (The throttler guard is registered before this module in AppModule.)
 */
@Global()
@Module({
  providers: [
    AccessService,
    TokenService,
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: PermissionsGuard },
    { provide: APP_GUARD, useClass: EntitlementsGuard },
    { provide: APP_GUARD, useClass: RecentAuthGuard },
  ],
  exports: [AccessService, TokenService],
})
export class AccessModule {}
