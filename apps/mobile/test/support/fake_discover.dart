import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/discover/discover_repository.dart';

CreativeCardDto creativeCard({
  String handle = 'wanjiku',
  String name = 'Wanjiku Njeri',
  String? headline = 'Illustrator and 2D animator',
  String? discipline = 'Animation',
  List<String> tags = const ['Procreate'],
  String? location = 'Nairobi',
  bool verified = false,
  bool open = false,
  String? reason,
}) => CreativeCardDto(
  handle: handle,
  displayName: name,
  headline: headline,
  avatarUrl: null,
  discipline: discipline == null
      ? null
      : DisciplineLite(id: 'd-$discipline', name: discipline, icon: 'aperture'),
  tags: tags,
  location: location,
  verified: verified,
  openToCommissions: open,
  reason: reason,
);

ArticleCardDto articleCard({
  String id = 'a-1',
  String slug = 'pricing-illustration',
  String title = 'How to price commissioned illustration in Kenya',
  String author = 'Kiptoo Langat',
  int minutes = 6,
  String source = 'ATARAH',
  String? sourceLabel,
}) => ArticleCardDto(
  id: id,
  slug: slug,
  title: title,
  summary: 'Clients do not buy hours.',
  source: ArticleCardDtoSource.fromJson(source),
  sourceLabel: sourceLabel,
  authorName: author,
  readMinutes: minutes,
  publishedAt: DateTime.utc(2026, 10, 9),
  tags: const ['animation'],
);

ArticleDto articleDto({
  String id = 'a-1',
  String slug = 'pricing-illustration',
  String title = 'How to price commissioned illustration in Kenya',
  bool saved = false,
  String source = 'ATARAH',
  String? sourceLabel,
  List<ArticleBlockDto>? blocks,
}) => ArticleDto(
  id: id,
  slug: slug,
  title: title,
  summary: 'Clients do not buy hours.',
  source: ArticleDtoSource.fromJson(source),
  sourceLabel: sourceLabel,
  authorName: 'Kiptoo Langat',
  readMinutes: 6,
  publishedAt: DateTime.utc(2026, 10, 9),
  tags: const ['animation'],
  blocks:
      blocks ??
      const [
        ArticleBlockDto(
          type: ArticleBlockDtoType.heading,
          text: 'Start with a day rate',
        ),
        ArticleBlockDto(
          type: ArticleBlockDtoType.paragraph,
          text: 'Clients do not buy hours, they buy usage.',
        ),
        ArticleBlockDto(
          type: ArticleBlockDtoType.callout,
          title: 'Rule of thumb',
          text: 'An editorial spot is not a billboard.',
        ),
        ArticleBlockDto(
          type: ArticleBlockDtoType.quote,
          text: 'Price the usage.',
          attribution: 'Anonymous',
        ),
      ],
  saved: saved,
  shareUrl: 'https://atarah.app/articles/$slug',
);

HomeDto homeDto({
  String firstName = 'Nia',
  int completion = 60,
  int unread = 0,
  ArticleCardDto? article,
  List<RecommendationDto> recommended = const [],
  List<CreativeCardDto> creatives = const [],
}) => HomeDto(
  firstName: firstName,
  completionPercent: completion,
  unreadNotifications: unread,
  article: article,
  recommended: recommended,
  creatives: creatives,
  unavailable: const [],
);

SearchHitDto creativeHit(String handle, String name, {bool verified = false}) =>
    SearchHitDto(
      type: SearchHitDtoType.creatives,
      id: handle,
      title: name,
      subtitle: 'Animator',
      verified: verified,
      path: '/creatives/$handle',
    );

SearchHitDto articleHit(String slug, String title) => SearchHitDto(
  type: SearchHitDtoType.articles,
  id: 'id-$slug',
  title: title,
  subtitle: 'Kiptoo Langat · 6 min read',
  verified: false,
  path: '/articles/$slug',
);

/// In-memory stand-in for [DiscoverRepository]. Lists are filtered the way the server would for the cases
/// the tests care about (discipline, county, availability, verified); everything is recorded.
class FakeDiscoverRepository implements DiscoverRepository {
  FakeDiscoverRepository({
    HomeDto? home,
    List<CreativeCardDto>? creatives,
    List<ArticleCardDto>? articles,
    Map<String, ArticleDto>? articleDetails,
    List<SearchHitDto>? creativeHits,
    List<SearchHitDto>? articleHits,
    List<String>? recents,
  }) : homeData = home ?? homeDto(),
       creativeList = creatives ?? [],
       articleList = articles ?? [],
       details = articleDetails ?? {},
       creativeHitList = creativeHits ?? [],
       articleHitList = articleHits ?? [],
       recentList = [
         for (final (i, q) in (recents ?? const <String>[]).indexed)
           RecentSearchDto(id: 'r-$i', query: q),
       ];

  HomeDto homeData;
  final List<CreativeCardDto> creativeList;
  final List<ArticleCardDto> articleList;
  final Map<String, ArticleDto> details;
  final List<SearchHitDto> creativeHitList;
  final List<SearchHitDto> articleHitList;
  final List<RecentSearchDto> recentList;

  /// Make the next call to that method throw this.
  AppFailure? homeFailure;
  AppFailure? creativesFailure;
  AppFailure? articleFailure;

  /// Per-discipline membership for filtering: handle -> discipline id.
  final Map<String, String> disciplineOf = {};
  final Map<String, String> countyOf = {};

  final List<CreativeFilters> creativeRequests = [];
  final List<String> searches = [];
  final List<String> recorded = [];
  final Set<String> saved = {};
  int homeCalls = 0;

  @override
  Future<HomeDto> home() async {
    homeCalls++;
    final f = homeFailure;
    if (f != null) throw f;
    return homeData;
  }

  @override
  Future<PageOf<CreativeCardDto>> creatives(
    CreativeFilters f, {
    int page = 1,
    int limit = 20,
  }) async {
    creativeRequests.add(f);
    final fail = creativesFailure;
    if (fail != null) throw fail;
    final all = [
      for (final c in creativeList)
        if ((f.disciplineId == null ||
                disciplineOf[c.handle] == f.disciplineId) &&
            (f.countyId == null || countyOf[c.handle] == f.countyId) &&
            (!f.available || c.openToCommissions) &&
            (!f.verified || c.verified))
          c,
    ];
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, all.length);
    return PageOf(
      start >= all.length ? [] : all.sublist(start, end),
      all.length,
    );
  }

  @override
  Future<List<SearchGroupDto>> search(
    String q, {
    SearchKind? kind,
    int page = 1,
    int limit = 20,
  }) async {
    searches.add('$q|${kind?.name ?? 'all'}|$page');
    final lower = q.toLowerCase();
    List<SearchHitDto> hits(List<SearchHitDto> all) => [
      for (final h in all)
        if (h.title.toLowerCase().contains(lower)) h,
    ];
    final people = hits(creativeHitList);
    final pieces = hits(articleHitList);
    SearchGroupDto group(
      SearchGroupDtoType t,
      List<SearchHitDto> all, {
      required bool preview,
    }) {
      final start = preview ? 0 : (page - 1) * limit;
      final take = preview ? 3 : limit;
      final end = (start + take).clamp(0, all.length);
      return SearchGroupDto(
        type: t,
        count: all.length,
        items: start >= all.length ? [] : all.sublist(start, end),
      );
    }

    return switch (kind) {
      SearchKind.creatives => [
        group(SearchGroupDtoType.creatives, people, preview: false),
      ],
      SearchKind.articles => [
        group(SearchGroupDtoType.articles, pieces, preview: false),
      ],
      null => [
        group(SearchGroupDtoType.creatives, people, preview: true),
        group(SearchGroupDtoType.articles, pieces, preview: true),
      ],
    };
  }

  @override
  Future<List<RecentSearchDto>> recentSearches() async => [...recentList];

  @override
  Future<void> recordSearch(String query) async {
    recorded.add(query);
    recentList.removeWhere((r) => r.query.toLowerCase() == query.toLowerCase());
    recentList.insert(
      0,
      RecentSearchDto(id: 'r-new-${recorded.length}', query: query),
    );
  }

  @override
  Future<void> removeRecentSearch(String id) async =>
      recentList.removeWhere((r) => r.id == id);

  @override
  Future<void> clearRecentSearches() async => recentList.clear();

  @override
  Future<PageOf<ArticleCardDto>> articles({
    int page = 1,
    int limit = 20,
  }) async {
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, articleList.length);
    return PageOf(
      start >= articleList.length ? [] : articleList.sublist(start, end),
      articleList.length,
    );
  }

  @override
  Future<ArticleDto> article(String slug) async {
    final f = articleFailure;
    if (f != null) throw f;
    final a = details[slug];
    if (a == null) {
      throw const ApiFailure(
        code: 'RESOURCE_NOT_FOUND',
        message: 'That article is not available.',
        statusCode: 404,
      );
    }
    return a;
  }

  @override
  Future<void> saveArticle(String id) async => saved.add(id);

  @override
  Future<void> unsaveArticle(String id) async => saved.remove(id);
}
