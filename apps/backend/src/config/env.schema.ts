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

const secret = z.string().min(32, 'must be at least 32 characters');

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

    ATARAH_DATABASE_URL: z.string().url(),
    ATARAH_REDIS_URL: z.string().url(),

    ATARAH_JWT_ACCESS_SECRET: secret,
    ATARAH_REFRESH_TOKEN_PEPPER: secret,
    ATARAH_CODE_PEPPER: secret,
    /** Encrypts TOTP secrets and other at-rest secrets (AES-256-GCM; key is derived from this value). */
    ATARAH_DATA_ENCRYPTION_KEY: secret,

    ATARAH_S3_ENDPOINT: z.string().url(),
    ATARAH_S3_REGION: z.string().min(1).default('us-east-1'),
    ATARAH_S3_ACCESS_KEY: z.string().min(1),
    ATARAH_S3_SECRET_KEY: z.string().min(1),
    ATARAH_S3_BUCKET_PUBLIC: z.string().min(1).default('public-media'),
    ATARAH_S3_BUCKET_PRIVATE: z.string().min(1).default('private-media'),
    ATARAH_S3_BUCKET_EVIDENCE: z.string().min(1).default('verification-evidence'),

    ATARAH_SMTP_HOST: z.string().min(1).default('localhost'),
    ATARAH_SMTP_PORT: z.coerce.number().int().default(51025),
    ATARAH_EMAIL_FROM: z.string().min(3).default('Atarah <no-reply@atarah.app>'),
    ATARAH_SMS_PROVIDER: z.enum(['log']).default('log'),

    /** Origin used to build links in emails (the app's universal-link domain). Assumed until DEC-007 is confirmed. */
    ATARAH_APP_LINK_BASE_URL: z.string().url().default('https://atarah.app'),
    ATARAH_FCM_SERVICE_ACCOUNT_JSON: z.string().optional().default(''),
    ATARAH_SENTRY_DSN: z.string().optional().default(''),

    /** Tooling only: skip opening DB/Redis connections (OpenAPI export). Never set in deployed environments. */
    ATARAH_SKIP_CONNECT: z
      .enum(['0', '1'])
      .default('0')
      .transform((v) => v === '1'),
  })
  .superRefine((env, ctx) => {
    if (env.ATARAH_ENV === 'production' || env.ATARAH_ENV === 'staging') {
      for (const key of [
        'ATARAH_JWT_ACCESS_SECRET',
        'ATARAH_REFRESH_TOKEN_PEPPER',
        'ATARAH_CODE_PEPPER',
        'ATARAH_DATA_ENCRYPTION_KEY',
      ] as const) {
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
