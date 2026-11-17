import { timingSafeEqual } from 'node:crypto';
import { Controller, Get, Headers, Res } from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import { SkipThrottle } from '@nestjs/throttler';
import type { Response } from 'express';
import { Public } from '../access/decorators';
import { ApiException } from '../common/api.exception';
import { AppConfigService } from '../config/app-config.service';
import { MetricsService } from './metrics.service';

/**
 * `GET /metrics` for the monitoring system. Internal: outside `/api/v1`, excluded from OpenAPI, and protected by a
 * bearer token (`ATARAH_METRICS_TOKEN`, required in staging and production). In dev and test, with no token set,
 * it is open on localhost only.
 */
@ApiExcludeController()
@Public()
@SkipThrottle()
@Controller('metrics')
export class MetricsController {
  constructor(
    private readonly metrics: MetricsService,
    private readonly config: AppConfigService,
  ) {}

  @Get()
  async scrape(
    @Res() res: Response,
    @Headers('authorization') authorization?: string,
  ): Promise<void> {
    const token = this.config.metricsToken;
    if (token) {
      const given = Buffer.from((authorization ?? '').replace(/^Bearer\s+/i, ''));
      const want = Buffer.from(token);
      if (given.length !== want.length || !timingSafeEqual(given, want)) {
        throw ApiException.unauthenticated();
      }
    } else if (this.config.isDeployed) {
      throw ApiException.forbidden();
    }
    // Raw Prometheus text, not the JSON response envelope.
    res
      .set('Cache-Control', 'no-store')
      .type('text/plain; version=0.0.4; charset=utf-8')
      .send(await this.metrics.render());
  }
}
