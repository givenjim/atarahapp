-- P1-M12 hardening: indexes found by the volume-seed performance run (docs/PERFORMANCE.md). Hand-written; additive
-- only (no table or column changes). Partial indexes cannot be expressed in the Prisma schema, so they live here.

-- The community feed walks visible posts newest first (windowed ranking, see FeedService). This partial index lets
-- the planner read them in order and stop after the first few rows instead of sorting every visible post.
CREATE INDEX IF NOT EXISTS "posts_visible_created_idx" ON "posts" ("createdAt" DESC, "id" DESC)
  WHERE "status" = 'VISIBLE' AND "deletedAt" IS NULL;

-- Post search matches the body with ILIKE as well as full text (typos and fragments): a trigram index makes that
-- indexable, so the OR of the two uses a bitmap of both indexes instead of reading every visible post.
CREATE INDEX IF NOT EXISTS "posts_body_trgm" ON "posts" USING GIN ("body" gin_trgm_ops);
