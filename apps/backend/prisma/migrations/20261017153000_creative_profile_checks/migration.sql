-- Guard rails the Prisma schema cannot express.
ALTER TABLE "creative_profiles"
  ADD CONSTRAINT "creative_profiles_completion_range" CHECK ("completionPercent" BETWEEN 0 AND 100),
  ADD CONSTRAINT "creative_profiles_handle_format" CHECK ("handle" IS NULL OR "handle" ~ '^[a-z0-9_]{3,30}$');

-- One primary discipline per member.
CREATE UNIQUE INDEX "creative_disciplines_one_primary" ON "creative_disciplines" ("profileId") WHERE "isPrimary";

-- Passport numbers use a three-letter code and a positive sequence.
ALTER TABLE "creative_passports"
  ADD CONSTRAINT "creative_passports_code_format" CHECK ("countyCode" ~ '^[A-Z]{3}$'),
  ADD CONSTRAINT "creative_passports_sequence_positive" CHECK ("sequence" > 0);
