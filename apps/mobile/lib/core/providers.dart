import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'analytics/analytics.dart';
import 'api/generated/export.dart';
import 'auth/auth_repository.dart';
import 'auth/session_controller.dart';
import 'config/app_config.dart';
import 'networking/dio_factory.dart';
import 'networking/session_refresher.dart';
import 'storage/token_store.dart';

part 'providers.g.dart';

/// Riverpod 3 retries failed providers automatically. The session check must fail visibly instead, so the
/// splash can say "Can't reach Atarah" and offer a retry. Pass this as `retry:` to the root scope.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

/// Overridden in `bootstrap` with the flavour's configuration.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) =>
    throw UnimplementedError('appConfigProvider must be overridden');

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => SecureTokenStore();

@Riverpod(keepAlive: true)
AnalyticsSink analytics(Ref ref) => const NoopAnalytics();

@Riverpod(keepAlive: true)
Dio plainDio(Ref ref) => buildPlainDio(ref.watch(appConfigProvider));

@Riverpod(keepAlive: true)
SessionRefresher sessionRefresher(Ref ref) {
  final plain = AtarahApiClient(ref.watch(plainDioProvider));
  return SessionRefresher(
    store: ref.watch(tokenStoreProvider),
    refreshCall: (refreshToken) async {
      final res = await plain.auth.refresh(
        body: RefreshDto(refreshToken: refreshToken),
      );
      return StoredTokens(
        accessToken: res.data.accessToken,
        refreshToken: res.data.refreshToken,
      );
    },
  );
}

@Riverpod(keepAlive: true)
Dio apiDio(Ref ref) => buildApiDio(
  config: ref.watch(appConfigProvider),
  store: ref.watch(tokenStoreProvider),
  refresher: ref.watch(sessionRefresherProvider),
  // Read lazily: the session controller itself depends on this Dio.
  onSessionExpired: () => ref.read(sessionControllerProvider.notifier).expire(),
);

@Riverpod(keepAlive: true)
AtarahApiClient apiClient(Ref ref) =>
    AtarahApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(
  api: ref.watch(apiClientProvider),
  store: ref.watch(tokenStoreProvider),
);
