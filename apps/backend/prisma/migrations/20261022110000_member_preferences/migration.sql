-- P1-M7: member preferences (appearance, locale, time zone, marketing opt-in). One row per user, created lazily
-- by the backend. locale and time zone move here from "users" (single source of truth); existing values are copied.
CREATE TYPE "Appearance" AS ENUM ('LIGHT', 'DARK');

CREATE TABLE "member_preferences" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "appearance" "Appearance" NOT NULL DEFAULT 'LIGHT',
    "locale" TEXT NOT NULL DEFAULT 'en',
    "timeZone" TEXT NOT NULL DEFAULT 'Africa/Nairobi',
    "marketingOptIn" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "member_preferences_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "member_preferences_userId_key" ON "member_preferences"("userId");
ALTER TABLE "member_preferences"
  ADD CONSTRAINT "member_preferences_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Deny-all for anon and authenticated: RLS on, no policies, no grants (Master Prompt 5.7). The backend role bypasses RLS.
ALTER TABLE "member_preferences" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "member_preferences" FROM anon, authenticated;
GRANT ALL ON TABLE "member_preferences" TO atarah_backend;

-- Backfill: one row per existing user, carrying the values they already had.
INSERT INTO "member_preferences" ("id", "userId", "locale", "timeZone", "createdAt", "updatedAt")
SELECT gen_random_uuid(), "id", "locale", "timeZone", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM "users";

ALTER TABLE "users" DROP COLUMN "timeZone", DROP COLUMN "locale";
