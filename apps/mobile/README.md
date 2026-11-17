# atarah

Atarah — Create · Connect · Grow. The Flutter app (Riverpod, go_router, dio).

## Run it

Details are in `docs/DEVELOPMENT.md` (Mobile). In short:

```bash
cd apps/mobile
flutter pub get
dart run build_runner build
# create env.dev.json in the JSON shape shown at the top of .env.example
adb reverse tcp:55321 tcp:55321
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env.dev.json
```

## Configuration per flavour

Passed with `--dart-define-from-file=env.<flavor>.json` (git-ignored; `.env.example` shows the shape).

| Define                            | Purpose                                                                                           |
| --------------------------------- | ------------------------------------------------------------------------------------------------- |
| `ATARAH_API_BASE_URL`             | The NestJS API host (default: dev `http://10.0.2.2:3000`, staging and prod as in `AppConfig`)     |
| `ATARAH_SUPABASE_URL`             | Supabase project URL. Dev defaults to `http://127.0.0.1:55321` (local stack); no default elsewhere |
| `ATARAH_SUPABASE_PUBLISHABLE_KEY` | The Supabase publishable (anon) key. Required. A public client key, never written into source     |
| `ATARAH_SENTRY_DSN`               | Optional error reporting                                                                          |

The app refuses to start without the Supabase URL and key.

## Authentication

Supabase Auth through `supabase_flutter`, behind the `AuthGateway` interface (`lib/core/auth`). The Supabase
client is used for Auth and for one Realtime subscription (new rows in `public.notifications`, which drives the
Home bell). Application data never goes through it: every data request goes to the NestJS API with the
Supabase access token as the bearer. The session is stored in `flutter_secure_storage`. After sign-in the app
calls `PUT /me/device` with a random per-install id.

On an emulator, `adb reverse tcp:55321 tcp:55321` makes the local Supabase reachable as `127.0.0.1`, the same host
the API puts in signed storage URLs. Verification and recovery codes are in Mailpit, `http://127.0.0.1:55324`.

## Checks

```bash
flutter analyze && dart format --set-exit-if-changed lib test integration_test && flutter test
```

Integration tests (`integration_test/`) need an emulator and the full local stack; they are run by the owner.
