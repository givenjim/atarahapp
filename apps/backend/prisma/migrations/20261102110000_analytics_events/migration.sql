-- P1-M12: analytics events (partitioned monthly), their daily roll-up, a registration trigger, and temporary
-- suspensions (`users.suspendedUntil`). Hand-written (DEC-061). RLS on, client roles get nothing.

-- Temporary suspension: the account is reactivated by an hourly job once this time has passed.
ALTER TABLE "users" ADD COLUMN "suspendedUntil" TIMESTAMP(3);

-- ---- analytics_events: partitioned by month on "occurredAt" ----------------------------------------------------
CREATE TABLE "analytics_events" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "occurredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name" TEXT NOT NULL,
    "actorHash" TEXT,
    "props" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "analytics_events_pkey" PRIMARY KEY ("id","occurredAt"),
    CONSTRAINT "analytics_events_name_check" CHECK (char_length("name") BETWEEN 1 AND 64)
) PARTITION BY RANGE ("occurredAt");

-- Strays (clock skew, a missed job run) land here instead of failing the insert.
CREATE TABLE "analytics_events_default" PARTITION OF "analytics_events" DEFAULT;

-- Partitions for the previous month and the next three; the nightly job keeps creating the following months.
CREATE OR REPLACE FUNCTION atarah_ensure_analytics_partition(month_start date) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  part_name text := 'analytics_events_' || to_char(month_start, 'YYYY_MM');
BEGIN
  IF to_regclass('public.' || part_name) IS NULL THEN
    EXECUTE format(
      'CREATE TABLE public.%I PARTITION OF public.analytics_events FOR VALUES FROM (%L) TO (%L)',
      part_name, month_start, (month_start + interval '1 month')::date);
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', part_name);
    EXECUTE format('REVOKE ALL ON TABLE public.%I FROM anon, authenticated', part_name);
    EXECUTE format('GRANT ALL ON TABLE public.%I TO atarah_backend', part_name);
  END IF;
END $$;

DO $$
DECLARE m date := date_trunc('month', now() - interval '1 month')::date;
BEGIN
  FOR i IN 0..4 LOOP
    PERFORM atarah_ensure_analytics_partition((m + (i || ' month')::interval)::date);
  END LOOP;
END $$;

CREATE INDEX "analytics_events_name_occurredAt_idx" ON "analytics_events"("name", "occurredAt" DESC);
CREATE INDEX "analytics_events_occurredAt_idx" ON "analytics_events"("occurredAt" DESC);

-- ---- analytics_daily_counts ------------------------------------------------------------------------------------
CREATE TABLE "analytics_daily_counts" (
    "date" DATE NOT NULL,
    "name" TEXT NOT NULL,
    "events" INTEGER NOT NULL DEFAULT 0,
    "actors" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "analytics_daily_counts_pkey" PRIMARY KEY ("date","name")
);

-- ---- registration: one event for every new account (no actor, only how they signed up) ----------------------------
CREATE OR REPLACE FUNCTION atarah_track_registration() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO analytics_events ("id", "occurredAt", "name", "actorHash", "props")
  VALUES (gen_random_uuid(), now(), 'registration', NULL,
    jsonb_build_object('method', CASE WHEN NEW."email" IS NOT NULL THEN 'email' WHEN NEW."phone" IS NOT NULL THEN 'phone' ELSE 'unknown' END));
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Analytics must never be the reason an account cannot be created.
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION atarah_track_registration() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION atarah_ensure_analytics_partition(date) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION atarah_ensure_analytics_partition(date) TO atarah_backend;

-- Retention: drops whole monthly partitions that end before the given date. Returns how many were dropped.
CREATE OR REPLACE FUNCTION atarah_drop_old_analytics_partitions(before date) RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE r record; dropped integer := 0;
BEGIN
  FOR r IN
    SELECT c.relname FROM pg_inherits i
    JOIN pg_class c ON c.oid = i.inhrelid
    JOIN pg_class p ON p.oid = i.inhparent
    WHERE p.relname = 'analytics_events' AND c.relname ~ '^analytics_events_[0-9]{4}_[0-9]{2}$'
  LOOP
    IF (to_date(substring(r.relname from '([0-9]{4}_[0-9]{2})$'), 'YYYY_MM') + interval '1 month')::date <= before THEN
      EXECUTE format('DROP TABLE public.%I', r.relname);
      dropped := dropped + 1;
    END IF;
  END LOOP;
  RETURN dropped;
END $$;
REVOKE ALL ON FUNCTION atarah_drop_old_analytics_partitions(date) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION atarah_drop_old_analytics_partitions(date) TO atarah_backend;

CREATE TRIGGER "users_track_registration" AFTER INSERT ON "users"
  FOR EACH ROW EXECUTE FUNCTION atarah_track_registration();

-- ---- Row level security ----------------------------------------------------------------------------------------
ALTER TABLE "analytics_events" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "analytics_events" FROM anon, authenticated;
GRANT ALL ON TABLE "analytics_events" TO atarah_backend;
ALTER TABLE "analytics_events_default" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "analytics_events_default" FROM anon, authenticated;
GRANT ALL ON TABLE "analytics_events_default" TO atarah_backend;
ALTER TABLE "analytics_daily_counts" ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE "analytics_daily_counts" FROM anon, authenticated;
GRANT ALL ON TABLE "analytics_daily_counts" TO atarah_backend;
