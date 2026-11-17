import '../../../core/api/generated/export.dart';
import '../../../core/networking/failures.dart';
import '../../discover/discover_repository.dart' show PageOf;

/// One page of a cursor-paginated list. [nextCursor] is null on the last page; cursors are opaque.
class CursorPage<T> {
  const CursorPage(this.items, this.nextCursor);
  final List<T> items;
  final String? nextCursor;
}

/// Groups: listing, one group, join/leave and a group's discussions, with errors mapped to typed failures.
/// Widgets go through providers; tests replace this with an in-memory fake.
class GroupsRepository {
  GroupsRepository({required this._api});

  final AtarahApiClient _api;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<PageOf<GroupCardDto>> list({
    required GroupScope scope,
    GroupType? type,
    String? q,
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.community.listGroups(
      scope: scope,
      type: type,
      q: q == null || q.trim().isEmpty ? null : q.trim(),
      page: page,
      limit: limit,
    );
    final meta = res.meta;
    final total = meta is Map && meta['total'] is num
        ? (meta['total'] as num).toInt()
        : res.data.length;
    return PageOf(res.data, total);
  });

  /// [ref] is the group's id or slug.
  Future<GroupDetailDto> detail(String ref) =>
      _guard(() async => (await _api.community.getGroup(ref: ref)).data);

  Future<GroupMembershipStateDto> join(String ref) =>
      _guard(() async => (await _api.community.joinGroup(ref: ref)).data);

  Future<GroupMembershipStateDto> leave(String ref) =>
      _guard(() async => (await _api.community.leaveGroup(ref: ref)).data);

  Future<CursorPage<PostViewDto>> posts(
    String ref, {
    String? cursor,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.community.listGroupPosts(
      ref: ref,
      cursor: cursor,
      limit: limit,
    );
    final meta = res.meta;
    final next = meta is Map ? meta['nextCursor'] : null;
    return CursorPage(res.data, next is String ? next : null);
  });
}
