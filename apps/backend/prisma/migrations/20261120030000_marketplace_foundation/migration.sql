-- P2-M3: marketplace foundation (sellers, listings, media, portfolio links, enquiries, reviews, reports, views).
-- Hand-written (DEC-061); the table and index statements below were produced by `prisma migrate diff` and then
-- extended by hand with the generated search vector, CHECK constraints, the partial unique index and RLS.
-- No checkout, escrow or payouts (Master Prompt section 4.2).

-- CreateEnum
CREATE TYPE "SellerStatus" AS ENUM ('ACTIVE', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "ReviewVisibility" AS ENUM ('VISIBLE', 'HIDDEN');

-- CreateEnum
CREATE TYPE "ListingReportStatus" AS ENUM ('OPEN', 'RESOLVED', 'DISMISSED');

-- CreateTable
CREATE TABLE "seller_profiles" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "status" "SellerStatus" NOT NULL DEFAULT 'ACTIVE',
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'NOT_SUBMITTED',
    "termsVersion" TEXT NOT NULL,
    "termsAcceptedAt" TIMESTAMP(3) NOT NULL,
    "canPublishDirectly" BOOLEAN NOT NULL DEFAULT false,
    "suspendedReason" TEXT,
    "suspendedAt" TIMESTAMP(3),
    "ratingAverage" DOUBLE PRECISION,
    "ratingCount" INTEGER NOT NULL DEFAULT 0,
    "completedCount" INTEGER NOT NULL DEFAULT 0,
    "medianReplyMinutes" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "seller_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listings" (
    "id" UUID NOT NULL,
    "sellerId" UUID NOT NULL,
    "type" "ListingType" NOT NULL,
    "title" TEXT NOT NULL,
    "categoryId" UUID NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "includedItems" JSONB NOT NULL DEFAULT '[]',
    "deliveryDays" INTEGER,
    "workMode" "WorkMode" NOT NULL DEFAULT 'REMOTE',
    "locationText" TEXT,
    "audienceText" TEXT,
    "pricingType" "PricingType" NOT NULL DEFAULT 'ON_REQUEST',
    "priceMinMinor" INTEGER,
    "priceMaxMinor" INTEGER,
    "currency" CHAR(3) NOT NULL DEFAULT 'KES',
    "status" "ListingStatus" NOT NULL DEFAULT 'DRAFT',
    "rejectionReason" TEXT,
    "suspendedReason" TEXT,
    "featuredUntil" TIMESTAMP(3),
    "publishedAt" TIMESTAMP(3),
    "profileServiceId" UUID,
    "searchVector" tsvector GENERATED ALWAYS AS (setweight(to_tsvector('simple', coalesce("title", '')), 'A') || setweight(to_tsvector('simple', coalesce("description", '')), 'B')) STORED,
    "isDemo" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "listings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listing_media" (
    "id" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "mediaId" UUID NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "listing_media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listing_portfolio_links" (
    "id" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "listing_portfolio_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listing_reviews" (
    "id" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "enquiryId" UUID NOT NULL,
    "reviewerId" UUID NOT NULL,
    "rating" INTEGER NOT NULL,
    "body" TEXT,
    "status" "ReviewVisibility" NOT NULL DEFAULT 'VISIBLE',
    "hiddenReason" TEXT,
    "hiddenById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "listing_reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "enquiries" (
    "id" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "buyerId" UUID NOT NULL,
    "sellerUserId" UUID NOT NULL,
    "message" TEXT NOT NULL,
    "budgetMinor" INTEGER,
    "preferredTiming" TEXT,
    "status" "EnquiryStatus" NOT NULL DEFAULT 'NEW',
    "firstReplyAt" TIMESTAMP(3),
    "lastMessageAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "buyerReadAt" TIMESTAMP(3),
    "sellerReadAt" TIMESTAMP(3),
    "closedAt" TIMESTAMP(3),
    "closedById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "enquiries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "enquiry_messages" (
    "id" UUID NOT NULL,
    "enquiryId" UUID NOT NULL,
    "senderId" UUID NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "enquiry_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listing_reports" (
    "id" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "reporterId" UUID NOT NULL,
    "reason" "ReportReason" NOT NULL,
    "note" TEXT,
    "status" "ListingReportStatus" NOT NULL DEFAULT 'OPEN',
    "resolution" TEXT,
    "resolvedById" UUID,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "listing_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listing_views" (
    "id" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "viewerId" UUID NOT NULL,
    "viewedOn" DATE NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "listing_views_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "seller_profiles_userId_key" ON "seller_profiles"("userId");

-- CreateIndex
CREATE INDEX "seller_profiles_status_idx" ON "seller_profiles"("status");

-- CreateIndex
CREATE UNIQUE INDEX "listings_profileServiceId_key" ON "listings"("profileServiceId");

-- CreateIndex
CREATE INDEX "listings_status_publishedAt_idx" ON "listings"("status", "publishedAt" DESC);

-- CreateIndex
CREATE INDEX "listings_sellerId_status_idx" ON "listings"("sellerId", "status");

-- CreateIndex
CREATE INDEX "listings_categoryId_status_idx" ON "listings"("categoryId", "status");

-- CreateIndex
CREATE INDEX "listings_search_vector_idx" ON "listings" USING GIN ("searchVector");

-- CreateIndex
CREATE INDEX "listings_title_trgm" ON "listings" USING GIN ("title" gin_trgm_ops);

-- CreateIndex
CREATE INDEX "listing_media_listingId_sortOrder_idx" ON "listing_media"("listingId", "sortOrder");

-- CreateIndex
CREATE UNIQUE INDEX "listing_media_listingId_mediaId_key" ON "listing_media"("listingId", "mediaId");

-- CreateIndex
CREATE INDEX "listing_portfolio_links_projectId_idx" ON "listing_portfolio_links"("projectId");

-- CreateIndex
CREATE UNIQUE INDEX "listing_portfolio_links_listingId_projectId_key" ON "listing_portfolio_links"("listingId", "projectId");

-- CreateIndex
CREATE UNIQUE INDEX "listing_reviews_enquiryId_key" ON "listing_reviews"("enquiryId");

-- CreateIndex
CREATE INDEX "listing_reviews_listingId_status_createdAt_idx" ON "listing_reviews"("listingId", "status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "enquiries_sellerUserId_status_lastMessageAt_idx" ON "enquiries"("sellerUserId", "status", "lastMessageAt" DESC);

-- CreateIndex
CREATE INDEX "enquiries_buyerId_lastMessageAt_idx" ON "enquiries"("buyerId", "lastMessageAt" DESC);

-- CreateIndex
CREATE INDEX "enquiries_listingId_buyerId_idx" ON "enquiries"("listingId", "buyerId");

-- CreateIndex
CREATE INDEX "enquiry_messages_enquiryId_createdAt_idx" ON "enquiry_messages"("enquiryId", "createdAt");

-- CreateIndex
CREATE INDEX "listing_reports_status_createdAt_idx" ON "listing_reports"("status", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "listing_reports_listingId_reporterId_key" ON "listing_reports"("listingId", "reporterId");

-- CreateIndex
CREATE INDEX "listing_views_listingId_viewedOn_idx" ON "listing_views"("listingId", "viewedOn");

-- CreateIndex
CREATE UNIQUE INDEX "listing_views_listingId_viewerId_viewedOn_key" ON "listing_views"("listingId", "viewerId", "viewedOn");

-- AddForeignKey
ALTER TABLE "seller_profiles" ADD CONSTRAINT "seller_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES "seller_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "marketplace_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_profileServiceId_fkey" FOREIGN KEY ("profileServiceId") REFERENCES "profile_services"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_media" ADD CONSTRAINT "listing_media_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_media" ADD CONSTRAINT "listing_media_mediaId_fkey" FOREIGN KEY ("mediaId") REFERENCES "media_assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_portfolio_links" ADD CONSTRAINT "listing_portfolio_links_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_portfolio_links" ADD CONSTRAINT "listing_portfolio_links_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_reviews" ADD CONSTRAINT "listing_reviews_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_reviews" ADD CONSTRAINT "listing_reviews_enquiryId_fkey" FOREIGN KEY ("enquiryId") REFERENCES "enquiries"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_reviews" ADD CONSTRAINT "listing_reviews_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enquiries" ADD CONSTRAINT "enquiries_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enquiries" ADD CONSTRAINT "enquiries_buyerId_fkey" FOREIGN KEY ("buyerId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enquiries" ADD CONSTRAINT "enquiries_sellerUserId_fkey" FOREIGN KEY ("sellerUserId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enquiry_messages" ADD CONSTRAINT "enquiry_messages_enquiryId_fkey" FOREIGN KEY ("enquiryId") REFERENCES "enquiries"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enquiry_messages" ADD CONSTRAINT "enquiry_messages_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_reports" ADD CONSTRAINT "listing_reports_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_reports" ADD CONSTRAINT "listing_reports_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_views" ADD CONSTRAINT "listing_views_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_views" ADD CONSTRAINT "listing_views_viewerId_fkey" FOREIGN KEY ("viewerId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Business rules the database enforces as a last line of defence.
ALTER TABLE "listing_reviews" ADD CONSTRAINT "listing_reviews_rating_check" CHECK ("rating" BETWEEN 1 AND 5);
ALTER TABLE "listings" ADD CONSTRAINT "listings_price_check" CHECK (
  ("pricingType" = 'ON_REQUEST' AND "priceMinMinor" IS NULL AND "priceMaxMinor" IS NULL)
  OR ("pricingType" = 'FIXED' AND "priceMinMinor" IS NOT NULL AND "priceMinMinor" >= 0 AND "priceMaxMinor" IS NULL)
  OR ("pricingType" = 'RANGE' AND "priceMinMinor" IS NOT NULL AND "priceMaxMinor" IS NOT NULL AND "priceMinMinor" >= 0 AND "priceMaxMinor" >= "priceMinMinor")
);
ALTER TABLE "enquiries" ADD CONSTRAINT "enquiries_parties_check" CHECK ("buyerId" <> "sellerUserId");

-- One open enquiry per buyer and listing (a closed one does not block a new request).
CREATE UNIQUE INDEX "enquiries_one_open_per_buyer_listing" ON "enquiries" ("listingId", "buyerId") WHERE "status" <> 'CLOSED';

-- RLS: deny-all for the Supabase client roles; only the backend role reads and writes.
ALTER TABLE "seller_profiles" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "seller_profiles" FROM anon, authenticated;
GRANT ALL ON TABLE "seller_profiles" TO atarah_backend;
ALTER TABLE "listings" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "listings" FROM anon, authenticated;
GRANT ALL ON TABLE "listings" TO atarah_backend;
ALTER TABLE "listing_media" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "listing_media" FROM anon, authenticated;
GRANT ALL ON TABLE "listing_media" TO atarah_backend;
ALTER TABLE "listing_portfolio_links" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "listing_portfolio_links" FROM anon, authenticated;
GRANT ALL ON TABLE "listing_portfolio_links" TO atarah_backend;
ALTER TABLE "listing_reviews" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "listing_reviews" FROM anon, authenticated;
GRANT ALL ON TABLE "listing_reviews" TO atarah_backend;
ALTER TABLE "enquiries" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "enquiries" FROM anon, authenticated;
GRANT ALL ON TABLE "enquiries" TO atarah_backend;
ALTER TABLE "enquiry_messages" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "enquiry_messages" FROM anon, authenticated;
GRANT ALL ON TABLE "enquiry_messages" TO atarah_backend;
ALTER TABLE "listing_reports" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "listing_reports" FROM anon, authenticated;
GRANT ALL ON TABLE "listing_reports" TO atarah_backend;
ALTER TABLE "listing_views" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "listing_views" FROM anon, authenticated;
GRANT ALL ON TABLE "listing_views" TO atarah_backend;
