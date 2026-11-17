-- P1-M6 backend gap-fill (section 7.9): full-text search vectors with GIN indexes on the searchable entities that
-- exist today. The creative vector holds name, handle and headline only: the bio has its own visibility setting
-- and is not searchable (DEC-055). Stored generated columns, so they can never go stale. Later milestones add their own.
ALTER TABLE "creative_profiles" ADD COLUMN "searchVector" tsvector GENERATED ALWAYS AS (
  setweight(to_tsvector('simple', coalesce("displayName", '')), 'A') ||
  setweight(to_tsvector('simple', coalesce("handle"::text, '')), 'A') ||
  setweight(to_tsvector('simple', coalesce("headline", '')), 'B')
) STORED;
CREATE INDEX "creative_profiles_search_vector_idx" ON "creative_profiles" USING GIN ("searchVector");

ALTER TABLE "articles" ADD COLUMN "searchVector" tsvector GENERATED ALWAYS AS (
  setweight(to_tsvector('simple', coalesce("title", '')), 'A') ||
  setweight(to_tsvector('simple', coalesce("summary", '')), 'B') ||
  setweight(to_tsvector('simple', coalesce("authorName", '')), 'C')
) STORED;
CREATE INDEX "articles_search_vector_idx" ON "articles" USING GIN ("searchVector");
