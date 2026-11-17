import 'dart:convert';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/community/groups/groups_repository.dart';
import 'package:atarah/features/discover/discover_repository.dart' show PageOf;

/// A 1x1 transparent PNG, so cover images decode without a network.
final groupsTestPixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

GroupCardDto groupCard({
  String id = 'g-1',
  String slug = 'nairobi-animators',
  String name = 'Nairobi Animators',
  GroupType type = GroupType.discipline,
  int members = 1204,
  bool joined = false,
  GroupCardDtoRole? role,
  bool official = false,
  String? cover,
}) => GroupCardDto(
  id: id,
  slug: slug,
  type: type,
  name: name,
  description: 'Animators in Nairobi.',
  coverUrl: cover,
  memberCount: members,
  isOfficial: official,
  focus: 'Animation',
  joined: joined,
  role: joined ? (role ?? GroupCardDtoRole.member) : null,
);

PostViewDto groupPost({
  String id = 'p-1',
  String body = 'Sharing my lip-sync rig for Toon Boom, free download.',
  String author = 'Nia Wairimu',
  int replies = 31,
}) => PostViewDto(
  id: id,
  type: PostType.discussion,
  body: body,
  audience: PostAudience.group,
  group: null,
  author: PostAuthorDto(
    id: 'u-1',
    handle: 'nia',
    displayName: author,
    avatarUrl: null,
    headline: null,
    verified: false,
  ),
  media: const [],
  link: null,
  reactionCount: 3,
  replyCount: replies,
  isStaffAnnouncement: false,
  status: PostViewStatus.visible,
  viewer: const PostViewerDto(
    reacted: false,
    saved: false,
    muted: false,
    isAuthor: false,
  ),
  createdAt: DateTime.utc(2026, 10, 20),
  editedAt: null,
);

GroupDetailDto groupDetailDto({
  String id = 'g-1',
  String slug = 'nairobi-animators',
  String name = 'Nairobi Animators',
  int members = 1204,
  bool joined = false,
  GroupViewerDtoRole? role,
  bool canPost = false,
  GroupVisibility visibility = GroupVisibility.open,
  PostViewDto? pinned,
  bool official = false,
}) => GroupDetailDto(
  id: id,
  slug: slug,
  type: GroupType.discipline,
  name: name,
  description: 'Animators in Nairobi. Crit nights and shared rigs.',
  coverUrl: null,
  memberCount: members,
  isOfficial: official,
  focus: 'Animation',
  joined: joined,
  role: null,
  visibility: visibility,
  pinned: pinned,
  recentDiscussions: const [],
  viewer: GroupViewerDto(
    joined: joined,
    role: joined ? (role ?? GroupViewerDtoRole.member) : null,
    canPost: canPost,
  ),
);

/// In-memory stand-in for [GroupsRepository]. Records calls and can be scripted to fail.
class FakeGroupsRepository implements GroupsRepository {
  FakeGroupsRepository({
    List<GroupCardDto>? mine,
    List<GroupCardDto>? discover,
    GroupDetailDto? detail,
    List<PostViewDto>? postList,
    this.detailFailure,
    this.postsFailure,
    this.listFailure,
    this.joinFailure,
    this.leaveFailure,
    this.postPages,
    this.gate,
  }) : mine = mine ?? [],
       discover = discover ?? [],
       detailDto = detail,
       postList = postList ?? [];

  final List<GroupCardDto> mine;
  final List<GroupCardDto> discover;
  GroupDetailDto? detailDto;
  final List<PostViewDto> postList;
  AppFailure? detailFailure;
  AppFailure? postsFailure;
  AppFailure? listFailure;
  AppFailure? joinFailure;
  AppFailure? leaveFailure;

  /// When set, `posts` serves these pages in order with cursors `c1`, `c2`, ...
  List<List<PostViewDto>>? postPages;

  /// Join and leave wait for this before answering, so a test can look at the screen in between.
  Future<void>? gate;

  final List<String> calls = [];
  final List<GroupType?> typesAsked = [];
  final List<String?> searchesAsked = [];

  @override
  Future<PageOf<GroupCardDto>> list({
    required GroupScope scope,
    GroupType? type,
    String? q,
    int page = 1,
    int limit = 20,
  }) async {
    calls.add('list:${scope.json}');
    final f = listFailure;
    if (f != null && scope == GroupScope.discover) throw f;
    if (scope == GroupScope.mine) return PageOf(mine, mine.length);
    typesAsked.add(type);
    searchesAsked.add(q);
    final hits = [
      for (final g in discover)
        if ((type == null || g.type == type) &&
            (q == null || g.name.toLowerCase().contains(q.toLowerCase())))
          g,
    ];
    return PageOf(hits, hits.length);
  }

  @override
  Future<GroupDetailDto> detail(String ref) async {
    calls.add('detail:$ref');
    final f = detailFailure;
    if (f != null) throw f;
    return detailDto!;
  }

  @override
  Future<GroupMembershipStateDto> join(String ref) async {
    calls.add('join:$ref');
    await gate;
    final f = joinFailure;
    if (f != null) throw f;
    return GroupMembershipStateDto(
      groupId: ref,
      joined: true,
      memberCount: 1205,
    );
  }

  @override
  Future<GroupMembershipStateDto> leave(String ref) async {
    calls.add('leave:$ref');
    await gate;
    final f = leaveFailure;
    if (f != null) throw f;
    return GroupMembershipStateDto(
      groupId: ref,
      joined: false,
      memberCount: 1203,
    );
  }

  @override
  Future<CursorPage<PostViewDto>> posts(
    String ref, {
    String? cursor,
    int limit = 20,
  }) async {
    calls.add('posts:$ref:${cursor ?? ''}');
    final f = postsFailure;
    if (f != null) throw f;
    final pages = postPages;
    if (pages == null) return CursorPage(postList, null);
    final i = cursor == null ? 0 : int.parse(cursor.substring(1));
    return CursorPage(pages[i], i + 1 < pages.length ? 'c${i + 1}' : null);
  }
}
