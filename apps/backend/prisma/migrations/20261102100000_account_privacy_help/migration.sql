-- P1-M11: saved items for every type, notification type, per-field privacy, two-step settings, contact changes,
-- data export and account deletion requests, help articles and FAQ, staff broadcasts. Hand-written (DEC-061).
-- RLS is enabled on every new table; the backend role is granted access, the Supabase client roles get nothing.

-- Saved items: more kinds (LISTING and MENTOR are reserved for Phase 2) and an optional collection.
ALTER TYPE "SavedItemType" ADD VALUE IF NOT EXISTS 'LEARNING';
ALTER TYPE "SavedItemType" ADD VALUE IF NOT EXISTS 'CREATIVE';
ALTER TYPE "SavedItemType" ADD VALUE IF NOT EXISTS 'OPPORTUNITY';
ALTER TYPE "SavedItemType" ADD VALUE IF NOT EXISTS 'LISTING';
ALTER TYPE "SavedItemType" ADD VALUE IF NOT EXISTS 'MENTOR';
ALTER TABLE "saved_items" ADD COLUMN "collection" TEXT;

-- Notifications: a type key, and the index the list and the unread count use.
ALTER TABLE "notifications" ADD COLUMN "type" TEXT;
DROP INDEX IF EXISTS "notifications_userId_readAt_idx";
CREATE INDEX "notifications_userId_readAt_createdAt_idx" ON "notifications"("userId", "readAt", "createdAt" DESC);
CREATE INDEX "notifications_createdAt_idx" ON "notifications"("createdAt");

-- Devices: set once the device passed two-step sign-in.
ALTER TABLE "user_devices" ADD COLUMN "verifiedAt" TIMESTAMP(3);
-- Devices that exist today were registered before two-step existed: they count as verified.
UPDATE "user_devices" SET "verifiedAt" = "createdAt" WHERE "verifiedAt" IS NULL;

-- CreateEnum
CREATE TYPE "ProfileField" AS ENUM ('CONTACT', 'LOCATION', 'PORTFOLIO', 'EXPERIENCE', 'ACTIVITY');
CREATE TYPE "PrivacyRequestStatus" AS ENUM ('QUEUED', 'PROCESSING', 'READY', 'FAILED', 'EXPIRED');
CREATE TYPE "DeletionRequestStatus" AS ENUM ('PENDING', 'CANCELLED', 'PURGED');
CREATE TYPE "ContactChangeKind" AS ENUM ('EMAIL', 'PHONE');
CREATE TYPE "BroadcastTarget" AS ENUM ('ALL', 'ROLE', 'DISCIPLINE', 'COUNTY');
CREATE TYPE "BroadcastStatus" AS ENUM ('SCHEDULED', 'SENDING', 'SENT', 'CANCELLED');

-- CreateTable
CREATE TABLE "profile_field_visibility" (
    "userId" UUID NOT NULL,
    "field" "ProfileField" NOT NULL,
    "visibility" "Visibility" NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "profile_field_visibility_pkey" PRIMARY KEY ("userId","field")
);

CREATE TABLE "two_step_settings" (
    "userId" UUID NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "enabledAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "two_step_settings_pkey" PRIMARY KEY ("userId")
);

CREATE TABLE "contact_change_requests" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "kind" "ContactChangeKind" NOT NULL,
    "oldValue" TEXT,
    "newValue" TEXT NOT NULL,
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "contact_change_requests_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "data_export_requests" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "status" "PrivacyRequestStatus" NOT NULL DEFAULT 'QUEUED',
    "fileMediaId" UUID,
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "readyAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "error" TEXT,

    CONSTRAINT "data_export_requests_pkey" PRIMARY KEY ("id")
);

-- No foreign key on purpose: the row outlives the account (the log keeps only this non-personal id).
CREATE TABLE "account_deletion_requests" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "status" "DeletionRequestStatus" NOT NULL DEFAULT 'PENDING',
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "purgeAfter" TIMESTAMP(3) NOT NULL,
    "cancelledAt" TIMESTAMP(3),
    "purgedAt" TIMESTAMP(3),

    CONSTRAINT "account_deletion_requests_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "help_articles" (
    "id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT NOT NULL DEFAULT '',
    "body" JSONB NOT NULL DEFAULT '[]',
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "published" BOOLEAN NOT NULL DEFAULT false,
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "searchVector" tsvector GENERATED ALWAYS AS (setweight(to_tsvector('simple', coalesce("title", '')), 'A') || setweight(to_tsvector('simple', coalesce("summary", '')), 'B')) STORED,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "help_articles_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "faq_entries" (
    "id" UUID NOT NULL,
    "question" TEXT NOT NULL,
    "answer" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "published" BOOLEAN NOT NULL DEFAULT false,
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "searchVector" tsvector GENERATED ALWAYS AS (setweight(to_tsvector('simple', coalesce("question", '')), 'A') || setweight(to_tsvector('simple', coalesce("answer", '')), 'B')) STORED,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "faq_entries_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "notification_broadcasts" (
    "id" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "deepLink" TEXT,
    "category" "NotificationCategory" NOT NULL DEFAULT 'SYSTEM',
    "target" "BroadcastTarget" NOT NULL DEFAULT 'ALL',
    "targetValue" TEXT,
    "scheduledAt" TIMESTAMP(3),
    "status" "BroadcastStatus" NOT NULL DEFAULT 'SCHEDULED',
    "recipientCount" INTEGER NOT NULL DEFAULT 0,
    "sentAt" TIMESTAMP(3),
    "createdById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notification_broadcasts_pkey" PRIMARY KEY ("id"),
    -- A targeted broadcast names its target.
    CONSTRAINT "notification_broadcasts_target_check" CHECK ("target" = 'ALL' OR "targetValue" IS NOT NULL),
    CONSTRAINT "notification_broadcasts_deeplink_check" CHECK ("deepLink" IS NULL OR "deepLink" ~ '^/[^/\s\\]')
);

-- CreateIndex
CREATE INDEX "contact_change_requests_userId_completedAt_idx" ON "contact_change_requests"("userId", "completedAt");
CREATE INDEX "contact_change_requests_completedAt_requestedAt_idx" ON "contact_change_requests"("completedAt", "requestedAt");
CREATE INDEX "data_export_requests_userId_requestedAt_idx" ON "data_export_requests"("userId", "requestedAt" DESC);
CREATE INDEX "data_export_requests_status_requestedAt_idx" ON "data_export_requests"("status", "requestedAt");
CREATE INDEX "account_deletion_requests_userId_status_idx" ON "account_deletion_requests"("userId", "status");
CREATE INDEX "account_deletion_requests_status_purgeAfter_idx" ON "account_deletion_requests"("status", "purgeAfter");
-- One open deletion request per account.
CREATE UNIQUE INDEX "account_deletion_requests_one_pending_idx" ON "account_deletion_requests"("userId") WHERE "status" = 'PENDING';
CREATE UNIQUE INDEX "help_articles_slug_key" ON "help_articles"("slug");
CREATE INDEX "help_articles_published_sortOrder_idx" ON "help_articles"("published", "sortOrder");
CREATE INDEX "help_articles_search_vector_idx" ON "help_articles" USING GIN ("searchVector");
CREATE INDEX "faq_entries_published_sortOrder_idx" ON "faq_entries"("published", "sortOrder");
CREATE INDEX "faq_entries_search_vector_idx" ON "faq_entries" USING GIN ("searchVector");
CREATE INDEX "notification_broadcasts_status_scheduledAt_idx" ON "notification_broadcasts"("status", "scheduledAt");

-- AddForeignKey
ALTER TABLE "profile_field_visibility" ADD CONSTRAINT "profile_field_visibility_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "two_step_settings" ADD CONSTRAINT "two_step_settings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "contact_change_requests" ADD CONSTRAINT "contact_change_requests_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "data_export_requests" ADD CONSTRAINT "data_export_requests_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "data_export_requests" ADD CONSTRAINT "data_export_requests_fileMediaId_fkey" FOREIGN KEY ("fileMediaId") REFERENCES "media_assets"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "notification_broadcasts" ADD CONSTRAINT "notification_broadcasts_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Row level security: deny-all for the Supabase client roles, full access for the backend role.
ALTER TABLE "profile_field_visibility" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "profile_field_visibility" FROM anon, authenticated;
GRANT ALL ON TABLE "profile_field_visibility" TO atarah_backend;
ALTER TABLE "two_step_settings" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "two_step_settings" FROM anon, authenticated;
GRANT ALL ON TABLE "two_step_settings" TO atarah_backend;
ALTER TABLE "contact_change_requests" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "contact_change_requests" FROM anon, authenticated;
GRANT ALL ON TABLE "contact_change_requests" TO atarah_backend;
ALTER TABLE "data_export_requests" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "data_export_requests" FROM anon, authenticated;
GRANT ALL ON TABLE "data_export_requests" TO atarah_backend;
ALTER TABLE "account_deletion_requests" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "account_deletion_requests" FROM anon, authenticated;
GRANT ALL ON TABLE "account_deletion_requests" TO atarah_backend;
ALTER TABLE "help_articles" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "help_articles" FROM anon, authenticated;
GRANT ALL ON TABLE "help_articles" TO atarah_backend;
ALTER TABLE "faq_entries" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "faq_entries" FROM anon, authenticated;
GRANT ALL ON TABLE "faq_entries" TO atarah_backend;
ALTER TABLE "notification_broadcasts" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "notification_broadcasts" FROM anon, authenticated;
GRANT ALL ON TABLE "notification_broadcasts" TO atarah_backend;
