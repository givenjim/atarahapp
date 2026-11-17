-- P1-M8: community (posts, comments, reactions, groups, blocks, mutes) and moderation (reports, cases, the
-- append-only action log). Hand-reviewed from `prisma migrate diff --script` (DEC-061). Columns follow the existing
-- camelCase convention; tables are snake_case plural. `connections` already has its unordered-pair unique index and the
-- self-connection CHECK (P1-M3), so nothing changes there. Saved posts use the existing saved_items table.

-- Members can save posts (Master Prompt P1-M8, SavedPost through saved_items).
ALTER TYPE "SavedItemType" ADD VALUE IF NOT EXISTS 'POST';

-- CreateEnum
CREATE TYPE "PostStatus" AS ENUM ('VISIBLE', 'HIDDEN', 'REMOVED');

-- CreateEnum
CREATE TYPE "GroupVisibility" AS ENUM ('OPEN', 'PRIVATE');

-- CreateEnum
CREATE TYPE "GroupRole" AS ENUM ('MEMBER', 'MODERATOR', 'OWNER');

-- CreateEnum
CREATE TYPE "MuteTargetType" AS ENUM ('USER', 'POST');

-- CreateEnum
CREATE TYPE "ReportTargetType" AS ENUM ('POST', 'COMMENT', 'USER', 'GROUP');

-- CreateEnum
CREATE TYPE "ModerationPriority" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');

-- CreateTable
CREATE TABLE "posts" (
    "id" UUID NOT NULL,
    "authorId" UUID NOT NULL,
    "type" "PostType" NOT NULL,
    "body" TEXT NOT NULL,
    "audience" "PostAudience" NOT NULL DEFAULT 'MEMBERS',
    "groupId" UUID,
    "status" "PostStatus" NOT NULL DEFAULT 'VISIBLE',
    "reactionCount" INTEGER NOT NULL DEFAULT 0,
    "replyCount" INTEGER NOT NULL DEFAULT 0,
    "isStaffAnnouncement" BOOLEAN NOT NULL DEFAULT false,
    "searchVector" tsvector GENERATED ALWAYS AS (setweight(to_tsvector('simple', coalesce("body", '')), 'A')) STORED,
    "editedAt" TIMESTAMP(3),
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "posts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_media" (
    "id" UUID NOT NULL,
    "postId" UUID NOT NULL,
    "mediaAssetId" UUID NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "post_media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_links" (
    "id" UUID NOT NULL,
    "postId" UUID NOT NULL,
    "url" TEXT NOT NULL,
    "title" TEXT,
    "description" TEXT,
    "image" TEXT,
    "siteName" TEXT,
    "fetchedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "post_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_attachments" (
    "id" UUID NOT NULL,
    "postId" UUID NOT NULL,
    "opportunityId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "post_attachments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "comments" (
    "id" UUID NOT NULL,
    "postId" UUID NOT NULL,
    "authorId" UUID NOT NULL,
    "parentCommentId" UUID,
    "body" TEXT NOT NULL,
    "status" "PostStatus" NOT NULL DEFAULT 'VISIBLE',
    "editedAt" TIMESTAMP(3),
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reactions" (
    "id" UUID NOT NULL,
    "postId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "groups" (
    "id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "type" "GroupType" NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "coverMediaId" UUID,
    "disciplineId" UUID,
    "countyId" UUID,
    "isOfficial" BOOLEAN NOT NULL DEFAULT false,
    "visibility" "GroupVisibility" NOT NULL DEFAULT 'OPEN',
    "memberCount" INTEGER NOT NULL DEFAULT 0,
    "createdById" UUID,
    "archivedAt" TIMESTAMP(3),
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "group_memberships" (
    "id" UUID NOT NULL,
    "groupId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "role" "GroupRole" NOT NULL DEFAULT 'MEMBER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "group_memberships_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "group_pins" (
    "id" UUID NOT NULL,
    "groupId" UUID NOT NULL,
    "postId" UUID NOT NULL,
    "pinnedById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "group_pins_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "blocks" (
    "id" UUID NOT NULL,
    "blockerId" UUID NOT NULL,
    "blockedId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "blocks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mutes" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "targetType" "MuteTargetType" NOT NULL,
    "targetId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "mutes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reports" (
    "id" UUID NOT NULL,
    "reporterId" UUID NOT NULL,
    "targetType" "ReportTargetType" NOT NULL,
    "targetId" UUID NOT NULL,
    "reason" "ReportReason" NOT NULL,
    "note" TEXT,
    "status" "ReportStatus" NOT NULL DEFAULT 'SUBMITTED',
    "caseId" UUID,
    "notifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "moderation_cases" (
    "id" UUID NOT NULL,
    "targetType" "ReportTargetType" NOT NULL,
    "targetId" UUID NOT NULL,
    "targetAuthorId" UUID,
    "status" "ReportStatus" NOT NULL DEFAULT 'SUBMITTED',
    "priority" "ModerationPriority" NOT NULL DEFAULT 'NORMAL',
    "assigneeId" UUID,
    "reportCount" INTEGER NOT NULL DEFAULT 1,
    "topReason" "ReportReason" NOT NULL,
    "resolvedAt" TIMESTAMP(3),
    "alertedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "moderation_cases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "moderation_actions" (
    "id" UUID NOT NULL,
    "caseId" UUID NOT NULL,
    "action" "ModerationAction" NOT NULL,
    "reason" TEXT,
    "actorId" UUID NOT NULL,
    "targetType" "ReportTargetType" NOT NULL,
    "targetId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "moderation_actions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "community_restrictions" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "reason" TEXT,
    "restrictedById" UUID NOT NULL,
    "expiresAt" TIMESTAMP(3),
    "liftedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "community_restrictions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "posts_groupId_createdAt_idx" ON "posts"("groupId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "posts_authorId_createdAt_idx" ON "posts"("authorId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "posts_status_createdAt_idx" ON "posts"("status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "posts_search_vector_idx" ON "posts" USING GIN ("searchVector");

-- CreateIndex
CREATE UNIQUE INDEX "post_media_postId_mediaAssetId_key" ON "post_media"("postId", "mediaAssetId");

-- CreateIndex
CREATE UNIQUE INDEX "post_media_postId_sortOrder_key" ON "post_media"("postId", "sortOrder");

-- CreateIndex
CREATE UNIQUE INDEX "post_links_postId_key" ON "post_links"("postId");

-- CreateIndex
CREATE INDEX "post_attachments_postId_idx" ON "post_attachments"("postId");

-- CreateIndex
CREATE INDEX "comments_postId_createdAt_idx" ON "comments"("postId", "createdAt");

-- CreateIndex
CREATE INDEX "comments_parentCommentId_idx" ON "comments"("parentCommentId");

-- CreateIndex
CREATE INDEX "comments_authorId_idx" ON "comments"("authorId");

-- CreateIndex
CREATE INDEX "reactions_userId_idx" ON "reactions"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "reactions_postId_userId_key" ON "reactions"("postId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "groups_slug_key" ON "groups"("slug");

-- CreateIndex
CREATE INDEX "groups_type_archivedAt_idx" ON "groups"("type", "archivedAt");

-- CreateIndex
CREATE INDEX "groups_disciplineId_idx" ON "groups"("disciplineId");

-- CreateIndex
CREATE INDEX "groups_countyId_idx" ON "groups"("countyId");

-- CreateIndex
CREATE INDEX "group_memberships_userId_idx" ON "group_memberships"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "group_memberships_groupId_userId_key" ON "group_memberships"("groupId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "group_pins_groupId_postId_key" ON "group_pins"("groupId", "postId");

-- CreateIndex
CREATE INDEX "blocks_blockedId_idx" ON "blocks"("blockedId");

-- CreateIndex
CREATE UNIQUE INDEX "blocks_blockerId_blockedId_key" ON "blocks"("blockerId", "blockedId");

-- CreateIndex
CREATE INDEX "mutes_targetType_targetId_idx" ON "mutes"("targetType", "targetId");

-- CreateIndex
CREATE UNIQUE INDEX "mutes_userId_targetType_targetId_key" ON "mutes"("userId", "targetType", "targetId");

-- CreateIndex
CREATE INDEX "reports_status_createdAt_idx" ON "reports"("status", "createdAt");

-- CreateIndex
CREATE INDEX "reports_caseId_idx" ON "reports"("caseId");

-- CreateIndex
CREATE UNIQUE INDEX "reports_reporterId_targetType_targetId_key" ON "reports"("reporterId", "targetType", "targetId");

-- CreateIndex
CREATE INDEX "moderation_cases_status_createdAt_idx" ON "moderation_cases"("status", "createdAt");

-- CreateIndex
CREATE INDEX "moderation_cases_assigneeId_idx" ON "moderation_cases"("assigneeId");

-- CreateIndex
CREATE UNIQUE INDEX "moderation_cases_targetType_targetId_key" ON "moderation_cases"("targetType", "targetId");

-- CreateIndex
CREATE INDEX "moderation_actions_caseId_createdAt_idx" ON "moderation_actions"("caseId", "createdAt");

-- CreateIndex
CREATE INDEX "community_restrictions_userId_liftedAt_idx" ON "community_restrictions"("userId", "liftedAt");

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_media" ADD CONSTRAINT "post_media_postId_fkey" FOREIGN KEY ("postId") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_media" ADD CONSTRAINT "post_media_mediaAssetId_fkey" FOREIGN KEY ("mediaAssetId") REFERENCES "media_assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_links" ADD CONSTRAINT "post_links_postId_fkey" FOREIGN KEY ("postId") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_attachments" ADD CONSTRAINT "post_attachments_postId_fkey" FOREIGN KEY ("postId") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comments" ADD CONSTRAINT "comments_postId_fkey" FOREIGN KEY ("postId") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comments" ADD CONSTRAINT "comments_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "comments" ADD CONSTRAINT "comments_parentCommentId_fkey" FOREIGN KEY ("parentCommentId") REFERENCES "comments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reactions" ADD CONSTRAINT "reactions_postId_fkey" FOREIGN KEY ("postId") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reactions" ADD CONSTRAINT "reactions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "groups" ADD CONSTRAINT "groups_coverMediaId_fkey" FOREIGN KEY ("coverMediaId") REFERENCES "media_assets"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "groups" ADD CONSTRAINT "groups_disciplineId_fkey" FOREIGN KEY ("disciplineId") REFERENCES "disciplines"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "groups" ADD CONSTRAINT "groups_countyId_fkey" FOREIGN KEY ("countyId") REFERENCES "counties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "groups" ADD CONSTRAINT "groups_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_memberships" ADD CONSTRAINT "group_memberships_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_memberships" ADD CONSTRAINT "group_memberships_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_pins" ADD CONSTRAINT "group_pins_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_pins" ADD CONSTRAINT "group_pins_postId_fkey" FOREIGN KEY ("postId") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_pins" ADD CONSTRAINT "group_pins_pinnedById_fkey" FOREIGN KEY ("pinnedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "blocks" ADD CONSTRAINT "blocks_blockerId_fkey" FOREIGN KEY ("blockerId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "blocks" ADD CONSTRAINT "blocks_blockedId_fkey" FOREIGN KEY ("blockedId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mutes" ADD CONSTRAINT "mutes_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "moderation_cases"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "moderation_cases" ADD CONSTRAINT "moderation_cases_assigneeId_fkey" FOREIGN KEY ("assigneeId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "moderation_actions" ADD CONSTRAINT "moderation_actions_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "moderation_cases"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "community_restrictions" ADD CONSTRAINT "community_restrictions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ---- rules the schema language cannot express ---------------------------------------------------------------------

-- Length limits (Master Prompt P1-M8) and the group/audience pairing.
ALTER TABLE "posts" ADD CONSTRAINT "posts_body_length" CHECK (char_length("body") <= 5000);
ALTER TABLE "posts" ADD CONSTRAINT "posts_group_audience" CHECK (("audience" = 'GROUP') = ("groupId" IS NOT NULL));
ALTER TABLE "comments" ADD CONSTRAINT "comments_body_length" CHECK (char_length("body") BETWEEN 1 AND 2000);
ALTER TABLE "comments" ADD CONSTRAINT "comments_not_own_parent" CHECK ("parentCommentId" IS NULL OR "parentCommentId" <> "id");
ALTER TABLE "reports" ADD CONSTRAINT "reports_note_length" CHECK ("note" IS NULL OR char_length("note") <= 1000);
ALTER TABLE "groups" ADD CONSTRAINT "groups_slug_format" CHECK ("slug" ~ '^[a-z0-9]+(-[a-z0-9]+)*$');
ALTER TABLE "post_links" ADD CONSTRAINT "post_links_https" CHECK ("url" ~* '^https?://');

-- At most ten media per post: positions 0-9, unique per post (the unique index is above).
ALTER TABLE "post_media" ADD CONSTRAINT "post_media_max_ten" CHECK ("sortOrder" BETWEEN 0 AND 9);

-- Nobody blocks themselves; counters never go negative.
ALTER TABLE "blocks" ADD CONSTRAINT "blocks_not_self" CHECK ("blockerId" <> "blockedId");
ALTER TABLE "posts" ADD CONSTRAINT "posts_counters_non_negative" CHECK ("reactionCount" >= 0 AND "replyCount" >= 0);
ALTER TABLE "groups" ADD CONSTRAINT "groups_member_count_non_negative" CHECK ("memberCount" >= 0);

-- One reply level: a reply's parent must be a top-level comment on the same post.
CREATE OR REPLACE FUNCTION comments_enforce_one_level() RETURNS trigger AS $$
DECLARE
  parent RECORD;
BEGIN
  IF NEW."parentCommentId" IS NOT NULL THEN
    SELECT "postId", "parentCommentId" INTO parent FROM "comments" WHERE "id" = NEW."parentCommentId";
    IF NOT FOUND OR parent."parentCommentId" IS NOT NULL OR parent."postId" <> NEW."postId" THEN
      RAISE EXCEPTION 'a reply must answer a top-level comment on the same post'
        USING ERRCODE = 'check_violation';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER comments_one_level
  BEFORE INSERT OR UPDATE OF "parentCommentId", "postId" ON "comments"
  FOR EACH ROW EXECUTE FUNCTION comments_enforce_one_level();

-- moderation_actions is append-only, like audit_logs: reject UPDATE, DELETE and TRUNCATE for every role.
CREATE OR REPLACE FUNCTION moderation_actions_reject_mutation() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'moderation_actions is append-only: % is not permitted', TG_OP
    USING ERRCODE = 'restrict_violation';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER moderation_actions_no_update_delete
  BEFORE UPDATE OR DELETE ON "moderation_actions"
  FOR EACH ROW EXECUTE FUNCTION moderation_actions_reject_mutation();

CREATE TRIGGER moderation_actions_no_truncate
  BEFORE TRUNCATE ON "moderation_actions"
  FOR EACH STATEMENT EXECUTE FUNCTION moderation_actions_reject_mutation();

-- ---- Supabase posture: deny-all for the client roles (Master Prompt 5.7) ------------------------------------------
ALTER TABLE "posts" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "posts" FROM anon, authenticated;
GRANT ALL ON TABLE "posts" TO atarah_backend;
ALTER TABLE "post_media" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "post_media" FROM anon, authenticated;
GRANT ALL ON TABLE "post_media" TO atarah_backend;
ALTER TABLE "post_links" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "post_links" FROM anon, authenticated;
GRANT ALL ON TABLE "post_links" TO atarah_backend;
ALTER TABLE "post_attachments" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "post_attachments" FROM anon, authenticated;
GRANT ALL ON TABLE "post_attachments" TO atarah_backend;
ALTER TABLE "comments" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "comments" FROM anon, authenticated;
GRANT ALL ON TABLE "comments" TO atarah_backend;
ALTER TABLE "reactions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "reactions" FROM anon, authenticated;
GRANT ALL ON TABLE "reactions" TO atarah_backend;
ALTER TABLE "groups" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "groups" FROM anon, authenticated;
GRANT ALL ON TABLE "groups" TO atarah_backend;
ALTER TABLE "group_memberships" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "group_memberships" FROM anon, authenticated;
GRANT ALL ON TABLE "group_memberships" TO atarah_backend;
ALTER TABLE "group_pins" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "group_pins" FROM anon, authenticated;
GRANT ALL ON TABLE "group_pins" TO atarah_backend;
ALTER TABLE "blocks" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "blocks" FROM anon, authenticated;
GRANT ALL ON TABLE "blocks" TO atarah_backend;
ALTER TABLE "mutes" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "mutes" FROM anon, authenticated;
GRANT ALL ON TABLE "mutes" TO atarah_backend;
ALTER TABLE "reports" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "reports" FROM anon, authenticated;
GRANT ALL ON TABLE "reports" TO atarah_backend;
ALTER TABLE "moderation_cases" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "moderation_cases" FROM anon, authenticated;
GRANT ALL ON TABLE "moderation_cases" TO atarah_backend;
ALTER TABLE "moderation_actions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "moderation_actions" FROM anon, authenticated;
GRANT ALL ON TABLE "moderation_actions" TO atarah_backend;
ALTER TABLE "community_restrictions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "community_restrictions" FROM anon, authenticated;
GRANT ALL ON TABLE "community_restrictions" TO atarah_backend;

REVOKE ALL ON FUNCTION comments_enforce_one_level() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION moderation_actions_reject_mutation() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION comments_enforce_one_level() TO atarah_backend;
GRANT EXECUTE ON FUNCTION moderation_actions_reject_mutation() TO atarah_backend;
