-- P1-M10: Skill Labs (learning content, courses, lessons, enrolments, progress, certificates, progress overrides).
-- Hand-written (DEC-061). Columns follow the camelCase convention; tables are snake_case plural. RLS is enabled on
-- every table in this migration and the backend role is granted access (the Supabase client roles get nothing).

-- Members can save learning content (saved_items).
ALTER TYPE "SavedItemType" ADD VALUE IF NOT EXISTS 'LEARNING';

-- CreateEnum
CREATE TYPE "LearningAccess" AS ENUM ('FREE', 'PREMIUM_CONTENT');

-- CreateTable
CREATE TABLE "learning_contents" (
    "id" UUID NOT NULL,
    "slug" TEXT NOT NULL,
    "type" "LearningContentType" NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "categoryId" UUID NOT NULL,
    "level" "SkillLevel" NOT NULL DEFAULT 'BEGINNER',
    "durationMinutes" INTEGER NOT NULL DEFAULT 0,
    "source" "ContentSource" NOT NULL DEFAULT 'ATARAH',
    "delivery" "ContentDelivery" NOT NULL DEFAULT 'NATIVE',
    "providerName" TEXT,
    "instructorUserId" UUID,
    "externalUrl" TEXT,
    "embedUrl" TEXT,
    "coverMediaId" UUID,
    "access" "LearningAccess" NOT NULL DEFAULT 'FREE',
    "status" "PublicationStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMP(3),
    "featured" BOOLEAN NOT NULL DEFAULT false,
    "whatYouLearn" JSONB NOT NULL DEFAULT '[]',
    "whoItsFor" TEXT,
    "linkStatus" "LinkStatus" NOT NULL DEFAULT 'UNKNOWN',
    "lastCheckedAt" TIMESTAMP(3),
    "searchVector" tsvector GENERATED ALWAYS AS (setweight(to_tsvector('simple', coalesce("title", '')), 'A') || setweight(to_tsvector('simple', coalesce("summary", '')), 'B')) STORED,
    "createdById" UUID,
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "learning_contents_pkey" PRIMARY KEY ("id"),
    -- (An external or embedded item needs its address before it is PUBLISHED; the publish step checks that, so a
    -- draft may be saved half-written.)
    CONSTRAINT "learning_contents_duration_check" CHECK ("durationMinutes" >= 0)
);

-- CreateTable
CREATE TABLE "learning_content_disciplines" (
    "contentId" UUID NOT NULL,
    "disciplineId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "learning_content_disciplines_pkey" PRIMARY KEY ("contentId","disciplineId")
);

-- CreateTable
CREATE TABLE "learning_content_skills" (
    "contentId" UUID NOT NULL,
    "skillId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "learning_content_skills_pkey" PRIMARY KEY ("contentId","skillId")
);

-- CreateTable
CREATE TABLE "courses" (
    "contentId" UUID NOT NULL,
    "lessonCount" INTEGER NOT NULL DEFAULT 0,
    "totalMinutes" INTEGER NOT NULL DEFAULT 0,
    "sequential" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "courses_pkey" PRIMARY KEY ("contentId")
);

-- CreateTable
CREATE TABLE "lessons" (
    "id" UUID NOT NULL,
    "courseId" UUID NOT NULL,
    "sequence" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "durationMinutes" INTEGER NOT NULL DEFAULT 0,
    "videoMediaId" UUID,
    "embedUrl" TEXT,
    "body" JSONB NOT NULL DEFAULT '[]',
    "practicePrompt" TEXT,
    "practiceSkillId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "lessons_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "lessons_sequence_check" CHECK ("sequence" >= 1),
    -- A lesson plays an uploaded video or an embedded player, never both.
    CONSTRAINT "lessons_one_player_check" CHECK ("videoMediaId" IS NULL OR "embedUrl" IS NULL)
);

-- CreateTable
CREATE TABLE "enrolments" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "courseId" UUID NOT NULL,
    "enrolledAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "enrolments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lesson_progress" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "lessonId" UUID NOT NULL,
    "status" "LessonProgressStatus" NOT NULL DEFAULT 'NOT_STARTED',
    "lastPositionSeconds" INTEGER NOT NULL DEFAULT 0,
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "lesson_progress_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "lesson_progress_position_check" CHECK ("lastPositionSeconds" >= 0),
    CONSTRAINT "lesson_progress_completed_check" CHECK (("status" = 'COMPLETED') = ("completedAt" IS NOT NULL))
);

-- CreateTable
CREATE TABLE "content_progress" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "contentId" UUID NOT NULL,
    "status" "LessonProgressStatus" NOT NULL DEFAULT 'IN_PROGRESS',
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "content_progress_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "content_progress_completed_check" CHECK (("status" = 'COMPLETED') = ("completedAt" IS NOT NULL))
);

-- CreateTable
CREATE TABLE "learning_activity_daily" (
    "userId" UUID NOT NULL,
    "date" DATE NOT NULL,
    "minutes" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "learning_activity_daily_pkey" PRIMARY KEY ("userId","date"),
    CONSTRAINT "learning_activity_daily_minutes_check" CHECK ("minutes" >= 0)
);

-- CreateTable
CREATE TABLE "certificates" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "courseId" UUID NOT NULL,
    "certificateNumber" TEXT NOT NULL,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "achievementId" UUID,

    CONSTRAINT "certificates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning_progress_overrides" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "courseId" UUID NOT NULL,
    "lessonId" UUID,
    "action" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "actorId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "learning_progress_overrides_pkey" PRIMARY KEY ("id")
);

-- Certificate numbers: ATC-{year}-{sequence}.
CREATE SEQUENCE "certificate_number_seq" START 1;

-- CreateIndex
CREATE UNIQUE INDEX "learning_contents_slug_key" ON "learning_contents"("slug");
CREATE INDEX "learning_contents_categoryId_status_type_idx" ON "learning_contents"("categoryId", "status", "type");
CREATE INDEX "learning_contents_status_featured_idx" ON "learning_contents"("status", "featured");
CREATE INDEX "learning_contents_search_vector_idx" ON "learning_contents" USING GIN ("searchVector");
CREATE INDEX "learning_contents_title_trgm" ON "learning_contents" USING GIN ("title" gin_trgm_ops);
CREATE INDEX "learning_content_disciplines_disciplineId_idx" ON "learning_content_disciplines"("disciplineId");
CREATE INDEX "learning_content_skills_skillId_idx" ON "learning_content_skills"("skillId");
CREATE UNIQUE INDEX "lessons_courseId_sequence_key" ON "lessons"("courseId", "sequence");
CREATE UNIQUE INDEX "enrolments_userId_courseId_key" ON "enrolments"("userId", "courseId");
CREATE INDEX "enrolments_userId_completedAt_idx" ON "enrolments"("userId", "completedAt");
CREATE UNIQUE INDEX "lesson_progress_userId_lessonId_key" ON "lesson_progress"("userId", "lessonId");
CREATE INDEX "lesson_progress_userId_updatedAt_idx" ON "lesson_progress"("userId", "updatedAt" DESC);
CREATE UNIQUE INDEX "content_progress_userId_contentId_key" ON "content_progress"("userId", "contentId");
CREATE INDEX "content_progress_userId_updatedAt_idx" ON "content_progress"("userId", "updatedAt" DESC);
CREATE UNIQUE INDEX "certificates_certificateNumber_key" ON "certificates"("certificateNumber");
CREATE UNIQUE INDEX "certificates_userId_courseId_key" ON "certificates"("userId", "courseId");
CREATE INDEX "learning_progress_overrides_userId_courseId_idx" ON "learning_progress_overrides"("userId", "courseId");

-- AddForeignKey
ALTER TABLE "learning_contents" ADD CONSTRAINT "learning_contents_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "learning_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "learning_contents" ADD CONSTRAINT "learning_contents_instructorUserId_fkey" FOREIGN KEY ("instructorUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "learning_contents" ADD CONSTRAINT "learning_contents_coverMediaId_fkey" FOREIGN KEY ("coverMediaId") REFERENCES "media_assets"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "learning_contents" ADD CONSTRAINT "learning_contents_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "learning_content_disciplines" ADD CONSTRAINT "learning_content_disciplines_contentId_fkey" FOREIGN KEY ("contentId") REFERENCES "learning_contents"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "learning_content_disciplines" ADD CONSTRAINT "learning_content_disciplines_disciplineId_fkey" FOREIGN KEY ("disciplineId") REFERENCES "disciplines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "learning_content_skills" ADD CONSTRAINT "learning_content_skills_contentId_fkey" FOREIGN KEY ("contentId") REFERENCES "learning_contents"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "learning_content_skills" ADD CONSTRAINT "learning_content_skills_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES "skills"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "courses" ADD CONSTRAINT "courses_contentId_fkey" FOREIGN KEY ("contentId") REFERENCES "learning_contents"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "lessons" ADD CONSTRAINT "lessons_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "courses"("contentId") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "lessons" ADD CONSTRAINT "lessons_videoMediaId_fkey" FOREIGN KEY ("videoMediaId") REFERENCES "media_assets"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "lessons" ADD CONSTRAINT "lessons_practiceSkillId_fkey" FOREIGN KEY ("practiceSkillId") REFERENCES "skills"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "enrolments" ADD CONSTRAINT "enrolments_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "enrolments" ADD CONSTRAINT "enrolments_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "courses"("contentId") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "lesson_progress" ADD CONSTRAINT "lesson_progress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "lesson_progress" ADD CONSTRAINT "lesson_progress_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "lessons"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "content_progress" ADD CONSTRAINT "content_progress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "content_progress" ADD CONSTRAINT "content_progress_contentId_fkey" FOREIGN KEY ("contentId") REFERENCES "learning_contents"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "learning_activity_daily" ADD CONSTRAINT "learning_activity_daily_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "certificates" ADD CONSTRAINT "certificates_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "certificates" ADD CONSTRAINT "certificates_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "courses"("contentId") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "certificates" ADD CONSTRAINT "certificates_achievementId_fkey" FOREIGN KEY ("achievementId") REFERENCES "achievements"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Row level security: deny-all for the Supabase client roles, full access for the backend role.
ALTER TABLE "learning_contents" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "learning_contents" FROM anon, authenticated;
GRANT ALL ON TABLE "learning_contents" TO atarah_backend;
ALTER TABLE "learning_content_disciplines" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "learning_content_disciplines" FROM anon, authenticated;
GRANT ALL ON TABLE "learning_content_disciplines" TO atarah_backend;
ALTER TABLE "learning_content_skills" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "learning_content_skills" FROM anon, authenticated;
GRANT ALL ON TABLE "learning_content_skills" TO atarah_backend;
ALTER TABLE "courses" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "courses" FROM anon, authenticated;
GRANT ALL ON TABLE "courses" TO atarah_backend;
ALTER TABLE "lessons" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "lessons" FROM anon, authenticated;
GRANT ALL ON TABLE "lessons" TO atarah_backend;
ALTER TABLE "enrolments" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "enrolments" FROM anon, authenticated;
GRANT ALL ON TABLE "enrolments" TO atarah_backend;
ALTER TABLE "lesson_progress" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "lesson_progress" FROM anon, authenticated;
GRANT ALL ON TABLE "lesson_progress" TO atarah_backend;
ALTER TABLE "content_progress" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "content_progress" FROM anon, authenticated;
GRANT ALL ON TABLE "content_progress" TO atarah_backend;
ALTER TABLE "learning_activity_daily" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "learning_activity_daily" FROM anon, authenticated;
GRANT ALL ON TABLE "learning_activity_daily" TO atarah_backend;
ALTER TABLE "certificates" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "certificates" FROM anon, authenticated;
GRANT ALL ON TABLE "certificates" TO atarah_backend;
ALTER TABLE "learning_progress_overrides" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "learning_progress_overrides" FROM anon, authenticated;
GRANT ALL ON TABLE "learning_progress_overrides" TO atarah_backend;
GRANT USAGE, SELECT ON SEQUENCE "certificate_number_seq" TO atarah_backend;
