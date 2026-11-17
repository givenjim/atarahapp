import { Inject, Injectable } from '@nestjs/common';
import { type Env } from './env.schema';

export const ENV_TOKEN = Symbol('ATARAH_ENV');

/** Typed, validated configuration. Never read process.env elsewhere. */
@Injectable()
export class AppConfigService {
  constructor(@Inject(ENV_TOKEN) private readonly env: Env) {}

  get environment(): Env['ATARAH_ENV'] {
    return this.env.ATARAH_ENV;
  }
  get isProduction(): boolean {
    return this.env.ATARAH_ENV === 'production';
  }
  get isDeployed(): boolean {
    return this.env.ATARAH_ENV === 'production' || this.env.ATARAH_ENV === 'staging';
  }
  get port(): number {
    return this.env.ATARAH_PORT;
  }
  get publicUrl(): string {
    return this.env.ATARAH_PUBLIC_URL;
  }
  get corsOrigins(): string[] {
    return this.env.ATARAH_CORS_ORIGINS;
  }
  get databaseUrl(): string {
    return this.env.ATARAH_DATABASE_URL;
  }
  get redisUrl(): string {
    return this.env.ATARAH_REDIS_URL;
  }
  get skipConnect(): boolean {
    return this.env.ATARAH_SKIP_CONNECT;
  }
  get directUrl(): string | undefined {
    return this.env.ATARAH_DIRECT_URL;
  }
  get supabase() {
    const url = this.env.ATARAH_SUPABASE_URL.replace(/\/$/, '');
    return {
      url,
      publicUrl: (this.env.ATARAH_SUPABASE_PUBLIC_URL ?? this.env.ATARAH_SUPABASE_URL).replace(
        /\/$/,
        '',
      ),
      secretKey: this.env.ATARAH_SUPABASE_SECRET_KEY,
      publishableKey: this.env.ATARAH_SUPABASE_PUBLISHABLE_KEY,
      jwtSecret: this.env.ATARAH_SUPABASE_JWT_SECRET,
      jwksUrl: `${url}/auth/v1/.well-known/jwks.json`,
      issuer: `${url}/auth/v1`,
      audience: 'authenticated',
      smsHookSecret: this.env.ATARAH_SEND_SMS_HOOK_SECRET,
    };
  }
  get storage() {
    return {
      buckets: {
        public: this.env.ATARAH_STORAGE_BUCKET_PUBLIC,
        private: this.env.ATARAH_STORAGE_BUCKET_PRIVATE,
        evidence: this.env.ATARAH_STORAGE_BUCKET_EVIDENCE,
      },
    };
  }
  get smtp() {
    return {
      host: this.env.ATARAH_SMTP_HOST,
      port: this.env.ATARAH_SMTP_PORT,
      from: this.env.ATARAH_EMAIL_FROM,
    };
  }
  get smsProvider(): 'log' {
    return this.env.ATARAH_SMS_PROVIDER;
  }
  get appLinkBaseUrl(): string {
    return this.env.ATARAH_APP_LINK_BASE_URL.replace(/\/$/, '');
  }
  /** Firebase service-account JSON for push. Empty means push is not configured. */
  get fcmServiceAccountJson(): string {
    return this.env.ATARAH_FCM_SERVICE_ACCOUNT_JSON;
  }
  get metricsToken(): string {
    return this.env.ATARAH_METRICS_TOKEN;
  }
  get sentryDsn(): string {
    return this.env.ATARAH_SENTRY_DSN;
  }
}
