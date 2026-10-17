import base from '@atarah/shared-config/eslint';
import next from 'eslint-config-next/core-web-vitals';

// Next's rules first, so the shared TypeScript parser and rules (which need the TS parser) win.
const config = [
  ...next,
  ...base,
  { ignores: ['next-env.d.ts', 'src/fonts/**', 'test-results/**', 'playwright-report/**'] },
];

export default config;
