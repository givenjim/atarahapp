// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// True while the device has some network connection. (Reachability of Atarah itself is reported by the
/// failures of real requests; this only drives the global offline banner.)

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

/// True while the device has some network connection. (Reachability of Atarah itself is reported by the
/// failures of real requests; this only drives the global offline banner.)

final class IsOnlineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// True while the device has some network connection. (Reachability of Atarah itself is reported by the
  /// failures of real requests; this only drives the global offline banner.)
  IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isOnline(ref);
  }
}

String _$isOnlineHash() => r'd57e411e1d0d7402aebc3cb8c591dc5f251cec62';
