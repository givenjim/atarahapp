# Atarah — Security and privacy

Grows with each milestone. Current through P1-M6 (Supabase platform adoption).

Baseline commitments (Master Prompt §5.5, §5.7, §7.4): Supabase Auth for identity (hashed passwords, 1-hour JWT access tokens, rotating refresh tokens with reuse detection, 6-digit one-time codes valid 10 minutes with a 60 s resend cooldown, MFA); admin TOTP (AAL2); server-side validation, ownership and visibility checks; signed uploads with MIME sniffing and EXIF stripping; private evidence bucket; append-only audit log; no secrets, tokens, codes, ID numbers or full phone numbers in logs; Kenya Data Protection Act, 2019 alignment (consent, export, deletion, breach response).

## Implemented controls (P0-M3)

- Environment validated at boot; the process refuses to start on missing/invalid config, short secrets, placeholder secrets outside dev/test, or `ATARAH_SKIP_CONNECT` outside dev/test.
- Helmet headers; CORS allow-list from `ATARAH_CORS_ORIGINS`; `X-Powered-By` removed.
- Structured logs (pino) with redaction of authorization, cookies, passwords, codes, tokens, ID numbers and phone numbers; query strings are dropped from logged URLs; health probes are not logged.
- Audit log is append-only at the database (trigger rejects UPDATE, DELETE, TRUNCATE for every role). Audit payloads are scrubbed of sensitive keys before writing.
- Error responses never expose stack traces, SQL or library messages.

## Authentication and sessions (Supabase Auth, P1-M6)

Supabase Auth owns credentials, codes, sessions and MFA (DEC-061). Atarah never handles a password or a password hash. The apps call Supabase Auth directly for sign-up, code verification, sign-in, refresh, recovery and MFA; every other request goes to NestJS with the Supabase access token as the bearer.

### Auth settings (supabase/config.toml; set the same values per cloud project)

| Setting                                 | Value                                                                                                                                                                                                                                                         | Master Prompt |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| Password policy                         | minimum 8 characters, letters and digits (`password_requirements = letters_digits`)                                                                                                                                                                           | 5.5           |
| Email and SMS one-time code             | 6 digits, expiry 600 s (**10 minutes for sign-up and for recovery**; Supabase has one expiry, so the old "recovery 15 minutes" copy changed, DEC-063)                                                                                                         | 5.5           |
| Resend cooldown                         | 60 s (`auth.email.max_frequency`, `auth.sms.max_frequency`)                                                                                                                                                                                                   | 5.5           |
| Access token                            | JWT, 3600 s, signed with an asymmetric key (ES256, verified through JWKS)                                                                                                                                                                                     | 5.5           |
| Refresh tokens                          | rotation on, reuse detection on (`enable_refresh_token_rotation`, `refresh_token_reuse_interval = 10`)                                                                                                                                                        | 5.5           |
| Email confirmation / phone confirmation | required                                                                                                                                                                                                                                                      | 5.5           |
| MFA                                     | TOTP and phone enrolment and verification enabled                                                                                                                                                                                                             | 5.5           |
| Send SMS hook                           | enabled, calls `POST /api/v1/auth/hooks/send-sms` (Standard Webhooks signature)                                                                                                                                                                               | 5.5           |
| Secure password change                  | on (a recent sign-in is required)                                                                                                                                                                                                                             | 5.5           |
| Rate limits                             | Production: sign-ups and sign-ins 30 / 5 min per IP, OTP verifications 30 / 5 min, token refresh 150 / 5 min, emails 30 / h, SMS 30 / h. **Local `config.toml` raises them to 1000** so the integration tests can sign in hundreds of times from one address. | 5.5           |

### What NestJS checks on every request (`SupabaseAuthGuard`)

1. The bearer is a Supabase JWT: signature through the project's JWKS (the legacy HS256 secret only where a project still has one), issuer, audience `authenticated`, expiry. Anonymous Supabase users are refused.
2. The `session_id` in the token still exists in `auth.sessions` (checked through a `SECURITY DEFINER` function). Sign-out, "sign out other devices", revocation, password recovery and suspension therefore end a session at once, not when the one-hour token expires.
3. `public.users` is loaded by `sub`: `DELETED`/`deletedAt` is unauthenticated; `SUSPENDED`, `DEACTIVATED` and `DELETED` get `FORBIDDEN` with `details.reason = ACCOUNT_<STATUS>`; `PENDING_VERIFICATION` may only call routes marked `@AllowPending` (`GET /users/me`) and otherwise gets `VERIFICATION_REQUIRED`. Roles stop counting while an account is not ACTIVE.
4. Authorisation never reads Supabase `user_metadata` or `app_metadata` (a member can edit their own `user_metadata`). Metadata supplies a display name and the consent versions at sign-up only, and nothing derived from it grants access.

Suspending an account also bans it in Supabase Auth (no sign-in, no refresh) and deletes its sessions; reactivating lifts the ban.

### Authorisation (backend, every request)

Global guard chain, in order: **rate limit → authenticate → permissions → entitlements → recent re-auth.**

- `@Public()` opts a route out of authentication; everything else requires a valid token.
- `@RequiresPermission('resource.action')`: member-default permissions (only while ACTIVE) plus the permissions of every held role. Denial: `FORBIDDEN` with `details.missing`.
- `@RequiresEntitlement(KEY)`: from the member's live membership. `ACTIVE` until the period ends; `CANCELLED` until the paid period ends; `PAST_DUE` through the grace period (3 days); `EXPIRED` never. Denial: `PREMIUM_REQUIRED`.
- `@RequiresRecentAuth(minutes)`: the TOTP factor was verified on this session within the window (`amr` claim). Denial: `AUTHENTICATION_REQUIRED` with `details.reason = REAUTH_REQUIRED`.
- Ownership and visibility helpers: `canView` (PUBLIC / MEMBERS / PRIVATE), `assertOwner`, `assertNotSelf` (nobody grants themselves a role or verifies their own skill or opportunity).
- Denial codes: `FORBIDDEN`, `PREMIUM_REQUIRED`, `VERIFICATION_REQUIRED`, `APPROVAL_REQUIRED`, `AUTHENTICATION_REQUIRED`. The mobile and web clients decide only whether to show a control.

### Administrators

1. Staff sign in with email and password, then enrol (first time) or verify a **TOTP** factor in Supabase Auth. The session is then **AAL2**. A staff member at AAL1 gets `FORBIDDEN` with `details.reason = MFA_REQUIRED` on every `/api/v1/admin/*` route; a member without a staff role gets `ADMIN_ONLY`.
2. Admin access ends immediately if the staff role is revoked (roles are read from the database on every request).
3. 30 minutes without a request ends the session (`SESSION_IDLE`; a Redis activity key per session, then the Supabase session is deleted).
4. Sensitive actions (`@RequiresRecentAuth`) need a TOTP verification within the last 5 minutes. The console shows its re-auth dialog, verifies the factor again and retries with the new token.
5. Supabase TOTP has no recovery codes. A lost authenticator is reset by another super admin removing the factor (a console action is a follow-up; until then an operator does it in the Supabase dashboard, which is a documented exception to "never edit data in the dashboard").
6. Admin sign-ins and denied attempts are audited by Supabase Auth's own logs; admin actions are audited in `audit_logs`.

### Rate limits (current)

| Route                                          | Limit (per client address)  | Plus                                                   |
| ---------------------------------------------- | --------------------------- | ------------------------------------------------------ |
| Default, all `/api/v1`                         | 120 / min                   |                                                        |
| `POST /auth/hooks/send-sms`                    | 600 / min                   | Standard Webhooks signature, 5-minute timestamp window |
| `PUT /me/device`                               | 30 / min                    |                                                        |
| Supabase Auth (sign-up, OTP, sign-in, refresh) | see the Auth settings table | enforced by Supabase                                   |

Every mutating `/api/v1` route is covered by the default limit; routes that need a tighter one add `@Throttle`. Search is `GET` and is covered by the default (120 / min). The throttler runs before authentication, so unauthenticated floods are limited too.

### Delivery providers

Email and SMS sit behind `EmailProvider` / `SmsProvider` interfaces. **Auth emails** (codes) are sent by Supabase Auth through its SMTP setting (the local mail catcher in development; owner decision #2 supplies the production SMTP). **Auth SMS** goes through the Send SMS hook to `SmsProvider` (a log sink in dev; owner decision #19 supplies the Kenyan provider). The env schema rejects the SMS `log` provider in staging and production. Application notifications use the same interfaces through the BullMQ `notifications` queue.

## Supabase platform security (P1-M6)

- **Row Level Security** is enabled on every table in `public` (`scripts/check-rls.sql`, run in CI and in the integration tests). There are no policies except `notifications_select_own` (SELECT for `authenticated` where `userId = auth.uid()`), which exists only so the app can subscribe to its own new notifications through Realtime. `anon` and `authenticated` hold no table, sequence or function privileges beyond that one SELECT, and default privileges for new tables are revoked. A test proves the anon key is refused (`42501`) for reads and writes on every table, and that a signed-in member reads nothing but their own notifications.
- **The backend role** `atarah_backend` bypasses RLS and is separate from `anon`, `authenticated` and `postgres`. Its password is set from the secret store by `apps/backend/scripts/provision-backend-role.mjs`, never in a migration. It has no direct access to the Supabase-managed `auth` schema: sessions, MFA factor summaries and revocation go through narrow `SECURITY DEFINER` functions (`atarah_auth_*`), executable only by that role.
- **Keys.** The publishable (anon) key may ship in apps. The **service-role (secret) key**, the database password and the SMS hook secret exist only in the backend's secret store (`apps/backend/.env` locally, git-ignored). `supabase/.env` (git-ignored) holds the hook secret for the local stack.
- **Realtime** publishes only `notifications`. Clients must not use a column `filter` on it (the camelCase column name breaks Realtime filters); the RLS policy already limits delivery to the member's own rows.
- **Storage.** Buckets `private-media` and `verification-evidence` are private and `public-media` is public. Storage RLS has no policies, so clients cannot list, read or write objects directly; every upload and download uses a signed URL from NestJS. Supabase signed upload URLs do not bind the type or length (the old S3 URLs did), so `complete` checks the size and the validation job sniffs the real type and deletes anything that does not match.
- **Database dashboard.** Never edit data or schema in the Supabase dashboard; migrations are the only path.

## Breach-response notes

_Drafted in P3-M6._

### Mobile token handling

The Supabase session is stored through a custom storage adapter in `flutter_secure_storage` (Android Keystore / iOS Keychain), never in preferences, logs or crash reports. The SDK refreshes tokens; an API 401 triggers one refresh and one retry, then sign-out. The refresh token is rotated by Supabase with reuse detection. See DEC-025 and DEC-061.

### Admin console session (P0-M8)

The Supabase session never reaches browser JavaScript: it lives in `httpOnly`, `SameSite=Lax` cookies (`Secure` in production) managed by `@supabase/ssr` on the admin Next server. Only the publishable key is exposed client-side. Mutations are Server Actions (Origin-checked). A suspended account loses all sessions at once and is banned in Supabase Auth. Account-status changes require a TOTP verification within the last 5 minutes, cannot target oneself, and cannot target an administrator unless the caller is a SUPER_ADMIN. The console is `noindex`.

### Uploads (P0-M9)

Signed upload URLs (Supabase, valid two hours) do not bind the content type or length, so the confirmation step checks the exact size and the real type is read from the file bytes, never from the name or the declared type, so a script renamed to `.jpg` is rejected and deleted. Images are re-encoded, which removes EXIF and GPS data, and decoding is capped at 50 megapixels. Only `public-media` is public; every other download needs a short-lived signature. A member can only see, confirm or delete their own files, and gets "not found" for anyone else's. Verification evidence will use the separate `verification-evidence` bucket (P2-M6).

### Notifications (P0-M9)

Deep links in notifications are in-app paths only. Security notices are `critical` and cannot be switched off. Suspended and deleted members receive nothing. Push tokens belong to one member at a time and are revoked when the push service reports them invalid.

### Secret scanning (P0-M9)

`gitleaks dir . --config .gitleaks.toml` over the working tree is part of the Phase 0 gate and of CI (DEC-031).

## Community safety (P1-M8)

Community rate limits, per client address (all covered by the throttler that runs before authentication):

| Route                                    | Limit      |
| ---------------------------------------- | ---------- |
| `POST /posts`, `POST /groups/{id}/posts` | 10 / hour  |
| `POST /posts/{id}/comments`              | 60 / hour  |
| `PUT` and `DELETE /posts/{id}/reactions` | 300 / hour |
| `POST /reports`                          | 20 / day   |
| `POST /creatives/{handle}/connect`       | 50 / day   |

- **Authorisation is composed, never a role:** account status ACTIVE, verified email or phone (posting, commenting, connection requests), no `community_restrictions` row in force, ownership (authors edit and delete only their own posts and comments; anything else is the same 404 as a missing item), audience, group membership and blocks, all enforced on the backend. Announcements need `community.announce`; group management `community.group.manage`; the queue `report.view` / `report.resolve` / `moderation.act`; suspending an account from a case also needs `user.suspend` and a fresh authenticator check.
- **Visibility is one SQL predicate** (`community/post-sql.ts`) shared by the feed, group pages, single posts, saved posts and search, so a rule cannot be applied in one place and forgotten in another. Blocks apply in both directions and also to people search, People to meet, comments and notifications.
- **Moderators act only through moderation actions.** There is no endpoint that edits a member's words. Every decision is one transaction (effect, append-only `moderation_actions` row, case and report status, audit entry). Staff cannot decide on their own account or content.
- **Reporters learn only that a decision was made** (and whether action was taken): never who decided, which action or the reason. The reported member is told what happened to their content, never who reported it. Notification copy is fixed text, covered by a test.
- **Link previews never let a member aim the server at internal addresses.** The fetcher refuses non-http(s) URLs, credentials, internal host names, loopback, private, link-local (cloud metadata), carrier-grade NAT, multicast and reserved addresses (IPv4 and IPv6, including IPv4-mapped forms); it checks every address DNS returns and every redirect (three at most), connects to the address it checked, reads at most 512 KB of an HTML page within 5 seconds, and keeps the preview image only as an absolute https URL that the server never fetches.
- **Client roles cannot reach any community table.** Row Level Security is enabled with no policies and no grants on every new table; `moderation_actions` additionally refuses UPDATE, DELETE and TRUNCATE for every role.

## Opportunities (P1-M9)

- **Trust is a staff decision.** `trust` is not a field of any request body: new and imported listings are `EXTERNAL_SOURCE`; `SOURCE_CONFIRMED` and `EXTERNAL_SOURCE` need `opportunity.manage`; `VERIFIED` needs `opportunity.verify` and a fresh authenticator check, and the generic trust endpoint refuses it. A provider cannot publish, badge or edit a published listing and sees only what they own (anything else is the same 404 as a missing item). Every staff change is audited with before and after.
- **Eligibility is private.** The profile-gap check runs on the server against the signed-in member's own profile and returns only the outcome of their own facts; it is cached per member and listing for 5 minutes (Redis, best effort).
- **Leaving Atarah.** The API returns the application address and its domain; the app names the domain, says Atarah does not receive the application, and records `APPLIED` only if the member ticks the box. Application links must be `https` with no credentials. The weekly link check goes through the same SSRF guard as link previews (private addresses refused before connecting, after DNS and on every redirect), sends a polite user agent, times out, and only flags a listing (it never unpublishes or edits it).
- **Import.** CSV import is capped (500 rows, 1 MB), validated field by field, and can only create unpublished, untrusted drafts.

## Account, privacy and notifications (P1-M11)

- **Re-authentication.** Changing the password needs the current password (checked against Supabase Auth, 5 tries an hour). Deleting the account needs the word DELETE and either a sign-in in the last 5 minutes or the password. Changing an email or phone goes through Supabase's own change flows (confirmation on both addresses; an OTP for a phone) made with the member's own session, so Atarah never sets a contact itself; a confirmed change, a password change and a phone verification all sign the other devices out and send a critical notice (critical notices ignore push and email preferences).
- **Two-step sign-in.** Enforced in the authentication guard, after the session and status checks: a member with two-step on, a session at AAL1 and a device that is not trusted gets `403 TWO_STEP_REQUIRED` on every route except the few the challenge needs (`PUT /me/device`, `GET /users/me`, `GET /me/security`, the sessions routes). The second factor is a Supabase MFA factor; turning two-step off needs an AAL2 session. The platform switch `auth.two_step_enforced` is the emergency off. The phone factor itself cannot be exercised on the local stack (no SMS provider), so it is tested with a TOTP factor, which produces the same AAL2 token.
- **Deactivated accounts.** A `DEACTIVATED` account is refused everywhere except `GET /users/me` and `POST /me/restore`, and only while an open deletion request exists (`@AllowDeactivated`).
- **Privacy is one source of truth.** The Privacy screen writes the same profile-section rows the public profile and search read, so no reader can disagree with the setting. Other members' settings never touch your profile (every route is the caller's own).
- **Exports** are built from tables filtered by the member's own id, never include secrets, are stored in the private bucket, are reachable only through a signed link that expires in 7 days, and are deleted with the account.
- **Broadcasts** need `notification.broadcast`; creating one needs a fresh authenticator check; each recipient is de-duplicated by `notification_dispatches`; the deep link must be an in-app path; everything is audited.
- **Help and legal** are public reads with a per-address throttle; staff edits need `help.manage` or `legal.manage` and are audited; publishing a legal document needs a fresh authenticator check and a published version is never edited.
- **Rate limits (per client address and per member where noted):** password change 5 per hour (also per member), contact change 5 per hour (also per member), export 1 per 24 hours per member, delete 5 per hour, restore 10 per hour, help and legal 60 per minute.

## Phase 1 security review (P1-M12)

- **Authorisation matrix.** `test/authz-matrix.int-spec.ts` reads every route from the controllers' decorators (so a new endpoint is covered the day it exists) and runs it as anonymous, member, moderator, content admin, platform admin, super admin and a suspended member, asserting that the guards allow or refuse exactly what the metadata says and that a refused caller never gets a 2xx. It also states the role matrix for the sensitive actions explicitly, and has an IDOR suite where one member tries every `{id}` route on another member's data (projects, experience, achievements, services, posts, comments, recent searches, devices, sessions, connections, private groups and posts, draft opportunities, private media).
- **Rate limits.** Reads 120 a minute, writes 60 a minute per client by default (central, in `RateLimitModule`), tighter explicit limits on sensitive routes. `scripts/check-rate-limits.ts` lists every mutating and search route with its limit and fails when a sensitive one has none.
- **Raw SQL.** All 46 `$queryRaw` and `$executeRaw` calls in `src` use `Prisma.sql` or a tagged template, so every value is a bound parameter; there is no `$queryRawUnsafe` or `$executeRawUnsafe` in `src`, the seeds or the scripts. The one `Prisma.raw` is the nightly saved-item sweep, which takes four constant table names from the same file. Dynamic fragments (the feed's visibility predicate, search patterns) are composed from `Prisma.sql` pieces, and LIKE patterns are escaped by `likePattern`.
- **Payload limits.** Bodies are DTO-validated with length limits on every string; uploads are checked for size and type by sniffing the bytes; CSV import is capped at 1 MB and 500 rows.
- **Admin.** Every `/admin` route needs a staff account, an AAL2 session and its permission; sensitive changes need a recent authenticator code and are audited.
- **Analytics privacy.** Events carry no free text or identity; the actor is a keyed hash that cannot be reversed or matched without the backend secret.
- **Supabase posture.** `scripts/check-rls.mjs` (RLS on every table including partitions, only one policy, `anon` and `authenticated` hold nothing else) and `scripts/check-auth-config.mjs` (local Auth settings against section 5.5). Known platform limits: recovery codes expire in 10 minutes, not 15 (one expiry for all email codes), and SMS code expiry has no config key; the cloud project's rate limits are set in P3-M8.


## Payments (P2-M1)

- **Only the provider confirms money.** A payment becomes `SUCCEEDED` only after an STK status query to Safaricom says so. A client-reported status does not exist (no route accepts one), a callback body is never believed on its own, and an amount that differs from the payment is rejected (`AMOUNT_MISMATCH`).
- **Unsigned callbacks.** Daraja does not sign callbacks, so the route is `/api/v1/webhooks/payments/mpesa/{token}` with a secret token (32 or more characters, constant-time comparison, 404 otherwise) and an optional source-address allow-list; callbacks are matched by CheckoutRequestID and de-duplicated by body hash, so a replayed or duplicated callback changes nothing. Rotate the token by changing `ATARAH_MPESA_CALLBACK_TOKEN` and the callback URL together.
- **Data held.** Amount, method, status, provider references and the last four digits of the paying number. No card data of any kind, no full phone number. Raw provider payloads are kept encrypted (AES-256-GCM) in `payment_events` and are never exposed by an API. The ledger is append-only (database trigger) and one payment can be credited once (unique index).
- **Authorisation.** Members read only their own payments. Staff read with `payment.view` and re-query, refund, confirm or cancel refunds only with `payment.manage` (super admins), a fresh authenticator code, and an audit entry naming them; amounts and reasons are in the audit record.
- **Rate limits.** `POST /payments` 6 a minute, `GET /payments/{id}` 60 a minute, webhook 300 a minute, admin finance writes 20 to 30 a minute (`scripts/check-rate-limits.ts` covers `/payments`, `/admin/payments` and `/webhooks`).
- **Open items.** Safaricom's callback source addresses are to be supplied by ops for the allow-list; the Reversal API (automatic M-Pesa refunds) needs Safaricom credentials; live-sandbox and production verification are BLOCKED until Daraja credentials exist; the P3-M6 review covers the payment code paths again.
