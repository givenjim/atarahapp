import { Module } from '@nestjs/common';
import { AnalyticsModule } from '../analytics/analytics.module';
import { IdentityModule } from '../identity/identity.module';
import { AdminController } from './admin.controller';
import { AdminOpsController } from './admin-ops.controller';
import { AdminPlatformController } from './admin-platform.controller';
import { AdminOpsService } from './admin-ops.service';
import { AdminService } from './admin.service';

/** Back-office endpoints under /api/v1/admin. Every route declares its permissions; the guard chain enforces them. */
@Module({
  imports: [IdentityModule, AnalyticsModule],
  controllers: [AdminController, AdminOpsController, AdminPlatformController],
  providers: [AdminService, AdminOpsService],
  exports: [AdminService],
})
export class AdminModule {}
