import { rmSync } from 'node:fs';
import { dirname } from 'node:path';
import { FIXTURE_FILE } from './global-setup';

/** The fixture file holds a throwaway password; do not leave it on disk. */
export default function globalTeardown(): void {
  rmSync(dirname(FIXTURE_FILE), { recursive: true, force: true });
}
