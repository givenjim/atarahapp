-- CI guard (Master Prompt 5.7 rule 2, P1-M6): fails if any table in `public` has Row Level Security disabled,
-- has a policy that is not on the allow-list, or is reachable by the `anon` / `authenticated` roles beyond the
-- single allowed grant. Run with:  node scripts/check-rls.mjs   (or psql -v ON_ERROR_STOP=1 -f scripts/check-rls.sql)
--
-- Allow-list: public.notifications has exactly one policy, `notifications_select_own` (SELECT for `authenticated`,
-- "userId" = auth.uid()), so the app can subscribe to its own new notifications through Realtime.
DO $$
DECLARE
  bad text;
BEGIN
  SELECT string_agg(tablename, ', ' ORDER BY tablename) INTO bad
  FROM pg_tables WHERE schemaname = 'public' AND NOT rowsecurity;
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION 'Row Level Security is disabled on: %', bad;
  END IF;

  SELECT string_agg(tablename || '.' || policyname, ', ' ORDER BY tablename, policyname) INTO bad
  FROM pg_policies
  WHERE schemaname = 'public' AND (tablename, policyname) NOT IN (('notifications', 'notifications_select_own'));
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION 'Policies that are not on the allow-list: %', bad;
  END IF;

  SELECT string_agg(grantee || ' ' || privilege_type || ' on ' || table_name, ', ' ORDER BY table_name, grantee, privilege_type) INTO bad
  FROM information_schema.role_table_grants
  WHERE table_schema = 'public'
    AND grantee IN ('anon', 'authenticated')
    AND NOT (table_name = 'notifications' AND grantee = 'authenticated' AND privilege_type = 'SELECT');
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION 'anon/authenticated hold table privileges: %', bad;
  END IF;

  SELECT string_agg(p.proname, ', ' ORDER BY p.proname) INTO bad
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public'
    AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.objid = p.oid AND d.deptype = 'e') -- not an extension's
    AND has_function_privilege('anon', p.oid, 'EXECUTE');
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION 'anon can execute public functions: %', bad;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'notifications') THEN
    RAISE EXCEPTION 'notifications is not published to Realtime';
  END IF;
  SELECT string_agg(tablename, ', ' ORDER BY tablename) INTO bad
  FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND NOT (schemaname = 'public' AND tablename = 'notifications');
  IF bad IS NOT NULL THEN
    RAISE EXCEPTION 'Tables other than notifications are published to Realtime: %', bad;
  END IF;
END $$;
