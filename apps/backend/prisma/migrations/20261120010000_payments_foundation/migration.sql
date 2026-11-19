-- P2-M1: payments foundation (payments, events, refunds, ledger, payouts).
-- Hand-written (DEC-061). Columns follow the camelCase convention; tables are snake_case plural. RLS is enabled on
-- every table and only the backend role is granted access (the Supabase client roles get nothing).

-- CreateEnum
CREATE TYPE "PaymentProviderKey" AS ENUM ('MPESA_DARAJA', 'CARD');

-- CreateEnum
CREATE TYPE "PaymentEventKind" AS ENUM ('INITIATED', 'CALLBACK', 'STATUS_QUERY', 'STATUS_CHANGE', 'REFUND', 'REVIEW');

-- CreateEnum
CREATE TYPE "PaymentEventSource" AS ENUM ('API', 'PROVIDER_CALLBACK', 'STATUS_QUERY', 'JOB', 'ADMIN');

-- CreateEnum
CREATE TYPE "RefundStatus" AS ENUM ('PENDING', 'SUCCEEDED', 'FAILED');

-- CreateEnum
CREATE TYPE "LedgerEntryType" AS ENUM ('PAYMENT', 'REFUND');

-- CreateEnum
CREATE TYPE "PayoutStatus" AS ENUM ('PENDING', 'PAID', 'FAILED');

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL,
    "purpose" "PaymentPurpose" NOT NULL,
    "referenceType" TEXT,
    "referenceId" UUID,
    "payerId" UUID NOT NULL,
    "payeeId" UUID,
    "amountMinor" BIGINT NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'KES',
    "platformFeeMinor" BIGINT NOT NULL DEFAULT 0,
    "refundedMinor" BIGINT NOT NULL DEFAULT 0,
    "method" "PaymentMethod" NOT NULL,
    "provider" "PaymentProviderKey" NOT NULL,
    "providerReference" TEXT,
    "merchantReference" TEXT,
    "receiptNumber" TEXT,
    "msisdnLast4" VARCHAR(4),
    "status" "PaymentStatus" NOT NULL DEFAULT 'INITIATED',
    "idempotencyKey" TEXT NOT NULL,
    "failureCode" TEXT,
    "failureReason" TEXT,
    "description" TEXT,
    "expiresAt" TIMESTAMP(3),
    "lastQueriedAt" TIMESTAMP(3),
    "queryAttempts" INTEGER NOT NULL DEFAULT 0,
    "initiatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),
    "version" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "payments_amount_positive_check" CHECK ("amountMinor" > 0),
    CONSTRAINT "payments_fee_range_check" CHECK ("platformFeeMinor" >= 0 AND "platformFeeMinor" <= "amountMinor"),
    CONSTRAINT "payments_refunded_range_check" CHECK ("refundedMinor" >= 0 AND "refundedMinor" <= "amountMinor"),
    CONSTRAINT "payments_reference_pair_check" CHECK (("referenceType" IS NULL) = ("referenceId" IS NULL))
);

-- CreateTable
CREATE TABLE "payment_events" (
    "id" UUID NOT NULL,
    "paymentId" UUID NOT NULL,
    "kind" "PaymentEventKind" NOT NULL,
    "source" "PaymentEventSource" NOT NULL,
    "fromStatus" "PaymentStatus",
    "toStatus" "PaymentStatus",
    "summary" TEXT NOT NULL,
    "payloadEncrypted" TEXT,
    "dedupeKey" TEXT,
    "actorId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refunds" (
    "id" UUID NOT NULL,
    "paymentId" UUID NOT NULL,
    "amountMinor" BIGINT NOT NULL,
    "reason" TEXT NOT NULL,
    "status" "RefundStatus" NOT NULL DEFAULT 'PENDING',
    "mode" TEXT NOT NULL DEFAULT 'AUTOMATIC',
    "providerReference" TEXT,
    "failureReason" TEXT,
    "requestedById" UUID,
    "idempotencyKey" TEXT,
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "refunds_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "refunds_amount_positive_check" CHECK ("amountMinor" > 0),
    CONSTRAINT "refunds_mode_check" CHECK ("mode" IN ('AUTOMATIC', 'MANUAL'))
);

-- CreateTable
CREATE TABLE "transactions" (
    "id" UUID NOT NULL,
    "paymentId" UUID NOT NULL,
    "refundId" UUID,
    "type" "LedgerEntryType" NOT NULL,
    "payerId" UUID NOT NULL,
    "payeeId" UUID,
    "grossMinor" BIGINT NOT NULL,
    "platformFeeMinor" BIGINT NOT NULL,
    "netMinor" BIGINT NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "transactions_balance_check" CHECK ("grossMinor" = "platformFeeMinor" + "netMinor"),
    -- A refund row is negative and names its refund; a payment row is positive and names no refund.
    CONSTRAINT "transactions_sign_check" CHECK (
      ("type" = 'PAYMENT' AND "grossMinor" > 0 AND "refundId" IS NULL)
      OR ("type" = 'REFUND' AND "grossMinor" < 0 AND "refundId" IS NOT NULL)
    )
);

-- CreateTable
CREATE TABLE "payouts" (
    "id" UUID NOT NULL,
    "payeeId" UUID NOT NULL,
    "amountMinor" BIGINT NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'KES',
    "status" "PayoutStatus" NOT NULL DEFAULT 'PENDING',
    "periodStart" TIMESTAMP(3),
    "periodEnd" TIMESTAMP(3),
    "providerReference" TEXT,
    "note" TEXT,
    "paidAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payouts_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "payouts_amount_positive_check" CHECK ("amountMinor" > 0)
);

-- CreateIndex
CREATE UNIQUE INDEX "payments_payerId_idempotencyKey_key" ON "payments"("payerId", "idempotencyKey");
CREATE UNIQUE INDEX "payments_provider_providerReference_key" ON "payments"("provider", "providerReference");
CREATE INDEX "payments_payerId_createdAt_idx" ON "payments"("payerId", "createdAt" DESC);
CREATE INDEX "payments_status_expiresAt_idx" ON "payments"("status", "expiresAt");
CREATE INDEX "payments_referenceType_referenceId_idx" ON "payments"("referenceType", "referenceId");
CREATE UNIQUE INDEX "payment_events_dedupeKey_key" ON "payment_events"("dedupeKey");
CREATE INDEX "payment_events_paymentId_createdAt_idx" ON "payment_events"("paymentId", "createdAt");
CREATE UNIQUE INDEX "refunds_paymentId_idempotencyKey_key" ON "refunds"("paymentId", "idempotencyKey");
CREATE INDEX "refunds_paymentId_idx" ON "refunds"("paymentId");
CREATE UNIQUE INDEX "transactions_refundId_key" ON "transactions"("refundId");
CREATE INDEX "transactions_paymentId_idx" ON "transactions"("paymentId");
CREATE INDEX "transactions_payeeId_createdAt_idx" ON "transactions"("payeeId", "createdAt");
CREATE INDEX "payouts_payeeId_status_idx" ON "payouts"("payeeId", "status");
-- One payment row of the ledger per payment: a repeated callback can never credit twice.
CREATE UNIQUE INDEX "transactions_one_payment_row" ON "transactions"("paymentId") WHERE "type" = 'PAYMENT';

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_payerId_fkey" FOREIGN KEY ("payerId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "payment_events" ADD CONSTRAINT "payment_events_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "payments"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "refunds" ADD CONSTRAINT "refunds_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "payments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_paymentId_fkey" FOREIGN KEY ("paymentId") REFERENCES "payments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_refundId_fkey" FOREIGN KEY ("refundId") REFERENCES "refunds"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- The ledger is append-only: reject UPDATE and DELETE.
CREATE OR REPLACE FUNCTION payments_ledger_reject_mutation() RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $fn$
BEGIN
  RAISE EXCEPTION 'transactions is append-only: % is not permitted', TG_OP
    USING ERRCODE = 'restrict_violation';
END;
$fn$;

REVOKE ALL ON FUNCTION public.payments_ledger_reject_mutation() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER transactions_no_update_delete
  BEFORE UPDATE OR DELETE ON "transactions"
  FOR EACH ROW EXECUTE FUNCTION payments_ledger_reject_mutation();

-- Row level security: deny-all for the Supabase client roles, full access for the backend role.
ALTER TABLE "payments" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "payments" FROM anon, authenticated;
GRANT ALL ON TABLE "payments" TO atarah_backend;
ALTER TABLE "payment_events" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "payment_events" FROM anon, authenticated;
GRANT ALL ON TABLE "payment_events" TO atarah_backend;
ALTER TABLE "refunds" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "refunds" FROM anon, authenticated;
GRANT ALL ON TABLE "refunds" TO atarah_backend;
ALTER TABLE "transactions" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "transactions" FROM anon, authenticated;
GRANT ALL ON TABLE "transactions" TO atarah_backend;
ALTER TABLE "payouts" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "payouts" FROM anon, authenticated;
GRANT ALL ON TABLE "payouts" TO atarah_backend;
