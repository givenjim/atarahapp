# Atarah — Testing

Placeholder (P0-M1). Expectations are in Master Prompt §7.7.

| Layer       | Tools                                                                  |
| ----------- | ---------------------------------------------------------------------- |
| Backend     | Jest, Supertest, Testcontainers (real PostgreSQL and Redis)            |
| Mobile      | flutter_test, golden tests, `integration_test` on the Android emulator |
| Web / admin | Vitest/Jest + Testing Library, Playwright                              |
| Load        | k6                                                                     |

Results are recorded here with real numbers. A defect list (bug bash) starts in P3-M7.

## Mobile (Flutter)

Run from `apps/mobile`:

```bash
flutter analyze            # strict lints (analysis_options.yaml)
dart format --set-exit-if-changed lib test
flutter test               # 239 tests: widget, accessibility, contrast, golden, routing redirect, networking, app flow
flutter test --update-goldens test/design_system/golden_test.dart   # after an intentional visual change
```

| Suite (`test/design_system/`) | What it proves                                                                                                                                                                                                                                                                                                                     |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `inputs_test.dart`            | Text field (52 high, prefix, error, counter), password strength rule, code input (digits only, paste, 6 max), checkbox / toggle (48×28) / radio / segmented                                                                                                                                                                        |
| `components_test.dart`        | Button heights 54/48/34, loading/disabled, icon-button targets, chips, tags, verification labels, avatar/progress, overlays (leaving-Atarah choices, AI sheet Apply/Discard), skeleton under reduce-motion, empty/error variants, offline copy, premium gate, `AtFutureScreen` phase labels, tab shell, media tile, domain widgets |
| `accessibility_test.dart`     | For **every gallery entry**: no overflow at 100 % and 200 % text, every tap target ≥ 48×48, every control labelled                                                                                                                                                                                                                 |
| `contrast_test.dart`          | WCAG contrast of every text/background token pair used by components (4.5:1; 3:1 for bold ≥ 14px)                                                                                                                                                                                                                                  |
| `golden_test.dart`            | One image per gallery entry at 1× and 2× text scale (32 images in `goldens/`)                                                                                                                                                                                                                                                      |

### Emulator journeys (real backend, no fakes)

| Date       | Milestone | Test                                     | Device                         | Result |
| ---------- | --------- | ---------------------------------------- | ------------------------------ | ------ |
| 2026-10-17 | P0-M7     | `integration_test/app_journey_test.dart` | Android emulator (Pixel 6 AVD) | PASS   |

Covers: welcome, wrong password message from the server, sign-in, every tab, profile from `GET /users/me`, placeholder routes, session restored after restart from secure storage, sign-out clearing tokens. iOS is not verifiable on this Windows host.

## Web and admin (P0-M8)

| Suite                                                                   | Command                                          | Covers                                                                                                                                                                                                    |
| ----------------------------------------------------------------------- | ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Backend integration (`test/admin.int-spec.ts`, real PostgreSQL + Redis) | `pnpm --filter @atarah/backend test:integration` | list/search/paginate users, suspend revokes sessions and audits, reactivate, invalid transitions, self and peer-admin protection, re-auth required, permission and token-type denials, validation         |
| Admin kit (vitest)                                                      | `pnpm --filter @atarah/admin test`               | table, pagination links, status pill, confirm dialog (reason), re-auth dialog, 18-section nav, permission filtering, Soon panels                                                                          |
| Web (vitest)                                                            | `pnpm --filter @atarah/web test`                 | store-link flag, join call-to-action, wordmark                                                                                                                                                            |
| Playwright (`apps/admin/e2e`)                                           | `pnpm --filter @atarah/admin e2e`                | redirect when signed out, wrong password, TOTP enrolment, recovery codes, filtered sidebar, Soon panel, user search, suspend with wrong then right re-auth, audit entry shows actor, reactivate, sign-out |

Last run 2026-10-17: backend 189 pass, admin kit 13 pass, web 5 pass, Playwright 1 pass (Chromium, real backend).

## Media and notifications (P0-M9)

| Suite                                                                                     | Command                                          | Covers                                                                                                                                                                                                                                                                                                                                                                                       |
| ----------------------------------------------------------------------------------------- | ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/media/media.rules.spec.ts` (unit)                                                    | `pnpm --filter @atarah/backend test:unit`        | file-type sniffing for 12 formats, 6 non-formats (PHP, HTML, SVG, executable, empty, unknown RIFF), allow-list, limits, aliases                                                                                                                                                                                                                                                              |
| `src/notifications/push.spec.ts` (unit)                                                   | same                                             | FCM request shape, 500-token batching, invalid-token reporting, retry on other errors (fake client)                                                                                                                                                                                                                                                                                          |
| `test/media.int-spec.ts` (real S3 server via Testcontainers, real Redis queue and worker) | `pnpm --filter @atarah/backend test:integration` | upload, validate and ready; EXIF stripped and verified; 200/600/1200 variants fetched with signed URLs; bare object URL refused; script disguised as JPEG rejected and deleted; PNG declared as JPEG rejected; corrupt image rejected; decompression bomb rejected; PDF accepted; declaration limits; storage refuses wrong size and wrong type; confirm before upload; ownership and delete |
| `test/notifications.int-spec.ts` (real queue and worker, dev outbox)                      | same                                             | default fan-out; per-category and per-channel preferences; channels skipped when there is no device or no verified email; critical notices override preferences; SMS only when asked; off-platform deep links refused; suspended members get nothing; preference and device endpoints; token reassignment; ten-device cap                                                                    |

Not verified by tests: delivery to Google FCM (no credentials), real email and SMS providers (owner decisions).
