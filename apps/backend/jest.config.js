/** @type {import('jest').Config} */
const base = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  transform: { '^.+\.ts$': ['ts-jest', { tsconfig: 'tsconfig.json', diagnostics: true }] },
  moduleFileExtensions: ['js', 'json', 'ts'],
};

module.exports = {
  // Integration suites share the local Supabase stack and one Redis, so run suites one at a time.
  maxWorkers: 1,
  // Real Supabase Auth, Postgres and Storage: allow for the first-run reference seed and network round trips.
  testTimeout: 60000,
  projects: [
    { ...base, displayName: 'unit', rootDir: '.', testMatch: ['<rootDir>/src/**/*.spec.ts'] },
    {
      ...base,
      displayName: 'integration',
      rootDir: '.',
      testMatch: ['<rootDir>/test/**/*.int-spec.ts'],
      globalSetup: '<rootDir>/test/global-setup.ts',
      testTimeout: 60000,
    },
  ],
};
