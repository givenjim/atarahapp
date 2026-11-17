import { readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';
import 'reflect-metadata';
import { DEFAULT_JOB_OPTIONS, QUEUE_NAMES } from './queues.constants';

/**
 * P1-M12 job audit (unit level, no Redis or database). It reads every `*.processor.ts` in the source tree and checks
 * the rules that keep background work safe:
 *  - one processor per queue (two would hand each other's jobs to the wrong handler),
 *  - every repeating job a processor registers has a handler (no "Unknown job" failure at 3 a.m.),
 *  - the platform retry policy gives every job several attempts with exponential backoff and keeps failed jobs for
 *    at least a week, which is the dead-letter store the admin "failed jobs" view reads (GET /admin/jobs),
 *  - a job nobody handles is reported with its queue (queues whose milestone has not started yet are listed, not hidden).
 */
const SRC = join(__dirname, '..');
const PROCESSOR_METADATA = 'bullmq:processor_metadata';

function processorFiles(dir: string, out: string[] = []): string[] {
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    if (statSync(p).isDirectory()) processorFiles(p, out);
    else if (f.endsWith('.processor.ts')) out.push(p);
  }
  return out;
}

interface Found {
  file: string;
  cls: new (...a: unknown[]) => {
    process(job: unknown): Promise<unknown>;
    onApplicationBootstrap?: () => Promise<void>;
  };
  queue: string;
}

function load(): Found[] {
  const found: Found[] = [];
  for (const file of processorFiles(SRC)) {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const mod = require(file) as Record<string, unknown>;
    for (const value of Object.values(mod)) {
      if (typeof value !== 'function') continue;
      const meta = Reflect.getMetadata(PROCESSOR_METADATA, value) as { name?: string } | undefined;
      if (meta)
        found.push({
          file: file.replace(SRC, 'src'),
          cls: value as Found['cls'],
          queue: meta.name ?? '',
        });
    }
  }
  return found;
}

/** A stand-in for any service: every method exists, answers asynchronously and does nothing. */
const anything = (): unknown =>
  new Proxy(function stub() {}, {
    get: (_t, prop) => (prop === 'then' ? undefined : () => Promise.resolve({})),
    apply: () => Promise.resolve({}),
  });

function build(f: Found, scheduled: string[]) {
  // `@InjectQueue('x')` records the injection token of the parameter; the declared type is erased (type-only import).
  const injected =
    (Reflect.getMetadata('self:paramtypes', f.cls) as
      Array<{ index: number; param: unknown }> | undefined) ?? [];
  const queueAt = new Set(
    injected.filter((i) => /queue/i.test(String(i.param))).map((i) => i.index),
  );
  const count =
    (Reflect.getMetadata('design:paramtypes', f.cls) as unknown[] | undefined)?.length ?? 0;
  const deps = Array.from({ length: count }, (_, i) =>
    queueAt.has(i)
      ? { upsertJobScheduler: async (id: string) => void scheduled.push(id), add: async () => ({}) }
      : anything(),
  );
  return new f.cls(...deps);
}

describe('background jobs', () => {
  const processors = load();

  it('finds the processors of the application', () => {
    expect(processors.length).toBeGreaterThanOrEqual(4);
    expect(processors.map((p) => p.queue)).toEqual(
      expect.arrayContaining(['system', 'media', 'notifications', 'maintenance', 'analytics']),
    );
  });

  it('has exactly one processor per queue, and only on queues that exist', () => {
    const seen = new Map<string, string>();
    for (const p of processors) {
      expect(QUEUE_NAMES as readonly string[]).toContain(p.queue);
      expect([p.queue, seen.get(p.queue)]).toEqual([p.queue, undefined]);
      seen.set(p.queue, p.file);
    }
  });

  it('handles every repeating job it schedules, and refuses unknown jobs loudly', async () => {
    for (const p of processors) {
      const scheduled: string[] = [];
      const instance = build(p, scheduled);
      await instance.onApplicationBootstrap?.();
      for (const name of scheduled) {
        await expect(instance.process({ name, data: {} })).resolves.not.toThrow();
      }
      await expect(instance.process({ name: '__unknown__', data: {} })).rejects.toThrow(/unknown/i);
    }
  });

  it('schedules each repeating job name once across the platform', async () => {
    const all: string[] = [];
    for (const p of processors) await build(p, all).onApplicationBootstrap?.();
    expect(new Set(all).size).toBe(all.length);
    // The jobs the Appendix lists for Phase 1 that exist today.
    expect(all).toEqual(
      expect.arrayContaining([
        'community-reconcile-counters',
        'community-moderation-backlog',
        'opportunities-expire',
        'opportunities-deadline-reminders',
        'opportunities-link-health',
        'analytics-aggregate',
        'analytics-purge',
        'suspensions-expire',
      ]),
    );
  });

  it('retries with exponential backoff and keeps failed jobs for the admin failed-jobs view', () => {
    expect(DEFAULT_JOB_OPTIONS.attempts).toBeGreaterThanOrEqual(3);
    expect(DEFAULT_JOB_OPTIONS.backoff.type).toBe('exponential');
    expect(DEFAULT_JOB_OPTIONS.backoff.delay).toBeGreaterThan(0);
    // The failed set is the dead-letter store: kept for at least a week, readable and retryable by admins.
    expect(DEFAULT_JOB_OPTIONS.removeOnFail.age).toBeGreaterThanOrEqual(7 * 24 * 3600);
  });

  it('reports queues without a processor so an unfinished milestone cannot hide', () => {
    const handled = new Set(processors.map((p) => p.queue));
    const idle = (QUEUE_NAMES as readonly string[]).filter((q) => !handled.has(q));
    // `payments` belongs to Phase 2 (P2-M1). Anything else appearing here is a queue nobody consumes.
    expect(idle.filter((q) => q !== 'payments')).toEqual([]);
  });
});
