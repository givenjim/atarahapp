-- P2-M6: Verified Creative and skill verification. Hand-written (DEC-061 convention).
-- RLS on, client roles get nothing; the backend role has full access. Requirement rows are seeded by the reference seed.

CREATE TYPE "VerificationSubjectType" AS ENUM ('CREATIVE_IDENTITY', 'SKILL', 'SELLER', 'OPPORTUNITY_PROVIDER', 'MENTOR');
CREATE TYPE "VerificationEvidenceType" AS ENUM ('GOVERNMENT_ID', 'PORTFOLIO_PROJECT', 'REFERENCE', 'DOCUMENT', 'LINK');
CREATE TYPE "VerificationReferenceStatus" AS ENUM ('PENDING', 'CONFIRMED', 'DECLINED', 'EXPIRED');
CREATE TYPE "VerificationBadgeEndReason" AS ENUM ('EXPIRED', 'REVOKED', 'SUPERSEDED');

CREATE TABLE "verification_cases" (
    "id" UUID NOT NULL,
    "applicantId" UUID NOT NULL,
    "subjectType" "VerificationSubjectType" NOT NULL,
    "subjectId" UUID NOT NULL,
    "status" "VerificationStatus" NOT NULL DEFAULT 'NOT_SUBMITTED',
    "subjectMeta" JSONB,
    "submittedAt" TIMESTAMP(3),
    "slaDueAt" TIMESTAMP(3),
    "reviewerId" UUID,
    "assignedAt" TIMESTAMP(3),
    "decidedAt" TIMESTAMP(3),
    "feedback" TEXT,
    "decisionNotes" TEXT,
    "moreInfoNote" TEXT,
    "moreInfoRequestedAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "expiryReminderSentAt" TIMESTAMP(3),
    "version" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verification_cases_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "verification_requirements" (
    "id" UUID NOT NULL,
    "subjectType" "VerificationSubjectType" NOT NULL,
    "key" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "evidenceTypes" "VerificationEvidenceType"[],
    "minCount" INTEGER NOT NULL DEFAULT 1,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verification_requirements_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "verification_evidence" (
    "id" UUID NOT NULL,
    "caseId" UUID NOT NULL,
    "type" "VerificationEvidenceType" NOT NULL,
    "label" TEXT,
    "mediaAssetId" UUID,
    "projectId" UUID,
    "url" TEXT,
    "referenceId" UUID,
    "note" TEXT,
    "purgeAfter" TIMESTAMP(3),
    "purgedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verification_evidence_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "verification_references" (
    "id" UUID NOT NULL,
    "caseId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "relationship" TEXT NOT NULL,
    "status" "VerificationReferenceStatus" NOT NULL DEFAULT 'PENDING',
    "tokenHash" TEXT NOT NULL,
    "tokenExpiresAt" TIMESTAMP(3) NOT NULL,
    "sentAt" TIMESTAMP(3),
    "respondedAt" TIMESTAMP(3),
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "verification_references_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "verification_badges" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "subjectType" "VerificationSubjectType" NOT NULL,
    "subjectId" UUID NOT NULL,
    "caseId" UUID NOT NULL,
    "grantedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3),
    "endedAt" TIMESTAMP(3),
    "endReason" "VerificationBadgeEndReason",
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verification_badges_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "verification_case_events" (
    "id" UUID NOT NULL,
    "caseId" UUID NOT NULL,
    "action" TEXT NOT NULL,
    "actorId" UUID,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verification_case_events_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "verification_cases_status_submittedAt_idx" ON "verification_cases"("status", "submittedAt");
CREATE INDEX "verification_cases_applicantId_subjectType_subjectId_idx" ON "verification_cases"("applicantId", "subjectType", "subjectId");
CREATE INDEX "verification_cases_reviewerId_status_idx" ON "verification_cases"("reviewerId", "status");
CREATE INDEX "verification_cases_status_expiresAt_idx" ON "verification_cases"("status", "expiresAt");
-- One open case (draft, submitted or under review) per applicant and subject.
CREATE UNIQUE INDEX "verification_cases_one_open_key" ON "verification_cases"("applicantId", "subjectType", "subjectId")
    WHERE "status" IN ('NOT_SUBMITTED', 'SUBMITTED', 'UNDER_REVIEW');
CREATE UNIQUE INDEX "verification_requirements_subjectType_key_key" ON "verification_requirements"("subjectType", "key");
CREATE UNIQUE INDEX "verification_evidence_referenceId_key" ON "verification_evidence"("referenceId");
CREATE INDEX "verification_evidence_caseId_type_idx" ON "verification_evidence"("caseId", "type");
CREATE INDEX "verification_evidence_purgeAfter_purgedAt_idx" ON "verification_evidence"("purgeAfter", "purgedAt");
CREATE UNIQUE INDEX "verification_references_tokenHash_key" ON "verification_references"("tokenHash");
CREATE INDEX "verification_references_caseId_idx" ON "verification_references"("caseId");
CREATE INDEX "verification_references_status_tokenExpiresAt_idx" ON "verification_references"("status", "tokenExpiresAt");
CREATE UNIQUE INDEX "verification_badges_caseId_key" ON "verification_badges"("caseId");
CREATE INDEX "verification_badges_userId_subjectType_idx" ON "verification_badges"("userId", "subjectType");
CREATE INDEX "verification_badges_subjectType_subjectId_idx" ON "verification_badges"("subjectType", "subjectId");
CREATE INDEX "verification_badges_endedAt_expiresAt_idx" ON "verification_badges"("endedAt", "expiresAt");
-- One active badge per owner and subject.
CREATE UNIQUE INDEX "verification_badges_one_active_key" ON "verification_badges"("userId", "subjectType", "subjectId")
    WHERE "endedAt" IS NULL;
CREATE INDEX "verification_case_events_caseId_createdAt_idx" ON "verification_case_events"("caseId", "createdAt");

ALTER TABLE "verification_cases" ADD CONSTRAINT "verification_cases_applicantId_fkey" FOREIGN KEY ("applicantId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "verification_cases" ADD CONSTRAINT "verification_cases_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "verification_evidence" ADD CONSTRAINT "verification_evidence_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "verification_cases"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "verification_evidence" ADD CONSTRAINT "verification_evidence_referenceId_fkey" FOREIGN KEY ("referenceId") REFERENCES "verification_references"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "verification_references" ADD CONSTRAINT "verification_references_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "verification_cases"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "verification_badges" ADD CONSTRAINT "verification_badges_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "verification_badges" ADD CONSTRAINT "verification_badges_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "verification_cases"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "verification_case_events" ADD CONSTRAINT "verification_case_events_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "verification_cases"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Row level security: deny-all for the Supabase client roles, full access for the backend role.
ALTER TABLE "verification_cases" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "verification_cases" FROM anon, authenticated;
GRANT ALL ON TABLE "verification_cases" TO atarah_backend;
ALTER TABLE "verification_requirements" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "verification_requirements" FROM anon, authenticated;
GRANT ALL ON TABLE "verification_requirements" TO atarah_backend;
ALTER TABLE "verification_evidence" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "verification_evidence" FROM anon, authenticated;
GRANT ALL ON TABLE "verification_evidence" TO atarah_backend;
ALTER TABLE "verification_references" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "verification_references" FROM anon, authenticated;
GRANT ALL ON TABLE "verification_references" TO atarah_backend;
ALTER TABLE "verification_badges" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "verification_badges" FROM anon, authenticated;
GRANT ALL ON TABLE "verification_badges" TO atarah_backend;
ALTER TABLE "verification_case_events" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "verification_case_events" FROM anon, authenticated;
GRANT ALL ON TABLE "verification_case_events" TO atarah_backend;
