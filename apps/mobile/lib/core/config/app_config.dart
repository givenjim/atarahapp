/// Build flavours. Each has its own API base URL (and, later, Firebase project).
enum Flavor { dev, staging, prod }

/// Runtime configuration. Values come from `--dart-define` / `--dart-define-from-file` (never committed with
/// real secrets); the defaults below are the public, non-secret endpoints for each flavour.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    this.sentryDsn = '',
    this.supabaseUrl = '',
    this.supabasePublishableKey = '',
  });

  final Flavor flavor;

  /// Host only, e.g. `http://10.0.2.2:3000`. The generated client adds `/api/v1/...`.
  final String apiBaseUrl;
  final String sentryDsn;

  /// Supabase project URL (Auth and the notifications Realtime channel only; data always goes to the API).
  final String supabaseUrl;

  /// The Supabase publishable (anon) key. It is a public client key, but it still comes from
  /// `--dart-define` / `--dart-define-from-file` per environment and is never written into source.
  final String supabasePublishableKey;

  /// Auth cannot start without both Supabase values.
  bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  /// Developer-only screens (component gallery, developer sign-in) exist in the dev flavour only.
  bool get showDevTools => flavor == Flavor.dev;

  /// Default endpoints. 10.0.2.2 is the Android emulator's alias for the host machine's localhost.
  /// The staging and production hosts are assumptions until the owner confirms the domain (DEC-007).
  static String defaultApiBaseUrl(Flavor flavor) => switch (flavor) {
    Flavor.dev => 'http://10.0.2.2:3000',
    Flavor.staging => 'https://api.staging.atarah.app',
    Flavor.prod => 'https://api.atarah.app',
  };

  /// The dev flavour talks to the local Supabase stack (`supabase start`). On an emulator, `adb reverse
  /// tcp:55321 tcp:55321` makes it reachable at 127.0.0.1, which is also the host inside the signed storage
  /// URLs the API returns. The staging and production projects have no default: set `ATARAH_SUPABASE_URL`.
  static String defaultSupabaseUrl(Flavor flavor) => switch (flavor) {
    Flavor.dev => 'http://127.0.0.1:55321',
    Flavor.staging || Flavor.prod => '',
  };

  factory AppConfig.forFlavor(Flavor flavor) {
    const apiOverride = String.fromEnvironment('ATARAH_API_BASE_URL');
    const dsn = String.fromEnvironment('ATARAH_SENTRY_DSN');
    const supabaseUrl = String.fromEnvironment('ATARAH_SUPABASE_URL');
    const supabaseKey = String.fromEnvironment(
      'ATARAH_SUPABASE_PUBLISHABLE_KEY',
    );
    return AppConfig(
      flavor: flavor,
      apiBaseUrl: apiOverride.isEmpty ? defaultApiBaseUrl(flavor) : apiOverride,
      sentryDsn: dsn,
      supabaseUrl: supabaseUrl.isEmpty
          ? defaultSupabaseUrl(flavor)
          : supabaseUrl,
      supabasePublishableKey: supabaseKey,
    );
  }
}
