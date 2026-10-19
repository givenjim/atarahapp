-- CreateEnum
CREATE TYPE "ProjectCategory" AS ENUM ('PROJECT', 'MEDIA', 'PUBLICATION', 'PERFORMANCE');

-- CreateEnum
CREATE TYPE "CollaboratorStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REMOVED');

-- CreateEnum
CREATE TYPE "AchievementType" AS ENUM ('AWARD', 'CERTIFICATE', 'FEATURE', 'SELECTION', 'NOMINATION');

-- CreateEnum
CREATE TYPE "AchievementSource" AS ENUM ('MANUAL', 'SYSTEM');

-- CreateTable
CREATE TABLE "projects" (
    "id" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "role" TEXT,
    "client" TEXT,
    "projectDate" DATE,
    "category" "ProjectCategory" NOT NULL DEFAULT 'PROJECT',
    "disciplineId" UUID,
    "description" TEXT,
    "outcome" TEXT,
    "featured" BOOLEAN NOT NULL DEFAULT false,
    "status" "PublicationStatus" NOT NULL DEFAULT 'DRAFT',
    "visibility" "Visibility" NOT NULL DEFAULT 'PUBLIC',
    "publishedAt" TIMESTAMP(3),
    "hiddenAt" TIMESTAMP(3),
    "hiddenReason" TEXT,
    "hiddenById" UUID,
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_media" (
    "projectId" UUID NOT NULL,
    "mediaId" UUID NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "caption" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "project_media_pkey" PRIMARY KEY ("projectId","mediaId")
);

-- CreateTable
CREATE TABLE "project_skills" (
    "projectId" UUID NOT NULL,
    "skillId" UUID NOT NULL,

    CONSTRAINT "project_skills_pkey" PRIMARY KEY ("projectId","skillId")
);

-- CreateTable
CREATE TABLE "project_links" (
    "id" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "label" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "project_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_collaborators" (
    "id" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "userId" UUID,
    "name" TEXT,
    "role" TEXT,
    "status" "CollaboratorStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "project_collaborators_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "experiences" (
    "id" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "organisation" TEXT NOT NULL,
    "location" TEXT,
    "startDate" DATE NOT NULL,
    "endDate" DATE,
    "current" BOOLEAN NOT NULL DEFAULT false,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "experiences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "achievements" (
    "id" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "type" "AchievementType" NOT NULL,
    "title" TEXT NOT NULL,
    "issuer" TEXT,
    "achievedOn" DATE,
    "description" TEXT,
    "url" TEXT,
    "source" "AchievementSource" NOT NULL DEFAULT 'MANUAL',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "achievements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "profile_services" (
    "id" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "priceType" "PricingType" NOT NULL DEFAULT 'ON_REQUEST',
    "priceMin" INTEGER,
    "priceMax" INTEGER,
    "currency" CHAR(3) NOT NULL DEFAULT 'KES',
    "status" "ProfileServiceStatus" NOT NULL DEFAULT 'PROFILE_ONLY',
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "profile_services_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "projects_profileId_status_deletedAt_idx" ON "projects"("profileId", "status", "deletedAt");

-- CreateIndex
CREATE INDEX "projects_profileId_featured_idx" ON "projects"("profileId", "featured");

-- CreateIndex
CREATE INDEX "project_media_projectId_sortOrder_idx" ON "project_media"("projectId", "sortOrder");

-- CreateIndex
CREATE INDEX "project_media_mediaId_idx" ON "project_media"("mediaId");

-- CreateIndex
CREATE INDEX "project_skills_skillId_idx" ON "project_skills"("skillId");

-- CreateIndex
CREATE INDEX "project_links_projectId_sortOrder_idx" ON "project_links"("projectId", "sortOrder");

-- CreateIndex
CREATE INDEX "project_collaborators_projectId_idx" ON "project_collaborators"("projectId");

-- CreateIndex
CREATE INDEX "project_collaborators_userId_status_idx" ON "project_collaborators"("userId", "status");

-- CreateIndex
CREATE INDEX "experiences_profileId_startDate_idx" ON "experiences"("profileId", "startDate");

-- CreateIndex
CREATE INDEX "achievements_profileId_achievedOn_idx" ON "achievements"("profileId", "achievedOn");

-- CreateIndex
CREATE INDEX "profile_services_profileId_sortOrder_idx" ON "profile_services"("profileId", "sortOrder");

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_disciplineId_fkey" FOREIGN KEY ("disciplineId") REFERENCES "disciplines"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_media" ADD CONSTRAINT "project_media_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_media" ADD CONSTRAINT "project_media_mediaId_fkey" FOREIGN KEY ("mediaId") REFERENCES "media_assets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_skills" ADD CONSTRAINT "project_skills_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_skills" ADD CONSTRAINT "project_skills_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES "skills"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_links" ADD CONSTRAINT "project_links_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_collaborators" ADD CONSTRAINT "project_collaborators_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_collaborators" ADD CONSTRAINT "project_collaborators_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "experiences" ADD CONSTRAINT "experiences_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "achievements" ADD CONSTRAINT "achievements_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profile_services" ADD CONSTRAINT "profile_services_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Checks the application also enforces; the database refuses what the API should never write.
ALTER TABLE "project_links" ADD CONSTRAINT "project_links_https" CHECK ("url" ~* '^https://');
ALTER TABLE "achievements" ADD CONSTRAINT "achievements_url_https" CHECK ("url" IS NULL OR "url" ~* '^https://');
ALTER TABLE "experiences" ADD CONSTRAINT "experiences_dates" CHECK ("endDate" IS NULL OR "endDate" >= "startDate");
ALTER TABLE "experiences" ADD CONSTRAINT "experiences_current_open" CHECK (NOT "current" OR "endDate" IS NULL);
ALTER TABLE "profile_services" ADD CONSTRAINT "profile_services_price" CHECK (
  ("priceMin" IS NULL OR "priceMin" >= 0) AND ("priceMax" IS NULL OR "priceMax" >= COALESCE("priceMin", 0))
);
ALTER TABLE "project_collaborators" ADD CONSTRAINT "project_collaborators_who" CHECK ("userId" IS NOT NULL OR "name" IS NOT NULL);
-- A member is tagged on a project once.
CREATE UNIQUE INDEX "project_collaborators_member_unique" ON "project_collaborators" ("projectId", "userId") WHERE "userId" IS NOT NULL;
