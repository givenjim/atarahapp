import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

/// What narrows the list of creatives on Explore. Equal filters are equal values, so the live result count in
/// the filters sheet can be cached per combination.
class CreativeFilters {
  const CreativeFilters({
    this.q,
    this.disciplineId,
    this.countyId,
    this.countyName,
    this.available = false,
    this.verified = false,
    this.recent = false,
  });

  final String? q;
  final String? disciplineId;
  final String? countyId;

  /// Only for showing the chosen county on a chip; not sent to the API.
  final String? countyName;
  final bool available;
  final bool verified;

  /// Newest first instead of best match.
  final bool recent;

  /// How many filters are on (the discipline tiles are not counted; they are a tab, not a filter).
  int get activeCount =>
      [countyId != null, available, verified, recent].where((x) => x).length;

  bool get isEmpty => disciplineId == null && activeCount == 0 && q == null;

  CreativeFilters copyWith({
    Object? q = _keep,
    Object? disciplineId = _keep,
    Object? countyId = _keep,
    Object? countyName = _keep,
    bool? available,
    bool? verified,
    bool? recent,
  }) => CreativeFilters(
    q: identical(q, _keep) ? this.q : q as String?,
    disciplineId: identical(disciplineId, _keep)
        ? this.disciplineId
        : disciplineId as String?,
    countyId: identical(countyId, _keep) ? this.countyId : countyId as String?,
    countyName: identical(countyName, _keep)
        ? this.countyName
        : countyName as String?,
    available: available ?? this.available,
    verified: verified ?? this.verified,
    recent: recent ?? this.recent,
  );

  static const _keep = Object();

  @override
  bool operator ==(Object other) =>
      other is CreativeFilters &&
      other.q == q &&
      other.disciplineId == disciplineId &&
      other.countyId == countyId &&
      other.available == available &&
      other.verified == verified &&
      other.recent == recent;

  @override
  int get hashCode =>
      Object.hash(q, disciplineId, countyId, available, verified, recent);
}

/// One page of anything paged, with how many there are in all.
class PageOf<T> {
  const PageOf(this.items, this.total);
  final List<T> items;
  final int total;
}

int _total(dynamic meta, int fallback) {
  if (meta is Map && meta['total'] is num) {
    return (meta['total'] as num).toInt();
  }
  return fallback;
}

/// Home, finding creatives, search and articles, with errors mapped to typed failures. Widgets go through
/// providers; tests replace this with an in-memory fake.
class DiscoverRepository {
  DiscoverRepository({required this._api});

  final AtarahApiClient _api;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<HomeDto> home() =>
      _guard(() async => (await _api.discover.homeFeed()).data);

  Future<PageOf<CreativeCardDto>> creatives(
    CreativeFilters f, {
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.discover.creativeList(
      q: f.q,
      disciplineId: f.disciplineId,
      countyId: f.countyId,
      available: f.available ? true : null,
      verified: f.verified ? true : null,
      sort: f.recent ? Sort.recent : Sort.relevance,
      page: page,
      limit: limit,
    );
    return PageOf(res.data, _total(res.meta, res.data.length));
  });

  Future<List<SearchGroupDto>> search(
    String q, {
    SearchKind? kind,
    int page = 1,
    int limit = 20,
  }) => _guard(
    () async => (await _api.discover.find(
      q: q,
      type: switch (kind) {
        SearchKind.creatives => Type2.creatives,
        SearchKind.articles => Type2.articles,
        null => null,
      },
      page: page,
      limit: limit,
    )).data.groups,
  );

  Future<List<RecentSearchDto>> recentSearches() =>
      _guard(() async => (await _api.discover.recent()).data);

  Future<void> recordSearch(String query) =>
      _guard(() => _api.discover.record(body: RecordSearchDto(query: query)));

  Future<void> removeRecentSearch(String id) =>
      _guard(() => _api.discover.remove(id: id));

  Future<void> clearRecentSearches() => _guard(() => _api.discover.clear());

  // ---- articles ----

  Future<PageOf<ArticleCardDto>> articles({int page = 1, int limit = 20}) =>
      _guard(() async {
        final res = await _api.articles.list(page: page, limit: limit);
        return PageOf(res.data, _total(res.meta, res.data.length));
      });

  Future<ArticleDto> article(String slug) =>
      _guard(() async => (await _api.articles.detail(slug: slug)).data);

  Future<void> saveArticle(String id) =>
      _guard(() => _api.articles.save(type: Type.article, id: id));

  Future<void> unsaveArticle(String id) =>
      _guard(() => _api.articles.unsave(type: Type.article, id: id));
}

/// The kinds of result search can narrow to today.
enum SearchKind { creatives, articles }
