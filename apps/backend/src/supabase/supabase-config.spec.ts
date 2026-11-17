import { readFileSync } from 'node:fs';
import path from 'node:path';

/** Reads `[section]` key = value pairs from the committed Supabase CLI config (a deliberately tiny TOML reader). */
function readToml(file: string): Map<string, string> {
  const out = new Map<string, string>();
  let section = '';
  for (const raw of readFileSync(file, 'utf8').split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const header = /^\[([^\]]+)\]$/.exec(line);
    if (header) {
      section = header[1]!;
      continue;
    }
    const kv = /^([A-Za-z0-9_.-]+)\s*=\s*(.+)$/.exec(line);
    if (kv) out.set(`${section}.${kv[1]}`, kv[2]!.replace(/\s+#.*$/, '').trim());
  }
  return out;
}

const config = readToml(path.resolve(__dirname, '../../../../supabase/config.toml'));

/** Guards the Auth settings that Master Prompt 5.5 fixes, so a config edit cannot silently weaken them. */
describe('supabase/config.toml matches Master Prompt 5.5 and 5.7', () => {
  it.each([
    ['auth.email.otp_length', '6'],
    ['auth.email.otp_expiry', '600'],
    ['auth.email.max_frequency', '"60s"'],
    ['auth.email.enable_confirmations', 'true'],
    ['auth.sms.enable_confirmations', 'true'],
    ['auth.sms.max_frequency', '"60s"'],
    ['auth.minimum_password_length', '8'],
    ['auth.password_requirements', '"letters_digits"'],
    ['auth.enable_refresh_token_rotation', 'true'],
    ['auth.jwt_expiry', '3600'],
    ['auth.enable_anonymous_sign_ins', 'false'],
    ['auth.mfa.totp.enroll_enabled', 'true'],
    ['auth.mfa.totp.verify_enabled', 'true'],
    ['auth.mfa.phone.enroll_enabled', 'true'],
    ['auth.mfa.phone.verify_enabled', 'true'],
    ['auth.mfa.phone.otp_length', '6'],
    ['auth.hook.send_sms.enabled', 'true'],
    ['storage.buckets.public-media.public', 'true'],
    ['storage.buckets.private-media.public', 'false'],
    ['storage.buckets.verification-evidence.public', 'false'],
    ['db.pooler.enabled', 'true'],
    ['db.pooler.pool_mode', '"transaction"'],
  ])('%s = %s', (key, expected) => {
    expect(config.get(key)).toBe(expected);
  });

  it('points the Send SMS hook at the signed backend endpoint and keeps its secret out of the file', () => {
    expect(config.get('auth.hook.send_sms.uri')).toContain('/api/v1/auth/hooks/send-sms');
    expect(config.get('auth.hook.send_sms.secrets')).toBe('"env(SEND_SMS_HOOK_SECRET)"');
  });
});
