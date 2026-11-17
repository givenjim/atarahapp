import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/community/community_repository.dart';

PostAuthorDto author({
  String id = 'u-kiptoo',
  String name = 'Kiptoo Langat',
  String? headline = 'Graphic designer',
  bool verified = false,
}) => PostAuthorDto(
  id: id,
  handle: name.toLowerCase().replaceAll(' ', ''),
  displayName: name,
  avatarUrl: null,
  headline: headline,
  verified: verified,
);

PostViewDto postDto({
  String id = 'p-1',
  PostType type = PostType.discussion,
  String body = 'How are you pricing short-form brand content in 2026?',
  PostAuthorDto? by,
  int likes = 48,
  int replies = 23,
  bool reacted = false,
  bool saved = false,
  bool muted = false,
  bool mine = false,
  bool announcement = false,
  PostLinkPreviewDto? link,
  List<PostMediaItemDto> media = const [],
}) => PostViewDto(
  id: id,
  type: type,
  body: body,
  audience: PostAudience.members,
  group: null,
  author: by ?? author(),
  media: media,
  link: link,
  reactionCount: likes,
  replyCount: replies,
  isStaffAnnouncement: announcement,
  status: PostViewStatus.visible,
  viewer: PostViewerDto(
    reacted: reacted,
    saved: saved,
    muted: muted,
    isAuthor: mine,
  ),
  createdAt: DateTime.utc(2026, 10, 22, 10),
  editedAt: null,
);

CommentViewDto commentDto({
  String id = 'c-1',
  String postId = 'p-1',
  String body = 'Splitting usage from production changed everything for me.',
  PostAuthorDto? by,
  bool mine = false,
  List<ReplyViewDto> replies = const [],
}) => CommentViewDto(
  id: id,
  postId: postId,
  parentCommentId: null,
  body: body,
  author: by ?? author(),
  isMine: mine,
  createdAt: DateTime.utc(2026, 10, 22, 11),
  editedAt: null,
  replies: replies,
);

ReplyViewDto replyDto({
  String id = 'r-1',
  String parentId = 'c-1',
  String body = 'Do you charge for revisions separately?',
  bool mine = false,
}) => ReplyViewDto(
  id: id,
  postId: 'p-1',
  parentCommentId: parentId,
  body: body,
  author: author(id: 'u-amani', name: 'Amani Otieno'),
  isMine: mine,
  createdAt: DateTime.utc(2026, 10, 22, 11, 30),
  editedAt: null,
);

/// In-memory community: a feed served in cursor pages, comments, and every write recorded.
class FakeCommunityRepository implements CommunityRepository {
  FakeCommunityRepository({
    List<PostViewDto>? posts,
    this.pageSize = 20,
    Map<String, List<CommentViewDto>>? comments,
  }) : posts = posts ?? [],
       _comments = comments ?? {};

  final List<PostViewDto> posts;
  final Map<String, List<CommentViewDto>> _comments;
  final int pageSize;

  AppFailure? feedFailure;
  AppFailure? reactFailure;
  AppFailure? createFailure;
  AppFailure? reportFailure;
  AppFailure? blockFailure;

  /// Every cursor the feed was asked for (null for the first page).
  final List<String?> feedCursors = [];
  final List<PostType?> feedTypes = [];
  final List<CreatePostDto> created = [];
  final List<String> reacted = [];
  final List<String> unreacted = [];
  final List<String> saved = [];
  final List<String> unsaved = [];
  final List<String> muted = [];
  final List<String> deleted = [];
  final List<String> blocked = [];
  final List<String> unblocked = [];
  final List<
    ({ReportTargetType type, String id, ReportReason reason, String? note})
  >
  reports = [];
  final List<({String body, String? parent})> replies = [];
  List<GroupCardDto> groups = [];

  @override
  Future<CursorPage<PostViewDto>> feed({
    PostType? type,
    String? cursor,
    int limit = 20,
  }) async {
    feedCursors.add(cursor);
    feedTypes.add(type);
    final f = feedFailure;
    if (f != null) throw f;
    final all = [
      for (final p in posts)
        if (type == null || p.type == type) p,
    ];
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + pageSize).clamp(0, all.length);
    return CursorPage(
      all.sublist(start, end),
      end < all.length ? '$end' : null,
    );
  }

  @override
  Future<PostViewDto> post(String id) async {
    final p = posts.where((p) => p.id == id);
    if (p.isEmpty) {
      throw const ApiFailure(
        code: 'RESOURCE_NOT_FOUND',
        message: 'Not found',
        statusCode: 404,
      );
    }
    return p.first;
  }

  @override
  Future<PostViewDto> createPost(CreatePostDto body) async {
    final f = createFailure;
    if (f != null) throw f;
    created.add(body);
    final p = postDto(
      id: 'p-new-${created.length}',
      type: body.type,
      body: body.body ?? '',
      mine: true,
      likes: 0,
      replies: 0,
    );
    posts.insert(0, p);
    return p;
  }

  @override
  Future<PostViewDto> updatePost(String id, String body) async {
    final i = posts.indexWhere((p) => p.id == id);
    final old = posts[i];
    final updated = PostViewDto(
      id: old.id,
      type: old.type,
      body: body,
      audience: old.audience,
      group: old.group,
      author: old.author,
      media: old.media,
      link: old.link,
      reactionCount: old.reactionCount,
      replyCount: old.replyCount,
      isStaffAnnouncement: old.isStaffAnnouncement,
      status: old.status,
      viewer: old.viewer,
      createdAt: old.createdAt,
      editedAt: DateTime.utc(2026, 10, 22, 12),
    );
    posts[i] = updated;
    return updated;
  }

  @override
  Future<void> deletePost(String id) async {
    deleted.add(id);
    posts.removeWhere((p) => p.id == id);
  }

  @override
  Future<CursorPage<CommentViewDto>> comments(
    String postId, {
    String? cursor,
    int limit = 20,
  }) async => CursorPage(_comments[postId] ?? const [], null);

  @override
  Future<CommentViewDto> createComment(
    String postId,
    String body, {
    String? parentCommentId,
  }) async {
    replies.add((body: body, parent: parentCommentId));
    return CommentViewDto(
      id: 'c-new-${replies.length}',
      postId: postId,
      parentCommentId: parentCommentId,
      body: body,
      author: author(id: 'me', name: 'Nia Wairimu'),
      isMine: true,
      createdAt: DateTime.utc(2026, 10, 22, 13),
      editedAt: null,
      replies: const [],
    );
  }

  @override
  Future<CommentViewDto> updateComment(String id, String body) async =>
      commentDto(id: id, body: body, mine: true);

  @override
  Future<void> deleteComment(String id) async {}

  @override
  Future<ReactionStateDto> react(String postId) async {
    final f = reactFailure;
    if (f != null) throw f;
    reacted.add(postId);
    final p = posts.firstWhere((p) => p.id == postId);
    return ReactionStateDto(reacted: true, reactionCount: p.reactionCount + 1);
  }

  @override
  Future<ReactionStateDto> unreact(String postId) async {
    final f = reactFailure;
    if (f != null) throw f;
    unreacted.add(postId);
    final p = posts.firstWhere((p) => p.id == postId);
    return ReactionStateDto(reacted: false, reactionCount: p.reactionCount - 1);
  }

  @override
  Future<bool> save(String postId) async {
    saved.add(postId);
    return true;
  }

  @override
  Future<bool> unsave(String postId) async {
    unsaved.add(postId);
    return false;
  }

  @override
  Future<List<GroupCardDto>> myGroups() async => groups;

  @override
  Future<void> blockMember(String userId) async {
    final f = blockFailure;
    if (f != null) throw f;
    blocked.add(userId);
  }

  @override
  Future<void> unblockMember(String userId) async => unblocked.add(userId);

  @override
  Future<void> muteThread(String postId) async => muted.add(postId);

  @override
  Future<void> unmuteThread(String postId) async => muted.remove(postId);

  @override
  Future<void> report({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReason reason,
    String? note,
  }) async {
    final f = reportFailure;
    if (f != null) throw f;
    reports.add((type: targetType, id: targetId, reason: reason, note: note));
  }
}
