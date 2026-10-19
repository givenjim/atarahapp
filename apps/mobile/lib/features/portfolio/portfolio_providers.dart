import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/generated/export.dart';
import '../../core/providers.dart';
import '../profile/profile_repository.dart';
import 'media_seams.dart';
import 'portfolio_repository.dart';

part 'portfolio_providers.g.dart';

@Riverpod(keepAlive: true)
PortfolioRepository portfolioRepository(Ref ref) => PortfolioRepository(
  api: ref.watch(apiClientProvider),
  plain: ref.watch(plainDioProvider),
);

@Riverpod(keepAlive: true)
MediaPicker mediaPicker(Ref ref) => DeviceMediaPicker();

/// How a project's video, audio and embedded player are drawn. Replaced in tests.
@Riverpod(keepAlive: true)
MediaViewBuilder videoView(Ref ref) => deviceVideoView;

@Riverpod(keepAlive: true)
MediaViewBuilder audioView(Ref ref) => deviceAudioView;

@Riverpod(keepAlive: true)
MediaViewBuilder embedView(Ref ref) => deviceEmbedView;

PreviewAs? _previewAs(PublicProfilePreview? p) => switch (p) {
  PublicProfilePreview.public => PreviewAs.public,
  PublicProfilePreview.members => PreviewAs.members,
  null => null,
};

// ---- own ----

@riverpod
Future<List<ProjectCardDto>> myProjects(Ref ref) =>
    ref.watch(portfolioRepositoryProvider).myProjects();

@riverpod
Future<ProjectDto> myProject(Ref ref, String id) =>
    ref.watch(portfolioRepositoryProvider).myProject(id);

@riverpod
Future<List<CollaborationDto>> myCollaborations(Ref ref) =>
    ref.watch(portfolioRepositoryProvider).myCollaborations();

@riverpod
Future<List<SkillEntryDto>> mySkills(Ref ref) =>
    ref.watch(portfolioRepositoryProvider).mySkills();

@riverpod
Future<List<ExperienceDto>> myExperience(Ref ref) =>
    ref.watch(portfolioRepositoryProvider).myExperience();

@riverpod
Future<List<AchievementDto>> myAchievements(Ref ref) =>
    ref.watch(portfolioRepositoryProvider).myAchievements();

@riverpod
Future<List<ServiceDto>> myServices(Ref ref) =>
    ref.watch(portfolioRepositoryProvider).myServices();

// ---- someone else's (or the owner's own, for "Public view") ----

@riverpod
Future<List<ProjectCardDto>> creativeProjects(
  Ref ref,
  String handle,
  PublicProfilePreview? preview,
) => ref
    .watch(portfolioRepositoryProvider)
    .creativeProjects(handle, previewAs: _previewAs(preview));

@riverpod
Future<ProjectDto> creativeProject(
  Ref ref,
  String handle,
  String id,
  PublicProfilePreview? preview,
) => ref
    .watch(portfolioRepositoryProvider)
    .creativeProject(handle, id, previewAs: _previewAs(preview));

@riverpod
Future<List<SkillEntryDto>> creativeSkills(
  Ref ref,
  String handle,
  PublicProfilePreview? preview,
) => ref
    .watch(portfolioRepositoryProvider)
    .creativeSkills(handle, previewAs: _previewAs(preview));

@riverpod
Future<List<ExperienceDto>> creativeExperience(
  Ref ref,
  String handle,
  PublicProfilePreview? preview,
) => ref
    .watch(portfolioRepositoryProvider)
    .creativeExperience(handle, previewAs: _previewAs(preview));

@riverpod
Future<List<AchievementDto>> creativeAchievements(
  Ref ref,
  String handle,
  PublicProfilePreview? preview,
) => ref
    .watch(portfolioRepositoryProvider)
    .creativeAchievements(handle, previewAs: _previewAs(preview));

@riverpod
Future<List<ServiceDto>> creativeServices(
  Ref ref,
  String handle,
  PublicProfilePreview? preview,
) => ref
    .watch(portfolioRepositoryProvider)
    .creativeServices(handle, previewAs: _previewAs(preview));
