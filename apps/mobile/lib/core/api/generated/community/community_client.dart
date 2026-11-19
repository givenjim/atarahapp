// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_comment_dto.dart';
import '../models/create_post_dto.dart';
import '../models/delete_api_v1_posts_id_reactions_response.dart';
import '../models/delete_api_v1_posts_id_save_response.dart';
import '../models/get_api_v1_community_feed_response.dart';
import '../models/get_api_v1_creatives_suggestions_response.dart';
import '../models/get_api_v1_groups_ref_posts_response.dart';
import '../models/get_api_v1_groups_ref_response.dart';
import '../models/get_api_v1_groups_response.dart';
import '../models/get_api_v1_me_saved_posts_response.dart';
import '../models/get_api_v1_posts_id_comments_response.dart';
import '../models/get_api_v1_posts_id_response.dart';
import '../models/group_post_body_dto.dart';
import '../models/group_scope.dart';
import '../models/group_type.dart';
import '../models/patch_api_v1_comments_id_response.dart';
import '../models/patch_api_v1_posts_id_response.dart';
import '../models/post_api_v1_groups_ref_join_response.dart';
import '../models/post_api_v1_groups_ref_leave_response.dart';
import '../models/post_api_v1_groups_ref_posts_response.dart';
import '../models/post_api_v1_posts_id_comments_response.dart';
import '../models/post_api_v1_posts_response.dart';
import '../models/post_type.dart';
import '../models/put_api_v1_posts_id_reactions_response.dart';
import '../models/put_api_v1_posts_id_save_response.dart';
import '../models/update_comment_dto.dart';
import '../models/update_post_dto.dart';

part 'community_client.g.dart';

@RestApi()
abstract class CommunityClient {
  factory CommunityClient(Dio dio, {String? baseUrl}) = _CommunityClient;

  /// [countyId] - Only people who show their county to you.
  ///
  /// [verified] - Only people Atarah has verified.
  ///
  /// [available] - Only people open to work (open to commissions).
  @GET('/api/v1/creatives/suggestions')
  Future<GetApiV1CreativesSuggestionsResponse> listPeopleToMeet({
    @Query('disciplineId') String? disciplineId,
    @Query('countyId') String? countyId,
    @Query('verified') bool? verified,
    @Query('available') bool? available,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  /// [cursor] - Opaque cursor from the previous page.
  ///
  /// [type] - Only this kind of post (the Discussions tab uses DISCUSSION).
  @GET('/api/v1/community/feed')
  Future<GetApiV1CommunityFeedResponse> communityFeed({
    @Query('limit') num? limit = 20,
    @Query('cursor') String? cursor,
    @Query('type') PostType? type,
  });

  @POST('/api/v1/posts')
  Future<PostApiV1PostsResponse> createPost({
    @Body() required CreatePostDto body,
  });

  @GET('/api/v1/posts/{id}')
  Future<GetApiV1PostsIdResponse> getPost({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/posts/{id}')
  Future<PatchApiV1PostsIdResponse> updatePost({
    @Path('id') required String id,
    @Body() required UpdatePostDto body,
  });

  @DELETE('/api/v1/posts/{id}')
  Future<void> deletePost({
    @Path('id') required String id,
  });

  /// [cursor] - Opaque cursor from the previous page.
  @GET('/api/v1/posts/{id}/comments')
  Future<GetApiV1PostsIdCommentsResponse> listPostComments({
    @Path('id') required String id,
    @Query('limit') num? limit = 20,
    @Query('cursor') String? cursor,
  });

  @POST('/api/v1/posts/{id}/comments')
  Future<PostApiV1PostsIdCommentsResponse> createPostComment({
    @Path('id') required String id,
    @Body() required CreateCommentDto body,
  });

  @PATCH('/api/v1/comments/{id}')
  Future<PatchApiV1CommentsIdResponse> updateComment({
    @Path('id') required String id,
    @Body() required UpdateCommentDto body,
  });

  @DELETE('/api/v1/comments/{id}')
  Future<void> deleteComment({
    @Path('id') required String id,
  });

  @PUT('/api/v1/posts/{id}/reactions')
  Future<PutApiV1PostsIdReactionsResponse> reactToPost({
    @Path('id') required String id,
  });

  @DELETE('/api/v1/posts/{id}/reactions')
  Future<DeleteApiV1PostsIdReactionsResponse> unreactToPost({
    @Path('id') required String id,
  });

  @PUT('/api/v1/posts/{id}/save')
  Future<PutApiV1PostsIdSaveResponse> savePost({
    @Path('id') required String id,
  });

  @DELETE('/api/v1/posts/{id}/save')
  Future<DeleteApiV1PostsIdSaveResponse> unsavePost({
    @Path('id') required String id,
  });

  /// [cursor] - Opaque cursor from the previous page.
  @GET('/api/v1/me/saved-posts')
  Future<GetApiV1MeSavedPostsResponse> listSavedPosts({
    @Query('limit') num? limit = 20,
    @Query('cursor') String? cursor,
  });

  /// [scope] - discover = groups you have not joined; mine = your groups.
  ///
  /// [q] - Part of the group name.
  @GET('/api/v1/groups')
  Future<GetApiV1GroupsResponse> listGroups({
    @Query('scope') GroupScope? scope,
    @Query('type') GroupType? type,
    @Query('q') String? q,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/groups/{ref}')
  Future<GetApiV1GroupsRefResponse> getGroup({
    @Path('ref') required String ref,
  });

  @POST('/api/v1/groups/{ref}/join')
  Future<PostApiV1GroupsRefJoinResponse> joinGroup({
    @Path('ref') required String ref,
  });

  @POST('/api/v1/groups/{ref}/leave')
  Future<PostApiV1GroupsRefLeaveResponse> leaveGroup({
    @Path('ref') required String ref,
  });

  /// [cursor] - Opaque cursor from the previous page.
  @GET('/api/v1/groups/{ref}/posts')
  Future<GetApiV1GroupsRefPostsResponse> listGroupPosts({
    @Path('ref') required String ref,
    @Query('limit') num? limit = 20,
    @Query('cursor') String? cursor,
    @Query('type') PostType? type,
  });

  @POST('/api/v1/groups/{ref}/posts')
  Future<PostApiV1GroupsRefPostsResponse> createGroupPost({
    @Path('ref') required String ref,
    @Body() required GroupPostBodyDto body,
  });
}
