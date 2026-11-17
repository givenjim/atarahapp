-- P1-M9: opportunities (providers, listings, structured eligibility rules, member tracking, link checks).
-- Hand-written (DEC-061). Columns follow the camelCase convention; tables are snake_case plural. RLS is enabled on
-- every table in this migration and the backend role is granted access (the Supabase client roles get nothing).

-- CreateEnum
CREATE TYPE "OpportunityProviderType" AS ENUM ('GOVERNMENT', 'NGO', 'CORPORATE', 'FESTIVAL', 'STUDIO', 'EDUCATION', 'OTHER');

-- CreateEnum
CREATE TYPE "WorkMode" AS ENUM ('ONSITE', 'REMOTE', 'HYBRID');

-- CreateEnum
CREATE TYPE "LinkStatus" AS ENUM ('UNKNOWN', 'OK', 'BROKEN');

-- CreateEnum
CREATE TYPE "OpportunityRuleType" AS ENUM ('RESIDENCY', 'AGE_RANGE', 'DISCIPLINE_IN', 'SKILL_IN', 'MIN_PROJECTS', 'DOCUMENT', 'CUSTOM_TEXT');

-- CreateTable
CREATE TABLE "opportunity_providers" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "type" "OpportunityProviderType" NOT NULL DEFAULT 'OTHER',
    "logoMediaId" UUID,
    "website" TEXT,
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'NOT_SUBMITTED',
    "ownerUserId" UUID,
    "opportunitiesCount" INTEGER NOT NULL DEFAULT 0,
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "opportunity_providers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "opportunities" (
    "id" UUID NOT NULL,
    "providerId" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "type" "OpportunityType" NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "about" TEXT NOT NULL DEFAULT '',
    "requirements" JSONB NOT NULL DEFAULT '[]',
    "benefits" JSONB NOT NULL DEFAULT '[]',
    "valueMinMinor" BIGINT,
    "valueMaxMinor" BIGINT,
    "valueCurrency" CHAR(3),
    "valueText" TEXT,
    "deadlineAt" TIMESTAMP(3),
    "countryId" UUID,
    "countyId" UUID,
    "workMode" "WorkMode" NOT NULL DEFAULT 'ONSITE',
    "applicationMethod" "ApplicationMethod" NOT NULL DEFAULT 'EXTERNAL_WEBSITE',
    "applicationUrl" TEXT,
    "applicationEmail" TEXT,
    "applicationDomain" TEXT,
    "trust" "OpportunityTrust" NOT NULL DEFAULT 'EXTERNAL_SOURCE',
    "status" "OpportunityStatus" NOT NULL DEFAULT 'DRAFT',
    "featuredUntil" TIMESTAMP(3),
    "isPublic" BOOLEAN NOT NULL DEFAULT false,
    "sourceUrl" TEXT,
    "importedAt" TIMESTAMP(3),
    "lastCheckedAt" TIMESTAMP(3),
    "linkStatus" "LinkStatus" NOT NULL DEFAULT 'UNKNOWN',
    "publishedAt" TIMESTAMP(3),
    "createdById" UUID,
    "searchVector" tsvector GENERATED ALWAYS AS (setweight(to_tsvector('simple', coalesce("title", '')), 'A') || setweight(to_tsvector('simple', coalesce("summary", '')), 'B')) STORED,
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "opportunities_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "opportunities_value_range_check" CHECK ("valueMinMinor" IS NULL OR "valueMaxMinor" IS NULL OR "valueMinMinor" <= "valueMaxMinor"),
    CONSTRAINT "opportunities_value_nonneg_check" CHECK (COALESCE("valueMinMinor", 0) >= 0 AND COALESCE("valueMaxMinor", 0) >= 0),
    CONSTRAINT "opportunities_value_currency_check" CHECK (("valueMinMinor" IS NULL AND "valueMaxMinor" IS NULL) OR "valueCurrency" IS NOT NULL)
);

-- CreateTable
CREATE TABLE "opportunity_disciplines" (
    "opportunityId" UUID NOT NULL,
    "disciplineId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "opportunity_disciplines_pkey" PRIMARY KEY ("opportunityId","disciplineId")
);

-- CreateTable
CREATE TABLE "opportunity_requirement_rules" (
    "id" UUID NOT NULL,
    "opportunityId" UUID NOT NULL,
    "ruleType" "OpportunityRuleType" NOT NULL,
    "params" JSONB NOT NULL DEFAULT '{}',
    "label" TEXT NOT NULL,
    "isBlocking" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "opportunity_requirement_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "opportunity_trackings" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "opportunityId" UUID NOT NULL,
    "status" "OpportunityTrackingStatus" NOT NULL DEFAULT 'SAVED',
    "savedAt" TIMESTAMP(3),
    "appliedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "outcome" "OpportunityOutcome",
    "checklist" JSONB NOT NULL DEFAULT '[]',
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "opportunity_trackings_pkey" PRIMARY KEY ("id"),
    -- An outcome only exists once the application is completed.
    CONSTRAINT "opportunity_trackings_outcome_check" CHECK ("outcome" IS NULL OR "status" = 'COMPLETED')
);

-- CreateTable
CREATE TABLE "external_link_checks" (
    "id" UUID NOT NULL,
    "opportunityId" UUID NOT NULL,
    "url" TEXT NOT NULL,
    "checkedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "httpStatus" INTEGER,
    "result" "LinkStatus" NOT NULL,
    "error" TEXT,

    CONSTRAINT "external_link_checks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "opportunity_providers_ownerUserId_idx" ON "opportunity_providers"("ownerUserId");
CREATE INDEX "opportunity_providers_name_trgm" ON "opportunity_providers" USING GIN ("name" gin_trgm_ops);

CREATE UNIQUE INDEX "opportunities_slug_key" ON "opportunities"("slug");
-- Members' list queries filter on PUBLISHED and order by deadline.
CREATE INDEX "opportunities_published_deadline_idx" ON "opportunities"("status", "deadlineAt") WHERE "status" = 'PUBLISHED';
CREATE INDEX "opportunities_type_status_idx" ON "opportunities"("type", "status");
CREATE INDEX "opportunities_countyId_status_idx" ON "opportunities"("countyId", "status");
CREATE INDEX "opportunities_providerId_status_idx" ON "opportunities"("providerId", "status");
CREATE INDEX "opportunities_search_vector_idx" ON "opportunities" USING GIN ("searchVector");
CREATE INDEX "opportunities_title_trgm" ON "opportunities" USING GIN ("title" gin_trgm_ops);

CREATE INDEX "opportunity_disciplines_disciplineId_idx" ON "opportunity_disciplines"("disciplineId");
CREATE INDEX "opportunity_requirement_rules_opportunityId_sortOrder_idx" ON "opportunity_requirement_rules"("opportunityId", "sortOrder");

CREATE UNIQUE INDEX "opportunity_trackings_userId_opportunityId_key" ON "opportunity_trackings"("userId", "opportunityId");
CREATE INDEX "opportunity_trackings_userId_status_idx" ON "opportunity_trackings"("userId", "status");
CREATE INDEX "opportunity_trackings_opportunityId_status_idx" ON "opportunity_trackings"("opportunityId", "status");

CREATE INDEX "external_link_checks_opportunityId_checkedAt_idx" ON "external_link_checks"("opportunityId", "checkedAt" DESC);
CREATE INDEX "external_link_checks_result_checkedAt_idx" ON "external_link_checks"("result", "checkedAt" DESC);

CREATE INDEX "post_attachments_opportunityId_idx" ON "post_attachments"("opportunityId");

-- AddForeignKey
ALTER TABLE "opportunity_providers" ADD CONSTRAINT "opportunity_providers_logoMediaId_fkey" FOREIGN KEY ("logoMediaId") REFERENCES "media_assets"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "opportunity_providers" ADD CONSTRAINT "opportunity_providers_ownerUserId_fkey" FOREIGN KEY ("ownerUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "opportunities" ADD CONSTRAINT "opportunities_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "opportunity_providers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "opportunities" ADD CONSTRAINT "opportunities_countryId_fkey" FOREIGN KEY ("countryId") REFERENCES "countries"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "opportunities" ADD CONSTRAINT "opportunities_countyId_fkey" FOREIGN KEY ("countyId") REFERENCES "counties"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "opportunities" ADD CONSTRAINT "opportunities_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "opportunity_disciplines" ADD CONSTRAINT "opportunity_disciplines_opportunityId_fkey" FOREIGN KEY ("opportunityId") REFERENCES "opportunities"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "opportunity_disciplines" ADD CONSTRAINT "opportunity_disciplines_disciplineId_fkey" FOREIGN KEY ("disciplineId") REFERENCES "disciplines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "opportunity_requirement_rules" ADD CONSTRAINT "opportunity_requirement_rules_opportunityId_fkey" FOREIGN KEY ("opportunityId") REFERENCES "opportunities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "opportunity_trackings" ADD CONSTRAINT "opportunity_trackings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "opportunity_trackings" ADD CONSTRAINT "opportunity_trackings_opportunityId_fkey" FOREIGN KEY ("opportunityId") REFERENCES "opportunities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "external_link_checks" ADD CONSTRAINT "external_link_checks_opportunityId_fkey" FOREIGN KEY ("opportunityId") REFERENCES "opportunities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Post attachments (P1-M8 column, no FK until now): drop any attachment pointing at nothing, then enforce it.
DELETE FROM "post_attachments" WHERE "opportunityId" IS NOT NULL AND "opportunityId" NOT IN (SELECT "id" FROM "opportunities");
ALTER TABLE "post_attachments" ADD CONSTRAINT "post_attachments_opportunityId_fkey" FOREIGN KEY ("opportunityId") REFERENCES "opportunities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Row level security: deny-all for the Supabase client roles, full access for the backend role.
ALTER TABLE "opportunity_providers" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "opportunity_providers" FROM anon, authenticated;
GRANT ALL ON TABLE "opportunity_providers" TO atarah_backend;
ALTER TABLE "opportunities" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "opportunities" FROM anon, authenticated;
GRANT ALL ON TABLE "opportunities" TO atarah_backend;
ALTER TABLE "opportunity_disciplines" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "opportunity_disciplines" FROM anon, authenticated;
GRANT ALL ON TABLE "opportunity_disciplines" TO atarah_backend;
ALTER TABLE "opportunity_requirement_rules" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "opportunity_requirement_rules" FROM anon, authenticated;
GRANT ALL ON TABLE "opportunity_requirement_rules" TO atarah_backend;
ALTER TABLE "opportunity_trackings" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "opportunity_trackings" FROM anon, authenticated;
GRANT ALL ON TABLE "opportunity_trackings" TO atarah_backend;
ALTER TABLE "external_link_checks" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "external_link_checks" FROM anon, authenticated;
GRANT ALL ON TABLE "external_link_checks" TO atarah_backend;
