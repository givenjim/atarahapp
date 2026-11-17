// Applies the Atarah Auth settings (the cloud equivalent of supabase/config.toml) to a hosted Supabase project through
// the Management API. Idempotent. Phone sign-in and the Send SMS hook stay off until the API has a public URL and an
// SMS provider exists (owner decisions 18 and 19).
//
//   node scripts/push-auth-config.mjs apps/backend/.env.cloud
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const envFile = process.argv[2];
if (!envFile) throw new Error('usage: node scripts/push-auth-config.mjs <env file>');
const env = Object.fromEntries(
  readFileSync(envFile, 'utf8')
    .split(/\r?\n/)
    .filter((l) => /^[A-Z_]+=/.test(l))
    .map((l) => [l.slice(0, l.indexOf('=')), l.slice(l.indexOf('=') + 1)]),
);
const ref = env.SUPABASE_PROJECT_REF;
const token = env.SUPABASE_ACCESS_TOKEN;
if (!ref || !token) throw new Error('SUPABASE_PROJECT_REF and SUPABASE_ACCESS_TOKEN are required');

const tpl = (name) => readFileSync(join(root, 'supabase', 'templates', `${name}.html`), 'utf8');

const body = {
  site_url: env.ATARAH_SITE_URL ?? 'https://atarah.app',
  uri_allow_list: 'atarah://auth-callback,http://127.0.0.1:3001,http://127.0.0.1:3200',
  jwt_exp: 3600,
  refresh_token_rotation_enabled: true,
  security_refresh_token_reuse_interval: 10,
  disable_signup: false,
  external_anonymous_users_enabled: false,
  password_min_length: 8,
  password_required_characters: 'abcdefghijklmnopqrstuvwxyz:ABCDEFGHIJKLMNOPQRSTUVWXYZ:0123456789',
  mailer_autoconfirm: false,
  mailer_otp_length: 6,
  mailer_otp_exp: 600,
  mailer_secure_email_change_enabled: true,
  security_update_password_require_reauthentication: true,
  mailer_subjects_confirmation: 'Your Atarah verification code',
  mailer_subjects_recovery: 'Reset your Atarah password',
  mailer_subjects_email_change: 'Confirm your new Atarah email',
  mailer_subjects_reauthentication: 'Confirm it is you',
  mailer_templates_confirmation_content: tpl('confirmation'),
  mailer_templates_recovery_content: tpl('recovery'),
  mailer_templates_email_change_content: tpl('email_change'),
  mailer_templates_reauthentication_content: tpl('reauthentication'),
  mfa_totp_enroll_enabled: true,
  mfa_totp_verify_enabled: true,
  mfa_max_enrolled_factors: 10,
  external_phone_enabled: false,
  hook_send_sms_enabled: false,
};

const send = (payload) =>
  fetch(`https://api.supabase.com/v1/projects/${ref}/config/auth`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
let res = await send(body);
let text = await res.text();
if (res.status === 400 && /template modification is not available/i.test(text)) {
  // Free plan with the default mailer: templates need custom SMTP (owner decision 2). Apply everything else.
  for (const k of Object.keys(body)) if (/^mailer_(templates|subjects)/.test(k)) delete body[k];
  console.warn(
    'push-auth-config: email templates NOT applied (needs custom SMTP); applying the rest.',
  );
  res = await send(body);
  text = await res.text();
}
if (!res.ok) {
  console.error(`push-auth-config: FAILED ${res.status} ${text.slice(0, 500)}`);
  process.exit(1);
}
const got = JSON.parse(text);
const diff = Object.keys(body).filter(
  (k) =>
    k in got && !/^mailer_templates/.test(k) && JSON.stringify(got[k]) !== JSON.stringify(body[k]),
);
console.log(
  diff.length ? `push-auth-config: applied; differs: ${diff.join(', ')}` : 'push-auth-config: OK',
);
