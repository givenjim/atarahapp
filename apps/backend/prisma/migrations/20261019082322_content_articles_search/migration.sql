-- CreateEnum
CREATE TYPE "ArticleStatus" AS ENUM ('DRAFT', 'IN_REVIEW', 'PUBLISHED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "SavedItemType" AS ENUM ('ARTICLE');

-- CreateTable
CREATE TABLE "articles" (
    "id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "body" JSONB NOT NULL DEFAULT '[]',
    "heroMediaId" UUID,
    "authorName" TEXT NOT NULL,
    "source" "ContentSource" NOT NULL DEFAULT 'ATARAH',
    "sourceLabel" TEXT,
    "readMinutes" INTEGER NOT NULL DEFAULT 1,
    "status" "ArticleStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMP(3),
    "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "createdById" UUID NOT NULL,
    "updatedById" UUID,
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "articles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "saved_items" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "type" "SavedItemType" NOT NULL,
    "targetId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "saved_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recent_searches" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "query" TEXT NOT NULL,
    "normalized" TEXT NOT NULL,
    "usedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "recent_searches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "home_config" (
    "id" TEXT NOT NULL DEFAULT 'home',
    "featuredArticleId" UUID,
    "updatedById" UUID,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "home_config_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "creative_verifications" (
    "profileId" UUID NOT NULL,
    "status" "VerificationStatus" NOT NULL DEFAULT 'NOT_SUBMITTED',
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "creative_verifications_pkey" PRIMARY KEY ("profileId")
);

-- CreateIndex
CREATE UNIQUE INDEX "articles_slug_key" ON "articles"("slug");

-- CreateIndex
CREATE INDEX "articles_status_publishedAt_idx" ON "articles"("status", "publishedAt" DESC);

-- CreateIndex
CREATE INDEX "saved_items_userId_type_createdAt_idx" ON "saved_items"("userId", "type", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "saved_items_userId_type_targetId_key" ON "saved_items"("userId", "type", "targetId");

-- CreateIndex
CREATE INDEX "recent_searches_userId_usedAt_idx" ON "recent_searches"("userId", "usedAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "recent_searches_userId_normalized_key" ON "recent_searches"("userId", "normalized");

-- CreateIndex
CREATE INDEX "creative_verifications_status_idx" ON "creative_verifications"("status");

-- AddForeignKey
ALTER TABLE "articles" ADD CONSTRAINT "articles_heroMediaId_fkey" FOREIGN KEY ("heroMediaId") REFERENCES "media_assets"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "articles" ADD CONSTRAINT "articles_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "articles" ADD CONSTRAINT "articles_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_items" ADD CONSTRAINT "saved_items_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recent_searches" ADD CONSTRAINT "recent_searches_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "home_config" ADD CONSTRAINT "home_config_featuredArticleId_fkey" FOREIGN KEY ("featuredArticleId") REFERENCES "articles"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "home_config" ADD CONSTRAINT "home_config_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_verifications" ADD CONSTRAINT "creative_verifications_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ---- Hand-written additions -------------------------------------------------------------------------------------

-- Typo-tolerant search (P1-M5). pg_trgm ships with PostgreSQL.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX "creative_profiles_display_name_trgm" ON "creative_profiles" USING GIN ("displayName" gin_trgm_ops);
CREATE INDEX "creative_profiles_headline_trgm" ON "creative_profiles" USING GIN ("headline" gin_trgm_ops);
CREATE INDEX "articles_title_trgm" ON "articles" USING GIN ("title" gin_trgm_ops);
CREATE INDEX "skills_name_trgm" ON "skills" USING GIN ("name" gin_trgm_ops);

ALTER TABLE "articles"
  ADD CONSTRAINT "articles_read_minutes_positive" CHECK ("readMinutes" >= 1),
  ADD CONSTRAINT "articles_slug_format" CHECK ("slug" ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  ADD CONSTRAINT "articles_source_label" CHECK ("source" = 'ATARAH' OR "status" IN ('DRAFT', 'IN_REVIEW', 'ARCHIVED') OR "sourceLabel" IS NOT NULL),
  ADD CONSTRAINT "articles_published_has_date" CHECK ("status" NOT IN ('PUBLISHED') OR "publishedAt" IS NOT NULL);

ALTER TABLE "home_config" ADD CONSTRAINT "home_config_single_row" CHECK ("id" = 'home');
