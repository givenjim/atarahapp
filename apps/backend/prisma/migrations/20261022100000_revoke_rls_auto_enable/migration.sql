-- Supabase's "Enable automatic RLS" project option creates public.rls_auto_enable() (an event-trigger function).
-- Its default PUBLIC execute grant would let the anon key call it, so remove it. No-op where the function does not exist.
DO $$
BEGIN
  IF to_regprocedure('public.rls_auto_enable()') IS NOT NULL THEN
    REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
  END IF;
END $$;
