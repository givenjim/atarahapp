import { type StartedTestContainer } from 'testcontainers';

export default async function globalTeardown(): Promise<void> {
  const containers = (globalThis as Record<string, unknown>).__ATARAH_CONTAINERS__ as
    StartedTestContainer[] | undefined;
  await Promise.all((containers ?? []).map((c) => c.stop()));
}
