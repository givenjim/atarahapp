/** Test environment shared by integration suites. Container URLs come from global-setup. */
export function applyTestEnv(): void {
  Object.assign(process.env, {
    ATARAH_ENV: 'test',
    ATARAH_PUBLIC_URL: 'http://localhost:3000',
    ATARAH_CORS_ORIGINS: 'http://localhost:3001',
    ATARAH_JWT_ACCESS_SECRET: 'test-access-secret-test-access-secret-0000',
    ATARAH_REFRESH_TOKEN_PEPPER: 'test-refresh-pepper-test-refresh-pepper-00',
    ATARAH_CODE_PEPPER: 'test-code-pepper-test-code-pepper-000000',
    ATARAH_DATA_ENCRYPTION_KEY: 'test-data-key-test-data-key-test-0000000',
    // Suites that need real object storage start an S3 server and set these three before creating the app.
    ATARAH_S3_ENDPOINT: process.env.ATARAH_TEST_S3_ENDPOINT ?? 'http://localhost:1',
    ATARAH_S3_ACCESS_KEY: process.env.ATARAH_TEST_S3_ACCESS_KEY ?? 'test',
    ATARAH_S3_SECRET_KEY: process.env.ATARAH_TEST_S3_SECRET_KEY ?? 'test',
  });
}
