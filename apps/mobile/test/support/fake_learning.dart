import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/learning/learning_repository.dart';
import 'package:atarah/features/learning/lesson_players.dart';
import 'package:flutter/material.dart';

// ---- builders -----------------------------------------------------------------------------------------------

LearningCategoryRefDto catRef({
  String slug = 'portfolio-building',
  String name = 'Portfolio Building',
  LearningCategoryGroup group = LearningCategoryGroup.professional,
}) => LearningCategoryRefDto(
  id: 'cat-$slug',
  slug: slug,
  name: name,
  group: group,
);

LearningItemProgressDto itemProgress(
  int percent, {
  LessonProgressStatus? status,
}) => LearningItemProgressDto(
  status:
      status ??
      (percent >= 100
          ? LessonProgressStatus.completed
          : LessonProgressStatus.inProgress),
  percent: percent,
);

LearningCardDto labCard({
  String id = 'lab-1',
  String title = 'Build a Portfolio That Gets You Hired',
  LearningContentType type = LearningContentType.course,
  ContentSource source = ContentSource.atarah,
  ContentDelivery delivery = ContentDelivery.native,
  LearningCategoryRefDto? category,
  SkillLevel level = SkillLevel.beginner,
  int minutes = 35,
  int? lessons = 5,
  String? provider = 'Atarah Studio',
  LearningAccess access = LearningAccess.free,
  bool premiumLocked = false,
  bool featured = false,
  bool saved = false,
  LearningItemProgressDto? progress,
}) => LearningCardDto(
  id: id,
  slug: id,
  type: type,
  title: title,
  summary: 'Choose, present and write up your best work.',
  category: category ?? catRef(),
  level: level,
  durationMinutes: minutes,
  lessonCount: type == LearningContentType.course ? lessons : null,
  source: source,
  delivery: delivery,
  providerName: provider,
  coverUrl: null,
  access: access,
  premiumLocked: premiumLocked,
  featured: featured,
  saved: saved,
  progress: progress,
);

LessonSummaryDto lessonSummary(
  int n, {
  LessonSummaryDtoState state = LessonSummaryDtoState.locked,
  String? title,
  int minutes = 6,
  bool video = false,
  bool embed = false,
}) => LessonSummaryDto(
  id: 'lesson-$n',
  sequence: n,
  title: title ?? 'Lesson $n title',
  durationMinutes: minutes,
  state: state,
  hasVideo: video,
  hasEmbed: embed,
);

CertificateDto certificate({String number = 'ATC-2026-000007'}) =>
    CertificateDto(
      certificateNumber: number,
      issuedAt: DateTime.utc(2026, 11, 2, 9),
      achievementId: 'ach-1',
    );

CourseInfoDto courseInfo({
  List<LessonSummaryDto>? lessons,
  bool enrolled = false,
  int done = 0,
  String? next,
  bool sequential = true,
  CertificateDto? cert,
}) {
  final ls =
      lessons ??
      [
        for (var i = 1; i <= 3; i++)
          lessonSummary(
            i,
            state: !enrolled
                ? (i == 1
                      ? LessonSummaryDtoState.available
                      : LessonSummaryDtoState.locked)
                : i <= done
                ? LessonSummaryDtoState.done
                : i == done + 1
                ? LessonSummaryDtoState.current
                : LessonSummaryDtoState.locked,
          ),
      ];
  return CourseInfoDto(
    lessonCount: ls.length,
    totalMinutes: ls.fold<int>(0, (a, l) => a + l.durationMinutes.toInt()),
    sequential: sequential,
    enrolled: enrolled,
    completedLessons: done,
    percent: ls.isEmpty ? 0 : (done * 100 / ls.length).round(),
    nextLessonId: next ?? (ls.isEmpty ? null : 'lesson-${done + 1}'),
    lessons: ls,
    certificate: cert,
  );
}

LearningDetailDto labDetail({
  String id = 'lab-1',
  String title = 'Build a Portfolio That Gets You Hired',
  LearningContentType type = LearningContentType.course,
  ContentSource source = ContentSource.atarah,
  ContentDelivery delivery = ContentDelivery.native,
  CourseInfoDto? course,
  bool premiumLocked = false,
  LearningAccess access = LearningAccess.free,
  bool saved = false,
  String? externalUrl,
  String? externalDomain,
  String? embedUrl,
  LearningDetailDtoLinkStatus link = LearningDetailDtoLinkStatus.unknown,
  LearningItemProgressDto? itemProgress,
  String? instructor = 'Kiptoo Langat',
  String? provider = 'Atarah Studio',
  LearningCategoryRefDto? category,
}) => LearningDetailDto(
  id: id,
  slug: id,
  type: type,
  title: title,
  summary: 'Choose, present and write up your best work.',
  category: category ?? catRef(),
  level: SkillLevel.beginner,
  durationMinutes: 35,
  lessonCount: course?.lessonCount,
  source: source,
  delivery: delivery,
  providerName: provider,
  access: access,
  premiumLocked: premiumLocked,
  featured: false,
  saved: saved,
  progress: course == null || !course.enrolled
      ? null
      : itemProgressOf(course.percent.toInt()),
  whatYouLearn: const [
    'Pick the three projects that show the work you want more of',
    'Write a project description a client can skim',
  ],
  whoItsFor: 'Creatives with a few finished projects.',
  instructorName: instructor,
  disciplines: const ['Design'],
  skills: const [SkillRefDto(id: 'skill-1', name: 'Colour')],
  course: course,
  externalUrl: externalUrl,
  externalDomain: externalDomain,
  embedUrl: embedUrl,
  linkStatus: link,
  itemProgress: itemProgress,
  shareUrl: 'https://atarah.app/learning/$id',
);

LearningItemProgressDto itemProgressOf(int percent) => itemProgress(percent);

LessonDto lessonDto({
  int n = 1,
  int total = 3,
  String title = 'What a portfolio is for',
  bool video = false,
  String? embed,
  int position = 0,
  LessonProgressStatus status = LessonProgressStatus.notStarted,
  PracticeDto? practice,
  List<ArticleBlockDto>? body,
  List<bool>? segments,
  LessonDtoState state = LessonDtoState.current,
}) => LessonDto(
  id: 'lesson-$n',
  courseId: 'lab-1',
  courseTitle: 'Build a Portfolio That Gets You Hired',
  sequence: n,
  lessonCount: total,
  title: title,
  durationMinutes: 6,
  body:
      body ??
      const [
        ArticleBlockDto(
          type: ArticleBlockDtoType.heading,
          text: 'A portfolio answers one question',
        ),
        ArticleBlockDto(
          type: ArticleBlockDtoType.paragraph,
          text: 'Can this person do what I need? Show work that says yes.',
        ),
        ArticleBlockDto(
          type: ArticleBlockDtoType.callout,
          title: 'Rule of thumb',
          text: 'Three strong projects beat twelve mixed ones.',
        ),
      ],
  practice: practice,
  hasVideo: video,
  embedUrl: embed,
  progress: LessonProgressDto(
    status: status,
    lastPositionSeconds: position,
    completedAt: status == LessonProgressStatus.completed
        ? DateTime.utc(2026, 11, 2)
        : null,
  ),
  state: state,
  previousLessonId: n > 1 ? 'lesson-${n - 1}' : null,
  nextLessonId: n < total ? 'lesson-${n + 1}' : null,
  segments: segments ?? [for (var i = 1; i <= total; i++) i < n],
);

LearningHubDto hubDto({
  ContinueLearningDto? cont,
  List<LearningCardDto> featured = const [],
  List<HubCategoryDto>? categories,
  List<RecommendedDto> recommended = const [],
}) => LearningHubDto(
  continueLearning: cont,
  featured: featured,
  categories:
      categories ??
      const [
        HubCategoryDto(
          id: 'c1',
          slug: 'animation',
          name: 'Animation',
          group: LearningCategoryGroup.creative,
          count: 3,
        ),
        HubCategoryDto(
          id: 'c2',
          slug: 'branding',
          name: 'Branding',
          group: LearningCategoryGroup.business,
          count: 2,
        ),
        HubCategoryDto(
          id: 'c3',
          slug: 'portfolio-building',
          name: 'Portfolio Building',
          group: LearningCategoryGroup.professional,
          count: 12,
        ),
      ],
  recommended: recommended,
);

// ---- fake players --------------------------------------------------------------------------------------------

/// Captures what the lesson screen hands to the video player, and lets a test drive the player's reports.
class FakeVideoPlayers {
  final List<LessonVideoArgs> created = [];

  LessonVideoArgs get last => created.last;

  Widget build(BuildContext context, LessonVideoArgs args) {
    created.add(args);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text('VIDEO ${args.url} from ${args.startAt.inSeconds}s'),
    );
  }
}

/// A labelled box for the embedded player; a test can call [fail] to make it report a failed load.
class FakeEmbeds {
  final List<String> urls = [];
  final List<VoidCallback> failures = [];

  void fail() => failures.last();

  Widget build(
    BuildContext context, {
    required String url,
    required VoidCallback onFailed,
  }) {
    urls.add(url);
    failures.add(onFailed);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text('EMBED $url'),
    );
  }
}

// ---- the fake repository -------------------------------------------------------------------------------------

class FakeLearningRepository implements LearningRepository {
  FakeLearningRepository({
    LearningHubDto? hub,
    Map<String, LearningDetailDto>? details,
    Map<String, LessonDto>? lessons,
    this.categoryItems = const [],
    this.categoryRef,
    this.mineActive = const [],
    this.mineCompleted = const [],
    this.mineSaved = const [],
    LearningStatsDto? stats,
    this.pageSize = 20,
  }) : hubData = hub ?? hubDto(),
       details = {...?details},
       lessons = {...?lessons},
       statsData =
           stats ??
           const LearningStatsDto(
             inProgress: 2,
             completed: 1,
             minutesThisMonth: 150,
             hoursThisMonth: 2.5,
           );

  LearningHubDto hubData;
  final Map<String, LearningDetailDto> details;
  final Map<String, LessonDto> lessons;
  List<LearningCardDto> categoryItems;
  LearningCategoryRefDto? categoryRef;
  List<MyLearningItemDto> mineActive;
  List<MyLearningItemDto> mineCompleted;
  List<MyLearningItemDto> mineSaved;
  LearningStatsDto statsData;
  final int pageSize;

  final List<String> calls = [];
  final List<({String lesson, int? position, bool? completed, bool? restart})>
  progressWrites = [];

  AppFailure? hubFailure;
  AppFailure? detailFailure;
  AppFailure? lessonFailure;
  AppFailure? enrolFailure;
  AppFailure? saveFailure;
  AppFailure? videoFailure;
  AppFailure? progressFailure;

  /// What the next completing write answers with (so a test can ask for a certificate).
  CertificateDto? certificateOnComplete;
  bool courseCompletesOnComplete = false;

  @override
  Future<LearningHubDto> hub() async {
    calls.add('hub');
    final f = hubFailure;
    if (f != null) throw f;
    return hubData;
  }

  @override
  Future<CategoryPage> category(
    String slug, {
    LearningContentType? type,
    int page = 1,
    int limit = 20,
  }) async {
    calls.add('category:$slug:${type?.json}:$page');
    final matching = categoryItems
        .where((c) => type == null || c.type == type)
        .toList();
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, matching.length);
    final counts = <LearningContentType, int>{};
    for (final c in categoryItems) {
      counts[c.type] = (counts[c.type] ?? 0) + 1;
    }
    return CategoryPage(
      items: start >= matching.length ? [] : matching.sublist(start, end),
      total: matching.length,
      allTotal: categoryItems.length,
      category: categoryRef ?? catRef(slug: slug),
      typeCounts: counts,
    );
  }

  @override
  Future<LearningPage> search(
    String q, {
    LearningContentType? type,
    int page = 1,
    int limit = 20,
  }) async => LearningPage(categoryItems, categoryItems.length);

  @override
  Future<LearningDetailDto> detail(String id) async {
    calls.add('detail:$id');
    final f = detailFailure;
    if (f != null) throw f;
    final d = details[id];
    if (d == null) {
      throw const ApiFailure(
        code: 'RESOURCE_NOT_FOUND',
        message: 'That Skill Lab is not available.',
        statusCode: 404,
      );
    }
    return d;
  }

  @override
  Future<EnrolmentDto> enrol(String id) async {
    calls.add('enrol:$id');
    final f = enrolFailure;
    if (f != null) throw f;
    final d = details[id]!;
    final course = courseInfo(
      lessons: [
        for (final l in d.course!.lessons)
          lessonSummary(
            l.sequence.toInt(),
            title: l.title,
            state: l.sequence == 1
                ? LessonSummaryDtoState.current
                : LessonSummaryDtoState.locked,
          ),
      ],
      enrolled: true,
      next: 'lesson-1',
    );
    details[id] = labDetail(
      id: id,
      title: d.title,
      course: course,
      access: d.access,
      source: d.source,
    );
    return EnrolmentDto(
      courseId: id,
      enrolledAt: DateTime.utc(2026, 11, 2),
      nextLessonId: 'lesson-1',
    );
  }

  @override
  Future<LearningItemProgressDto> start(String id) async {
    calls.add('start:$id');
    return itemProgress(0, status: LessonProgressStatus.inProgress);
  }

  @override
  Future<LearningItemProgressDto> complete(String id) async {
    calls.add('complete:$id');
    return itemProgress(100);
  }

  @override
  Future<void> save(String id) async {
    calls.add('save:$id');
    final f = saveFailure;
    if (f != null) throw f;
  }

  @override
  Future<void> unsave(String id) async {
    calls.add('unsave:$id');
    final f = saveFailure;
    if (f != null) throw f;
  }

  @override
  Future<LessonDto> lesson(String id) async {
    calls.add('lesson:$id');
    final f = lessonFailure;
    if (f != null) throw f;
    final l = lessons[id];
    if (l == null) {
      throw const ApiFailure(
        code: 'RESOURCE_NOT_FOUND',
        message: 'That lesson does not exist.',
        statusCode: 404,
      );
    }
    return l;
  }

  @override
  Future<LessonVideoDto> video(String lessonId) async {
    calls.add('video:$lessonId');
    final f = videoFailure;
    if (f != null) throw f;
    return LessonVideoDto(
      url: 'https://storage.example.org/signed/$lessonId.mp4',
      expiresAt: DateTime.utc(2026, 11, 2, 12),
      durationSeconds: 360,
    );
  }

  @override
  Future<ProgressResultDto> progress(
    String lessonId, {
    int? positionSeconds,
    bool? completed,
    bool? restart,
  }) async {
    calls.add('progress:$lessonId');
    progressWrites.add((
      lesson: lessonId,
      position: positionSeconds,
      completed: completed,
      restart: restart,
    ));
    final f = progressFailure;
    if (f != null) throw f;
    final l = lessons[lessonId];
    final n = l?.sequence.toInt() ?? 1;
    final total = l?.lessonCount.toInt() ?? 3;
    final finishing = completed == true && courseCompletesOnComplete;
    return ProgressResultDto(
      progress: LessonProgressDto(
        status: completed == true
            ? LessonProgressStatus.completed
            : LessonProgressStatus.inProgress,
        lastPositionSeconds: positionSeconds ?? 0,
      ),
      courseCompleted: finishing,
      percent: (n * 100 / total).round(),
      nextLessonId: n < total ? 'lesson-${n + 1}' : null,
      certificate: finishing ? (certificateOnComplete ?? certificate()) : null,
    );
  }

  @override
  Future<MyLearningPage> mine(
    MyLearningTab tab, {
    int page = 1,
    int limit = 50,
  }) async {
    calls.add('mine:${tab.name}');
    final items = switch (tab) {
      MyLearningTab.active => mineActive,
      MyLearningTab.completed => mineCompleted,
      MyLearningTab.saved => mineSaved,
    };
    return MyLearningPage(items, items.length);
  }

  @override
  Future<LearningStatsDto> stats() async => statsData;
}
