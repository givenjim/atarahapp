import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/generated/export.dart';
import '../../../core/networking/failures.dart';
import '../../../core/providers.dart';
import '../../discover/discover_repository.dart' show PageOf;
import 'groups_repository.dart';

part 'groups_providers.g.dart';

@Riverpod(keepAlive: true)
GroupsRepository groupsRepository(Ref ref) =>
    GroupsRepository(api: ref.watch(apiClientProvider));

/// The groups the member belongs to (the "Your groups" carousel).
@riverpod
Future<List<GroupCardDto>> myGroups(Ref ref) async =>
    (await ref
            .watch(groupsRepositoryProvider)
            .list(scope: GroupScope.mine, limit: 50))
        .items;

/// What narrows the discover list: a type chip and the search text.
class GroupQuery {
  const GroupQuery({this.type, this.q = ''});

  final GroupType? type;
  final String q;

  @override
  bool operator ==(Object other) =>
      other is GroupQuery && other.type == type && other.q == q;

  @override
  int get hashCode => Object.hash(type, q);
}

@riverpod
class GroupQueryState extends _$GroupQueryState {
  @override
  GroupQuery build() => const GroupQuery();

  void setType(GroupType? type) => state = GroupQuery(type: type, q: state.q);
  void setSearch(String q) => state = GroupQuery(type: state.type, q: q.trim());
}

/// The discover list, a page at a time.
class GroupList {
  const GroupList({
    required this.items,
    required this.total,
    required this.page,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final List<GroupCardDto> items;
  final int total;
  final int page;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => items.length < total;

  GroupList copyWith({
    List<GroupCardDto>? items,
    int? total,
    int? page,
    bool? loadingMore,
    bool? moreFailed,
  }) => GroupList(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

@riverpod
class DiscoverGroups extends _$DiscoverGroups {
  static const _pageSize = 20;

  @override
  Future<GroupList> build() async {
    final query = ref.watch(groupQueryStateProvider);
    final PageOf<GroupCardDto> first = await ref
        .watch(groupsRepositoryProvider)
        .list(
          scope: GroupScope.discover,
          type: query.type,
          q: query.q,
          limit: _pageSize,
        );
    return GroupList(items: first.items, total: first.total, page: 1);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    final query = ref.read(groupQueryStateProvider);
    try {
      final next = await ref
          .read(groupsRepositoryProvider)
          .list(
            scope: GroupScope.discover,
            type: query.type,
            q: query.q,
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

/// One group by id or slug.
@riverpod
Future<GroupDetailDto> groupDetail(Ref ref, String groupRef) =>
    ref.watch(groupsRepositoryProvider).detail(groupRef);

/// A group's discussions, newest first, a page at a time.
class GroupPostList {
  const GroupPostList({
    required this.items,
    required this.nextCursor,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final List<PostViewDto> items;
  final String? nextCursor;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => nextCursor != null;

  GroupPostList copyWith({
    List<PostViewDto>? items,
    String? nextCursor,
    bool? loadingMore,
    bool? moreFailed,
    bool clearCursor = false,
  }) => GroupPostList(
    items: items ?? this.items,
    nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

@riverpod
class GroupPosts extends _$GroupPosts {
  static const _pageSize = 20;

  @override
  Future<GroupPostList> build(String groupRef) async {
    final first = await ref
        .watch(groupsRepositoryProvider)
        .posts(groupRef, limit: _pageSize);
    return GroupPostList(items: first.items, nextCursor: first.nextCursor);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(groupsRepositoryProvider)
          .posts(groupRef, cursor: current.nextCursor, limit: _pageSize);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          nextCursor: next.nextCursor,
          clearCursor: next.nextCursor == null,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }
}

/// What the member has just done to a group's membership, shared by the carousel, the discover list and
/// the group screen so they agree while a request is in flight.
class MembershipOverride {
  const MembershipOverride({required this.joined, required this.memberCount});
  final bool joined;
  final num memberCount;
}

@Riverpod(keepAlive: true)
class GroupMembership extends _$GroupMembership {
  @override
  Map<String, MembershipOverride> build() => const {};

  final _busy = <String>{};

  bool isBusy(String groupId) => _busy.contains(groupId);

  /// Joins or leaves at once on screen, then asks the server. If the server refuses, the screen goes back
  /// to what it was and the [AppFailure] is thrown for the caller to show.
  Future<void> setJoined({
    required String groupId,
    required bool joined,
    required bool wasJoined,
    required num memberCount,
  }) async {
    if (!_busy.add(groupId)) return;
    final before = state;
    state = {
      ...state,
      groupId: MembershipOverride(
        joined: joined,
        memberCount:
            (memberCount + (joined == wasJoined ? 0 : (joined ? 1 : -1))).clamp(
              0,
              double.infinity,
            ),
      ),
    };
    final repo = ref.read(groupsRepositoryProvider);
    try {
      final res = joined ? await repo.join(groupId) : await repo.leave(groupId);
      state = {
        ...state,
        groupId: MembershipOverride(
          joined: res.joined,
          memberCount: res.memberCount,
        ),
      };
      ref.invalidate(myGroupsProvider);
      ref.invalidate(groupDetailProvider);
      ref.invalidate(groupPostsProvider);
    } on Object catch (e) {
      state = before;
      throw mapError(e);
    } finally {
      _busy.remove(groupId);
    }
  }
}
