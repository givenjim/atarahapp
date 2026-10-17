import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { ThrottlerStorageRedisService } from '@nest-lab/throttler-storage-redis';
import { Redis } from 'ioredis';
import { AppConfigService } from '../config/app-config.service';
import { REDIS } from '../redis/redis.module';

/** Default API-wide limit: 120 requests per minute per client. Sensitive routes tighten it with @Throttle. */
export const DEFAULT_THROTTLE = { ttl: 60_000, limit: 120 } as const;

/**
 * Redis-backed rate limiting. Imported before AccessModule so the throttler guard runs before
 * authentication: unauthenticated floods are limited too.
 */
@Module({
  imports: [
    ThrottlerModule.forRootAsync({
      inject: [REDIS, AppConfigService],
      useFactory: (redis: Redis, config: AppConfigService) => ({
        throttlers: [{ name: 'default', ...DEFAULT_THROTTLE }],
        storage: new ThrottlerStorageRedisService(redis),
        // Integration tests make many calls from one address; they opt in to throttling per request with
        // `X-Test-Throttle: on`, so rate limiting itself is still tested for real.
        skipIf: (ctx) =>
          config.environment === 'test' &&
          ctx.switchToHttp().getRequest<{ headers: Record<string, string> }>().headers[
            'x-test-throttle'
          ] !== 'on',
      }),
    }),
  ],
  providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class RateLimitModule {}
