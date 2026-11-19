-- P2-M7: Creative CV / EPK documents, PDF builds and revocable share links. Hand-written (DEC-061 convention).
-- RLS on, client roles get nothing; the backend role has full access.

CREATE TYPE "DocumentRenderStatus" AS ENUM ('QUEUED', 'PROCESSING', 'READY', 'FAILED');

CREATE TABLE "creative_documents" (
    "id" UUID NOT NULL,
    "profileId" UUID NOT NULL,
    "format" "CreativeDocumentFormat" NOT NULL,
    "sections" "ProfileSection"[],
    "projectIds" UUID[],
    "restricted" "ProfileSection"[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "creative_documents_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "creative_document_renders" (
    "id" UUID NOT NULL,
    "documentId" UUID NOT NULL,
    "status" "DocumentRenderStatus" NOT NULL DEFAULT 'QUEUED',
    "objectKey" TEXT,
    "sizeBytes" INTEGER,
    "error" TEXT,
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "readyAt" TIMESTAMP(3),

    CONSTRAINT "creative_document_renders_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "document_share_links" (
    "id" UUID NOT NULL,
    "documentId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "tokenHint" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "document_share_links_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "creative_documents_profileId_format_key" ON "creative_documents"("profileId", "format");
CREATE INDEX "creative_document_renders_documentId_requestedAt_idx" ON "creative_document_renders"("documentId", "requestedAt" DESC);
CREATE INDEX "creative_document_renders_status_requestedAt_idx" ON "creative_document_renders"("status", "requestedAt");
CREATE UNIQUE INDEX "document_share_links_tokenHash_key" ON "document_share_links"("tokenHash");
CREATE INDEX "document_share_links_documentId_createdAt_idx" ON "document_share_links"("documentId", "createdAt" DESC);

ALTER TABLE "creative_documents" ADD CONSTRAINT "creative_documents_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "creative_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "creative_document_renders" ADD CONSTRAINT "creative_document_renders_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES "creative_documents"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "document_share_links" ADD CONSTRAINT "document_share_links_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES "creative_documents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Row level security: deny-all for the Supabase client roles, full access for the backend role.
ALTER TABLE "creative_documents" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "creative_documents" FROM anon, authenticated;
GRANT ALL ON TABLE "creative_documents" TO atarah_backend;
ALTER TABLE "creative_document_renders" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "creative_document_renders" FROM anon, authenticated;
GRANT ALL ON TABLE "creative_document_renders" TO atarah_backend;
ALTER TABLE "document_share_links" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "document_share_links" FROM anon, authenticated;
GRANT ALL ON TABLE "document_share_links" TO atarah_backend;
