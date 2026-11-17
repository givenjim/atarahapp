// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `bootstrap` with the flavour's configuration.

@ProviderFor(appConfig)
final appConfigProvider = AppConfigProvider._();

/// Overridden in `bootstrap` with the flavour's configuration.

final class AppConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  /// Overridden in `bootstrap` with the flavour's configuration.
  AppConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $ProviderElement<AppConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfig create(Ref ref) {
    return appConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfig>(value),
    );
  }
}

String _$appConfigHash() => r'549adbd5e67e18e10b0abf9ad110abfa319b72a0';

/// Secrets and per-install values (the Supabase session, the device id) live in the platform keystore.

@ProviderFor(keyValueStore)
final keyValueStoreProvider = KeyValueStoreProvider._();

/// Secrets and per-install values (the Supabase session, the device id) live in the platform keystore.

final class KeyValueStoreProvider
    extends $FunctionalProvider<KeyValueStore, KeyValueStore, KeyValueStore>
    with $Provider<KeyValueStore> {
  /// Secrets and per-install values (the Supabase session, the device id) live in the platform keystore.
  KeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyValueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyValueStoreHash();

  @$internal
  @override
  $ProviderElement<KeyValueStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KeyValueStore create(Ref ref) {
    return keyValueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyValueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyValueStore>(value),
    );
  }
}

String _$keyValueStoreHash() => r'9ffd3436760b8d239a333602675030b0359a34b2';

/// Overridden in `bootstrap` once the Supabase SDK is initialised. Used for Auth and the one Realtime channel.

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// Overridden in `bootstrap` once the Supabase SDK is initialised. Used for Auth and the one Realtime channel.

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Overridden in `bootstrap` once the Supabase SDK is initialised. Used for Auth and the one Realtime channel.
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'be9b73ceb39b5b9b384e9bf0fe9fff2f23bae70f';

@ProviderFor(authGateway)
final authGatewayProvider = AuthGatewayProvider._();

final class AuthGatewayProvider
    extends $FunctionalProvider<AuthGateway, AuthGateway, AuthGateway>
    with $Provider<AuthGateway> {
  AuthGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authGatewayHash();

  @$internal
  @override
  $ProviderElement<AuthGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthGateway create(Ref ref) {
    return authGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthGateway>(value),
    );
  }
}

String _$authGatewayHash() => r'f74d34af51a18ca06a472060210819cfc7e4815b';

@ProviderFor(notificationsRealtime)
final notificationsRealtimeProvider = NotificationsRealtimeProvider._();

final class NotificationsRealtimeProvider
    extends
        $FunctionalProvider<
          NotificationsRealtime,
          NotificationsRealtime,
          NotificationsRealtime
        >
    with $Provider<NotificationsRealtime> {
  NotificationsRealtimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRealtimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRealtimeHash();

  @$internal
  @override
  $ProviderElement<NotificationsRealtime> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsRealtime create(Ref ref) {
    return notificationsRealtime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsRealtime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsRealtime>(value),
    );
  }
}

String _$notificationsRealtimeHash() =>
    r'099292a11f2c1f007c6adb3a4f02b5e3ff70d792';

@ProviderFor(analytics)
final analyticsProvider = AnalyticsProvider._();

final class AnalyticsProvider
    extends $FunctionalProvider<AnalyticsSink, AnalyticsSink, AnalyticsSink>
    with $Provider<AnalyticsSink> {
  AnalyticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsHash();

  @$internal
  @override
  $ProviderElement<AnalyticsSink> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsSink create(Ref ref) {
    return analytics(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsSink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsSink>(value),
    );
  }
}

String _$analyticsHash() => r'd0af90a4ce3c9bc341d91af9f1d6bac8d431c20d';

@ProviderFor(plainDio)
final plainDioProvider = PlainDioProvider._();

final class PlainDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  PlainDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plainDioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plainDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return plainDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$plainDioHash() => r'd5adcb05ae1aed85b07aa50e36373681f56877a0';

@ProviderFor(apiDio)
final apiDioProvider = ApiDioProvider._();

final class ApiDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  ApiDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiDioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return apiDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$apiDioHash() => r'54c731fd999a52be5368c34d5f867dc50790f155';

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

final class ApiClientProvider
    extends
        $FunctionalProvider<AtarahApiClient, AtarahApiClient, AtarahApiClient>
    with $Provider<AtarahApiClient> {
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<AtarahApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AtarahApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AtarahApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AtarahApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'08355ec0d4f3847a150baafa6d7874618a3a9fa7';

@ProviderFor(deviceRegistrar)
final deviceRegistrarProvider = DeviceRegistrarProvider._();

final class DeviceRegistrarProvider
    extends
        $FunctionalProvider<DeviceRegistrar, DeviceRegistrar, DeviceRegistrar>
    with $Provider<DeviceRegistrar> {
  DeviceRegistrarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceRegistrarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceRegistrarHash();

  @$internal
  @override
  $ProviderElement<DeviceRegistrar> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceRegistrar create(Ref ref) {
    return deviceRegistrar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceRegistrar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceRegistrar>(value),
    );
  }
}

String _$deviceRegistrarHash() => r'53d013db315a4cc372c5282fd0721980e65d986d';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'e5a65b644f8af5e43cb51caa6720a6bae507327b';

@ProviderFor(contentRepository)
final contentRepositoryProvider = ContentRepositoryProvider._();

final class ContentRepositoryProvider
    extends
        $FunctionalProvider<
          ContentRepository,
          ContentRepository,
          ContentRepository
        >
    with $Provider<ContentRepository> {
  ContentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContentRepository create(Ref ref) {
    return contentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentRepository>(value),
    );
  }
}

String _$contentRepositoryHash() => r'65755893b333a0b247782cb4aecb47f046ec6d3e';

/// Whether "Continue with Google" is shown. Off until the server says otherwise.

@ProviderFor(googleSignInEnabled)
final googleSignInEnabledProvider = GoogleSignInEnabledProvider._();

/// Whether "Continue with Google" is shown. Off until the server says otherwise.

final class GoogleSignInEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether "Continue with Google" is shown. Off until the server says otherwise.
  GoogleSignInEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleSignInEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleSignInEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return googleSignInEnabled(ref);
  }
}

String _$googleSignInEnabledHash() =>
    r'4668fe5da2a99efbd553fed36c14c15756987d06';
