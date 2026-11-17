import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

type TableKind = 'ARTICLE' | 'POST' | 'LEARNING' | 'CREATIVE';

/** Nightly housekeeping of `saved_items`; only needs the database, so the worker can run it on its own. */
@Injectable()
export class SavedCleanupService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Deletes saved rows whose target no longer exists at all. Something merely hidden or unpublished is kept (it may
   * come back) and is filtered out when the list is read.
   */
  async cleanup(): Promise<number> {
    const sweep = (table: string, type: TableKind) =>
      this.prisma.$executeRaw(
        Prisma.sql`DELETE FROM saved_items s WHERE s.type::text = ${type}
          AND NOT EXISTS (SELECT 1 FROM ${Prisma.raw(table)} t WHERE t.id = s."targetId")`,
      );
    const counts = await Promise.all([
      sweep('articles', 'ARTICLE'),
      sweep('posts', 'POST'),
      sweep('learning_contents', 'LEARNING'),
      sweep('creative_profiles', 'CREATIVE'),
    ]);
    return counts.reduce((a, b) => a + b, 0);
  }
}
