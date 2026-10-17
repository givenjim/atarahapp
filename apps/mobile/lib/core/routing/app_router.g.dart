// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Navigation graph: splash -> session check -> welcome / home, the five-tab shell, and the deep-link
/// routes. Redirect logic lives in [computeRedirect].

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Navigation graph: splash -> session check -> welcome / home, the five-tab shell, and the deep-link
/// routes. Redirect logic lives in [computeRedirect].

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Navigation graph: splash -> session check -> welcome / home, the five-tab shell, and the deep-link
  /// routes. Redirect logic lives in [computeRedirect].
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'0681374d3287f37402a51692bc4e02a1bb7b9822';
