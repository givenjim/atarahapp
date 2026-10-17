# Atarah — Security and privacy

Grows with each milestone. Current through P0-M5.

Baseline commitments (Master Prompt §5.5, §7.4): Argon2id passwords; 15-minute JWT access tokens and rotating 30-day refresh tokens with reuse detection; hashed single-use 6-digit codes (10 min; recovery 15 min; 60 s resend cooldown); admin TOTP; server-side validation, ownership and visibility checks; signed uploads with MIME sniffing and EXIF stripping; private evidence bucket; append-only audit log; no secrets, tokens, codes, ID numbers or full phone numbers in logs; Kenya Data Protection Act, 2019 alignment (consent, export, deletion, breach response).

## Implemented controls (P0-M3)

- Environment validated at boot; the process refuses to start on missing/invalid config, short secrets, placeholder secrets outside dev/test, or `ATARAH_SKIP_CONNECT` outside dev/test.
- Helmet headers; CORS allow-list from `ATARAH_CORS_ORIGINS`; `X-Powered-By` removed.
- Structured logs (pino) with redaction of authorization, cookies, passwords, codes, tokens, ID numbers and phone numbers; query strings are dropped from logged URLs; health probes are not logged.
- Audit log is append-only at the database (trigger rejects UPDATE, DELETE, TRUNCATE for every role). Audit payloads are scrubbed of sensitive keys before writing.
- Error responses never expose stack traces, SQL or library messages.

## Authentication and sessions (P0-M5)

### Passwords

Argon2id (19 MiB, 2 iterations, 1 lane, OWASP baseline). Minimum 8 characters including a number, maximum 128, validated on the server. Unknown accounts cost the same time as a wrong password (dummy hash), so response time does not reveal which emails exist. Hashes are upgraded transparently on sign-in when parameters change.

### One-time codes (verification, recovery, two-step)

- Six digits from a CSPRNG (`crypto.randomInt`), stored as `HMAC-SHA256(pepper, userId:purpose:code)`. The code itself is never stored or logged.
- Lifetime 10 minutes (account recovery 15 minutes). Both are `PlatformSetting` values (`auth.code_ttl_minutes`, `auth.recovery_code_ttl_minutes`).
- Single use (atomic compare-and-set on `consumedAt`), at most 5 guesses per code, then the code is dead.
- 60 second resend cooldown (`auth.code_resend_cooldown_seconds`); the API answers `429 RATE_LIMITED` with `details.retryAfterSeconds`.
- Issuing a new code expires every older unused code for the same user and purpose. A code for one purpose never works for another.
- Registration verify, resend and forgot-password answer identically for existing and unknown accounts. The one deliberate exception is sign-up, which tells the user an account already exists (the prototype's "Sign in instead?" flow).

### Tokens and sessions

| Token            | Form                                                                      | Lifetime                                        | Storage                                                                              |
| ---------------- | ------------------------------------------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------ |
| Access           | JWT HS256 (`iss`, `aud`, `jti`, claims `sub`, `fam`, `adm`, `mfa`, `typ`) | 15 min (`auth.access_token_ttl_minutes`)        | Client memory only                                                                   |
| Refresh (member) | 256-bit opaque random                                                     | 30 days sliding (`auth.refresh_token_ttl_days`) | Server: `HMAC-SHA256(pepper, token)` in `sessions`. Mobile: `flutter_secure_storage` |
| Refresh (admin)  | same                                                                      | 12 hours; 30 min idle limit on every request    | same                                                                                 |
| Admin challenge  | JWT, `typ=admin-challenge`                                                | 5 min                                           | Grants no API access                                                                 |

- Every refresh **rotates** the token. A session "family" (`familyId`) ties the chain together and identifies the device.
- **Reuse detection:** presenting an already-rotated token after a 10 second grace window revokes the whole family (`TOKEN_REUSED`). Inside the grace window it is treated as a client retry racing its own rotation (`REFRESH_IN_PROGRESS`, nothing revoked).
- Every authenticated request checks, in the database, that the family is live, the user exists, and the account status permits the action. Logout, "sign out of other devices", suspension and role removal therefore take effect immediately, not after the access token expires.
- Password reset signs out every device. Logout-all revokes every family.
- Sign-in lockout: 5 failures per identifier in 15 minutes returns `429` with `details.reason = SIGN_IN_LOCKED` even for the right password; reset or time clears it.
- Web and admin: the Next.js servers keep tokens in `httpOnly`, `Secure`, `SameSite=Lax` cookies with CSRF protection (P0-M8). The API itself is bearer-token based and never sets cookies (DEC-018).

### Account status on every request

`PENDING_VERIFICATION` may only call routes marked `@AllowPending` (`GET /users/me`) and gets `VERIFICATION_REQUIRED`; `SUSPENDED`, `DEACTIVATED` and `DELETED` get `FORBIDDEN` with `details.reason = ACCOUNT_<STATUS>`. Roles stop counting while an account is not ACTIVE.

### Authorisation (backend, every request)

Global guard chain, in order: **rate limit → authenticate → permissions → entitlements → recent re-auth.**

- `@Public()` opts a route out of authentication; everything else requires a valid token.
- `@RequiresPermission('resource.action')`: member-default permissions (only while ACTIVE) plus the permissions of every held role. Denial: `FORBIDDEN` with `details.missing`.
- `@RequiresEntitlement(KEY)`: from the member's live membership. `ACTIVE` until the period ends; `CANCELLED` until the paid period ends; `PAST_DUE` through the grace period (3 days); `EXPIRED` never. Denial: `PREMIUM_REQUIRED`.
- `@RequiresRecentAuth(minutes)`: password and TOTP re-entered within the window. Denial: `AUTHENTICATION_REQUIRED` with `details.reason = REAUTH_REQUIRED`.
- Ownership and visibility helpers: `canView` (PUBLIC / MEMBERS / PRIVATE), `assertOwner`, `assertNotSelf` (nobody grants themselves a role or verifies their own skill or opportunity).
- Denial codes: `FORBIDDEN`, `PREMIUM_REQUIRED`, `VERIFICATION_REQUIRED`, `APPROVAL_REQUIRED`, `AUTHENTICATION_REQUIRED`. The mobile and web clients decide only whether to show a control.

### Administrators

1. `POST /admin/auth/login` (email + password). Staff-only; a non-staff account gets the same answer as a wrong password.
2. First time: `POST /admin/auth/totp/setup` returns the secret and `otpauth://` URL once; the secret is stored AES-256-GCM encrypted. `POST /admin/auth/totp/verify` with a code confirms enrolment and returns 8 single-use recovery codes (shown once, stored hashed).
3. Later: password, then TOTP code (or a recovery code). Codes are accepted within ±30 s, and a time step can be used **once** (replay protection with compare-and-set). 5 wrong codes lock further attempts for 15 minutes.
4. The result is an admin session. Admin tokens work only on `/api/v1/admin/*`; member tokens never do. Admin access ends immediately if the staff role is revoked.
5. Sensitive actions require `POST /admin/auth/reauth` (password + fresh code) within the last 5 minutes.
6. Admin sign-ins, TOTP enrolment, failed attempts and re-authentications are audited.

### Rate limits (current)

| Route                                                 | Limit (per client address) | Plus                            |
| ----------------------------------------------------- | -------------------------- | ------------------------------- |
| Default, all `/api/v1`                                | 120 / min                  |                                 |
| `POST /auth/register`                                 | 5 / min                    |                                 |
| `POST /auth/verify`                                   | 10 / min                   | 5 guesses per code              |
| `POST /auth/resend-code`                              | 3 / min                    | 60 s cooldown per user          |
| `POST /auth/login`                                    | 10 / min                   | 5 failures / 15 min per account |
| `POST /auth/refresh`                                  | 30 / min                   |                                 |
| `POST /auth/password/forgot`                          | 3 / min                    | 60 s cooldown per user          |
| `POST /auth/password/reset`                           | 5 / min                    | 5 guesses per code              |
| `POST /auth/google`                                   | 10 / min                   | feature flag                    |
| `POST /admin/auth/login`, `totp/setup`, `totp/verify` | 10 / min                   | 5 failures / 15 min             |
| `POST /admin/auth/refresh`                            | 30 / min                   |                                 |

### Delivery providers

Email and SMS sit behind `EmailProvider` / `SmsProvider` interfaces. Development uses SMTP to Mailpit (http://localhost:58025) and an SMS log sink that prints the message in `dev` only. The env schema rejects the SMS `log` provider in staging and production. Production providers are owner decisions #2 and #3. Delivery runs inline today and moves onto the BullMQ `notifications` queue with retries in P0-M9.

## Breach-response notes

_Drafted in P3-M6._

### Mobile token handling

Tokens live only in `flutter_secure_storage` (Android Keystore / iOS Keychain), never in preferences, logs or crash reports. Concurrent 401s share a single refresh so a rotated token is never replayed. A terminal reason (`TOKEN_REUSED`, `SESSION_IDLE`) clears the session without a refresh attempt. See DEC-025.

### Admin console session (P0-M8)

Tokens never reach browser JavaScript: they are `httpOnly`, `SameSite=Lax` cookies (`Secure` in production) set by the admin Next server. Mutations are Server Actions (Origin-checked). A suspended account loses all sessions at once. Account-status changes require recent password + TOTP re-authentication, cannot target oneself, and cannot target an administrator unless the caller is a SUPER_ADMIN. The console is `noindex`.

### Uploads (P0-M9)

Signed upload URLs bind the content type and exact length and expire in 15 minutes. The real type is read from the file bytes, never from the name or the declared type, so a script renamed to `.jpg` is rejected and deleted. Images are re-encoded, which removes EXIF and GPS data, and decoding is capped at 50 megapixels. Buckets are private; every download needs a short-lived signature. A member can only see, confirm or delete their own files, and gets "not found" for anyone else's. Verification evidence will use the separate `verification-evidence` bucket (P2-M6).

### Notifications (P0-M9)

Deep links in notifications are in-app paths only. Security notices are `critical` and cannot be switched off. Suspended and deleted members receive nothing. Push tokens belong to one member at a time and are revoked when the push service reports them invalid.

### Secret scanning (P0-M9)

`gitleaks dir . --config .gitleaks.toml` over the working tree is part of the Phase 0 gate and of CI (DEC-031).
