import { Injectable } from '@nestjs/common';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { AppConfigService } from '../config/app-config.service';

/**
 * The service-role Supabase client. It bypasses RLS and Auth rules, so it lives in the backend only and is
 * used for exactly three things: the Auth admin API, Storage, and nothing that reads application tables.
 */
@Injectable()
export class SupabaseAdminService {
  readonly client: SupabaseClient;

  constructor(config: AppConfigService) {
    this.client = createClient(config.supabase.url, config.supabase.secretKey, {
      auth: { autoRefreshToken: false, persistSession: false, detectSessionInUrl: false },
    });
  }

  get auth(): SupabaseClient['auth']['admin'] {
    return this.client.auth.admin;
  }

  get storage(): SupabaseClient['storage'] {
    return this.client.storage;
  }
}
