import { Injectable } from '@nestjs/common';
import { collectDefaultMetrics, Gauge, Histogram, Registry } from 'prom-client';
import { QueueAdminService } from '../queues/queue-admin.service';
import { QUEUE_NAMES } from '../queues/queues.constants';

/**
 * Prometheus-style metrics (Master Prompt 5.1 Observability): request latency, queue depth and job failures,
 * plus Node process metrics. Scraped from `GET /metrics` (internal; see MetricsController).
 */
@Injectable()
export class MetricsService {
  readonly registry = new Registry();
  private readonly httpDuration = new Histogram({
    name: 'atarah_http_request_duration_seconds',
    help: 'HTTP request latency by method, route pattern and status class',
    labelNames: ['method', 'route', 'status'] as const,
    buckets: [0.01, 0.025, 0.05, 0.1, 0.2, 0.3, 0.5, 0.75, 1, 2, 5],
    registers: [this.registry],
  });
  private readonly queueJobs = new Gauge({
    name: 'atarah_queue_jobs',
    help: 'Jobs per queue and state (waiting, active, delayed, failed, completed)',
    labelNames: ['queue', 'state'] as const,
    registers: [this.registry],
  });

  constructor(private readonly queues: QueueAdminService) {
    collectDefaultMetrics({ register: this.registry, prefix: 'atarah_' });
  }

  observeRequest(method: string, route: string, status: number, seconds: number): void {
    this.httpDuration.observe({ method, route, status: `${Math.floor(status / 100)}xx` }, seconds);
  }

  async render(): Promise<string> {
    await Promise.all(
      QUEUE_NAMES.map(async (name) => {
        const counts = await this.queues.counts(name).catch(() => null);
        if (!counts) return;
        for (const [state, n] of Object.entries(counts))
          this.queueJobs.set({ queue: name, state }, n);
      }),
    );
    return this.registry.metrics();
  }
}
