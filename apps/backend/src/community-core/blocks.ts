import { Prisma } from '@prisma/client';

/**
 * SQL: no block in either direction between the viewer and the member that `memberExpr` names.
 * Blocking hides content both ways (Master Prompt P1-M8), so every reader of someone else's content uses this.
 */
export const notBlockedSql = (viewerId: string, memberExpr: Prisma.Sql): Prisma.Sql =>
  Prisma.sql`NOT EXISTS (SELECT 1 FROM blocks b
    WHERE (b."blockerId" = ${viewerId}::uuid AND b."blockedId" = ${memberExpr})
       OR (b."blockerId" = ${memberExpr} AND b."blockedId" = ${viewerId}::uuid))`;

/** Prisma `where` fragment for a user relation: nobody the viewer blocked and nobody who blocked the viewer. */
export const notBlockedWhere = (viewerId: string): Prisma.UserWhereInput => ({
  blocksMade: { none: { blockedId: viewerId } },
  blocksReceived: { none: { blockerId: viewerId } },
});
