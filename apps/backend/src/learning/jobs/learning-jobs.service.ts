import { Injectable } from '@nestjs/common';
import { SafeFetcher } from '../../community/jobs/safe-fetch';
import { DAY_MS } from '../../opportunities/opportunity-logic';
import { PrismaService } from '../../prisma/prisma.service';

/** The learning module's job on the `maintenance` queue. */
export const LEARNING_LINKS_JOB = 'learning-embed-availability';

const BATCH = 100;
const RECHECK_DAYS = 6;
/** Robot-blocking answers say nothing about whether the page is alive. */
const NOT_A_VERDICT = new Set([401, 403, 429]);

/** Weekly: checks the external and embedded addresses of published Skill Labs and flags the broken ones (never unpublishes). */
@Injectable()
export class LearningJobsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly fetcher: SafeFetcher,
  ) {}

  async checkLinks(now = new Date()): Promise<{ checked: number; broken: number }> {
    const cutoff = new Date(now.getTime() - RECHECK_DAYS * DAY_MS);
    const due = await this.prisma.learningContent.findMany({
      where: {
        status: 'PUBLISHED',
        delivery: { in: ['EXTERNAL_LINK', 'EMBEDDED'] },
        OR: [{ lastCheckedAt: null }, { lastCheckedAt: { lt: cutoff } }],
      },
      select: { id: true, delivery: true, externalUrl: true, embedUrl: true },
      orderBy: [{ lastCheckedAt: { sort: 'asc', nulls: 'first' } }, { id: 'asc' }],
      take: BATCH,
    });
    let broken = 0;
    for (const c of due) {
      const url = c.delivery === 'EXTERNAL_LINK' ? c.externalUrl : c.embedUrl;
      let bad = false;
      if (url) {
        try {
          const res = await this.fetcher.probe(url);
          bad = res.status >= 400 && !NOT_A_VERDICT.has(res.status);
        } catch {
          bad = true;
        }
      }
      if (bad) broken += 1;
      await this.prisma.learningContent.update({
        where: { id: c.id },
        data: { linkStatus: bad ? 'BROKEN' : 'OK', lastCheckedAt: now },
      });
    }
    return { checked: due.length, broken };
  }
}
