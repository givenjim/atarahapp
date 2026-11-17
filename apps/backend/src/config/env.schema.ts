import { z } from 'zod';

const csv = z
  .string()
  .default('')
  .transform((v) =>
    v
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean),
  );

/** An empty value in a .env file means "not set". */
const optionalUrl = z.preprocess((v) => (v === '' ? undefined : v), z.string().url().optional());

/**
 * Environment contract. The app refuses to start if any required value is missing or invalid
 * (Master Prompt P0-M3). Names carry the ATARAH_ prefix.
 */
export const envSchema = z
  .object({
    ATARAH_ENV: z.enum(['dev', 'test', 'staging', 'production']).default('dev'),
    ATARAH_PORT: z.coerce.number().int().min(1).max(65535).default(3000),
    ATARAH_PUBLIC_URL: z.string().url(),
    ATARAH_CORS_ORIGINS: csv,

    /** Supabase transaction pooler (port 6543 in the cloud), connecting as the `atarah_backend` role. */
    ATARAH_DATABASE_URL: z.string().url(),
    /** Direct connection for Prisma migrations and long-running jobs. Not needed at runtime. */
    ATARAH_DIRECT_URL: optionalUrl,
    ATARAH_REDIS_URL: z.string().url(),

    /** Supabase project API URL as the backend reaches it, e.g. http://127.0.0.1:55321 locally. */
    ATARAH_SUPABASE_URL: z.string().url(),
    /** What clients see in signed storage URLs, when it differs from the backend's view (emulator: 10.0.2.2). */
    ATARAH_SUPABASE_PUBLIC_URL: optionalUrl,
    /**
     * Publishable (anon) key. Optional: only needed to check a member's current password and to run the email and phone
     * change flows on their behalf (both are Supabase Auth calls made with the member's own session). Public by design.
     */
    ATARAH_SUPABASE_PUBLISHABLE_KEY: z.string().optional().default(''),
    /** Service-role (secret) key. Backend secret store only: never a client, the repo or logs. */
    ATARAH_SUPABASE_SECRET_KEY: z.string().min(20),
    /** Legacy HS256 JWT secret, only for projects without asymmetric signing keys. JWKS is preferred. */
    ATARAH_SUPABASE_JWT_SECRET: z.string().optional().default(''),
    /** `v1,whsec_<base64>` secret that signs the Send SMS auth hook (Standard Webhooks). */
    ATARAH_SEND_SMS_HOOK_SECRET: z.string().min(32, 'must be at least 32 characters'),

    ATARAH_STORAGE_BUCKET_PUBLIC: z.string().min(1).default('public-media'),
    ATARAH_STORAGE_BUCKET_PRIVATE: z.string().min(1).default('private-media'),
    ATARAH_STORAGE_BUCKET_EVIDENCE: z.string().min(1).default('verification-evidence'),

    ATARAH_SMTP_HOST: z.string().min(1).default('localhost'),
    ATARAH_SMTP_PORT: z.coerce.number().int().default(55325),
    ATARAH_EMAIL_FROM: z.string().min(3).default('Atarah <no-reply@atarah.app>'),
    ATARAH_SMS_PROVIDER: z.enum(['log']).default('log'),

    /** Origin used to build links in emails (the app's universal-link domain). Assumed until DEC-007 is confirmed. */
    ATARAH_APP_LINK_BASE_URL: z.string().url().default('https://atarah.app'),
    ATARAH_FCM_SERVICE_ACCOUNT_JSON: z.string().optional().default(''),
    /** Bearer token the monitoring system presents to GET /metrics. Required in staging and production. */
    ATARAH_METRICS_TOKEN: z.string().optional().default(''),
    ATARAH_SENTRY_DSN: z.string().optional().default(''),

    /** Tooling only: skip opening DB/Redis connections (OpenAPI export). Never set in deployed environments. */
    ATARAH_SKIP_CONNECT: z
      .enum(['0', '1'])
      .default('0')
      .transform((v) => v === '1'),
  })
  .superRefine((env, ctx) => {
    if (env.ATARAH_ENV === 'production' || env.ATARAH_ENV === 'staging') {
      for (const key of ['ATARAH_SEND_SMS_HOOK_SECRET'] as const) {
        if (env[key].startsWith('change-me')) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            path: [key],
            message: 'placeholder secret is not allowed outside dev/test',
          });
        }
      }
      if (env.ATARAH_SMS_PROVIDER === 'log') {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['ATARAH_SMS_PROVIDER'],
          message: 'the log sink is a development stand-in; configure a real SMS provider',
        });
      }
      if (env.ATARAH_METRICS_TOKEN.length < 24) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['ATARAH_METRICS_TOKEN'],
          message: 'required (at least 24 characters) in staging and production',
        });
      }
      if (env.ATARAH_SKIP_CONNECT) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['ATARAH_SKIP_CONNECT'],
          message: 'must not be set outside dev/test',
        });
      }
    }
  });

export type Env = z.infer<typeof envSchema>;

/** Parse and validate. Throws one readable error listing every problem. */
export function parseEnv(raw: Record<string, unknown>): Env {
  const result = envSchema.safeParse(raw);
  if (!result.success) {
    const lines = result.error.issues.map(
      (i) => `  - ${i.path.join('.') || '(root)'}: ${i.message}`,
    );
    throw new Error(`Invalid environment configuration:\n${lines.join('\n')}`);
  }
  return result.data;
}
