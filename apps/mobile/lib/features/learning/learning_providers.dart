import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import '../portfolio/portfolio_providers.dart';
import '../profile/profile_providers.dart';
import 'learning_cache.dart';
import 'learning_repository.dart';

final learningRepositoryProvider = Provider<LearningRepository>(
  (ref) => LearningRepository(api: ref.watch(apiClientProvider)),
);

/// The read-only offline copy of what the member is learning.
final learningCacheProvider = Provider<LearningCache>(
  (ref) => LearningCache(ref.watch(keyValueStoreProvider)),
);

/// A value and whether it is the saved copy (the member is offline) rather than the server's.
class Loaded<T> {
  const Loaded(this.value, {this.fromCache = false});
  final T value;
  final bool fromCache;
}

/// The Skill Labs hub's one aggregated payload.
final learningHubProvider = FutureProvider.autoDispose<LearningHubDto>(
  (ref) => ref.watch(learningRepositoryProvider).hub(),
);

final learningStatsProvider = FutureProvider.autoDispose<LearningStatsDto>(
  (ref) => ref.watch(learningRepositoryProvider).stats(),
);

/// The member's own learning for one tab (the first 50; a member rarely has more in progress).
final myLearningProvider = FutureProvider.autoDispose
    .family<MyLearningPage, MyLearningTab>(
      (ref, tab) => ref.watch(learningRepositoryProvider).mine(tab),
    );

/// One Skill Lab. While offline, a course the member is on is read from the saved copy.
final learningDetailProvider = FutureProvider.autoDispose
    .family<Loaded<LearningDetailDto>, String>((ref, id) async {
      final repo = ref.watch(learningRepositoryProvider);
      final cache = ref.watch(learningCacheProvider);
      try {
        final d = await repo.detail(id);
        await cache.saveDetail(d);
        return Loaded(d);
      } on NetworkFailure {
        final saved = await cache.detail(id);
        if (saved != null) return Loaded(saved, fromCache: true);
        rethrow;
      }
    });

/// One lesson with the member's progress. Offline, a lesson they opened before is read from the saved copy.
final lessonProvider = FutureProvider.autoDispose
    .family<Loaded<LessonDto>, String>((ref, id) async {
      final repo = ref.watch(learningRepositoryProvider);
      final cache = ref.watch(learningCacheProvider);
      try {
        final l = await repo.lesson(id);
        await cache.saveLesson(l);
        return Loaded(l);
      } on NetworkFailure {
        final saved = await cache.lesson(id);
        if (saved != null) return Loaded(saved, fromCache: true);
        rethrow;
      }
    });

/// What the member has just saved or un-saved, ahead of the server's answer. A card shows
/// `overrides[id] ?? card.saved`.
class LearningSaves extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => const {};

  void forget(String id) => state = {...state}..remove(id);

  /// Flips the bookmark at once and tells the server. On failure it flips back and rethrows (the screen shows the
  /// server's words).
  Future<void> toggle(String id, {required bool currentlySaved}) async {
    final before = state;
    final next = !currentlySaved;
    state = {...state, id: next};
    final repo = ref.read(learningRepositoryProvider);
    try {
      if (next) {
        await repo.save(id);
      } else {
        await repo.unsave(id);
      }
    } on Object {
      state = before;
      rethrow;
    }
    ref
      ..invalidate(learningHubProvider)
      ..invalidate(myLearningProvider)
      ..invalidate(learningDetailProvider(id));
  }
}

final learningSavesProvider =
    NotifierProvider<LearningSaves, Map<String, bool>>(LearningSaves.new);

/// What members do in Skill Labs, and everything that has to refresh afterwards.
class LearningActions {
  LearningActions(this._ref);

  final Ref _ref;

  LearningRepository get _repo => _ref.read(learningRepositoryProvider);

  void _refreshLists(String courseId) {
    _ref
      ..invalidate(learningHubProvider)
      ..invalidate(myLearningProvider)
      ..invalidate(learningStatsProvider)
      ..invalidate(learningDetailProvider(courseId));
  }

  Future<EnrolmentDto> enrol(String courseId) async {
    final e = await _repo.enrol(courseId);
    _refreshLists(courseId);
    return e;
  }

  /// A single item was opened (in the browser or the player): started, once.
  Future<LearningItemProgressDto> start(String id) async {
    final p = await _repo.start(id);
    _refreshLists(id);
    return p;
  }

  Future<LearningItemProgressDto> completeItem(String id) async {
    final p = await _repo.complete(id);
    _refreshLists(id);
    return p;
  }

  /// A position report while the lesson plays. Cheap on purpose: nothing is refreshed until the member leaves.
  Future<ProgressResultDto> reportPosition(String lessonId, int seconds) async {
    final r = await _repo.progress(lessonId, positionSeconds: seconds);
    await _ref.read(learningCacheProvider).savePosition(lessonId, seconds);
    return r;
  }

  Future<ProgressResultDto> restart(String lessonId) =>
      _repo.progress(lessonId, restart: true);

  /// "Mark complete & next". When it finishes the course, the certificate and achievement exist on the server,
  /// so the member's achievements and growth are refreshed too.
  Future<ProgressResultDto> completeLesson(
    String lessonId, {
    required String courseId,
    int? positionSeconds,
  }) async {
    final r = await _repo.progress(
      lessonId,
      positionSeconds: positionSeconds,
      completed: true,
    );
    _ref.invalidate(lessonProvider(lessonId));
    _refreshLists(courseId);
    if (r.courseCompleted) {
      _ref
        ..invalidate(myAchievementsProvider)
        ..invalidate(mySkillsProvider)
        ..invalidate(myPassportProvider);
    }
    return r;
  }

  /// The member left a lesson: what the course page shows ("Continue learning", percentages) is refreshed.
  void leftLesson(String lessonId, String courseId) {
    _ref.invalidate(lessonProvider(lessonId));
    _refreshLists(courseId);
  }
}

final learningActionsProvider = Provider<LearningActions>(LearningActions.new);
