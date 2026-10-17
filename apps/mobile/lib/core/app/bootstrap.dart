import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_config.dart';
import '../providers.dart';
import 'app.dart';

/// Shared start-up for every flavour. Error reporting is enabled only when a Sentry DSN is configured
/// (it never is in the repository), and sends no personal data.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.forFlavor(flavor);

  Future<void> run() async => runApp(
    ProviderScope(
      retry: noAutomaticRetry,
      overrides: [appConfigProvider.overrideWithValue(config)],
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
