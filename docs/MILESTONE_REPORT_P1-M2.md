# Milestone report — P1-M2 Onboarding and creative profile creation

Date: 2026-10-17. Status: **COMPLETED, emulator not run** (the owner runs emulator checks at the end of each phase, DEC-033). Waiting for the product owner before P1-M3.

## What was built

| Area                 | What it does                                                                                                                                                                                                                                                                                                                                                                        |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Setup flow (mobile)  | Seven steps in the prototype's frame (back, progress bar, Skip, "Step n of 6", Continue/Finish): intro, discipline (3-column tiles), specialisation (multi-select rows plus "Suggest a specialization" sheet), skills / interests / areas to develop (chips with counters), location, profile basics, photo. Then the dark completion screen with the real Passport and completion. |
| Saved on the server  | Every step is saved before the next opens. Closing the app and reopening resumes at the saved step with earlier answers. Skip saves nothing and moves on. Changing the discipline clears specialisations.                                                                                                                                                                           |
| Location             | Country (Kenya), county list with search, optional town, "Use my current location" (coarse location, the phone's own geocoder, server matches the name to a county), who-can-see-it control with the three notes.                                                                                                                                                                   |
| Profile link         | `atarah.app/{handle}` suggested from the name, checked live, taken or reserved links explained with free alternatives, a simultaneous claim decided by the database.                                                                                                                                                                                                                |
| Photo                | Gallery or camera, square crop with a circular guide, upload through the media pipeline, replace and remove.                                                                                                                                                                                                                                                                        |
| Passport             | `ATR-{COUNTY}-{sequence}` issued once from an atomic per-county counter; a double tap or concurrent completions never share or waste a number.                                                                                                                                                                                                                                      |
| Completion engine    | One backend function scores every profile; weights documented in `docs/DOMAIN.md`; returns the percentage and the next missing items.                                                                                                                                                                                                                                               |
| Routing              | Splash and the auth screens send a member with unfinished setup to the saved step; finished members go Home. A failing check never traps anyone (DEC-038).                                                                                                                                                                                                                          |
| Admin                | New **Taxonomy** section: disciplines, specialisations, skills, interests, areas to develop (create, rename, archive/restore, reorder, usage counts) and the **Suggestions** queue (approve with a corrected name, merge, reject with a note).                                                                                                                                      |
| "Help me write this" | Opens the labelled **Soon · P3** screen.                                                                                                                                                                                                                                                                                                                                            |

Backend: new `creative` module (taxonomy and location reads, onboarding, handles, avatar, Passport, admin taxonomy and suggestions), two migrations, 9 new tables, OpenAPI regenerated, Dart and TypeScript clients regenerated.

## Evidence

| Check                                   | Result                                                                                                                                                                                                                                    |
| --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Backend tests (unit + integration)      | **285 pass** (was 238): 13 unit for the completion engine, handles and place matching; 25 integration for onboarding; 9 for admin taxonomy and the suggestion queue. Race tests included.                                                 |
| Flutter tests                           | **343 pass** (was 291): 46 widget tests for setup (every step, failure and skip path, 200% text on every step) and 6 redirect tests for the gate.                                                                                         |
| Admin                                   | 31 Vitest pass (18 new). Playwright: 2 pass, including the new taxonomy flow against the real backend (reported by the delegated run; I did not re-run it myself after the final contract regeneration, only typecheck, lint and Vitest). |
| Analyze, lint, typecheck, format, brand | Clean (`flutter analyze`, backend and admin lint and typecheck, `pnpm format:check`, brand check).                                                                                                                                        |
| **Emulator**                            | **Not run** (deferred to the end of the phase by the owner). `integration_test/onboarding_journey_test.dart` is written and analysed, not executed.                                                                                       |

## Not verified or left PARTIAL

- **On a device:** nothing in this milestone has been seen on a phone. In particular the **photo picker, camera and crop gestures**, the **location permission prompt and the phone's geocoder**, keyboard behaviour on the forms, and how the screens look against the prototype. Widget tests cover the logic around these through small seams, not the native parts.
- **Photo upload needs the worker.** The upload waits up to 45 seconds for the background job that validates and resizes the picture. With only the API running (no `dev:worker`) the member sees a timeout message.
- **Completion tops out at 75%** until P1-M4 adds projects and experience (DEC-034).
- **Specialisation suggestions** reach the admin queue, but there is no email or in-app list for the member beyond the decision notification.
- **Towns** are free text; the town table is empty and admin-managed later.
- **No pixel comparison** with the prototype was made.
- The admin Playwright run signs in as a PLATFORM_ADMIN; a CONTENT_ADMIN-only login is tested only through the API.

## Decisions to confirm

See DEC-033 to DEC-039. The ones that need your eye:

1. **Passport number for a member with no county** uses the code `GEN` (for example `ATR-GEN-0007`) and keeps it forever. Alternative: require a county before Finish.
2. **Setup is not a hard gate.** Members can leave it (Back on step one) and use the app; the splash brings them back to it. Alternative: lock the app until setup is done.
3. **Caps:** 20 skills, 10 specialisations, 10 interests, 10 areas.
4. Approving or merging a suggestion also adds it to the suggester's profile.
5. Specialisation suggestions: 5 pending per member.

## Files changed

Backend: `prisma/schema/{creative,identity,media-notifications,taxonomy}.prisma`, migrations `20261017152813_creative_profile_onboarding` and `20261017153000_creative_profile_checks`, `src/creative/*` (completion, handle, dto, profile service, taxonomy service, admin taxonomy service, controllers, module, slug), `src/app.module.ts`, `src/media/media.service.ts` (`imageUrl`), `scripts/e2e-fixtures.ts`, tests `test/creative.int-spec.ts`, `test/admin-taxonomy.int-spec.ts`, `src/creative/creative.spec.ts`.
Contract: `packages/api-contracts/openapi.json`, `src/schema.d.ts`; regenerated Dart client under `apps/mobile/lib/core/api/generated`.
Mobile: `lib/features/onboarding/*` (repository, providers, draft, steps, screen, done screen, crop, pick sheet, device services, icons), `lib/core/routing/{redirect,app_router}.dart`, `lib/core/l10n/app_en.arb`, `android/.../AndroidManifest.xml` (coarse location), `ios/Runner/Info.plist`, `pubspec.yaml` (`image_picker`, `crop_your_image`, `geolocator`, `geocoding`), tests `test/features/onboarding_test.dart`, `test/support/fake_onboarding.dart`, updated harness and flow tests, `integration_test/onboarding_journey_test.dart`.
Admin: `src/app/(console)/taxonomy/*`, `src/app/taxonomy-actions.ts`, `src/lib/{taxonomy,taxonomy-api}.ts`, `src/components/ui/form-dialog.tsx`, `src/lib/nav.ts`, `globals.css`, tests and `e2e/{helpers,taxonomy-flow.spec,admin-flow.spec}.ts`.
Docs: `DECISIONS.md` (DEC-033 to DEC-039), `API.md`, `DOMAIN.md`, `TESTING.md`, `PROJECT_PROGRESS.md`.

---

# Manual check procedure

Allow about 25 minutes. Run it when you choose (end of the phase, or sooner if you ask). You need Docker, the API **and the worker**, and an emulator or phone.

## 0. Start everything

```bash
pnpm bootstrap                                   # first time only (applies the new migrations and the reference seed)
pnpm --filter @atarah/backend build
node apps/backend/dist/main.js                   # API on :3000 (own terminal)
node apps/backend/dist/worker.js                 # worker (own terminal): photos are processed here
cd apps/mobile
flutter run --flavor dev -t lib/main_dev.dart --dart-define=ATARAH_API_BASE_URL=http://10.0.2.2:3000
```

Mailpit (`http://localhost:58025`) shows every code. Admin console: see `docs/DEVELOPMENT.md` (`pnpm --filter @atarah/admin dev`) and sign in with an admin that holds `taxonomy.manage`.

## 1. Setup, happy path

1. Create an account, verify with the code from Mailpit. You land on **Let's set up your creative identity** with four tiles, "Getting started" and **Get started**. There is no Skip on this screen.
2. **Get started** → **What do you create?** Tap **Continue** without choosing: a red message appears and nothing moves. Choose **Animation** → **Continue**.
3. **Your specialization** reads "Within **Animation**". Pick **2D animation** and **Character design** → Continue.
4. **Skills & interests**: tap a few chips; each group's counter ("2 selected") follows. Continue.
5. **Where are you based?** Country shows Kenya. Tap **County**, search "kis", choose **Kisumu**. Type a town. Switch the visibility control and read the three notes. Continue.
6. **Introduce yourself**: the profile link is filled from your name and shows "… is available." Type a bio and watch the counter. Continue.
7. **Add a profile photo**: choose **Gallery**, pick a picture, crop (drag and pinch), **Use photo**. After a moment "Photo added." appears. Tap **Remove photo**, then add it again. **Finish**.
8. The dark screen shows your photo, name, "Animation · 2D animation", "Kisumu, Kenya", a Passport like **ATR · KSM · 0001** and a completion percentage (with all steps done and no project yet it should read 70% or more, never 100%). **Go to Home** shows the tab bar.

## 2. Resume and edges

1. Create another account and stop on step 4. Force-close the app, reopen: you land on the **same** step with your earlier answers (tap Back to see them).
2. On the discipline step choose **Music**, continue, go back, choose **Animation**: your Music specialisations are gone.
3. **Skip** on a step: it moves on and nothing is saved for it. Skip everything including the photo ("Skip for now"): the Passport reads **ATR · GEN · …**, "Specialization not set", "Location not set".
4. **Use my current location**: allow the prompt. You should see "We set your county to …" if the phone's geocoder works. Deny it: a message says so and the list still works. Report anything else (this part has not been tried on a device).
5. **Suggest a specialization**: send "Puppetry". A thank-you appears. Suggest an existing name (for example "Singer" under Music): you are told it is already in the list.
6. Profile link: try `no spaces!` (format message), `admin` (reserved), and a link another account already holds (taken, with three alternatives you can tap). With two phones or accounts choose the same new link at the same moment: one wins, the other gets the "taken" message.
7. Switch the phone to aeroplane mode on the last step and tap Finish: a message says you're offline and you stay on the step; turn it off and Finish works.
8. **Help me write this** opens a screen labelled **Soon · P3**.
9. Set the system font size to the largest. Check every step for cut-off text. With TalkBack on, tiles and rows should read their names and "selected".

## 3. Admin

1. **Taxonomy → Disciplines**: create "Craft" with icon `hammer`; rename it; add a specialisation under **Specialisations** (choose Craft in the discipline filter); move it up and down; archive and restore it. Archived rows look muted; members stop seeing archived entries.
2. **Suggestions**: with a pending "Puppetry": **Approve** (try correcting the name), another suggestion **Merge** into an existing specialisation, another **Reject** with a note. The member gets a notification; an approved or merged one appears on their profile.
3. Seeded disciplines should still show in prototype order.

Anything that looks off, or any step that does not behave as described, is a defect. Tell me which step and what you saw.
