import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/generated/export.dart';
import '../../core/networking/failures.dart';
import '../../core/providers.dart';
import 'community_common.dart';
import 'community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepository(api: ref.watch(apiClientProvider)),
);

/// "Now" for relative times ("2h"). A provider so tests can fix the clock.
final communityClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// Whether the member may post announcements (the staff permission `community.announce`). `GET /users/me`
/// carries roles and membership entitlements but not staff permissions, so the app cannot know: the
/// Announcement chip stays hidden. Staff announce from the admin console (`POST /admin/announcements`).
final canAnnounceProvider = Provider<bool>((ref) => false);

// ---- the latest known state of a post, shared by the feed and the thread ----

class PostOverrides {
  const PostOverrides({this.posts = const {}, this.removed = const {}});

  /// Posts the member has just changed (liked, saved, edited, ...), newest first-hand version.
  final Map<String, PostViewDto> posts;

  /// Posts the member has just deleted.
  final Set<String> removed;

  PostViewDto resolve(PostViewDto p) => posts[p.id] ?? p;
}

class PostOverridesNotifier extends Notifier<PostOverrides> {
  @override
  PostOverrides build() => const PostOverrides();

  void put(PostViewDto p) => state = PostOverrides(
    posts: {...state.posts, p.id: p},
    removed: state.removed,
  );

  void remove(String id) => state = PostOverrides(
    posts: {...state.posts}..remove(id),
    removed: {...state.removed, id},
  );

  /// Fresh data from the server replaces whatever was held here.
  void clear() => state = const PostOverrides();
}

final postOverridesProvider =
    NotifierProvider<PostOverridesNotifier, PostOverrides>(
      PostOverridesNotifier.new,
    );

// ---- the feed ----

class FeedState {
  const FeedState({
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

  FeedState copyWith({
    List<PostViewDto>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? loadingMore,
    bool? moreFailed,
  }) => FeedState(
    items: items ?? this.items,
    nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

/// The community feed (all posts, or one [type]), a cursor page at a time.
class FeedNotifier extends AsyncNotifier<FeedState> {
  FeedNotifier(this.type);

  final PostType? type;

  static const pageSize = 20;

  @override
  Future<FeedState> build() async {
    final page = await ref
        .watch(communityRepositoryProvider)
        .feed(type: type, limit: pageSize);
    return FeedState(items: page.items, nextCursor: page.nextCursor);
  }

  /// Pull to refresh: drops what the member changed locally and asks again.
  Future<void> refresh() async {
    ref.read(postOverridesProvider.notifier).clear();
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await ref
          .read(communityRepositoryProvider)
          .feed(type: type, cursor: current.nextCursor, limit: pageSize);
      final seen = {for (final p in current.items) p.id};
      state = AsyncData(
        FeedState(
          items: [
            ...current.items,
            for (final p in next.items)
              if (!seen.contains(p.id)) p,
          ],
          nextCursor: next.nextCursor,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }
}

final feedProvider =
    AsyncNotifierProvider.family<FeedNotifier, FeedState, PostType?>(
      FeedNotifier.new,
    );

// ---- one discussion ----

class ThreadState {
  const ThreadState({
    required this.post,
    required this.comments,
    required this.nextCursor,
    this.loadingMore = false,
    this.moreFailed = false,
  });

  final PostViewDto post;
  final List<CommentViewDto> comments;
  final String? nextCursor;
  final bool loadingMore;
  final bool moreFailed;

  bool get hasMore => nextCursor != null;

  ThreadState copyWith({
    PostViewDto? post,
    List<CommentViewDto>? comments,
    String? nextCursor,
    bool clearCursor = false,
    bool? loadingMore,
    bool? moreFailed,
  }) => ThreadState(
    post: post ?? this.post,
    comments: comments ?? this.comments,
    nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
    loadingMore: loadingMore ?? this.loadingMore,
    moreFailed: moreFailed ?? this.moreFailed,
  );
}

class ThreadNotifier extends AsyncNotifier<ThreadState> {
  ThreadNotifier(this.postId);

  final String postId;

  CommunityRepository get _repo => ref.read(communityRepositoryProvider);

  @override
  Future<ThreadState> build() async {
    final repo = ref.watch(communityRepositoryProvider);
    final results = await Future.wait([
      repo.post(postId),
      repo.comments(postId),
    ]);
    final post = results[0] as PostViewDto;
    final comments = results[1] as CursorPage<CommentViewDto>;
    return ThreadState(
      post: post,
      comments: comments.items,
      nextCursor: comments.nextCursor,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true, moreFailed: false));
    try {
      final next = await _repo.comments(postId, cursor: current.nextCursor);
      final seen = {for (final c in current.comments) c.id};
      state = AsyncData(
        ThreadState(
          post: current.post,
          comments: [
            ...current.comments,
            for (final c in next.items)
              if (!seen.contains(c.id)) c,
          ],
          nextCursor: next.nextCursor,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false, moreFailed: true));
    }
  }

  void _bumpReplyCount(int delta) {
    final current = state.value;
    if (current == null) return;
    final base = ref.read(postOverridesProvider).resolve(current.post);
    ref
        .read(postOverridesProvider.notifier)
        .put(
          copyPost(
            base,
            replyCount: (base.replyCount + delta).clamp(0, 1 << 30),
          ),
        );
  }

  /// Adds a reply to the post, or to a top-level comment when [parentCommentId] is given.
  Future<void> reply(String body, {String? parentCommentId}) async {
    final created = await _repo.createComment(
      postId,
      body,
      parentCommentId: parentCommentId,
    );
    final current = state.value;
    if (current == null) return;
    if (parentCommentId == null) {
      state = AsyncData(
        current.copyWith(comments: [...current.comments, created]),
      );
    } else {
      state = AsyncData(
        current.copyWith(
          comments: [
            for (final c in current.comments)
              if (c.id == parentCommentId)
                copyComment(c, replies: [...c.replies, replyOf(created)])
              else
                c,
          ],
        ),
      );
    }
    _bumpReplyCount(1);
  }

  Future<void> editComment(String id, String body) async {
    final updated = await _repo.updateComment(id, body);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        comments: [
          for (final c in current.comments)
            if (c.id == id)
              copyComment(c, body: updated.body, editedAt: updated.editedAt)
            else
              copyComment(
                c,
                replies: [
                  for (final r in c.replies)
                    if (r.id == id)
                      ReplyViewDto(
                        id: r.id,
                        postId: r.postId,
                        parentCommentId: r.parentCommentId,
                        body: updated.body,
                        author: r.author,
                        isMine: r.isMine,
                        createdAt: r.createdAt,
                        editedAt: updated.editedAt,
                      )
                    else
                      r,
                ],
              ),
        ],
      ),
    );
  }

  Future<void> deleteComment(String id) async {
    await _repo.deleteComment(id);
    final current = state.value;
    if (current == null) return;
    var removed = 0;
    final next = <CommentViewDto>[];
    for (final c in current.comments) {
      if (c.id == id) {
        removed += 1 + c.replies.length;
        continue;
      }
      final kept = [
        for (final r in c.replies)
          if (r.id != id) r,
      ];
      removed += c.replies.length - kept.length;
      next.add(
        kept.length == c.replies.length ? c : copyComment(c, replies: kept),
      );
    }
    state = AsyncData(current.copyWith(comments: next));
    _bumpReplyCount(-removed);
  }
}

final threadProvider = AsyncNotifierProvider.autoDispose
    .family<ThreadNotifier, ThreadState, String>(ThreadNotifier.new);

// ---- what the member does to a post ----

/// Like, save, mute, edit and delete. Likes and saves show at once and roll back when the server says no.
class PostActions {
  PostActions(this._ref);

  final Ref _ref;
  final Set<String> _busy = {};

  CommunityRepository get _repo => _ref.read(communityRepositoryProvider);
  PostOverridesNotifier get _overrides =>
      _ref.read(postOverridesProvider.notifier);

  PostViewDto _current(PostViewDto shown) =>
      _ref.read(postOverridesProvider).resolve(shown);

  /// Optimistic like: the heart and the count change now. If the request fails, the state before the tap is
  /// put back and the failure is rethrown for the caller to explain.
  Future<void> toggleLike(PostViewDto shown) async {
    final key = 'like:${shown.id}';
    if (!_busy.add(key)) return;
    final before = _current(shown);
    final now = !before.viewer.reacted;
    _overrides.put(
      copyPost(
        before,
        reacted: now,
        reactionCount: (before.reactionCount + (now ? 1 : -1)).clamp(
          0,
          1 << 30,
        ),
      ),
    );
    try {
      final state = now
          ? await _repo.react(before.id)
          : await _repo.unreact(before.id);
      _overrides.put(
        copyPost(
          _current(before),
          reacted: state.reacted,
          reactionCount: state.reactionCount,
        ),
      );
    } on Object catch (e) {
      _overrides.put(before);
      throw mapError(e);
    } finally {
      _busy.remove(key);
    }
  }

  Future<void> toggleSave(PostViewDto shown) async {
    final key = 'save:${shown.id}';
    if (!_busy.add(key)) return;
    final before = _current(shown);
    final now = !before.viewer.saved;
    _overrides.put(copyPost(before, saved: now));
    try {
      final saved = now
          ? await _repo.save(before.id)
          : await _repo.unsave(before.id);
      _overrides.put(copyPost(_current(before), saved: saved));
    } on Object catch (e) {
      _overrides.put(before);
      throw mapError(e);
    } finally {
      _busy.remove(key);
    }
  }

  Future<void> toggleMute(PostViewDto shown) async {
    final before = _current(shown);
    final now = !before.viewer.muted;
    if (now) {
      await _repo.muteThread(before.id);
    } else {
      await _repo.unmuteThread(before.id);
    }
    _overrides.put(copyPost(_current(before), muted: now));
  }

  Future<void> editPost(PostViewDto shown, String body) async {
    final updated = await _repo.updatePost(shown.id, body);
    _overrides.put(updated);
  }

  Future<void> deletePost(PostViewDto shown) async {
    await _repo.deletePost(shown.id);
    _overrides.remove(shown.id);
  }
}

final postActionsProvider = Provider<PostActions>(PostActions.new);

/// Groups the member belongs to, for the composer's audience row.
final myGroupsProvider = FutureProvider.autoDispose<List<GroupCardDto>>(
  (ref) => ref.watch(communityRepositoryProvider).myGroups(),
);
