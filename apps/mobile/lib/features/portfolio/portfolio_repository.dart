import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

/// Which projects the owner's list shows.
enum OwnProjectFilter { all, drafts, published }

/// A file the member chose for a project, still on the phone.
class PickedMedia {
  const PickedMedia({
    required this.path,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String path;
  final String name;
  final String mimeType;
  final int sizeBytes;

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');
  bool get isAudio => mimeType.startsWith('audio/');
}

/// Everything the portfolio, skills, experience, achievements and services screens need from the API, with
/// errors mapped to typed failures. Widgets go through providers; tests replace this with an in-memory fake.
class PortfolioRepository {
  PortfolioRepository({required this._api, required this._plain});

  final AtarahApiClient _api;

  /// A Dio with no auth interceptor: the signed upload URL carries its own authority and must not receive
  /// the member's bearer token.
  final Dio _plain;

  static const _processingTimeout = Duration(minutes: 3);
  static const _processingPoll = Duration(seconds: 1);

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  // ---- projects: own ----

  Future<List<ProjectCardDto>> myProjects([
    OwnProjectFilter filter = OwnProjectFilter.all,
  ]) => _guard(
    () async => (await _api.portfolio.myProjects(
      listFilter: switch (filter) {
        OwnProjectFilter.all => ListFilter.all,
        OwnProjectFilter.drafts => ListFilter.drafts,
        OwnProjectFilter.published => ListFilter.published,
      },
    )).data,
  );

  Future<ProjectDto> createProject({String? title}) => _guard(
    () async => (await _api.portfolio.createProject(
      body: CreateProjectDto(title: title),
    )).data,
  );

  Future<ProjectDto> myProject(String id) =>
      _guard(() async => (await _api.portfolio.myProject(id: id)).data);

  Future<ProjectDto> updateProject(String id, UpdateProjectDto body) => _guard(
    () async => (await _api.portfolio.updateProject(id: id, body: body)).data,
  );

  Future<ProjectDto> publishProject(String id) =>
      _guard(() async => (await _api.portfolio.publishProject(id: id)).data);

  Future<void> deleteProject(String id) =>
      _guard(() => _api.portfolio.deleteProject(id: id));

  Future<ProjectDto> addCollaborator(
    String projectId,
    AddCollaboratorDto body,
  ) => _guard(
    () async =>
        (await _api.portfolio.addCollaborator(id: projectId, body: body)).data,
  );

  Future<ProjectDto> removeCollaborator(
    String projectId,
    String collaboratorId,
  ) => _guard(
    () async => (await _api.portfolio.removeCollaborator(
      id: projectId,
      collaboratorId: collaboratorId,
    )).data,
  );

  Future<List<CollaborationDto>> myCollaborations() =>
      _guard(() async => (await _api.portfolio.myCollaborations()).data);

  Future<CollaborationDto> acceptCollaboration(String id) => _guard(
    () async => (await _api.portfolio.acceptCollaboration(id: id)).data,
  );

  Future<void> leaveCollaboration(String id) =>
      _guard(() => _api.portfolio.leaveCollaboration(id: id));

  Future<List<MemberHitDto>> searchMembers(String q) => _guard(
    () async => (await _api.portfolio.searchMembers(q: q, limit: 10)).data,
  );

  // ---- projects: someone else's ----

  Future<List<ProjectCardDto>> creativeProjects(
    String handle, {
    String? category,
    bool featuredOnly = false,
    PreviewAs? previewAs,
  }) => _guard(
    () async => (await _api.portfolio.creativeProjects(
      handle: handle,
      previewAs: previewAs,
      category: category == null ? null : Category.fromJson(category),
      featuredOnly: featuredOnly ? true : null,
    )).data,
  );

  Future<ProjectDto> creativeProject(
    String handle,
    String id, {
    PreviewAs? previewAs,
  }) => _guard(
    () async => (await _api.portfolio.creativeProject(
      handle: handle,
      id: id,
      previewAs: previewAs,
    )).data,
  );

  Future<List<SkillEntryDto>> creativeSkills(
    String handle, {
    PreviewAs? previewAs,
  }) => _guard(
    () async => (await _api.portfolio.creativeSkills(
      handle: handle,
      previewAs: previewAs,
    )).data,
  );

  Future<List<ExperienceDto>> creativeExperience(
    String handle, {
    PreviewAs? previewAs,
  }) => _guard(
    () async => (await _api.portfolio.creativeExperience(
      handle: handle,
      previewAs: previewAs,
    )).data,
  );

  Future<List<AchievementDto>> creativeAchievements(
    String handle, {
    PreviewAs? previewAs,
  }) => _guard(
    () async => (await _api.portfolio.creativeAchievements(
      handle: handle,
      previewAs: previewAs,
    )).data,
  );

  Future<List<ServiceDto>> creativeServices(
    String handle, {
    PreviewAs? previewAs,
  }) => _guard(
    () async => (await _api.portfolio.creativeServices(
      handle: handle,
      previewAs: previewAs,
    )).data,
  );

  // ---- skills ----

  Future<List<SkillEntryDto>> mySkills() =>
      _guard(() async => (await _api.portfolio.mySkills()).data);

  Future<SkillEntryDto> setSkill(String skillId, SetSkillDtoLevel level) =>
      _guard(
        () async => (await _api.portfolio.setSkill(
          skillId: skillId,
          body: SetSkillDto(level: level),
        )).data,
      );

  Future<void> removeSkill(String skillId) =>
      _guard(() => _api.portfolio.removeSkill(skillId: skillId));

  /// Skills the member can add, general ones plus those of [disciplineId].
  Future<List<TaxonomyItemDto>> skillChoices({String? disciplineId}) => _guard(
    () async => (await _api.taxonomy.skills(discipline: disciplineId)).data,
  );

  // ---- experience ----

  Future<List<ExperienceDto>> myExperience() =>
      _guard(() async => (await _api.portfolio.myExperience()).data);

  Future<ExperienceDto> addExperience(ExperienceInputDto body) =>
      _guard(() async => (await _api.portfolio.addExperience(body: body)).data);

  Future<ExperienceDto> updateExperience(String id, UpdateExperienceDto body) =>
      _guard(
        () async =>
            (await _api.portfolio.updateExperience(id: id, body: body)).data,
      );

  Future<void> deleteExperience(String id) =>
      _guard(() => _api.portfolio.deleteExperience(id: id));

  // ---- achievements ----

  Future<List<AchievementDto>> myAchievements() =>
      _guard(() async => (await _api.portfolio.myAchievements()).data);

  Future<AchievementDto> addAchievement(AchievementInputDto body) => _guard(
    () async => (await _api.portfolio.addAchievement(body: body)).data,
  );

  Future<AchievementDto> updateAchievement(
    String id,
    UpdateAchievementDto body,
  ) => _guard(
    () async =>
        (await _api.portfolio.updateAchievement(id: id, body: body)).data,
  );

  Future<void> deleteAchievement(String id) =>
      _guard(() => _api.portfolio.deleteAchievement(id: id));

  // ---- services ----

  Future<List<ServiceDto>> myServices() =>
      _guard(() async => (await _api.portfolio.myServices()).data);

  Future<ServiceDto> addService(ServiceInputDto body) =>
      _guard(() async => (await _api.portfolio.addService(body: body)).data);

  Future<ServiceDto> updateService(String id, UpdateServiceDto body) => _guard(
    () async => (await _api.portfolio.updateService(id: id, body: body)).data,
  );

  Future<void> deleteService(String id) =>
      _guard(() => _api.portfolio.deleteService(id: id));

  // ---- uploads ----

  /// Sends [file] through the media pipeline (signed PUT, confirm, wait for validation) and returns the
  /// finished asset's id. [onProgress] reports 0..1 while the bytes go up.
  Future<String> uploadMedia(
    PickedMedia file, {
    void Function(double progress)? onProgress,
  }) => _guard(() async {
    final kind = file.isImage
        ? RequestUploadDtoKind.image
        : file.isVideo
        ? RequestUploadDtoKind.video
        : RequestUploadDtoKind.audio;
    final ticket = (await _api.media.requestUpload(
      body: RequestUploadDto(
        kind: kind,
        mimeType: file.mimeType,
        sizeBytes: file.sizeBytes,
        visibility: RequestUploadDtoVisibility.public,
      ),
    )).data;
    await _plain.put<void>(
      ticket.uploadUrl,
      // Streamed from disk: a 200 MB video must not sit in memory.
      data: File(file.path).openRead(),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
      options: Options(
        headers: {
          ...ticket.headers,
          Headers.contentLengthHeader: file.sizeBytes,
        },
        sendTimeout: const Duration(minutes: 10),
        // The storage server answers 200 with an empty body; anything else is a failure.
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
    var asset = (await _api.media.complete(id: ticket.id)).data;
    final deadline = DateTime.now().add(_processingTimeout);
    while (asset.status != MediaAssetDtoStatus.ready) {
      if (asset.status == MediaAssetDtoStatus.rejected ||
          asset.status == MediaAssetDtoStatus.deleted) {
        throw ApiFailure(
          code: 'VALIDATION_ERROR',
          message:
              asset.rejectionReason ??
              'That file could not be used. Try another one.',
          statusCode: 400,
        );
      }
      if (DateTime.now().isAfter(deadline)) {
        throw const NetworkFailure(timedOut: true);
      }
      await Future<void>.delayed(_processingPoll);
      asset = (await _api.media.getApiV1MediaId(id: ticket.id)).data;
    }
    return ticket.id;
  });
}
