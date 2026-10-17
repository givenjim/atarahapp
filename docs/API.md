# Atarah — API

Implemented in P0-M3. Endpoints are added per module; the OpenAPI document is always generated from the code.

## Conventions

- Base path `/api/v1`; admin under `/api/v1/admin/*`; webhooks under `/api/v1/webhooks/{provider}`. Health probes are the exception: `/health/live`, `/health/ready` (DEC-011).
- Success: `{ "data": ..., "meta": { ... } }`. Collections: `meta: { page, limit, total }` (offset) or `meta: { nextCursor, limit }` (feeds). Default `limit` 20, maximum 100.
- Error: `{ "error": { "code", "message", "details", "requestId" } }`. Codes: `AUTHENTICATION_REQUIRED`, `INVALID_CREDENTIALS`, `FORBIDDEN`, `PREMIUM_REQUIRED`, `VERIFICATION_REQUIRED`, `APPROVAL_REQUIRED`, `RESOURCE_NOT_FOUND`, `VALIDATION_ERROR`, `CONFLICT`, `INVALID_STATE`, `RATE_LIMITED`, `PAYMENT_ERROR`, `EXTERNAL_SERVICE_ERROR`, `INTERNAL_ERROR`. Unexpected errors are always `INTERNAL_ERROR` with a generic message; internals are logged against the `requestId`.
- `VALIDATION_ERROR` carries `details.fields: [{ field, messages[] }]`. Unknown request properties are rejected.
- Send `X-Request-Id` (8–64 chars of `A-Za-z0-9._-`) to correlate; otherwise the server generates one. It is echoed in the response header and the error body.
- Sorting uses a per-resource whitelist of `recent | deadline | relevance | popularity | rating | price`; anything else is `VALIDATION_ERROR`.
- `Idempotency-Key` is required on payment initiation, booking creation, membership upgrade, opportunity submission and enrolment (implemented with those endpoints).

## Building blocks (apps/backend/src/common)

`ApiException` (throw this from domain code), `AllExceptionsFilter`, `ResponseEnvelopeInterceptor` + `Paged`, `createValidationPipe`, `PageQueryDto` / `CursorQueryDto` / `cursorPage`, `resolveSort`.

## OpenAPI

- Swagger UI: `http://localhost:3000/api/docs` (not served in production). JSON: `/api/docs/openapi.json`.
- Regenerate the committed contract: `pnpm gen:api` → `packages/api-contracts/openapi.json` (no database needed).
- 20 documented paths (auth, admin auth, users). Health is hidden from Swagger by design.

## Auth endpoints (P0-M5)

Bearer token = `Authorization: Bearer <accessToken>`. Responses use the standard envelope. "Public" means no token.

| Method and path              | Auth                              | Request body                                                                                 | Success                                                                                                                                                                           |
| ---------------------------- | --------------------------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `POST /auth/register`        | Public                            | `fullName`, `identifier` (email or phone), `password`, `consent {terms, privacy}`, `client?` | `201` `{ verification: { channel, destination (masked), expiresAt, resendAvailableAt } }`                                                                                         |
| `POST /auth/verify`          | Public                            | `identifier`, `code` (6 digits), `client?`, `deviceName?`                                    | `200` session                                                                                                                                                                     |
| `POST /auth/resend-code`     | Public                            | `identifier`                                                                                 | `200` `{ resendAvailableAt }` (identical for unknown accounts)                                                                                                                    |
| `POST /auth/login`           | Public                            | `identifier`, `password`, `client` (`ANDROID` `IOS` `WEB`), `deviceName?`                    | `200` session                                                                                                                                                                     |
| `POST /auth/refresh`         | Public                            | `refreshToken`                                                                               | `200` session (rotated)                                                                                                                                                           |
| `POST /auth/logout`          | Bearer                            |                                                                                              | `200` `{ loggedOut }`                                                                                                                                                             |
| `POST /auth/logout-all`      | Bearer                            |                                                                                              | `200` `{ sessionsRevoked }`                                                                                                                                                       |
| `POST /auth/password/forgot` | Public                            | `identifier`                                                                                 | `200` `{ sent: true }` (always)                                                                                                                                                   |
| `POST /auth/password/reset`  | Public                            | `identifier`, `code`, `newPassword`                                                          | `200` `{ reset: true }`; signs out all devices                                                                                                                                    |
| `POST /auth/google`          | Public                            | `idToken`, `client`                                                                          | `404` while the `google-sign-in` flag is off                                                                                                                                      |
| `GET /auth/sessions`         | Bearer                            |                                                                                              | `200` `[ { id, client, deviceName, approxLocation, lastActiveAt, current } ]`                                                                                                     |
| `DELETE /auth/sessions/{id}` | Bearer                            |                                                                                              | `200` `{ revoked }` (own sessions only)                                                                                                                                           |
| `GET /users/me`              | Bearer (pending accounts allowed) |                                                                                              | `200` `{ id, fullName, email, phone, emailVerified, phoneVerified, status, timeZone, locale, roles[], entitlements[], membership { plan, status, currentPeriodEnd }, createdAt }` |

**Session object:** `{ accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt, user }`.

**Admin (`/admin/auth/*`)**

| Method and path                | Auth            | Notes                                                                                                                      |
| ------------------------------ | --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `POST /admin/auth/login`       | Public          | `{ email, password }` → `{ step: TOTP_ENROLMENT_REQUIRED or TOTP_REQUIRED, challengeToken }`                               |
| `POST /admin/auth/totp/setup`  | challenge token | First enrolment only → `{ secret, otpauthUrl }`                                                                            |
| `POST /admin/auth/totp/verify` | challenge token | `{ challengeToken, code }` or `{ challengeToken, recoveryCode }` → admin session (+ `recoveryCodes[8]` on first enrolment) |
| `POST /admin/auth/refresh`     | Public          | `{ refreshToken }`                                                                                                         |
| `POST /admin/auth/reauth`      | Admin bearer    | `{ password, code }` → `{ reauthenticatedUntil }`                                                                          |
| `POST /admin/auth/logout`      | Admin bearer    |                                                                                                                            |
| `GET /admin/auth/me`           | Admin bearer    | User view plus `permissions[]` for the sidebar                                                                             |

**Denial responses clients must handle**

| Situation                      | Status / code                 | `details`                                                                        |
| ------------------------------ | ----------------------------- | -------------------------------------------------------------------------------- |
| No or invalid token            | 401 `AUTHENTICATION_REQUIRED` |                                                                                  |
| Refresh token replayed         | 401 `AUTHENTICATION_REQUIRED` | `reason: TOKEN_REUSED` (family revoked; sign in again)                           |
| Refresh raced itself           | 401 `AUTHENTICATION_REQUIRED` | `reason: REFRESH_IN_PROGRESS` (retry with the newest token)                      |
| Admin idle                     | 401 `AUTHENTICATION_REQUIRED` | `reason: SESSION_IDLE`                                                           |
| Sensitive admin action         | 401 `AUTHENTICATION_REQUIRED` | `reason: REAUTH_REQUIRED`                                                        |
| Wrong credentials              | 401 `INVALID_CREDENTIALS`     |                                                                                  |
| Account not verified           | 403 `VERIFICATION_REQUIRED`   | `reason: ACCOUNT_NOT_VERIFIED` (login) or `ACCOUNT_PENDING_VERIFICATION` (token) |
| Account suspended, deactivated | 403 `FORBIDDEN`               | `reason: ACCOUNT_SUSPENDED`, `ACCOUNT_DEACTIVATED`                               |
| Missing permission             | 403 `FORBIDDEN`               | `missing: [..]`                                                                  |
| Needs Pro                      | 403 `PREMIUM_REQUIRED`        | `entitlement`                                                                    |
| Wrong token type for the route | 403 `FORBIDDEN`               | `reason: ADMIN_ONLY` or `MEMBER_ONLY`                                            |
| Too many attempts              | 429 `RATE_LIMITED`            | `retryAfterSeconds`, `reason: SIGN_IN_LOCKED` (sign-in)                          |

## Admin back office (P0-M8)

All under `/api/v1/admin`; admin bearer token, `admin.access` plus the permission shown. Lists use `?page=&limit=` and return `meta: { page, limit, total }`.

| Endpoint                            | Permission     | Notes                                                                                          |
| ----------------------------------- | -------------- | ---------------------------------------------------------------------------------------------- |
| `GET /admin/users`                  | `user.view`    | `q` (name, email or phone) and `status` filters                                                |
| `GET /admin/users/{id}`             | `user.view`    | Account, status reason, roles, last sign-in                                                    |
| `POST /admin/users/{id}/suspend`    | `user.suspend` | `{ reason }` (5-500 chars). Recent re-auth. Ends all sessions. Audited as `user.suspend`       |
| `POST /admin/users/{id}/reactivate` | `user.suspend` | `{ reason? }`. Recent re-auth. Audited as `user.reactivate`                                    |
| `GET /admin/audit-logs`             | `audit.view`   | `action`, `entityType`, `entityId`, `actorId` filters; newest first; includes the actor's name |

Refusals: self-targeting and acting on an administrator without SUPER_ADMIN return `FORBIDDEN`; suspending an already-suspended account or reactivating a non-suspended one returns `INVALID_STATE` (409).

## Media (P0-M9)

Member bearer token, permission `profile.edit`. Files go to storage, not through the API.

| Endpoint                    | Notes                                                                                                                                                                  |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `POST /media/uploads`       | `{ kind, mimeType, sizeBytes, visibility }` → `{ id, uploadUrl, method: "PUT", headers, expiresAt }`. 400 for a type not allowed for the kind or a file over the limit |
| `POST /media/{id}/complete` | After the PUT. 409 `INVALID_STATE` if the object is not there yet. Idempotent. Queues validation                                                                       |
| `GET /media/{id}`           | `status` (`PENDING_UPLOAD`, `UPLOADED`, `PROCESSING`, `READY`, `REJECTED`), `rejectionReason`, and when ready `url` and `variants` (signed)                            |
| `DELETE /media/{id}`        | 204. Removes the file and its variants. Another member's id answers 404                                                                                                |

## Notifications and devices (P0-M9)

Member bearer token, permission `notification.manage.own`.

| Endpoint                         | Notes                                                                                                     |
| -------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `GET /notifications/preferences` | `{ preferences: [{ category, pushEnabled, emailEnabled }] }` for all seven categories                     |
| `PUT /notifications/preferences` | Same shape; send only the categories to change                                                            |
| `POST /devices`                  | `{ token, platform: ANDROID \| IOS \| WEB, appVersion? }` → `{ id }`. Re-registering a token refreshes it |
| `DELETE /devices/{id}`           | 204. Call on sign-out                                                                                     |

## Public content (P1-M1)

No sign-in needed.

| Endpoint                      | Notes                                                                                                           |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `GET /config/public`          | `{ googleSignIn: boolean }`. Apps show optional features only when true                                         |
| `GET /legal/{TERMS\|PRIVACY}` | `{ type, version, title, body, isDraft }`. Latest published version, else the seeded draft with `isDraft: true` |
