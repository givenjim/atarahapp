import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/portfolio/media_seams.dart';
import 'package:atarah/features/portfolio/portfolio_repository.dart';
import 'package:flutter/widgets.dart';

ProjectDto projectDto({
  String id = 'pr-1',
  String title = 'Mama Mboga',
  String category = 'MEDIA',
  String status = 'PUBLISHED',
  String visibility = 'PUBLIC',
  bool featured = false,
  bool hidden = false,
  String? role = 'Lead animator',
  String? client,
  String? description = 'A short film about the market.',
  String? outcome = 'Shown at three festivals.',
  String? projectDate = '2026-03-14',
  String? hiddenReason,
  List<ProjectMediaDto> media = const [],
  List<ProjectLinkDto> links = const [],
  List<TaxonomyItemDto> skills = const [],
  List<CollaboratorDto> collaborators = const [],
}) => ProjectDto(
  id: id,
  title: title,
  role: role,
  category: ProjectDtoCategory.fromJson(category),
  projectDate: projectDate,
  featured: featured,
  status: ProjectDtoStatus.fromJson(status),
  visibility: ProjectDtoVisibility.fromJson(visibility),
  coverUrl: null,
  mediaCount: media.length,
  hidden: hidden,
  updatedAt: DateTime.utc(2026, 10, 18),
  client: client,
  description: description,
  outcome: outcome,
  skills: skills,
  media: media,
  links: links,
  collaborators: collaborators,
  hiddenReason: hiddenReason,
);

ProjectMediaDto imageMedia(String id) => ProjectMediaDto(
  id: id,
  kind: ProjectMediaDtoKind.image,
  mimeType: 'image/jpeg',
  status: ProjectMediaDtoStatus.ready,
  url: 'https://signed.test/$id',
  thumbnailUrl: 'https://signed.test/$id-600',
  width: 800,
  height: 600,
);

ProjectMediaDto videoMedia(String id) => ProjectMediaDto(
  id: id,
  kind: ProjectMediaDtoKind.video,
  mimeType: 'video/mp4',
  status: ProjectMediaDtoStatus.ready,
  url: 'https://signed.test/$id.mp4',
);

ProjectMediaDto audioMedia(String id) => ProjectMediaDto(
  id: id,
  kind: ProjectMediaDtoKind.audio,
  mimeType: 'audio/mpeg',
  status: ProjectMediaDtoStatus.ready,
  url: 'https://signed.test/$id.mp3',
);

ProjectCardDto cardOf(ProjectDto p) => ProjectCardDto(
  id: p.id,
  title: p.title,
  role: p.role,
  category: ProjectCardDtoCategory.fromJson(p.category.json!),
  projectDate: p.projectDate,
  featured: p.featured,
  status: ProjectCardDtoStatus.fromJson(p.status.json!),
  visibility: ProjectCardDtoVisibility.fromJson(p.visibility.json!),
  coverUrl: p.media.isEmpty ? null : p.media.first.thumbnailUrl,
  mediaCount: p.media.length,
  hidden: p.hidden,
  updatedAt: p.updatedAt,
);

SkillEntryDto skillEntry(
  String id,
  String name, {
  String? level,
  String source = 'SELF_DECLARED',
  int projects = 0,
}) => SkillEntryDto(
  id: id,
  slug: name.toLowerCase().replaceAll(' ', '-'),
  name: name,
  level: level == null ? null : SkillEntryDtoLevel.fromJson(level),
  source: SkillEntryDtoSource.fromJson(source),
  projectCount: projects,
);

/// In-memory stand-in for the portfolio, skills, experience, achievements and services API.
class FakePortfolioRepository implements PortfolioRepository {
  /// The signed-in member's projects, newest first.
  final List<ProjectDto> projects = [];
  final List<CollaborationDto> collaborations = [];
  final List<SkillEntryDto> skills = [];
  final List<TaxonomyItemDto> skillCatalogue = [];
  final List<ExperienceDto> experience = [];
  final List<AchievementDto> achievements = [];
  final List<ServiceDto> services = [];
  final List<MemberHitDto> members = [];

  /// What other members' pages return, by handle.
  final Map<String, List<ProjectDto>> creativeProjectsByHandle = {};
  final Map<String, List<ServiceDto>> creativeServicesByHandle = {};
  final Map<String, List<ExperienceDto>> creativeExperienceByHandle = {};
  final Map<String, List<AchievementDto>> creativeAchievementsByHandle = {};

  AppFailure? listFailure;
  AppFailure? saveFailure;
  AppFailure? publishFailure;
  AppFailure? uploadFailure;

  final List<UpdateProjectDto> updates = [];
  final List<PickedMedia> uploaded = [];
  final List<String> calls = [];
  var _next = 0;
  String _id(String p) => '$p-${++_next}';

  ProjectDto _find(String id) => projects.firstWhere(
    (p) => p.id == id,
    orElse: () => throw const ApiFailure(
      code: 'RESOURCE_NOT_FOUND',
      message: 'Not found',
      statusCode: 404,
    ),
  );

  void _replace(ProjectDto next) {
    final i = projects.indexWhere((p) => p.id == next.id);
    projects[i] = next;
  }

  // ---- projects ----

  @override
  Future<List<ProjectCardDto>> myProjects([
    OwnProjectFilter filter = OwnProjectFilter.all,
  ]) async {
    final f = listFailure;
    if (f != null) {
      listFailure = null;
      throw f;
    }
    return [
      for (final p in projects)
        if (filter == OwnProjectFilter.all ||
            (filter == OwnProjectFilter.drafts &&
                p.status == ProjectDtoStatus.draft) ||
            (filter == OwnProjectFilter.published &&
                p.status == ProjectDtoStatus.published))
          cardOf(p),
    ];
  }

  @override
  Future<ProjectDto> createProject({String? title}) async {
    calls.add('create');
    final p = projectDto(
      id: _id('pr'),
      title: title ?? '',
      status: 'DRAFT',
      category: 'PROJECT',
      role: null,
      description: null,
      outcome: null,
      projectDate: null,
    );
    projects.insert(0, p);
    return p;
  }

  @override
  Future<ProjectDto> myProject(String id) async {
    final f = listFailure;
    if (f != null) {
      listFailure = null;
      throw f;
    }
    return _find(id);
  }

  @override
  Future<ProjectDto> updateProject(String id, UpdateProjectDto body) async {
    final f = saveFailure;
    if (f != null) throw f;
    updates.add(body);
    final cur = _find(id);
    String? blank(String? v) => v == null || v.isEmpty ? null : v;
    final next = ProjectDto(
      id: cur.id,
      title: body.title ?? cur.title,
      role: body.role == null ? cur.role : blank(body.role),
      category: body.category == null
          ? cur.category
          : ProjectDtoCategory.fromJson(body.category!.json!),
      projectDate: body.projectDate == null
          ? cur.projectDate
          : blank(body.projectDate),
      featured: body.featured ?? cur.featured,
      status: cur.status,
      visibility: body.visibility == null
          ? cur.visibility
          : ProjectDtoVisibility.fromJson(body.visibility!.json!),
      coverUrl: cur.coverUrl,
      mediaCount: body.mediaIds?.length ?? cur.mediaCount,
      hidden: cur.hidden,
      updatedAt: DateTime.now().toUtc(),
      client: body.client == null ? cur.client : blank(body.client),
      description: body.description == null
          ? cur.description
          : blank(body.description),
      outcome: body.outcome == null ? cur.outcome : blank(body.outcome),
      skills: body.skillIds == null
          ? cur.skills
          : [
              for (final s in body.skillIds!)
                skillCatalogue.firstWhere((c) => c.id == s),
            ],
      media: body.mediaIds == null
          ? cur.media
          : [for (final m in body.mediaIds!) imageMedia(m)],
      links: body.links == null
          ? cur.links
          : [
              for (final (i, l) in body.links!.indexed)
                ProjectLinkDto(id: 'ln$i', label: l.label, url: l.url),
            ],
      collaborators: cur.collaborators,
    );
    _replace(next);
    return next;
  }

  @override
  Future<ProjectDto> publishProject(String id) async {
    final f = publishFailure;
    if (f != null) throw f;
    calls.add('publish');
    final cur = _find(id);
    final next = projectDto(
      id: cur.id,
      title: cur.title,
      category: cur.category.json!,
      status: 'PUBLISHED',
      visibility: cur.visibility.json!,
      featured: cur.featured,
      role: cur.role,
      client: cur.client,
      description: cur.description,
      outcome: cur.outcome,
      projectDate: cur.projectDate,
      media: cur.media,
      links: cur.links,
      skills: cur.skills,
      collaborators: cur.collaborators,
    );
    _replace(next);
    return next;
  }

  @override
  Future<void> deleteProject(String id) async {
    calls.add('delete');
    projects.removeWhere((p) => p.id == id);
  }

  @override
  Future<ProjectDto> addCollaborator(
    String projectId,
    AddCollaboratorDto body,
  ) async {
    calls.add('collaborator');
    final cur = _find(projectId);
    final name =
        body.name ??
        members.firstWhere((m) => m.userId == body.userId).displayName;
    final next = projectDto(
      id: cur.id,
      title: cur.title,
      status: cur.status.json!,
      collaborators: [
        ...cur.collaborators,
        CollaboratorDto(
          id: _id('cb'),
          name: name,
          role: body.role,
          status: body.userId == null
              ? CollaboratorDtoStatus.accepted
              : CollaboratorDtoStatus.pending,
          handle: body.userId == null ? null : 'member',
        ),
      ],
    );
    _replace(next);
    return next;
  }

  @override
  Future<ProjectDto> removeCollaborator(
    String projectId,
    String collaboratorId,
  ) async {
    final cur = _find(projectId);
    final next = projectDto(
      id: cur.id,
      title: cur.title,
      status: cur.status.json!,
      collaborators: [
        for (final c in cur.collaborators)
          if (c.id != collaboratorId) c,
      ],
    );
    _replace(next);
    return next;
  }

  @override
  Future<List<CollaborationDto>> myCollaborations() async =>
      List.of(collaborations);

  @override
  Future<CollaborationDto> acceptCollaboration(String id) async {
    calls.add('accept:$id');
    final i = collaborations.indexWhere((c) => c.id == id);
    final c = collaborations[i];
    collaborations[i] = CollaborationDto(
      id: c.id,
      status: CollaborationDtoStatus.accepted,
      role: c.role,
      projectId: c.projectId,
      projectTitle: c.projectTitle,
      ownerName: c.ownerName,
      ownerHandle: c.ownerHandle,
    );
    return collaborations[i];
  }

  @override
  Future<void> leaveCollaboration(String id) async {
    calls.add('leave:$id');
    collaborations.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<MemberHitDto>> searchMembers(String q) async => [
    for (final m in members)
      if (m.displayName.toLowerCase().contains(q.toLowerCase())) m,
  ];

  // ---- someone else's ----

  @override
  Future<List<ProjectCardDto>> creativeProjects(
    String handle, {
    String? category,
    bool featuredOnly = false,
    PreviewAs? previewAs,
  }) async {
    final f = listFailure;
    if (f != null) {
      listFailure = null;
      throw f;
    }
    calls.add('creativeProjects:$handle:${previewAs?.json}');
    return [
      for (final p in creativeProjectsByHandle[handle] ?? const <ProjectDto>[])
        cardOf(p),
    ];
  }

  @override
  Future<ProjectDto> creativeProject(
    String handle,
    String id, {
    PreviewAs? previewAs,
  }) async {
    final list = creativeProjectsByHandle[handle] ?? const <ProjectDto>[];
    return list.firstWhere(
      (p) => p.id == id,
      orElse: () => throw const ApiFailure(
        code: 'RESOURCE_NOT_FOUND',
        message: 'Not found',
        statusCode: 404,
      ),
    );
  }

  @override
  Future<List<SkillEntryDto>> creativeSkills(
    String handle, {
    PreviewAs? previewAs,
  }) async => skills;

  @override
  Future<List<ExperienceDto>> creativeExperience(
    String handle, {
    PreviewAs? previewAs,
  }) async => creativeExperienceByHandle[handle] ?? const [];

  @override
  Future<List<AchievementDto>> creativeAchievements(
    String handle, {
    PreviewAs? previewAs,
  }) async => creativeAchievementsByHandle[handle] ?? const [];

  @override
  Future<List<ServiceDto>> creativeServices(
    String handle, {
    PreviewAs? previewAs,
  }) async => creativeServicesByHandle[handle] ?? const [];

  // ---- skills ----

  @override
  Future<List<SkillEntryDto>> mySkills() async => List.of(skills);

  @override
  Future<SkillEntryDto> setSkill(String skillId, SetSkillDtoLevel level) async {
    calls.add('setSkill:$skillId:${level.json}');
    final i = skills.indexWhere((s) => s.id == skillId);
    final name = skillCatalogue.firstWhere((s) => s.id == skillId).name;
    final entry = skillEntry(skillId, name, level: level.json);
    if (i < 0) {
      skills.add(entry);
    } else {
      skills[i] = entry;
    }
    return entry;
  }

  @override
  Future<void> removeSkill(String skillId) async {
    calls.add('removeSkill:$skillId');
    skills.removeWhere((s) => s.id == skillId);
  }

  @override
  Future<List<TaxonomyItemDto>> skillChoices({String? disciplineId}) async =>
      List.of(skillCatalogue);

  // ---- experience ----

  @override
  Future<List<ExperienceDto>> myExperience() async => List.of(experience);

  @override
  Future<ExperienceDto> addExperience(ExperienceInputDto body) async {
    final f = saveFailure;
    if (f != null) throw f;
    final e = ExperienceDto(
      id: _id('xp'),
      title: body.title,
      organisation: body.organisation,
      location: body.location,
      startDate: body.startDate,
      endDate: body.endDate,
      current: body.current,
      description: body.description,
    );
    experience.insert(0, e);
    return e;
  }

  @override
  Future<ExperienceDto> updateExperience(
    String id,
    UpdateExperienceDto body,
  ) async {
    final i = experience.indexWhere((e) => e.id == id);
    final c = experience[i];
    final e = ExperienceDto(
      id: c.id,
      title: body.title ?? c.title,
      organisation: body.organisation ?? c.organisation,
      location: c.location,
      startDate: body.startDate ?? c.startDate,
      endDate: (body.endDate ?? '').isEmpty ? null : body.endDate,
      current: body.current ?? c.current,
      description: c.description,
    );
    experience[i] = e;
    return e;
  }

  @override
  Future<void> deleteExperience(String id) async =>
      experience.removeWhere((e) => e.id == id);

  // ---- achievements ----

  @override
  Future<List<AchievementDto>> myAchievements() async => List.of(achievements);

  @override
  Future<AchievementDto> addAchievement(AchievementInputDto body) async {
    final f = saveFailure;
    if (f != null) throw f;
    final a = AchievementDto(
      id: _id('ac'),
      type: AchievementDtoType.fromJson(body.type.json!),
      title: body.title,
      issuer: body.issuer,
      achievedOn: body.achievedOn,
      description: body.description,
      url: body.url,
      source: AchievementDtoSource.manual,
    );
    achievements.insert(0, a);
    return a;
  }

  @override
  Future<AchievementDto> updateAchievement(
    String id,
    UpdateAchievementDto body,
  ) async {
    final i = achievements.indexWhere((a) => a.id == id);
    final c = achievements[i];
    final a = AchievementDto(
      id: c.id,
      type: body.type == null
          ? c.type
          : AchievementDtoType.fromJson(body.type!.json!),
      title: body.title ?? c.title,
      issuer: c.issuer,
      achievedOn: c.achievedOn,
      description: c.description,
      url: (body.url ?? '').isEmpty ? null : body.url,
      source: c.source,
    );
    achievements[i] = a;
    return a;
  }

  @override
  Future<void> deleteAchievement(String id) async =>
      achievements.removeWhere((a) => a.id == id);

  // ---- services ----

  @override
  Future<List<ServiceDto>> myServices() async => List.of(services);

  @override
  Future<ServiceDto> addService(ServiceInputDto body) async {
    final f = saveFailure;
    if (f != null) throw f;
    final s = ServiceDto(
      id: _id('sv'),
      title: body.title,
      description: body.description,
      priceType: ServiceDtoPriceType.fromJson(body.priceType.json!),
      priceMin: body.priceMin,
      priceMax: body.priceMax,
      status: ServiceDtoStatus.profileOnly,
    );
    services.add(s);
    return s;
  }

  @override
  Future<ServiceDto> updateService(String id, UpdateServiceDto body) async {
    final i = services.indexWhere((s) => s.id == id);
    final c = services[i];
    final s = ServiceDto(
      id: c.id,
      title: body.title ?? c.title,
      description: c.description,
      priceType: body.priceType == null
          ? c.priceType
          : ServiceDtoPriceType.fromJson(body.priceType!.json!),
      priceMin: body.priceMin,
      priceMax: body.priceMax,
      status: c.status,
    );
    services[i] = s;
    return s;
  }

  @override
  Future<void> deleteService(String id) async =>
      services.removeWhere((s) => s.id == id);

  // ---- uploads ----

  @override
  Future<String> uploadMedia(
    PickedMedia file, {
    void Function(double progress)? onProgress,
  }) async {
    final f = uploadFailure;
    if (f != null) throw f;
    uploaded.add(file);
    onProgress?.call(1);
    return _id('media');
  }
}

/// Returns whatever files the test queued, once per call.
class FakeMediaPicker implements MediaPicker {
  final List<List<PickedMedia>> queue = [];
  final List<MediaPickKind> asked = [];

  @override
  Future<List<PickedMedia>> pick(
    MediaPickKind kind, {
    required int limit,
  }) async {
    asked.add(kind);
    return queue.isEmpty ? const [] : queue.removeAt(0);
  }
}

/// The player seams in tests: a labelled box, so tests can see which player was asked for.
Widget fakePlayer(BuildContext context, String url) => Directionality(
  textDirection: TextDirection.ltr,
  child: Text('PLAYER $url'),
);
