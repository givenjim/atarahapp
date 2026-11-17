import { Global, Module } from '@nestjs/common';
import { SupabaseAdminService } from './supabase-admin.service';
import { SupabaseJwtService } from './supabase-jwt.service';

/** Supabase client pieces the backend needs: JWT verification and the service-role (admin) client. */
@Global()
@Module({
  providers: [SupabaseJwtService, SupabaseAdminService],
  exports: [SupabaseJwtService, SupabaseAdminService],
})
export class SupabaseModule {}
