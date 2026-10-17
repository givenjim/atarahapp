import { Inject, Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { Redis } from 'ioredis';
import { AuditService } from '../audit/audit.service';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';
import { PrismaService } from '../prisma/prisma.service';
import { REDIS } from '../redis/redis.module';
import { FLAG_REGISTRY } from './flags.registry';

const CACHE_TTL_SECONDS = 30;
const cacheKey = (key: string) => `ff:${key}`;

export interface FlagView {
  key: string;
  description: string;
  enabled: boolean;
  phase: number;
}

/**
 * Feature flags backed by the `feature_flags` table and cached in Redis for 30 s.
 * Unknown flags are always off. Redis being down degrades to direct database reads.
 */
@Injectable()
export class FeatureFlagService implements OnModuleInit {
  private readonly logger = new Logger(FeatureFlagService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly config: AppConfigService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async onModuleInit(): Promise<void> {
    if (this.config.skipConnect) return;
    try {
      await this.syncRegistry();
    } catch (err) {
      this.logger.warn(`Could not sync feature flags: ${(err as Error).message}`);
    }
  }

  /** Create any registry flag that does not exist yet. Existing rows are never modified. */
  async syncRegistry(): Promise<number> {
    const result = await this.prisma.featureFlag.createMany({
      data: FLAG_REGISTRY.map((f) => ({
        key: f.key,
        description: f.description,
        phase: f.phase,
        enabled: f.defaultEnabled,
      })),
      skipDuplicates: true,
    });
    return result.count;
  }

  async isEnabled(key: string): Promise<boolean> {
    try {
      const cached = await this.redis.get(cacheKey(key));
      if (cached !== null) return cached === '1';
    } catch {
      // fall through to the database
    }
    const row = await this.prisma.featureFlag.findUnique({
      where: { key },
      select: { enabled: true },
    });
    const enabled = row?.enabled ?? false;
    try {
      await this.redis.set(cacheKey(key), enabled ? '1' : '0', 'EX', CACHE_TTL_SECONDS);
    } catch {
      // cache is best-effort
    }
    return enabled;
  }

  async list(): Promise<FlagView[]> {
    return this.prisma.featureFlag.findMany({
      orderBy: [{ phase: 'asc' }, { key: 'asc' }],
      select: { key: true, description: true, enabled: true, phase: true },
    });
  }

  async set(
    key: string,
    enabled: boolean,
    actor: { id: string; ip?: string; requestId?: string },
  ): Promise<FlagView> {
    const existing = await this.prisma.featureFlag.findUnique({ where: { key } });
    if (!existing) throw ApiException.notFound('That feature flag does not exist.');

    const updated = await this.prisma.transaction(async (tx) => {
      const row = await tx.featureFlag.update({
        where: { key },
        data: { enabled, updatedById: actor.id },
        select: { key: true, description: true, enabled: true, phase: true },
      });
      await this.audit.record(
        {
          actorType: 'ADMIN',
          actorId: actor.id,
          action: 'feature_flag.set',
          entityType: 'FeatureFlag',
          entityId: key,
          before: { enabled: existing.enabled },
          after: { enabled },
          ip: actor.ip,
          requestId: actor.requestId,
        },
        tx,
      );
      return row;
    });
    await this.redis.del(cacheKey(key)).catch(() => undefined);
    return updated;
  }
}
