import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/generated/export.dart';
import '../../core/auth/session_controller.dart';
import '../../core/providers.dart';
import '../../core/storage/offline_cache.dart';
import 'opportunities_repository.dart';

part 'opportunities_providers.g.dart';

@Riverpod(keepAlive: true)
OpportunitiesRepository opportunitiesRepository(Ref ref) =>
    OpportunitiesRepository(
      api: ref.watch(apiClientProvider),
      cache: OfflineCache(
        ref.watch(keyValueStoreProvider),
        ref.watch(sessionControllerProvider).value?.id,
      ),
    );

/// The Opportunities tab's one aggregated payload.
@riverpod
Future<OpportunitiesHomeDto> opportunitiesHome(Ref ref) =>
    ref.watch(opportunitiesRepositoryProvider).home();

/// One category list (or the whole list), a page at a time.
class OpportunityList {
  const OpportunityList({
    required this.items,
    required this.total,
    required this.page,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final List<OpportunityCardDto> items;
  final int total;
  final int page;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => items.length < total;

  OpportunityList copyWith({
    List<OpportunityCardDto>? items,
    int? total,
    int? page,
    bool? loadingMore,
    bool? moreFailed,
  }) => OpportunityList(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

@riverpod
class OpportunityListNotifier extends _$OpportunityListNotifier {
  static const _pageSize = 20;

  @override
  Future<OpportunityList> build(OpportunityFilters filters) async {
    final first = await ref
        .watch(opportunitiesRepositoryProvider)
        .list(filters, limit: _pageSize);
    return OpportunityList(items: first.items, total: first.total, page: 1);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(opportunitiesRepositoryProvider)
          .list(filters, page: current.page + 1, limit: _pageSize);
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

/// One opportunity with the member's profile check. [refresh] asks the server to skip its 5 minute cache,
/// for when the member comes back from fixing something or pulls to refresh.
@riverpod
class OpportunityDetail extends _$OpportunityDetail {
  @override
  Future<OpportunityDto> build(String id) =>
      ref.watch(opportunitiesRepositoryProvider).detail(id);

  Future<void> refresh() async {
    final repo = ref.read(opportunitiesRepositoryProvider);
    try {
      state = AsyncData(await repo.detail(id, refresh: true));
    } on Object catch (e, st) {
      // Keep what is on screen when only the refresh failed.
      if (!state.hasValue) state = AsyncError(e, st);
    }
  }
}

/// The member's own list for one tab, a page at a time, with the counts for every tab.
class MyOpportunities {
  const MyOpportunities({
    required this.items,
    required this.total,
    required this.page,
    required this.counts,
    this.loadingMore = false,
  });

  final List<MyOpportunityDto> items;
  final int total;
  final int page;
  final MyOpportunityCounts counts;
  final bool loadingMore;

  bool get hasMore => items.length < total;

  MyOpportunities copyWith({
    List<MyOpportunityDto>? items,
    int? total,
    int? page,
    MyOpportunityCounts? counts,
    bool? loadingMore,
  }) => MyOpportunities(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    counts: counts ?? this.counts,
    loadingMore: loadingMore ?? this.loadingMore,
  );
}

@riverpod
class MyOpportunitiesNotifier extends _$MyOpportunitiesNotifier {
  static const _pageSize = 20;

  @override
  Future<MyOpportunities> build(MyTab tab) async {
    final first = await ref
        .watch(opportunitiesRepositoryProvider)
        .mine(tab, limit: _pageSize);
    return MyOpportunities(
      items: first.items,
      total: first.total,
      page: 1,
      counts: first.counts,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref
          .read(opportunitiesRepositoryProvider)
          .mine(tab, page: current.page + 1, limit: _pageSize);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          total: next.total,
          page: current.page + 1,
          counts: next.counts,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}

/// What the member has just saved or un-saved, ahead of the server's answer. A card shows
/// `overrides[id] ?? card.saved`.
@Riverpod(keepAlive: true)
class OpportunitySaves extends _$OpportunitySaves {
  @override
  Map<String, bool> build() => const {};

  void forget(String id) => state = {...state}..remove(id);

  /// Flips the bookmark at once and tells the server. On failure it flips back and rethrows (the screen shows
  /// the server's words, e.g. "You have started this one…").
  Future<void> toggle(String id, {required bool currentlySaved}) async {
    final before = state;
    final next = !currentlySaved;
    state = {...state, id: next};
    final repo = ref.read(opportunitiesRepositoryProvider);
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
      ..invalidate(opportunitiesHomeProvider)
      ..invalidate(myOpportunitiesProvider)
      ..invalidate(opportunityDetailProvider(id));
  }
}

/// Moves an opportunity along the member's own steps and refreshes everything that shows it.
class OpportunityActions {
  OpportunityActions(this._ref);

  final Ref _ref;

  Future<TrackingStateDto> track(
    String id,
    OpportunityTrackingStatus status, {
    OpportunityOutcome? outcome,
  }) async {
    final state = await _ref
        .read(opportunitiesRepositoryProvider)
        .track(id, status, outcome: outcome);
    _ref.read(opportunitySavesProvider.notifier).forget(id);
    _ref
      ..invalidate(opportunitiesHomeProvider)
      ..invalidate(myOpportunitiesProvider)
      ..invalidate(opportunityDetailProvider(id));
    return state;
  }
}

final opportunityActionsProvider = Provider<OpportunityActions>(
  OpportunityActions.new,
);
