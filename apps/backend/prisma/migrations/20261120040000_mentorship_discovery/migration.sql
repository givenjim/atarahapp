-- P2-M4: Mentorship discovery and mentor onboarding (mentor profiles, session types, weekly availability,
-- date exceptions, mentor applications). Hand-written (DEC-061). The booking table belongs to P2-M5.
-- RLS is enabled on every table; the Supabase client roles get nothing, the backend role gets access.

-- CreateEnum
CREATE TYPE "MentorStatus" AS ENUM ('APPLIED', 'APPROVED', 'PAUSED', 'REMOVED');
CREATE TYPE "MentorApplicationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'WITHDRAWN');

-- CreateTable
CREATE TABLE "mentor_profiles" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "headline" TEXT NOT NULL,
    "yearsExperience" INTEGER NOT NULL DEFAULT 0,
    "bio" TEXT NOT NULL,
    "expertiseTags" TEXT[],
    "disciplineIds" UUID[],
    "credentials" JSONB NOT NULL DEFAULT '[]',
    "timeZone" TEXT NOT NULL,
    "videoCallLink" TEXT,
    "status" "MentorStatus" NOT NULL DEFAULT 'APPROVED',
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'NOT_SUBMITTED',
    "featured" BOOLEAN NOT NULL DEFAULT false,
    "ratingAverage" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "ratingCount" INTEGER NOT NULL DEFAULT 0,
    "sessionsCount" INTEGER NOT NULL DEFAULT 0,
    "approvedAt" TIMESTAMP(3),
    "statusReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "mentor_profiles_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "mentor_profiles_years_check" CHECK ("yearsExperience" >= 0 AND "yearsExperience" <= 80),
    CONSTRAINT "mentor_profiles_user_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "mentor_session_types" (
    "id" UUID NOT NULL,
    "mentorId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "durationMinutes" INTEGER NOT NULL,
    "priceMinor" INTEGER NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'KES',
    "format" "MentorSessionFormat" NOT NULL DEFAULT 'VIDEO_CALL',
    "sessionCount" INTEGER NOT NULL DEFAULT 1,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "disabledByStaff" BOOLEAN NOT NULL DEFAULT false,
    "staffNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "mentor_session_types_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "mentor_session_types_duration_check" CHECK ("durationMinutes" BETWEEN 15 AND 480),
    CONSTRAINT "mentor_session_types_price_check" CHECK ("priceMinor" >= 0),
    CONSTRAINT "mentor_session_types_count_check" CHECK ("sessionCount" BETWEEN 1 AND 24),
    CONSTRAINT "mentor_session_types_mentor_fkey" FOREIGN KEY ("mentorId") REFERENCES "mentor_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "mentor_availability" (
    "id" UUID NOT NULL,
    "mentorId" UUID NOT NULL,
    "weekday" INTEGER NOT NULL,
    "startMinute" INTEGER NOT NULL,
    "endMinute" INTEGER NOT NULL,
    "timeZone" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "mentor_availability_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "mentor_availability_range_check" CHECK ("weekday" BETWEEN 1 AND 7 AND "startMinute" >= 0 AND "endMinute" <= 1440 AND "startMinute" < "endMinute"),
    CONSTRAINT "mentor_availability_mentor_fkey" FOREIGN KEY ("mentorId") REFERENCES "mentor_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "mentor_availability_exceptions" (
    "id" UUID NOT NULL,
    "mentorId" UUID NOT NULL,
    "date" DATE NOT NULL,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "mentor_availability_exceptions_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "mentor_availability_exceptions_mentor_fkey" FOREIGN KEY ("mentorId") REFERENCES "mentor_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "mentor_applications" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "status" "MentorApplicationStatus" NOT NULL DEFAULT 'PENDING',
    "headline" TEXT NOT NULL,
    "yearsExperience" INTEGER NOT NULL DEFAULT 0,
    "statement" TEXT NOT NULL,
    "expertiseTags" TEXT[],
    "disciplineIds" UUID[],
    "credentials" JSONB NOT NULL DEFAULT '[]',
    "proposedSessionTypes" JSONB NOT NULL DEFAULT '[]',
    "evidenceLinks" TEXT[],
    "timeZone" TEXT NOT NULL,
    "passportSnapshot" JSONB NOT NULL DEFAULT '{}',
    "termsAcceptedAt" TIMESTAMP(3) NOT NULL,
    "reviewedById" UUID,
    "reviewedAt" TIMESTAMP(3),
    "reviewerNotes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "mentor_applications_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "mentor_applications_user_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "mentor_applications_reviewer_fkey" FOREIGN KEY ("reviewedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "mentor_profiles_userId_key" ON "mentor_profiles"("userId");
CREATE INDEX "mentor_profiles_status_featured_idx" ON "mentor_profiles"("status", "featured");
CREATE INDEX "mentor_session_types_mentorId_active_idx" ON "mentor_session_types"("mentorId", "active");
CREATE INDEX "mentor_availability_mentorId_weekday_idx" ON "mentor_availability"("mentorId", "weekday");
CREATE UNIQUE INDEX "mentor_availability_exceptions_mentorId_date_key" ON "mentor_availability_exceptions"("mentorId", "date");
CREATE INDEX "mentor_applications_status_createdAt_idx" ON "mentor_applications"("status", "createdAt");
CREATE INDEX "mentor_applications_userId_createdAt_idx" ON "mentor_applications"("userId", "createdAt");
-- One open application per member.
CREATE UNIQUE INDEX "mentor_applications_one_pending_per_user" ON "mentor_applications"("userId") WHERE "status" = 'PENDING';

-- Row Level Security: deny-all for the Supabase client roles; the backend role is granted access.
ALTER TABLE "mentor_profiles" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "mentor_profiles" FROM anon, authenticated;
GRANT ALL ON TABLE "mentor_profiles" TO atarah_backend;
ALTER TABLE "mentor_session_types" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "mentor_session_types" FROM anon, authenticated;
GRANT ALL ON TABLE "mentor_session_types" TO atarah_backend;
ALTER TABLE "mentor_availability" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "mentor_availability" FROM anon, authenticated;
GRANT ALL ON TABLE "mentor_availability" TO atarah_backend;
ALTER TABLE "mentor_availability_exceptions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "mentor_availability_exceptions" FROM anon, authenticated;
GRANT ALL ON TABLE "mentor_availability_exceptions" TO atarah_backend;
ALTER TABLE "mentor_applications" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "mentor_applications" FROM anon, authenticated;
GRANT ALL ON TABLE "mentor_applications" TO atarah_backend;
