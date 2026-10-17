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

String _$appRouterHash() => r'c010483d93cee0e4bea3e81ae632dbc82bddb70a';
