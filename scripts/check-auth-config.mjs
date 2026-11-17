// P1-M12 audit: compares the local Supabase Auth settings (supabase/config.toml) with Master Prompt section 5.5 and
// prints PASS, WARN or FAIL for each. WARN is a mismatch the platform cannot express or that is only fixable in the
// cloud project (printed with the reason); FAIL exits 1.
//
//   node scripts/check-auth-config.mjs
//
// The cloud project's settings are pushed with scripts/push-auth-config.mjs; this script reads the file that script
// and the local stack share, so a PASS here is what the cloud project receives too.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const toml = readFileSync(join(root, 'supabase', 'config.toml'), 'utf8');

/** `[section]` body without comments, and a value lookup inside it. */
function section(name) {
  const lines = toml.split(/\r?\n/);
  const start = lines.findIndex((l) => l.trim() === `[${name}]`);
  if (start < 0) return null;
  const body = [];
  for (let i = start + 1; i < lines.length; i += 1) {
    if (/^\s*\[/.test(lines[i])) break;
    if (!/^\s*#/.test(lines[i])) body.push(lines[i]);
  }
  return body;
}
function value(sectionName, key) {
  const body = section(sectionName);
  if (!body) return undefined;
  const line = body.find((l) => new RegExp(`^\\s*${key}\\s*=`).test(l));
  if (!line) return undefined;
  const raw = line.slice(line.indexOf('=') + 1).trim().replace(/\s+#.*$/, '');
  if (raw === 'true') return true;
  if (raw === 'false') return false;
  if (/^-?\d+$/.test(raw)) return Number(raw);
  return raw.replace(/^"|"$/g, '');
}

const results = [];
const check = (state, what, detail = '') => results.push({ state, what, detail });
const expectEq = (sec, key, want, what, how = 'FAIL') => {
  const got = value(sec, key);
  if (got === want) check('PASS', what, `${key} = ${got}`);
  else check(how, what, `${sec}.${key} is ${got === undefined ? 'not set' : got}, the spec says ${want}`);
};

// Passwords: at least 8 characters including a number.
expectEq('auth', 'minimum_password_length', 8, 'Password minimum length is 8');
const reqs = value('auth', 'password_requirements');
if (['letters_digits', 'lower_upper_letters_digits', 'lower_upper_letters_digits_symbols'].includes(reqs)) check('PASS', 'Passwords must include a number', `password_requirements = ${reqs}`);
else check('FAIL', 'Passwords must include a number', `password_requirements is ${reqs}`);
// Sessions: 1 hour access tokens, rotating refresh tokens with reuse detection.
expectEq('auth', 'jwt_expiry', 3600, 'Access tokens last 1 hour');
expectEq('auth', 'enable_refresh_token_rotation', true, 'Refresh tokens rotate (reuse detection on)');
const reuse = value('auth', 'refresh_token_reuse_interval');
if (typeof reuse === 'number' && reuse <= 30) check('PASS', 'Refresh token reuse window is short', `refresh_token_reuse_interval = ${reuse} s`);
else check('FAIL', 'Refresh token reuse window is short', `refresh_token_reuse_interval is ${reuse}`);
expectEq('auth', 'enable_anonymous_sign_ins', false, 'Anonymous sign-ins are off');
// Email: 6-digit code, 10 minute expiry, 60 s resend cooldown, confirmations on.
expectEq('auth.email', 'otp_length', 6, 'Email code is 6 digits');
expectEq('auth.email', 'otp_expiry', 600, 'Email code expires in 10 minutes');
expectEq('auth.email', 'max_frequency', '60s', 'Email resend cooldown is 60 seconds');
expectEq('auth.email', 'enable_confirmations', true, 'Email must be confirmed');
expectEq('auth.email', 'secure_password_change', true, 'A password change needs a recent sign-in');
// Phone: confirmations on, 60 s resend cooldown, delivery through the Send SMS hook.
expectEq('auth.sms', 'enable_confirmations', true, 'Phone must be confirmed');
expectEq('auth.sms', 'max_frequency', '60s', 'SMS resend cooldown is 60 seconds');
expectEq('auth.hook.send_sms', 'enabled', true, 'The Send SMS hook is enabled');
const hook = value('auth.hook.send_sms', 'uri');
if (typeof hook === 'string' && hook.endsWith('/api/v1/auth/hooks/send-sms')) check('PASS', 'The hook calls the NestJS endpoint', String(hook));
else check('FAIL', 'The hook calls the NestJS endpoint', `uri is ${hook}`);
if (value('auth.sms', 'otp_expiry') === undefined) check('WARN', 'SMS code expiry is 10 minutes', 'config.toml has no setting for it: Supabase uses its own default for phone codes. Set it on the cloud project (Auth > Providers > Phone) to 600 s in P3-M8.');
// MFA: TOTP for admins, phone for two-step sign-in.
expectEq('auth.mfa.totp', 'enroll_enabled', true, 'Authenticator (TOTP) enrolment is on');
expectEq('auth.mfa.totp', 'verify_enabled', true, 'Authenticator (TOTP) verification is on');
expectEq('auth.mfa.phone', 'enroll_enabled', true, 'Phone two-step enrolment is on');
expectEq('auth.mfa.phone', 'verify_enabled', true, 'Phone two-step verification is on');
expectEq('auth.mfa.phone', 'otp_length', 6, 'Two-step code is 6 digits');
// Things the platform cannot express as the spec words them.
check('WARN', 'Recovery codes expire in 15 minutes', 'Supabase uses one expiry for every email code (otp_expiry = 600 s, 10 minutes), so recovery codes expire in 10, not 15. Shorter than the spec, never longer; the prototype copy says 15 and should say 10, or the spec should change.');
const rate = value('auth.rate_limit', 'sign_in_sign_ups');
check('WARN', 'Auth rate limits', `Local limits are raised for tests (sign_in_sign_ups = ${rate} per 5 minutes per IP). The cloud project must use the limits in docs/SECURITY.md (set per project in P3-M8; the CLI does not push them).`);

for (const r of results) console.log(`${r.state.padEnd(5)} ${r.what}${r.detail ? `  (${r.detail})` : ''}`);
const fails = results.filter((r) => r.state === 'FAIL').length;
console.log(`\n${results.filter((r) => r.state === 'PASS').length} pass, ${results.filter((r) => r.state === 'WARN').length} warn, ${fails} fail`);
process.exit(fails > 0 ? 1 : 0);
