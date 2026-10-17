// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

final class OnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          OnboardingRepository,
          OnboardingRepository,
          OnboardingRepository
        >
    with $Provider<OnboardingRepository> {
  OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingRepository create(Ref ref) {
    return onboardingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingRepository>(value),
    );
  }
}

String _$onboardingRepositoryHash() =>
    r'99aa19dcd202b4f3d80ac47fc3d7df65b8e208bd';

@ProviderFor(locationLookup)
final locationLookupProvider = LocationLookupProvider._();

final class LocationLookupProvider
    extends $FunctionalProvider<LocationLookup, LocationLookup, LocationLookup>
    with $Provider<LocationLookup> {
  LocationLookupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationLookupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationLookupHash();

  @$internal
  @override
  $ProviderElement<LocationLookup> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationLookup create(Ref ref) {
    return locationLookup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationLookup value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationLookup>(value),
    );
  }
}

String _$locationLookupHash() => r'c37c2eb6182bea65a28e79c9bbc1343ca860bfa1';

@ProviderFor(photoPicker)
final photoPickerProvider = PhotoPickerProvider._();

final class PhotoPickerProvider
    extends $FunctionalProvider<PhotoPicker, PhotoPicker, PhotoPicker>
    with $Provider<PhotoPicker> {
  PhotoPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoPickerHash();

  @$internal
  @override
  $ProviderElement<PhotoPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoPicker create(Ref ref) {
    return photoPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoPicker>(value),
    );
  }
}

String _$photoPickerHash() => r'e1b561cdb9ab7fb4e394f2f8f43b6b397590981b';

@ProviderFor(photoCropper)
final photoCropperProvider = PhotoCropperProvider._();

final class PhotoCropperProvider
    extends $FunctionalProvider<PhotoCropper, PhotoCropper, PhotoCropper>
    with $Provider<PhotoCropper> {
  PhotoCropperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoCropperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoCropperHash();

  @$internal
  @override
  $ProviderElement<PhotoCropper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotoCropper create(Ref ref) {
    return photoCropper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoCropper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoCropper>(value),
    );
  }
}

String _$photoCropperHash() => r'2bba1b7ef2f991745f5e4123934d8281d929fc19';

@ProviderFor(avatarImage)
final avatarImageProvider = AvatarImageProvider._();

final class AvatarImageProvider
    extends
        $FunctionalProvider<
          AvatarImageBuilder,
          AvatarImageBuilder,
          AvatarImageBuilder
        >
    with $Provider<AvatarImageBuilder> {
  AvatarImageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarImageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarImageHash();

  @$internal
  @override
  $ProviderElement<AvatarImageBuilder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AvatarImageBuilder create(Ref ref) {
    return avatarImage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvatarImageBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvatarImageBuilder>(value),
    );
  }
}

String _$avatarImageHash() => r'3aedd838a34d697a3b65f9a5725439b8d976177b';

/// The signed-in member's onboarding state, fetched from the server. Null while signed out. Every step is
/// saved on the server, so this is also what resumes setup after the app is closed.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// The signed-in member's onboarding state, fetched from the server. Null while signed out. Every step is
/// saved on the server, so this is also what resumes setup after the app is closed.
final class OnboardingControllerProvider
    extends $AsyncNotifierProvider<OnboardingController, OnboardingStateDto?> {
  /// The signed-in member's onboarding state, fetched from the server. Null while signed out. Every step is
  /// saved on the server, so this is also what resumes setup after the app is closed.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();
}

String _$onboardingControllerHash() =>
    r'87b29592056e995be1374bf4d46d24a5643fec51';

/// The signed-in member's onboarding state, fetched from the server. Null while signed out. Every step is
/// saved on the server, so this is also what resumes setup after the app is closed.

abstract class _$OnboardingController
    extends $AsyncNotifier<OnboardingStateDto?> {
  FutureOr<OnboardingStateDto?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<OnboardingStateDto?>, OnboardingStateDto?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OnboardingStateDto?>, OnboardingStateDto?>,
              AsyncValue<OnboardingStateDto?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(onboardingGate)
final onboardingGateProvider = OnboardingGateProvider._();

final class OnboardingGateProvider
    extends $FunctionalProvider<OnboardingGate, OnboardingGate, OnboardingGate>
    with $Provider<OnboardingGate> {
  OnboardingGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingGateHash();

  @$internal
  @override
  $ProviderElement<OnboardingGate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OnboardingGate create(Ref ref) {
    return onboardingGate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingGate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingGate>(value),
    );
  }
}

String _$onboardingGateHash() => r'402f5d2c18866645be75b18e9fc24c98850e7c68';

@ProviderFor(disciplines)
final disciplinesProvider = DisciplinesProvider._();

final class DisciplinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DisciplineDto>>,
          List<DisciplineDto>,
          FutureOr<List<DisciplineDto>>
        >
    with
        $FutureModifier<List<DisciplineDto>>,
        $FutureProvider<List<DisciplineDto>> {
  DisciplinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disciplinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disciplinesHash();

  @$internal
  @override
  $FutureProviderElement<List<DisciplineDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DisciplineDto>> create(Ref ref) {
    return disciplines(ref);
  }
}

String _$disciplinesHash() => r'e9501f2804e29b197f439a9287229822f586ac87';

@ProviderFor(skillOptions)
final skillOptionsProvider = SkillOptionsFamily._();

final class SkillOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaxonomyItemDto>>,
          List<TaxonomyItemDto>,
          FutureOr<List<TaxonomyItemDto>>
        >
    with
        $FutureModifier<List<TaxonomyItemDto>>,
        $FutureProvider<List<TaxonomyItemDto>> {
  SkillOptionsProvider._({
    required SkillOptionsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'skillOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$skillOptionsHash();

  @override
  String toString() {
    return r'skillOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TaxonomyItemDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaxonomyItemDto>> create(Ref ref) {
    final argument = this.argument as String?;
    return skillOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SkillOptionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$skillOptionsHash() => r'ea061c2998808b5644b78af676aca1b324867f62';

final class SkillOptionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TaxonomyItemDto>>, String?> {
  SkillOptionsFamily._()
    : super(
        retry: null,
        name: r'skillOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SkillOptionsProvider call(String? disciplineId) =>
      SkillOptionsProvider._(argument: disciplineId, from: this);

  @override
  String toString() => r'skillOptionsProvider';
}

@ProviderFor(interestOptions)
final interestOptionsProvider = InterestOptionsProvider._();

final class InterestOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaxonomyItemDto>>,
          List<TaxonomyItemDto>,
          FutureOr<List<TaxonomyItemDto>>
        >
    with
        $FutureModifier<List<TaxonomyItemDto>>,
        $FutureProvider<List<TaxonomyItemDto>> {
  InterestOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interestOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interestOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<TaxonomyItemDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaxonomyItemDto>> create(Ref ref) {
    return interestOptions(ref);
  }
}

String _$interestOptionsHash() => r'358997aa99bb6062529e231f318af006038d84f6';

@ProviderFor(developmentAreaOptions)
final developmentAreaOptionsProvider = DevelopmentAreaOptionsProvider._();

final class DevelopmentAreaOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaxonomyItemDto>>,
          List<TaxonomyItemDto>,
          FutureOr<List<TaxonomyItemDto>>
        >
    with
        $FutureModifier<List<TaxonomyItemDto>>,
        $FutureProvider<List<TaxonomyItemDto>> {
  DevelopmentAreaOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'developmentAreaOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$developmentAreaOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<TaxonomyItemDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaxonomyItemDto>> create(Ref ref) {
    return developmentAreaOptions(ref);
  }
}

String _$developmentAreaOptionsHash() =>
    r'990ef1f78358e89789182635399a9fa5be1a5e54';

@ProviderFor(countryOptions)
final countryOptionsProvider = CountryOptionsProvider._();

final class CountryOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CountryDto>>,
          List<CountryDto>,
          FutureOr<List<CountryDto>>
        >
    with $FutureModifier<List<CountryDto>>, $FutureProvider<List<CountryDto>> {
  CountryOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'countryOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$countryOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<CountryDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CountryDto>> create(Ref ref) {
    return countryOptions(ref);
  }
}

String _$countryOptionsHash() => r'9a8a01a755ef37c59ce57ab2407b463d401dd566';

@ProviderFor(countyOptions)
final countyOptionsProvider = CountyOptionsFamily._();

final class CountyOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CountyDto>>,
          List<CountyDto>,
          FutureOr<List<CountyDto>>
        >
    with $FutureModifier<List<CountyDto>>, $FutureProvider<List<CountyDto>> {
  CountyOptionsProvider._({
    required CountyOptionsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'countyOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$countyOptionsHash();

  @override
  String toString() {
    return r'countyOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CountyDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CountyDto>> create(Ref ref) {
    final argument = this.argument as String?;
    return countyOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CountyOptionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$countyOptionsHash() => r'c822fad25ba1e2622f052fc4b251e9f50c07a4c8';

final class CountyOptionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CountyDto>>, String?> {
  CountyOptionsFamily._()
    : super(
        retry: null,
        name: r'countyOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CountyOptionsProvider call(String? country) =>
      CountyOptionsProvider._(argument: country, from: this);

  @override
  String toString() => r'countyOptionsProvider';
}
