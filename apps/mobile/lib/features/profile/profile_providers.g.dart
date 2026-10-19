// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'3d2969a7867fde5331e17bf78049b2ec3d3d10c0';

/// The signed-in member's own profile. Null while signed out. Reloads when a different member signs in.

@ProviderFor(MyProfile)
final myProfileProvider = MyProfileProvider._();

/// The signed-in member's own profile. Null while signed out. Reloads when a different member signs in.
final class MyProfileProvider
    extends $AsyncNotifierProvider<MyProfile, OwnProfileDto?> {
  /// The signed-in member's own profile. Null while signed out. Reloads when a different member signs in.
  MyProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileHash();

  @$internal
  @override
  MyProfile create() => MyProfile();
}

String _$myProfileHash() => r'67c6fb45540ac005322dfcce8a2a25da69058a8b';

/// The signed-in member's own profile. Null while signed out. Reloads when a different member signs in.

abstract class _$MyProfile extends $AsyncNotifier<OwnProfileDto?> {
  FutureOr<OwnProfileDto?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OwnProfileDto?>, OwnProfileDto?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OwnProfileDto?>, OwnProfileDto?>,
              AsyncValue<OwnProfileDto?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The Creative Passport screen's data, with the visibility rows editable in place.

@ProviderFor(MyPassport)
final myPassportProvider = MyPassportProvider._();

/// The Creative Passport screen's data, with the visibility rows editable in place.
final class MyPassportProvider
    extends $AsyncNotifierProvider<MyPassport, PassportDto> {
  /// The Creative Passport screen's data, with the visibility rows editable in place.
  MyPassportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPassportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPassportHash();

  @$internal
  @override
  MyPassport create() => MyPassport();
}

String _$myPassportHash() => r'c1ca8fd77ff6ac4ba457bda3e05de03aae11fe4d';

/// The Creative Passport screen's data, with the visibility rows editable in place.

abstract class _$MyPassport extends $AsyncNotifier<PassportDto> {
  FutureOr<PassportDto> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PassportDto>, PassportDto>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PassportDto>, PassportDto>,
              AsyncValue<PassportDto>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Another member's profile (or the owner's own, for "Public view"), filtered by the server for the caller.

@ProviderFor(creativeProfile)
final creativeProfileProvider = CreativeProfileFamily._();

/// Another member's profile (or the owner's own, for "Public view"), filtered by the server for the caller.

final class CreativeProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<PublicProfileDto>,
          PublicProfileDto,
          FutureOr<PublicProfileDto>
        >
    with $FutureModifier<PublicProfileDto>, $FutureProvider<PublicProfileDto> {
  /// Another member's profile (or the owner's own, for "Public view"), filtered by the server for the caller.
  CreativeProfileProvider._({
    required CreativeProfileFamily super.from,
    required (String, PublicProfilePreview?) super.argument,
  }) : super(
         retry: null,
         name: r'creativeProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creativeProfileHash();

  @override
  String toString() {
    return r'creativeProfileProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PublicProfileDto> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PublicProfileDto> create(Ref ref) {
    final argument = this.argument as (String, PublicProfilePreview?);
    return creativeProfile(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CreativeProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creativeProfileHash() => r'a9247c10b04c60c66c17144f72b99fc82bc591f1';

/// Another member's profile (or the owner's own, for "Public view"), filtered by the server for the caller.

final class CreativeProfileFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PublicProfileDto>,
          (String, PublicProfilePreview?)
        > {
  CreativeProfileFamily._()
    : super(
        retry: null,
        name: r'creativeProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Another member's profile (or the owner's own, for "Public view"), filtered by the server for the caller.

  CreativeProfileProvider call(String handle, PublicProfilePreview? preview) =>
      CreativeProfileProvider._(argument: (handle, preview), from: this);

  @override
  String toString() => r'creativeProfileProvider';
}

@ProviderFor(shareText)
final shareTextProvider = ShareTextProvider._();

final class ShareTextProvider
    extends $FunctionalProvider<ShareText, ShareText, ShareText>
    with $Provider<ShareText> {
  ShareTextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareTextProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareTextHash();

  @$internal
  @override
  $ProviderElement<ShareText> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareText create(Ref ref) {
    return shareText(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareText value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareText>(value),
    );
  }
}

String _$shareTextHash() => r'2018952dadcb9ce581f7fd1d7d74d64f4023b94a';

@ProviderFor(openLink)
final openLinkProvider = OpenLinkProvider._();

final class OpenLinkProvider
    extends $FunctionalProvider<OpenLink, OpenLink, OpenLink>
    with $Provider<OpenLink> {
  OpenLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openLinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openLinkHash();

  @$internal
  @override
  $ProviderElement<OpenLink> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OpenLink create(Ref ref) {
    return openLink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenLink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenLink>(value),
    );
  }
}

String _$openLinkHash() => r'ee86284348e7fb8a7454576adce9c67508874ed7';
