// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in member, or null when signed out. Starts by restoring a stored session.
/// `AsyncLoading` means "checking", and `AsyncError` means the check failed (usually offline).

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// The signed-in member, or null when signed out. Starts by restoring a stored session.
/// `AsyncLoading` means "checking", and `AsyncError` means the check failed (usually offline).
final class SessionControllerProvider
    extends $AsyncNotifierProvider<SessionController, MeDto?> {
  /// The signed-in member, or null when signed out. Starts by restoring a stored session.
  /// `AsyncLoading` means "checking", and `AsyncError` means the check failed (usually offline).
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();
}

String _$sessionControllerHash() => r'edc7eeef2159c4ad10a11986d5dffdeee9626db4';

/// The signed-in member, or null when signed out. Starts by restoring a stored session.
/// `AsyncLoading` means "checking", and `AsyncError` means the check failed (usually offline).

abstract class _$SessionController extends $AsyncNotifier<MeDto?> {
  FutureOr<MeDto?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MeDto?>, MeDto?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MeDto?>, MeDto?>,
              AsyncValue<MeDto?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Coarse status for the router.

@ProviderFor(sessionStatus)
final sessionStatusProvider = SessionStatusProvider._();

/// Coarse status for the router.

final class SessionStatusProvider
    extends $FunctionalProvider<SessionStatus, SessionStatus, SessionStatus>
    with $Provider<SessionStatus> {
  /// Coarse status for the router.
  SessionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStatusHash();

  @$internal
  @override
  $ProviderElement<SessionStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionStatus create(Ref ref) {
    return sessionStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionStatus>(value),
    );
  }
}

String _$sessionStatusHash() => r'ccb399572e9db584d96f73af825beaa50c6880db';
