-- P1-M6: link a device to its Supabase Auth session so the Active sessions list can name it.
ALTER TABLE "user_devices" ADD COLUMN "lastSessionId" UUID;
CREATE INDEX "user_devices_lastSessionId_idx" ON "user_devices"("lastSessionId");
