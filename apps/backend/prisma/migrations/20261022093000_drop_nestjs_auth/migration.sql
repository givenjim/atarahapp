-- P1-M6: Supabase Auth replaces the NestJS-issued credentials, sessions, one-time codes and admin TOTP.
-- Dev and staging only: these tables held no production data (there are no production users yet; DEC-061).

-- DropForeignKey
ALTER TABLE "admin_totp" DROP CONSTRAINT "admin_totp_userId_fkey";

-- DropForeignKey
ALTER TABLE "credentials" DROP CONSTRAINT "credentials_userId_fkey";

-- DropForeignKey
ALTER TABLE "sessions" DROP CONSTRAINT "sessions_userId_fkey";

-- DropForeignKey
ALTER TABLE "verification_codes" DROP CONSTRAINT "verification_codes_userId_fkey";

-- DropTable
DROP TABLE "admin_totp";

-- DropTable
DROP TABLE "credentials";

-- DropTable
DROP TABLE "sessions";

-- DropTable
DROP TABLE "verification_codes";

-- DropEnum
DROP TYPE "SessionClient";

-- DropEnum
DROP TYPE "CodeChannel";

-- DropEnum
DROP TYPE "CodePurpose";

