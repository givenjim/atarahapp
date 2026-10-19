// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(portfolioRepository)
final portfolioRepositoryProvider = PortfolioRepositoryProvider._();

final class PortfolioRepositoryProvider
    extends
        $FunctionalProvider<
          PortfolioRepository,
          PortfolioRepository,
          PortfolioRepository
        >
    with $Provider<PortfolioRepository> {
  PortfolioRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioRepositoryHash();

  @$internal
  @override
  $ProviderElement<PortfolioRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PortfolioRepository create(Ref ref) {
    return portfolioRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PortfolioRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PortfolioRepository>(value),
    );
  }
}

String _$portfolioRepositoryHash() =>
    r'061d11746e1e4feb8f60e067b728221148b5b43c';

@ProviderFor(mediaPicker)
final mediaPickerProvider = MediaPickerProvider._();

final class MediaPickerProvider
    extends $FunctionalProvider<MediaPicker, MediaPicker, MediaPicker>
    with $Provider<MediaPicker> {
  MediaPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaPickerHash();

  @$internal
  @override
  $ProviderElement<MediaPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaPicker create(Ref ref) {
    return mediaPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaPicker>(value),
    );
  }
}

String _$mediaPickerHash() => r'b7c38f9491f0fc2a5c9c1a30760c69716fe28e9c';

/// How a project's video, audio and embedded player are drawn. Replaced in tests.

@ProviderFor(videoView)
final videoViewProvider = VideoViewProvider._();

/// How a project's video, audio and embedded player are drawn. Replaced in tests.

final class VideoViewProvider
    extends
        $FunctionalProvider<
          MediaViewBuilder,
          MediaViewBuilder,
          MediaViewBuilder
        >
    with $Provider<MediaViewBuilder> {
  /// How a project's video, audio and embedded player are drawn. Replaced in tests.
  VideoViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoViewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoViewHash();

  @$internal
  @override
  $ProviderElement<MediaViewBuilder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaViewBuilder create(Ref ref) {
    return videoView(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaViewBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaViewBuilder>(value),
    );
  }
}

String _$videoViewHash() => r'a685ff799280f0cdfd751766c0f70e4b42d25f16';

@ProviderFor(audioView)
final audioViewProvider = AudioViewProvider._();

final class AudioViewProvider
    extends
        $FunctionalProvider<
          MediaViewBuilder,
          MediaViewBuilder,
          MediaViewBuilder
        >
    with $Provider<MediaViewBuilder> {
  AudioViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioViewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioViewHash();

  @$internal
  @override
  $ProviderElement<MediaViewBuilder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaViewBuilder create(Ref ref) {
    return audioView(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaViewBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaViewBuilder>(value),
    );
  }
}

String _$audioViewHash() => r'7e788abc559ba27485d4971c593a1667c41797cc';

@ProviderFor(embedView)
final embedViewProvider = EmbedViewProvider._();

final class EmbedViewProvider
    extends
        $FunctionalProvider<
          MediaViewBuilder,
          MediaViewBuilder,
          MediaViewBuilder
        >
    with $Provider<MediaViewBuilder> {
  EmbedViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'embedViewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$embedViewHash();

  @$internal
  @override
  $ProviderElement<MediaViewBuilder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaViewBuilder create(Ref ref) {
    return embedView(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaViewBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaViewBuilder>(value),
    );
  }
}

String _$embedViewHash() => r'c7f44277b7be241029ee9a319429955a7d68aa00';

@ProviderFor(myProjects)
final myProjectsProvider = MyProjectsProvider._();

final class MyProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProjectCardDto>>,
          List<ProjectCardDto>,
          FutureOr<List<ProjectCardDto>>
        >
    with
        $FutureModifier<List<ProjectCardDto>>,
        $FutureProvider<List<ProjectCardDto>> {
  MyProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<ProjectCardDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProjectCardDto>> create(Ref ref) {
    return myProjects(ref);
  }
}

String _$myProjectsHash() => r'6df841fafc2bc7535eecb1327771f2892982d513';

@ProviderFor(myProject)
final myProjectProvider = MyProjectFamily._();

final class MyProjectProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProjectDto>,
          ProjectDto,
          FutureOr<ProjectDto>
        >
    with $FutureModifier<ProjectDto>, $FutureProvider<ProjectDto> {
  MyProjectProvider._({
    required MyProjectFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myProjectProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myProjectHash();

  @override
  String toString() {
    return r'myProjectProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProjectDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ProjectDto> create(Ref ref) {
    final argument = this.argument as String;
    return myProject(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyProjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myProjectHash() => r'60cd3d1bd70c598d5bfa478f739139583605e8ff';

final class MyProjectFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProjectDto>, String> {
  MyProjectFamily._()
    : super(
        retry: null,
        name: r'myProjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MyProjectProvider call(String id) =>
      MyProjectProvider._(argument: id, from: this);

  @override
  String toString() => r'myProjectProvider';
}

@ProviderFor(myCollaborations)
final myCollaborationsProvider = MyCollaborationsProvider._();

final class MyCollaborationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CollaborationDto>>,
          List<CollaborationDto>,
          FutureOr<List<CollaborationDto>>
        >
    with
        $FutureModifier<List<CollaborationDto>>,
        $FutureProvider<List<CollaborationDto>> {
  MyCollaborationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCollaborationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCollaborationsHash();

  @$internal
  @override
  $FutureProviderElement<List<CollaborationDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CollaborationDto>> create(Ref ref) {
    return myCollaborations(ref);
  }
}

String _$myCollaborationsHash() => r'8105cbb780dc871865006e47b7bf58dd7c8d5f33';

@ProviderFor(mySkills)
final mySkillsProvider = MySkillsProvider._();

final class MySkillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SkillEntryDto>>,
          List<SkillEntryDto>,
          FutureOr<List<SkillEntryDto>>
        >
    with
        $FutureModifier<List<SkillEntryDto>>,
        $FutureProvider<List<SkillEntryDto>> {
  MySkillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySkillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySkillsHash();

  @$internal
  @override
  $FutureProviderElement<List<SkillEntryDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SkillEntryDto>> create(Ref ref) {
    return mySkills(ref);
  }
}

String _$mySkillsHash() => r'72324adc80a29ae538fe1e6cf8e5051f08f31a31';

@ProviderFor(myExperience)
final myExperienceProvider = MyExperienceProvider._();

final class MyExperienceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExperienceDto>>,
          List<ExperienceDto>,
          FutureOr<List<ExperienceDto>>
        >
    with
        $FutureModifier<List<ExperienceDto>>,
        $FutureProvider<List<ExperienceDto>> {
  MyExperienceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myExperienceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myExperienceHash();

  @$internal
  @override
  $FutureProviderElement<List<ExperienceDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExperienceDto>> create(Ref ref) {
    return myExperience(ref);
  }
}

String _$myExperienceHash() => r'b3cd8495d5c678537e3ec62b8a93b3e1e8cc4fb0';

@ProviderFor(myAchievements)
final myAchievementsProvider = MyAchievementsProvider._();

final class MyAchievementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AchievementDto>>,
          List<AchievementDto>,
          FutureOr<List<AchievementDto>>
        >
    with
        $FutureModifier<List<AchievementDto>>,
        $FutureProvider<List<AchievementDto>> {
  MyAchievementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAchievementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAchievementsHash();

  @$internal
  @override
  $FutureProviderElement<List<AchievementDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AchievementDto>> create(Ref ref) {
    return myAchievements(ref);
  }
}

String _$myAchievementsHash() => r'2fd86fb709608a25148e3e35153d335e26a557bd';

@ProviderFor(myServices)
final myServicesProvider = MyServicesProvider._();

final class MyServicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceDto>>,
          List<ServiceDto>,
          FutureOr<List<ServiceDto>>
        >
    with $FutureModifier<List<ServiceDto>>, $FutureProvider<List<ServiceDto>> {
  MyServicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myServicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myServicesHash();

  @$internal
  @override
  $FutureProviderElement<List<ServiceDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceDto>> create(Ref ref) {
    return myServices(ref);
  }
}

String _$myServicesHash() => r'e82c1a15cafd2169641b038cbcdd6d0581aa5382';

@ProviderFor(creativeProjects)
final creativeProjectsProvider = CreativeProjectsFamily._();

final class CreativeProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProjectCardDto>>,
          List<ProjectCardDto>,
          FutureOr<List<ProjectCardDto>>
        >
    with
        $FutureModifier<List<ProjectCardDto>>,
        $FutureProvider<List<ProjectCardDto>> {
  CreativeProjectsProvider._({
    required CreativeProjectsFamily super.from,
    required (String, PublicProfilePreview?) super.argument,
  }) : super(
         retry: null,
         name: r'creativeProjectsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creativeProjectsHash();

  @override
  String toString() {
    return r'creativeProjectsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProjectCardDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProjectCardDto>> create(Ref ref) {
    final argument = this.argument as (String, PublicProfilePreview?);
    return creativeProjects(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CreativeProjectsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creativeProjectsHash() => r'40b91f4ae97b3211c74b5165536a7c7bd29f3739';

final class CreativeProjectsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ProjectCardDto>>,
          (String, PublicProfilePreview?)
        > {
  CreativeProjectsFamily._()
    : super(
        retry: null,
        name: r'creativeProjectsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreativeProjectsProvider call(String handle, PublicProfilePreview? preview) =>
      CreativeProjectsProvider._(argument: (handle, preview), from: this);

  @override
  String toString() => r'creativeProjectsProvider';
}

@ProviderFor(creativeProject)
final creativeProjectProvider = CreativeProjectFamily._();

final class CreativeProjectProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProjectDto>,
          ProjectDto,
          FutureOr<ProjectDto>
        >
    with $FutureModifier<ProjectDto>, $FutureProvider<ProjectDto> {
  CreativeProjectProvider._({
    required CreativeProjectFamily super.from,
    required (String, String, PublicProfilePreview?) super.argument,
  }) : super(
         retry: null,
         name: r'creativeProjectProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creativeProjectHash();

  @override
  String toString() {
    return r'creativeProjectProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ProjectDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ProjectDto> create(Ref ref) {
    final argument = this.argument as (String, String, PublicProfilePreview?);
    return creativeProject(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is CreativeProjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creativeProjectHash() => r'6de8fb9dc517c34b07d7cfb2690ba868b3d3aae4';

final class CreativeProjectFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ProjectDto>,
          (String, String, PublicProfilePreview?)
        > {
  CreativeProjectFamily._()
    : super(
        retry: null,
        name: r'creativeProjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreativeProjectProvider call(
    String handle,
    String id,
    PublicProfilePreview? preview,
  ) => CreativeProjectProvider._(argument: (handle, id, preview), from: this);

  @override
  String toString() => r'creativeProjectProvider';
}

@ProviderFor(creativeSkills)
final creativeSkillsProvider = CreativeSkillsFamily._();

final class CreativeSkillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SkillEntryDto>>,
          List<SkillEntryDto>,
          FutureOr<List<SkillEntryDto>>
        >
    with
        $FutureModifier<List<SkillEntryDto>>,
        $FutureProvider<List<SkillEntryDto>> {
  CreativeSkillsProvider._({
    required CreativeSkillsFamily super.from,
    required (String, PublicProfilePreview?) super.argument,
  }) : super(
         retry: null,
         name: r'creativeSkillsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creativeSkillsHash();

  @override
  String toString() {
    return r'creativeSkillsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SkillEntryDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SkillEntryDto>> create(Ref ref) {
    final argument = this.argument as (String, PublicProfilePreview?);
    return creativeSkills(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CreativeSkillsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creativeSkillsHash() => r'e2f858d24de5e87b8cdcfff9aeceb4927af1253f';

final class CreativeSkillsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SkillEntryDto>>,
          (String, PublicProfilePreview?)
        > {
  CreativeSkillsFamily._()
    : super(
        retry: null,
        name: r'creativeSkillsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreativeSkillsProvider call(String handle, PublicProfilePreview? preview) =>
      CreativeSkillsProvider._(argument: (handle, preview), from: this);

  @override
  String toString() => r'creativeSkillsProvider';
}

@ProviderFor(creativeExperience)
final creativeExperienceProvider = CreativeExperienceFamily._();

final class CreativeExperienceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExperienceDto>>,
          List<ExperienceDto>,
          FutureOr<List<ExperienceDto>>
        >
    with
        $FutureModifier<List<ExperienceDto>>,
        $FutureProvider<List<ExperienceDto>> {
  CreativeExperienceProvider._({
    required CreativeExperienceFamily super.from,
    required (String, PublicProfilePreview?) super.argument,
  }) : super(
         retry: null,
         name: r'creativeExperienceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creativeExperienceHash();

  @override
  String toString() {
    return r'creativeExperienceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExperienceDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExperienceDto>> create(Ref ref) {
    final argument = this.argument as (String, PublicProfilePreview?);
    return creativeExperience(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CreativeExperienceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creativeExperienceHash() =>
    r'8f6dcb920ae391e4ca2a0d8378b418e8c0d884fa';

final class CreativeExperienceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExperienceDto>>,
          (String, PublicProfilePreview?)
        > {
  CreativeExperienceFamily._()
    : super(
        retry: null,
        name: r'creativeExperienceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreativeExperienceProvider call(
    String handle,
    PublicProfilePreview? preview,
  ) => CreativeExperienceProvider._(argument: (handle, preview), from: this);

  @override
  String toString() => r'creativeExperienceProvider';
}

@ProviderFor(creativeAchievements)
final creativeAchievementsProvider = CreativeAchievementsFamily._();

final class CreativeAchievementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AchievementDto>>,
          List<AchievementDto>,
          FutureOr<List<AchievementDto>>
        >
    with
        $FutureModifier<List<AchievementDto>>,
        $FutureProvider<List<AchievementDto>> {
  CreativeAchievementsProvider._({
    required CreativeAchievementsFamily super.from,
    required (String, PublicProfilePreview?) super.argument,
  }) : super(
         retry: null,
         name: r'creativeAchievementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creativeAchievementsHash();

  @override
  String toString() {
    return r'creativeAchievementsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<AchievementDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AchievementDto>> create(Ref ref) {
    final argument = this.argument as (String, PublicProfilePreview?);
    return creativeAchievements(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CreativeAchievementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creativeAchievementsHash() =>
    r'dbb6bfd046ae56a3c2f945b245b314e0c1cc00ac';

final class CreativeAchievementsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<AchievementDto>>,
          (String, PublicProfilePreview?)
        > {
  CreativeAchievementsFamily._()
    : super(
        retry: null,
        name: r'creativeAchievementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreativeAchievementsProvider call(
    String handle,
    PublicProfilePreview? preview,
  ) => CreativeAchievementsProvider._(argument: (handle, preview), from: this);

  @override
  String toString() => r'creativeAchievementsProvider';
}

@ProviderFor(creativeServices)
final creativeServicesProvider = CreativeServicesFamily._();

final class CreativeServicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ServiceDto>>,
          List<ServiceDto>,
          FutureOr<List<ServiceDto>>
        >
    with $FutureModifier<List<ServiceDto>>, $FutureProvider<List<ServiceDto>> {
  CreativeServicesProvider._({
    required CreativeServicesFamily super.from,
    required (String, PublicProfilePreview?) super.argument,
  }) : super(
         retry: null,
         name: r'creativeServicesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creativeServicesHash();

  @override
  String toString() {
    return r'creativeServicesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ServiceDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServiceDto>> create(Ref ref) {
    final argument = this.argument as (String, PublicProfilePreview?);
    return creativeServices(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CreativeServicesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creativeServicesHash() => r'429f3da7cbde59b97071b8c9b1e3a99127cf8313';

final class CreativeServicesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ServiceDto>>,
          (String, PublicProfilePreview?)
        > {
  CreativeServicesFamily._()
    : super(
        retry: null,
        name: r'creativeServicesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreativeServicesProvider call(String handle, PublicProfilePreview? preview) =>
      CreativeServicesProvider._(argument: (handle, preview), from: this);

  @override
  String toString() => r'creativeServicesProvider';
}
