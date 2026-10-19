import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/generated/export.dart';
import '../../core/providers.dart';
import 'discover_repository.dart';

part 'discover_providers.g.dart';

@Riverpod(keepAlive: true)
DiscoverRepository discoverRepository(Ref ref) =>
    DiscoverRepository(api: ref.watch(apiClientProvider));

/// The Home tab's one aggregated payload.
@riverpod
Future<HomeDto> homeFeed(Ref ref) =>
    ref.watch(discoverRepositoryProvider).home();

/// The filters Explore is showing. Kept while the app runs so coming back to the tab finds the same list.
@Riverpod(keepAlive: true)
class ExploreFilters extends _$ExploreFilters {
  @override
  CreativeFilters build() => const CreativeFilters();

  void set(CreativeFilters next) => state = next;
  void reset() => state = const CreativeFilters();
}

/// How many creatives match a set of filters (the sheet's "Show n results").
@riverpod
Future<int> creativeCount(Ref ref, CreativeFilters filters) async =>
    (await ref.watch(discoverRepositoryProvider).creatives(filters, limit: 1))
        .total;

/// Explore's list of creatives, a page at a time.
class CreativeList {
  const CreativeList({
    required this.items,
    required this.total,
    required this.page,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final List<CreativeCardDto> items;
  final int total;
  final int page;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => items.length < total;

  CreativeList copyWith({
    List<CreativeCardDto>? items,
    int? total,
    int? page,
    bool? loadingMore,
    bool? moreFailed,
  }) => CreativeList(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

@riverpod
class ExploreCreatives extends _$ExploreCreatives {
  static const _pageSize = 20;

  @override
  Future<CreativeList> build() async {
    final filters = ref.watch(exploreFiltersProvider);
    final first = await ref
        .watch(discoverRepositoryProvider)
        .creatives(filters, limit: _pageSize);
    return CreativeList(items: first.items, total: first.total, page: 1);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(discoverRepositoryProvider)
          .creatives(
            ref.read(exploreFiltersProvider),
            page: current.page + 1,
            limit: _pageSize,
          );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          total: next.total,
          page: current.page + 1,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }
}

@riverpod
Future<List<RecentSearchDto>> recentSearches(Ref ref) =>
    ref.watch(discoverRepositoryProvider).recentSearches();

@riverpod
Future<ArticleDto> article(Ref ref, String slug) =>
    ref.watch(discoverRepositoryProvider).article(slug);

/// The articles list, a page at a time.
@riverpod
class ArticleList extends _$ArticleList {
  static const _pageSize = 20;

  @override
  Future<PageOf<ArticleCardDto>> build() =>
      ref.watch(discoverRepositoryProvider).articles(limit: _pageSize);

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.items.length >= current.total) return;
    final page = current.items.length ~/ _pageSize + 1;
    try {
      final next = await ref
          .read(discoverRepositoryProvider)
          .articles(page: page, limit: _pageSize);
      state = AsyncData(PageOf([...current.items, ...next.items], next.total));
    } on Object {
      // The next scroll tries again.
    }
  }
}
