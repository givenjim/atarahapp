-- CreateEnum
CREATE TYPE "OnboardingStep" AS ENUM ('INTRO', 'DISCIPLINE', 'SPECIALISATION', 'SKILLS', 'LOCATION', 'BASICS', 'PHOTO', 'DONE');

-- CreateEnum
CREATE TYPE "SuggestionStatus" AS ENUM ('PENDING', 'APPROVED', 'MERGED', 'REJECTED');

-- CreateTable
CREATE TABLE "creative_profiles" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "handle" CITEXT,
    "displayName" TEXT NOT NULL,
    "headline" TEXT,
    "bio" TEXT,
    "primaryDisciplineId" UUID,
    "countryId" UUID,
    "countyId" UUID,
    "town" TEXT,
    "locationVisibility" "Visibility" NOT NULL DEFAULT 'MEMBERS',
    "avatarMediaId" UUID,
    "onboardingStep" "OnboardingStep" NOT NULL DEFAULT 'INTRO',
    "onboardingCompletedAt" TIMESTAMP(3),
    "completionPercent" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "creative_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "creative_disciplines" (
    "profileId" UUID NOT NULL,
    "disciplineId" UUID NOT NULL,
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "creative_disciplines_pkey" PRIMARY KEY ("profileId","disciplineId")
);

-- CreateTable
CREATE TABLE "creative_specialisations" (
    "profileId" UUID NOT NULL,
    "specialisationId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "creative_specialisations_pkey" PRIMARY KEY ("profileId","specialisationId")
);

-- CreateTable
CREATE TABLE "creative_skills" (
    "profileId" UUID NOT NULL,
    "skillId" UUID NOT NULL,
    "level" "SkillLevel",
    "source" "SkillSource" NOT NULL DEFAULT 'SELF_DECLARED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "creative_skills_pkey" PRIMARY KEY ("profileId","skillId")
);

-- CreateTable
CREATE TABLE "creative_interests" (
    "profileId" UUID NOT NULL,
    "interestId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "creative_interests_pkey" PRIMARY KEY ("profileId","interestId")
);

-- CreateTable
CREATE TABLE "creative_development_areas" (
    "profileId" UUID NOT NULL,
    "developmentAreaId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "creative_development_areas_pkey" PRIMARY KEY ("profileId","developmentAreaId")
);

-- CreateTable
CREATE TABLE "specialisation_suggestions" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "disciplineId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "status" "SuggestionStatus" NOT NULL DEFAULT 'PENDING',
    "specialisationId" UUID,
    "resolvedById" UUID,
    "resolutionNote" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "specialisation_suggestions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "creative_passports" (
    "id" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "passportNumber" TEXT NOT NULL,
    "countyCode" CHAR(3) NOT NULL,
    "sequence" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "creative_passports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "passport_counters" (
    "countyCode" CHAR(3) NOT NULL,
    "lastValue" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "passport_counters_pkey" PRIMARY KEY ("countyCode")
);

-- CreateIndex
CREATE UNIQUE INDEX "creative_profiles_userId_key" ON "creative_profiles"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "creative_profiles_handle_key" ON "creative_profiles"("handle");

-- CreateIndex
CREATE INDEX "creative_profiles_primaryDisciplineId_idx" ON "creative_profiles"("primaryDisciplineId");

-- CreateIndex
CREATE INDEX "creative_profiles_countyId_idx" ON "creative_profiles"("countyId");

-- CreateIndex
CREATE INDEX "creative_disciplines_disciplineId_idx" ON "creative_disciplines"("disciplineId");

-- CreateIndex
CREATE INDEX "creative_specialisations_specialisationId_idx" ON "creative_specialisations"("specialisationId");

-- CreateIndex
CREATE INDEX "creative_skills_skillId_idx" ON "creative_skills"("skillId");

-- CreateIndex
CREATE INDEX "creative_interests_interestId_idx" ON "creative_interests"("interestId");

-- CreateIndex
CREATE INDEX "creative_development_areas_developmentAreaId_idx" ON "creative_development_areas"("developmentAreaId");

-- CreateIndex
CREATE INDEX "specialisation_suggestions_status_createdAt_idx" ON "specialisation_suggestions"("status", "createdAt");

-- CreateIndex
CREATE INDEX "specialisation_suggestions_userId_status_idx" ON "specialisation_suggestions"("userId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "creative_passports_profileId_key" ON "creative_passports"("profileId");

-- CreateIndex
CREATE UNIQUE INDEX "creative_passports_passportNumber_key" ON "creative_passports"("passportNumber");

-- CreateIndex
CREATE UNIQUE INDEX "creative_passports_countyCode_sequence_key" ON "creative_passports"("countyCode", "sequence");

-- AddForeignKey
ALTER TABLE "creative_profiles" ADD CONSTRAINT "creative_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_profiles" ADD CONSTRAINT "creative_profiles_primaryDisciplineId_fkey" FOREIGN KEY ("primaryDisciplineId") REFERENCES "disciplines"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_profiles" ADD CONSTRAINT "creative_profiles_countryId_fkey" FOREIGN KEY ("countryId") REFERENCES "countries"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_profiles" ADD CONSTRAINT "creative_profiles_countyId_fkey" FOREIGN KEY ("countyId") REFERENCES "counties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_profiles" ADD CONSTRAINT "creative_profiles_avatarMediaId_fkey" FOREIGN KEY ("avatarMediaId") REFERENCES "media_assets"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_disciplines" ADD CONSTRAINT "creative_disciplines_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_disciplines" ADD CONSTRAINT "creative_disciplines_disciplineId_fkey" FOREIGN KEY ("disciplineId") REFERENCES "disciplines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_specialisations" ADD CONSTRAINT "creative_specialisations_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_specialisations" ADD CONSTRAINT "creative_specialisations_specialisationId_fkey" FOREIGN KEY ("specialisationId") REFERENCES "specialisations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_skills" ADD CONSTRAINT "creative_skills_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_skills" ADD CONSTRAINT "creative_skills_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES "skills"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_interests" ADD CONSTRAINT "creative_interests_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_interests" ADD CONSTRAINT "creative_interests_interestId_fkey" FOREIGN KEY ("interestId") REFERENCES "interests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_development_areas" ADD CONSTRAINT "creative_development_areas_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_development_areas" ADD CONSTRAINT "creative_development_areas_developmentAreaId_fkey" FOREIGN KEY ("developmentAreaId") REFERENCES "development_areas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "specialisation_suggestions" ADD CONSTRAINT "specialisation_suggestions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "specialisation_suggestions" ADD CONSTRAINT "specialisation_suggestions_resolvedById_fkey" FOREIGN KEY ("resolvedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "specialisation_suggestions" ADD CONSTRAINT "specialisation_suggestions_disciplineId_fkey" FOREIGN KEY ("disciplineId") REFERENCES "disciplines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "specialisation_suggestions" ADD CONSTRAINT "specialisation_suggestions_specialisationId_fkey" FOREIGN KEY ("specialisationId") REFERENCES "specialisations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "creative_passports" ADD CONSTRAINT "creative_passports_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;
