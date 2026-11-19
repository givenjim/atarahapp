// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cvRepository)
final cvRepositoryProvider = CvRepositoryProvider._();

final class CvRepositoryProvider
    extends $FunctionalProvider<CvRepository, CvRepository, CvRepository>
    with $Provider<CvRepository> {
  CvRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cvRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cvRepositoryHash();

  @$internal
  @override
  $ProviderElement<CvRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CvRepository create(Ref ref) {
    return cvRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CvRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CvRepository>(value),
    );
  }
}

String _$cvRepositoryHash() => r'43564c86c0a6e0cc5f15007d618af69e49669dd3';

/// How long the PDF flow waits between checks of a build. Replaced with zero in tests.

@ProviderFor(cvPollInterval)
final cvPollIntervalProvider = CvPollIntervalProvider._();

/// How long the PDF flow waits between checks of a build. Replaced with zero in tests.

final class CvPollIntervalProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long the PDF flow waits between checks of a build. Replaced with zero in tests.
  CvPollIntervalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cvPollIntervalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cvPollIntervalHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return cvPollInterval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$cvPollIntervalHash() => r'217fd5b82e7f8a80ca3e7fe8a4922e3726df21a3';

/// One format's choices, preview, latest PDF and share links, as the server filters them.

@ProviderFor(CvDoc)
final cvDocProvider = CvDocFamily._();

/// One format's choices, preview, latest PDF and share links, as the server filters them.
final class CvDocProvider extends $AsyncNotifierProvider<CvDoc, CvStateDto> {
  /// One format's choices, preview, latest PDF and share links, as the server filters them.
  CvDocProvider._({
    required CvDocFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cvDocProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cvDocHash();

  @override
  String toString() {
    return r'cvDocProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CvDoc create() => CvDoc();

  @override
  bool operator ==(Object other) {
    return other is CvDocProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cvDocHash() => r'3413a9f9600b144bc4941386653d8269be77e964';

/// One format's choices, preview, latest PDF and share links, as the server filters them.

final class CvDocFamily extends $Family
    with
        $ClassFamilyOverride<
          CvDoc,
          AsyncValue<CvStateDto>,
          CvStateDto,
          FutureOr<CvStateDto>,
          String
        > {
  CvDocFamily._()
    : super(
        retry: null,
        name: r'cvDocProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One format's choices, preview, latest PDF and share links, as the server filters them.

  CvDocProvider call(String format) =>
      CvDocProvider._(argument: format, from: this);

  @override
  String toString() => r'cvDocProvider';
}

/// One format's choices, preview, latest PDF and share links, as the server filters them.

abstract class _$CvDoc extends $AsyncNotifier<CvStateDto> {
  late final _$args = ref.$arg as String;
  String get format => _$args;

  FutureOr<CvStateDto> build(String format);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CvStateDto>, CvStateDto>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CvStateDto>, CvStateDto>,
              AsyncValue<CvStateDto>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
