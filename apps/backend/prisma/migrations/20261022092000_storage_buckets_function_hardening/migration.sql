-- P1-M6: the three storage buckets exist in every environment (local config.toml also creates them), and
-- Atarah's own trigger function is not callable by the client roles.

-- Buckets (Master Prompt 5.7 rule 5): everything private except public-media. Storage RLS has no policies for
-- these buckets, so clients cannot read or write objects directly; the backend issues signed URLs.
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES
  ('public-media', 'public-media', true, 52428800),
  ('private-media', 'private-media', false, 209715200),
  ('verification-evidence', 'verification-evidence', false, 10485760)
ON CONFLICT (id) DO NOTHING;

REVOKE ALL ON FUNCTION public.audit_logs_reject_mutation() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.audit_logs_reject_mutation() TO atarah_backend;
