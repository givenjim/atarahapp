import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import 'analytics/analytics.dart';
import 'api/generated/export.dart';
import 'auth/auth_gateway.dart';
import 'auth/auth_repository.dart';
import 'auth/gateway_tokens.dart';
import 'auth/session_controller.dart';
import 'auth/supabase_auth_gateway.dart';
import 'auth/two_step.dart';
import 'config/app_config.dart';
import 'content/content_repository.dart';
import 'device/device_registrar.dart';
import 'networking/dio_factory.dart';
import 'realtime/notifications_realtime.dart';
import 'storage/secure_storage.dart';

part 'providers.g.dart';

/// Riverpod 3 retries failed providers automatically. The session check must fail visibly instead, so the
/// splash can say "Can't reach Atarah" and offer a retry. Pass this as `retry:` to the root scope.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

/// Overridden in `bootstrap` with the flavour's configuration.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) =>
    throw UnimplementedError('appConfigProvider must be overridden');

/// Secrets and per-install values (the Supabase session, the device id) live in the platform keystore.
@Riverpod(keepAlive: true)
KeyValueStore keyValueStore(Ref ref) => SecureKeyValueStore();

/// Overridden in `bootstrap` once the Supabase SDK is initialised. Used for Auth and the one Realtime channel.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) =>
    throw UnimplementedError('supabaseClientProvider must be overridden');

@Riverpod(keepAlive: true)
AuthGateway authGateway(Ref ref) =>
    SupabaseAuthGateway(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
NotificationsRealtime notificationsRealtime(Ref ref) =>
    SupabaseNotificationsRealtime(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
AnalyticsSink analytics(Ref ref) => const NoopAnalytics();

@Riverpod(keepAlive: true)
Dio plainDio(Ref ref) => buildPlainDio(ref.watch(appConfigProvider));

@Riverpod(keepAlive: true)
Dio apiDio(Ref ref) => buildApiDio(
  config: ref.watch(appConfigProvider),
  tokens: GatewayTokens(ref.watch(authGatewayProvider)),
  // Read lazily: the session controller itself depends on this Dio.
  onSessionExpired: () => ref.read(sessionControllerProvider.notifier).expire(),
  onTwoStepRequired: () => ref.read(twoStepRequiredProvider.notifier).require(),
);

@Riverpod(keepAlive: true)
AtarahApiClient apiClient(Ref ref) =>
    AtarahApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
DeviceRegistrar deviceRegistrar(Ref ref) => DeviceRegistrar(
  dio: ref.watch(apiDioProvider),
  store: ref.watch(keyValueStoreProvider),
);

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final content = ref.watch(contentRepositoryProvider);
  return AuthRepository(
    gateway: ref.watch(authGatewayProvider),
    api: ref.watch(apiClientProvider),
    devices: ref.watch(deviceRegistrarProvider),
    legalVersions: () async {
      final docs = await Future.wait([
        content.legalDocument('TERMS'),
        content.legalDocument('PRIVACY'),
      ]);
      return (terms: docs[0].version, privacy: docs[1].version);
    },
  );
}

@Riverpod(keepAlive: true)
ContentRepository contentRepository(Ref ref) =>
    ContentRepository(api: ref.watch(apiClientProvider));

/// Whether "Continue with Google" is shown. Off until the server says otherwise.
@riverpod
Future<bool> googleSignInEnabled(Ref ref) =>
    ref.watch(contentRepositoryProvider).googleSignInEnabled();
