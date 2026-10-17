/// Build flavours. Each has its own API base URL (and, later, Firebase project).
enum Flavor { dev, staging, prod }

/// Runtime configuration. Values come from `--dart-define` / `--dart-define-from-file` (never committed with
/// real secrets); the defaults below are the public, non-secret endpoints for each flavour.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    this.sentryDsn = '',
  });

  final Flavor flavor;

  /// Host only, e.g. `http://10.0.2.2:3000`. The generated client adds `/api/v1/...`.
  final String apiBaseUrl;
  final String sentryDsn;

  /// Developer-only screens (component gallery, developer sign-in) exist in the dev flavour only.
  bool get showDevTools => flavor == Flavor.dev;

  /// Default endpoints. 10.0.2.2 is the Android emulator's alias for the host machine's localhost.
  /// The staging and production hosts are assumptions until the owner confirms the domain (DEC-007).
  static String defaultApiBaseUrl(Flavor flavor) => switch (flavor) {
    Flavor.dev => 'http://10.0.2.2:3000',
    Flavor.staging => 'https://api.staging.atarah.app',
    Flavor.prod => 'https://api.atarah.app',
  };

  factory AppConfig.forFlavor(Flavor flavor) {
    const apiOverride = String.fromEnvironment('ATARAH_API_BASE_URL');
    const dsn = String.fromEnvironment('ATARAH_SENTRY_DSN');
    return AppConfig(
      flavor: flavor,
      apiBaseUrl: apiOverride.isEmpty ? defaultApiBaseUrl(flavor) : apiOverride,
      sentryDsn: dsn,
    );
  }
}
