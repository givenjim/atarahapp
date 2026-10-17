-- AlterTable
ALTER TABLE "sessions" ADD COLUMN     "reauthAt" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "admin_totp" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "secretEncrypted" TEXT NOT NULL,
    "confirmedAt" TIMESTAMP(3),
    "lastUsedTimeStep" INTEGER,
    "recoveryCodeHashes" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "admin_totp_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "admin_totp_userId_key" ON "admin_totp"("userId");

-- AddForeignKey
ALTER TABLE "admin_totp" ADD CONSTRAINT "admin_totp_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
