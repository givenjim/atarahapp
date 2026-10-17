import { Module } from '@nestjs/common';
import { IdentityModule } from '../identity/identity.module';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

/** Back-office endpoints under /api/v1/admin. Every route declares its permissions; the guard chain enforces them. */
@Module({
  imports: [IdentityModule],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
