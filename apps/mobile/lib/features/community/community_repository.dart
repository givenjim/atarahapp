import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';

/// One page of a cursor-paged list. [nextCursor] is opaque: it goes back to the API unchanged.
class CursorPage<T> {
  const CursorPage(this.items, this.nextCursor);

  final List<T> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}

String? _nextCursor(dynamic meta) {
  if (meta is Map && meta['nextCursor'] is String) {
    return meta['nextCursor'] as String;
  }
  return null;
}

/// Posts, comments, reactions, saving, muting, blocking and reporting, with errors mapped to typed failures.
/// Widgets go through providers; tests replace this with an in-memory fake.
class CommunityRepository {
  CommunityRepository({required this._api});

  final AtarahApiClient _api;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  // ---- feed and posts ----

  Future<CursorPage<PostViewDto>> feed({
    PostType? type,
    String? cursor,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.community.communityFeed(
      type: type,
      cursor: cursor,
      limit: limit,
    );
    return CursorPage(res.data, _nextCursor(res.meta));
  });

  Future<PostViewDto> post(String id) =>
      _guard(() async => (await _api.community.getPost(id: id)).data);

  Future<PostViewDto> createPost(CreatePostDto body) =>
      _guard(() async => (await _api.community.createPost(body: body)).data);

  Future<PostViewDto> updatePost(String id, String body) => _guard(
    () async => (await _api.community.updatePost(
      id: id,
      body: UpdatePostDto(body: body),
    )).data,
  );

  Future<void> deletePost(String id) =>
      _guard(() => _api.community.deletePost(id: id));

  // ---- comments ----

  Future<CursorPage<CommentViewDto>> comments(
    String postId, {
    String? cursor,
    int limit = 20,
  }) => _guard(() async {
    final res = await _api.community.listPostComments(
      id: postId,
      cursor: cursor,
      limit: limit,
    );
    return CursorPage(res.data, _nextCursor(res.meta));
  });

  Future<CommentViewDto> createComment(
    String postId,
    String body, {
    String? parentCommentId,
  }) => _guard(
    () async => (await _api.community.createPostComment(
      id: postId,
      body: CreateCommentDto(body: body, parentCommentId: parentCommentId),
    )).data,
  );

  Future<CommentViewDto> updateComment(String id, String body) => _guard(
    () async => (await _api.community.updateComment(
      id: id,
      body: UpdateCommentDto(body: body),
    )).data,
  );

  Future<void> deleteComment(String id) =>
      _guard(() => _api.community.deleteComment(id: id));

  // ---- reactions and saving ----

  Future<ReactionStateDto> react(String postId) =>
      _guard(() async => (await _api.community.reactToPost(id: postId)).data);

  Future<ReactionStateDto> unreact(String postId) =>
      _guard(() async => (await _api.community.unreactToPost(id: postId)).data);

  Future<bool> save(String postId) => _guard(
    () async => (await _api.community.savePost(id: postId)).data.saved,
  );

  Future<bool> unsave(String postId) => _guard(
    () async => (await _api.community.unsavePost(id: postId)).data.saved,
  );

  // ---- groups the member can post into ----

  Future<List<GroupCardDto>> myGroups() => _guard(
    () async => (await _api.community.listGroups(
      scope: GroupScope.mine,
      limit: 100,
    )).data,
  );

  // ---- safety ----

  Future<void> blockMember(String userId) => _guard(
    () =>
        _api.communitySafety.blockMember(body: BlockMemberDto(userId: userId)),
  );

  Future<void> unblockMember(String userId) =>
      _guard(() => _api.communitySafety.unblockMember(userId: userId));

  Future<void> muteThread(String postId) => _guard(
    () => _api.communitySafety.muteTarget(
      body: MuteTargetDto(targetType: MuteTargetType.post, targetId: postId),
    ),
  );

  Future<void> unmuteThread(String postId) => _guard(
    () => _api.communitySafety.unmuteTarget(
      targetType: TargetType.post,
      targetId: postId,
    ),
  );

  Future<void> report({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReason reason,
    String? note,
  }) => _guard(
    () => _api.communitySafety.submitReport(
      body: CreateReportDto(
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        note: note == null || note.trim().isEmpty ? null : note.trim(),
      ),
    ),
  );
}
