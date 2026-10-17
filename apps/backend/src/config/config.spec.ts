import { parseEnv } from './env.schema';

const valid = {
  ATARAH_PUBLIC_URL: 'http://localhost:3000',
  ATARAH_DATABASE_URL: 'postgresql://u:p@localhost:5432/db',
  ATARAH_REDIS_URL: 'redis://localhost:6379',
  ATARAH_JWT_ACCESS_SECRET: 'a'.repeat(32),
  ATARAH_REFRESH_TOKEN_PEPPER: 'b'.repeat(32),
  ATARAH_CODE_PEPPER: 'c'.repeat(32),
  ATARAH_DATA_ENCRYPTION_KEY: 'd'.repeat(32),
  ATARAH_S3_ENDPOINT: 'http://localhost:9000',
  ATARAH_S3_ACCESS_KEY: 'k',
  ATARAH_S3_SECRET_KEY: 's',
};

describe('parseEnv', () => {
  it('accepts a complete environment and applies defaults', () => {
    const env = parseEnv({ ...valid, ATARAH_CORS_ORIGINS: 'http://a.test, http://b.test' });
    expect(env.ATARAH_ENV).toBe('dev');
    expect(env.ATARAH_PORT).toBe(3000);
    expect(env.ATARAH_CORS_ORIGINS).toEqual(['http://a.test', 'http://b.test']);
    expect(env.ATARAH_SKIP_CONNECT).toBe(false);
  });

  it('refuses to start when required values are missing, naming every one', () => {
    expect(() => parseEnv({})).toThrow(/ATARAH_DATABASE_URL[\s\S]*ATARAH_REDIS_URL/);
  });

  it('rejects short secrets and malformed URLs', () => {
    expect(() => parseEnv({ ...valid, ATARAH_JWT_ACCESS_SECRET: 'short' })).toThrow(
      /32 characters/,
    );
    expect(() => parseEnv({ ...valid, ATARAH_DATABASE_URL: 'not a url' })).toThrow(
      /ATARAH_DATABASE_URL/,
    );
  });

  it('rejects placeholder secrets and SKIP_CONNECT outside dev/test', () => {
    const placeholder = 'change-me-' + 'x'.repeat(30);
    expect(() =>
      parseEnv({ ...valid, ATARAH_ENV: 'production', ATARAH_JWT_ACCESS_SECRET: placeholder }),
    ).toThrow(/placeholder secret/);
    expect(() => parseEnv({ ...valid, ATARAH_ENV: 'staging', ATARAH_SKIP_CONNECT: '1' })).toThrow(
      /must not be set/,
    );
    expect(
      parseEnv({ ...valid, ATARAH_ENV: 'dev', ATARAH_JWT_ACCESS_SECRET: placeholder }),
    ).toBeTruthy();
  });
});
