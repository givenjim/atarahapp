# Milestone report — P1-M1 Entry and authentication screens

Date: 2026-10-17. Status: **COMPLETED** (waiting for the product owner before P1-M2).

## What was built

| Screen           | What it does                                                                                                                                                                                                                                                               |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Splash           | Brand gradient with the ribbon artwork, ATARAH wordmark and "CREATE · CONNECT · GROW", progress bar. Restores the session: no session goes to Welcome, a session goes Home. No tap-to-continue. Offline shows "Can't reach Atarah" with Try again.                         |
| Welcome          | Photo collage, headline "One creative identity. Many connected possibilities.", sub-line, four pillar tiles (Identity, Learn, Connect, Earn), Create account, Sign in, Terms and Privacy links that open the legal text.                                                   |
| Sign up          | Full name, email or phone (Kenyan numbers become +254 / E.164), password with show/hide and the four-segment strength meter, required consent checkbox with links, Continue. Server errors land under their field; "account already exists" offers "Sign in instead".      |
| Verify           | Six-box code input (typing and paste), button disabled until six digits, "Resend in 0:42" driven by the server cooldown, "Why we verify" and "What's next" panel.                                                                                                          |
| Sign in          | Email or phone and password, the exact error banner ("That password doesn't match this account. Check it and try again, or reset it."), lock-out message, Forgot password?, link to Create an account. An unverified account is sent to Verify (the API resends the code). |
| Forgot           | Asks for the email or phone, then opens Reset with "Code sent. It expires in 15 minutes."                                                                                                                                                                                  |
| Reset            | Recovery code, new password (with strength meter) and confirmation. On success it signs in and shows "Password updated. You were signed out of your other devices." as a banner at the top.                                                                                |
| Legal            | Read-only Terms and Privacy. Today it shows the seeded placeholder under a "draft, not reviewed" banner.                                                                                                                                                                   |
| Onboarding entry | A new member lands here after verifying. It is a labelled **"Soon · P1"** screen until P1-M2 builds the real steps; Back goes Home.                                                                                                                                        |

Backend: two small public endpoints, `GET /config/public` (is Google sign-in on) and `GET /legal/{TERMS|PRIVACY}`. The auth endpoints themselves already existed from P0-M5.
Analytics events `user_registered`, `verification_completed` and `sign_in` are emitted (the sink is still the no-op one).

## Evidence

| Check                                   | Result                                                                                                                                                                                                                                                                          |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Flutter tests                           | 291 pass (was 239). 33 new widget tests cover every state of the seven screens; 18 for phone and email parsing.                                                                                                                                                                 |
| Backend tests                           | 238 pass (4 new integration tests for the public endpoints).                                                                                                                                                                                                                    |
| Emulator, real backend and real inbox   | `integration_test/auth_journeys_test.dart`, 3 journeys, **PASS**: (1) register, wrong code, emailed code, onboarding entry, Home, profile, sign out; (2) wrong password banner then sign in; (3) forgot, emailed code, reset, notice, old password refused, new password works. |
| Analyze, format, lint, typecheck, brand | Clean.                                                                                                                                                                                                                                                                          |

## Not verified or deliberately left out

- **Pixel match to the prototype** was built from the prototype's layout and copy and checked in widget tests, but I have not compared screenshots side by side. The manual check below asks you to do that.
- **Continue with Google:** hidden unless the server flag is on. Turned on, it opens a labelled "Soon · Later" screen because the Google SDK and OAuth credentials are an owner decision.
- **Splash routing for "onboarding incomplete"** needs the profile model from P1-M2. Until then a signed-in member always goes Home.
- **Legal text** is the seeded placeholder. I did not write any.
- **Welcome artwork** is the prototype's placeholder images. The prototype's "1,280 creatives" counter was left out because it is sample data.
- **iOS** is not built (Windows host). **SMS** codes cannot be tried by phone number on a real network: the development sink prints them in the API console.

## Decisions to confirm

See DEC-032. The ones that need your eye: the Verify button is the only way to submit (no auto-submit), the onboarding placeholder, and the reset notice being a banner at the top instead of a snackbar (a snackbar blocked the tab bar).

## Files changed

Backend: `apps/backend/src/public-content/*`, `src/app.module.ts`, `test/public-content.int-spec.ts`.
Contract: `packages/api-contracts/openapi.json`, `src/schema.d.ts`.
Mobile: `lib/core/auth/{identifier,auth_repository,session_controller}.dart`, `lib/core/content/content_repository.dart`, `lib/core/notices/app_notice.dart`, `lib/core/providers.dart`, `lib/core/routing/{routes,redirect,app_router}.dart`, `lib/core/design_system/components/banners.dart`, `lib/core/l10n/app_en.arb`, `lib/features/auth/*` (welcome, splash, signup, verify, signin, forgot, reset, legal, shared widgets), `lib/features/shell/{app_shell,future_route_screen}.dart`, `assets/images/*`, regenerated API client, tests under `test/` and `integration_test/auth_journeys_test.dart`. Removed: the developer sign-in screen and `integration_test/app_journey_test.dart`.
Docs: `DECISIONS.md` (DEC-032), `PROJECT_PROGRESS.md`, `API.md`, `TESTING.md`, `DEVELOPMENT.md`, `ARCHITECTURE.md`.

---

# Manual check procedure

Allow about 15 minutes. You need the backend, the local services and an Android emulator or phone.

## 0. Start everything

```bash
pnpm bootstrap                                   # first time only; needs Docker running
pnpm --filter @atarah/backend build && node apps/backend/dist/main.js    # API on :3000 (own terminal)
cd apps/mobile
flutter run --flavor dev -t lib/main_dev.dart --dart-define=ATARAH_API_BASE_URL=http://10.0.2.2:3000
```

On a physical phone replace `10.0.2.2` with your computer's address. Open the inbox at **http://localhost:58025** (Mailpit). Every code arrives there.

## 1. Splash and Welcome

1. Cold start the app. You should see the purple gradient, the ribbon artwork, **ATARAH** with **CREATE · CONNECT · GROW**, and a progress bar. It moves on by itself in a second or two (no tap needed).
2. Welcome shows the photo collage, the headline **One creative identity. Many connected possibilities.**, the sub-line, four tiles (Identity, Learn, Connect, Earn), **Create account**, **Sign in**, and **Terms** / **Privacy** links.
3. Tap **Terms**. You should see a "draft, not reviewed" banner and placeholder text. Go back. Tap **Privacy**: same. Go back.
4. Turn on aeroplane mode, close and reopen the app: the splash should say **Can't reach Atarah** with **Try again**. Turn aeroplane mode off and tap Try again: Welcome appears.

## 2. Sign up (happy path, with mistakes first)

1. Tap **Create account**, then **Continue** with everything empty. Expect red messages under name, email or phone and password, and under the checkbox. Nothing is sent.
2. Type a password `abc` and watch the meter: **Weak**, then `abcdefgh` gives **Almost — add a number**, then `abcdefg1` gives **Strong — 8+ characters with a number**. Tap the eye icon: the password shows and hides.
3. Enter name `Your Name`, email `you+m1@example.com`, password `Passw0rd-1`, tick the box (tap **Terms of Service** first to check it opens the draft; go back), tap **Continue**.
4. You should land on **Verify your email** showing your address and **Resend in 0:5x** counting down.
5. Open Mailpit, copy the 6-digit code. In the app type `000000` and tap **Verify**: expect "That code is not right or has expired." Now type or paste the real code. **Verify** is greyed out until six digits are in.
6. After Verify you should see **Creative profile setup** with the **Soon · P1** label. Tap **Go back**: you are on Home with the tab bar. Open **Profile**: your name and email are shown.
7. **Sign out** (bottom of Profile) returns to Welcome.

## 3. Sign up edge cases

1. **Create account** again with the same email: the field shows "An account with this email already exists. Sign in instead?" and a **Sign in instead** button that opens Sign in.
2. Try a phone number: `0712 345 678`. While typing, a hint says numbers starting with 0 or 7 are treated as Kenyan. After Continue, the verify screen shows **Verify your phone number** and `+254712345678`. The code is printed in the API terminal (look for `[DEV SMS]`).
3. On Verify, wait for the countdown to reach 0, tap **Resend code**: **New code sent.** appears and the countdown restarts. A second email arrives in Mailpit.

## 4. Sign in

1. From Welcome tap **Sign in**. Enter your email and a wrong password: expect the banner **That password doesn't match this account. Check it and try again, or reset it.** and you stay on the screen.
2. Enter the right password: you land on Home.
3. Sign out. Sign in with a made-up email and wrong password five or six times quickly: after several failures the banner changes to **Too many sign-in attempts…** plus a line about resetting your password.
4. Type `not an email` and tap Sign in: "Enter a valid email address or phone number." appears before anything is sent.
5. Register one more account but stop at Verify (do not enter the code), force-close the app, reopen, then Sign in with that account and its password: you should be taken to **Verify** (a fresh code is in Mailpit).

## 5. Forgot and reset

1. Sign in screen, tap **Forgot password?**, enter your email, tap **Send code**.
2. The next screen is **Set a new password** with the green banner **Code sent. It expires in 15 minutes.**
3. Tap **Reset password** empty: errors for the code and the password. Enter the code from Mailpit, a new password `Passw0rd-2` and a different confirmation: "The passwords don't match."
4. Fix the confirmation and tap **Reset password**. You land on Home and a green banner at the top says **Password updated. You were signed out of your other devices.** (it closes by itself or with **Close**, and never covers the tab bar).
5. Sign out and sign in with the old password: it fails. The new one works.

## 6. Look and feel (your call)

Compare each screen with the prototype (`design/prototype/AtarahEntry.dc.html`): spacing, colours, button shapes, text. Increase the phone's font size to the largest setting and check that nothing is cut off. With a screen reader on (TalkBack), the code boxes should read as one "Verification code" field, and errors should be announced.

Anything that looks off, or any step that does not behave as described, is a defect. Tell me which step and what you saw.

## 7. Optional

Enable Google sign-in to see the button: in the database set the `google-sign-in` flag to on (admin Settings arrives in P1-M10, so for now use `GET /api/v1/config/public` to confirm the flag, and expect the button to open a "Soon · Later" screen).
