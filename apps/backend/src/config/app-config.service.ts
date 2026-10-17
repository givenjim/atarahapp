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
  get jwt() {
    return { accessSecret: this.env.ATARAH_JWT_ACCESS_SECRET };
  }
  get peppers() {
    return {
      refresh: this.env.ATARAH_REFRESH_TOKEN_PEPPER,
      code: this.env.ATARAH_CODE_PEPPER,
      dataKey: this.env.ATARAH_DATA_ENCRYPTION_KEY,
    };
  }
  get s3() {
    return {
      endpoint: this.env.ATARAH_S3_ENDPOINT,
      region: this.env.ATARAH_S3_REGION,
      accessKey: this.env.ATARAH_S3_ACCESS_KEY,
      secretKey: this.env.ATARAH_S3_SECRET_KEY,
      buckets: {
        public: this.env.ATARAH_S3_BUCKET_PUBLIC,
        private: this.env.ATARAH_S3_BUCKET_PRIVATE,
        evidence: this.env.ATARAH_S3_BUCKET_EVIDENCE,
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
  get sentryDsn(): string {
    return this.env.ATARAH_SENTRY_DSN;
  }
}
