import base from '@atarah/shared-config/eslint';

export default [
  ...base,
  {
    // NestJS dependency injection reads constructor parameter types from decorator metadata, so
    // injected classes must remain value imports. `import type` would silently break DI.
    rules: { '@typescript-eslint/consistent-type-imports': 'off' },
  },
  {
    files: ['test/**/*.ts', 'src/**/*.spec.ts'],
    rules: { '@typescript-eslint/no-explicit-any': 'off' },
  },
  {
    // Seed and tooling scripts print progress to stdout.
    files: ['scripts/**/*.ts', 'prisma/**/*.ts'],
    rules: { 'no-console': 'off' },
  },
];
