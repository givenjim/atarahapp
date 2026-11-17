import { Global, Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AccessService } from './access.service';
import { EntitlementsGuard, PermissionsGuard, RecentAuthGuard, SupabaseAuthGuard } from './guards';

/**
 * Global guard chain, in order: authenticate -> permissions -> entitlements -> recent re-auth.
 * (The throttler guard is registered before this module in AppModule.)
 */
@Global()
@Module({
  providers: [
    AccessService,
    { provide: APP_GUARD, useClass: SupabaseAuthGuard },
    { provide: APP_GUARD, useClass: PermissionsGuard },
    { provide: APP_GUARD, useClass: EntitlementsGuard },
    { provide: APP_GUARD, useClass: RecentAuthGuard },
  ],
  exports: [AccessService],
})
export class AccessModule {}
