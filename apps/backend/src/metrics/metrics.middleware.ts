import { Injectable, type NestMiddleware } from '@nestjs/common';
import type { NextFunction, Request, Response } from 'express';
import { MetricsService } from './metrics.service';

/**
 * Records every request's latency by route PATTERN (never the raw URL, which can hold ids and personal data).
 * A middleware, not an interceptor, so requests refused by a guard (401, 403, 429) are counted too.
 */
@Injectable()
export class MetricsMiddleware implements NestMiddleware {
  constructor(private readonly metrics: MetricsService) {}

  use(req: Request, res: Response, next: NextFunction): void {
    const started = process.hrtime.bigint();
    res.on('finish', () => {
      const seconds = Number(process.hrtime.bigint() - started) / 1e9;
      const route = (req.route as { path?: string } | undefined)?.path ?? 'unmatched';
      this.metrics.observeRequest(req.method, route, res.statusCode, seconds);
    });
    next();
  }
}
