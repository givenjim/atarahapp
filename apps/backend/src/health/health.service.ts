import { Inject, Injectable } from '@nestjs/common';
import { Redis } from 'ioredis';
import { ApiException } from '../common/api.exception';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';
import { StorageService } from '../storage/storage.service';

export type CheckName = 'postgres' | 'redis' | 'storage';
export type CheckResult = 'up' | 'down';

const CHECK_TIMEOUT_MS = 2_000;

function withTimeout<T>(p: Promise<T>, ms: number): Promise<T> {
  return Promise.race([
    p,
    new Promise<never>((_, reject) => setTimeout(() => reject(new Error('timeout')), ms).unref()),
  ]);
}

@Injectable()
export class HealthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  live(): { status: 'ok' } {
    return { status: 'ok' };
  }

  async ready(): Promise<{ status: 'ready'; checks: Record<CheckName, CheckResult> }> {
    const probes: Record<CheckName, () => Promise<unknown>> = {
      postgres: () => this.prisma.$queryRaw`SELECT 1`,
      redis: async () => {
        if ((await this.redis.ping()) !== 'PONG') throw new Error('bad ping');
      },
      storage: () => this.storage.check(),
    };

    const entries = await Promise.all(
      (Object.keys(probes) as CheckName[]).map(async (name) => {
        try {
          await withTimeout(probes[name](), CHECK_TIMEOUT_MS);
          return [name, 'up'] as const;
        } catch {
          return [name, 'down'] as const;
        }
      }),
    );
    const checks = Object.fromEntries(entries) as Record<CheckName, CheckResult>;

    if (Object.values(checks).includes('down')) {
      throw ApiException.external('Atarah is not ready to serve requests.', { checks });
    }
    return { status: 'ready', checks };
  }
}
