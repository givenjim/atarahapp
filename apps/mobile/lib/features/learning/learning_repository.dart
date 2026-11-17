import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

/// The tabs of the member's own learning (the API calls the same values `tab`; its generated enum is named
/// `Tab2`, so screens use this).
enum MyLearningTab { active, completed, saved }

/// One page of learning cards with how many there are in all.
class LearningPage {
  const LearningPage(this.items, this.total);
  final List<LearningCardDto> items;
  final int total;
}

/// One page of a category: the cards, the category itself and how many items of each type it holds (so the
/// type chips and the per-type empty state need no second request).
class CategoryPage {
  const CategoryPage({
    required this.items,
    required this.total,
    required this.allTotal,
    required this.category,
    required this.typeCounts,
  });

  final List<LearningCardDto> items;

  /// Items matching the type filter.
  final int total;

  /// All published items in the category, whatever the filter.
  final int allTotal;
  final LearningCategoryRefDto? category;
  final Map<LearningContentType, int> typeCounts;

  factory CategoryPage.fromResponse(List<LearningCardDto> items, dynamic meta) {
    final m = meta is Map ? meta : const <Object?, Object?>{};
    final cat = m['category'];
    final types = <LearningContentType, int>{};
    final raw = m['types'];
    if (raw is List) {
      for (final t in raw) {
        if (t is Map && t['type'] is String && t['count'] is num) {
          types[LearningContentType.fromJson(t['type'] as String)] =
              (t['count'] as num).toInt();
        }
      }
    }
    return CategoryPage(
      items: items,
      total: m['total'] is num ? (m['total'] as num).toInt() : items.length,
      allTotal: m['total_all'] is num
          ? (m['total_all'] as num).toInt()
          : items.length,
      category: cat is Map<String, dynamic>
          ? LearningCategoryRefDto.fromJson(cat)
          : null,
      typeCounts: types,
    );
  }
}

/// One page of the member's own learning.
class MyLearningPage {
  const MyLearningPage(this.items, this.total);
  final List<MyLearningItemDto> items;
  final int total;
}

int _total(dynamic meta, int fallback) {
  if (meta is Map && meta['total'] is num) {
    return (meta['total'] as num).toInt();
  }
  return fallback;
}

/// Skill Labs: the hub, categories, courses and lessons, progress and saving, with errors mapped to typed
/// failures. Widgets go through providers; tests replace this with an in-memory fake.
class LearningRepository {
  LearningRepository({required this._api});

  final AtarahApiClient _api;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<LearningHubDto> hub() =>
      _guard(() async => (await _api.learning.hub()).data);

  Future<CategoryPage> category(
    String slug, {
    LearningContentType? type,
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.learning.category(
      slug: slug,
      type: type,
      page: page,
      limit: limit,
    );
    return CategoryPage.fromResponse(res.data, res.meta);
  });

  Future<LearningPage> search(
    String q, {
    LearningContentType? type,
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.learning.search(
      q: q,
      type: type,
      page: page,
      limit: limit,
    );
    return LearningPage(res.data, _total(res.meta, res.data.length));
  });

  Future<LearningDetailDto> detail(String id) =>
      _guard(() async => (await _api.learning.detail(id: id)).data);

  Future<EnrolmentDto> enrol(String id) =>
      _guard(() async => (await _api.learning.enrol(id: id)).data);

  /// A single (non-course) item was opened: it counts as started.
  Future<LearningItemProgressDto> start(String id) =>
      _guard(() async => (await _api.learning.start(id: id)).data);

  Future<LearningItemProgressDto> complete(String id) =>
      _guard(() async => (await _api.learning.complete(id: id)).data);

  Future<void> save(String id) => _guard(() => _api.learning.save(id: id));

  Future<void> unsave(String id) => _guard(() => _api.learning.unsave(id: id));

  Future<LessonDto> lesson(String id) =>
      _guard(() async => (await _api.learning.lesson(id: id)).data);

  Future<LessonVideoDto> video(String lessonId) =>
      _guard(() async => (await _api.learning.video(id: lessonId)).data);

  /// Writes progress. The server keeps the position monotonic and completion once-only, so repeating or
  /// reordering writes is safe.
  Future<ProgressResultDto> progress(
    String lessonId, {
    int? positionSeconds,
    bool? completed,
    bool? restart,
  }) => _guard(
    () async => (await _api.learning.progress(
      id: lessonId,
      body: LessonProgressBodyDto(
        positionSeconds: positionSeconds,
        completed: completed,
        restart: restart,
      ),
    )).data,
  );

  Future<MyLearningPage> mine(
    MyLearningTab tab, {
    int page = 1,
    int limit = 50,
  }) => _guard(() async {
    final res = await _api.learning.mine(
      tab: switch (tab) {
        MyLearningTab.active => Tab2.active,
        MyLearningTab.completed => Tab2.completed,
        MyLearningTab.saved => Tab2.saved,
      },
      page: page,
      limit: limit,
    );
    return MyLearningPage(res.data, _total(res.meta, res.data.length));
  });

  Future<LearningStatsDto> stats() =>
      _guard(() async => (await _api.learning.stats()).data);
}
