import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../appearance/appearance_controller.dart';
import '../auth/supabase_auth_gateway.dart';
import '../config/app_config.dart';
import '../providers.dart';
import '../storage/secure_storage.dart';
import 'app.dart';

/// Shared start-up for every flavour. Starts Supabase Auth (session kept in the platform keystore), then the
/// app. Error reporting is enabled only when a Sentry DSN is configured (it never is in the repository), and
/// sends no personal data.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.forFlavor(flavor);
  if (!config.hasSupabase) {
    throw StateError(
      'Supabase is not configured for ${flavor.name}. Pass ATARAH_SUPABASE_URL and '
      'ATARAH_SUPABASE_PUBLISHABLE_KEY with --dart-define-from-file (see apps/mobile/README.md).',
    );
  }
  final supabase = await initialiseSupabase(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
    store: SecureKeyValueStore(),
  );
  // Read before the first frame so the app never flashes the wrong theme.
  final appearance = await AppearanceStore(SecureKeyValueStore()).load();

  Future<void> run() async => runApp(
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: [
        appConfigProvider.overrideWithValue(config),
        supabaseClientProvider.overrideWithValue(supabase),
        initialAppearanceProvider.overrideWithValue(appearance),
      ],
      child: const AtarahApp(),
    ),
  );

  if (config.sentryDsn.isEmpty) return run();

  await SentryFlutter.init((options) {
    options
      ..dsn = config.sentryDsn
      ..environment = flavor.name
      ..sendDefaultPii = false
      ..tracesSampleRate = 0.1;
  }, appRunner: run);
}
