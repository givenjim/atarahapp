-- CreateEnum
CREATE TYPE "ProfileSection" AS ENUM ('BIO', 'LOCATION', 'PORTFOLIO', 'SKILLS', 'EXPERIENCE', 'SERVICES', 'LINKS', 'CONTACT');

-- AlterTable
ALTER TABLE "creative_profiles" ADD COLUMN     "acceptConnections" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "contactForConnections" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "contactShowEmail" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "contactShowPhone" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "openToCommissions" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "profile_section_visibility" (
    "profileId" UUID NOT NULL,
    "section" "ProfileSection" NOT NULL,
    "visibility" "Visibility" NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "profile_section_visibility_pkey" PRIMARY KEY ("profileId","section")
);

-- CreateTable
CREATE TABLE "profile_links" (
    "id" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "label" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "profile_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "connections" (
    "id" UUID NOT NULL,
    "requesterId" UUID NOT NULL,
    "addresseeId" UUID NOT NULL,
    "status" "ConnectionStatus" NOT NULL DEFAULT 'PENDING',
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "connections_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "profile_links_profileId_sortOrder_idx" ON "profile_links"("profileId", "sortOrder");

-- CreateIndex
CREATE INDEX "connections_addresseeId_status_idx" ON "connections"("addresseeId", "status");

-- CreateIndex
CREATE INDEX "connections_requesterId_status_idx" ON "connections"("requesterId", "status");

-- AddForeignKey
ALTER TABLE "profile_section_visibility" ADD CONSTRAINT "profile_section_visibility_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "profile_links" ADD CONSTRAINT "profile_links_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "connections" ADD CONSTRAINT "connections_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "connections" ADD CONSTRAINT "connections_addresseeId_fkey" FOREIGN KEY ("addresseeId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- One connection row per unordered pair of members, and never a member with themselves.
CREATE UNIQUE INDEX "connections_pair_unique" ON "connections" (LEAST("requesterId", "addresseeId"), GREATEST("requesterId", "addresseeId"));
ALTER TABLE "connections" ADD CONSTRAINT "connections_not_self" CHECK ("requesterId" <> "addresseeId");

-- Links are web addresses.
ALTER TABLE "profile_links" ADD CONSTRAINT "profile_links_https" CHECK ("url" ~* '^https://');
