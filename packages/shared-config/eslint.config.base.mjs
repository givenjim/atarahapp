import js from '@eslint/js';
import tseslint from 'typescript-eslint';

/** Base flat config shared by backend, web and admin. Apps extend it and add framework rules. */
export default tseslint.config(
  {
    ignores: [
      'dist/**',
      'build/**',
      '.next/**',
      'coverage/**',
      'node_modules/**',
      '**/generated/**',
    ],
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      '@typescript-eslint/consistent-type-imports': ['error', { fixStyle: 'inline-type-imports' }],
      '@typescript-eslint/no-explicit-any': 'error',
      eqeqeq: ['error', 'always'],
      'no-console': ['error', { allow: ['warn', 'error'] }],
    },
  },
);
