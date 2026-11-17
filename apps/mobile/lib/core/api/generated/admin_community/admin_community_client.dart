// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/assign_case_body_dto.dart';
import '../models/create_announcement_dto.dart';
import '../models/create_group_dto.dart';
import '../models/delete_api_v1_admin_groups_id_moderators_user_id_response.dart';
import '../models/delete_api_v1_admin_groups_id_pins_post_id_response.dart';
import '../models/get_api_v1_admin_announcements_response.dart';
import '../models/get_api_v1_admin_groups_id_response.dart';
import '../models/get_api_v1_admin_groups_response.dart';
import '../models/get_api_v1_admin_moderation_cases_id_response.dart';
import '../models/get_api_v1_admin_moderation_cases_response.dart';
import '../models/get_api_v1_admin_reports_response.dart';
import '../models/group_moderator_body_dto.dart';
import '../models/group_type.dart';
import '../models/moderation_action_body_dto.dart';
import '../models/moderation_priority.dart';
import '../models/patch_api_v1_admin_groups_id_response.dart';
import '../models/pin_post_body_dto.dart';
import '../models/post_api_v1_admin_announcements_response.dart';
import '../models/post_api_v1_admin_groups_id_moderators_response.dart';
import '../models/post_api_v1_admin_groups_id_pins_response.dart';
import '../models/post_api_v1_admin_groups_response.dart';
import '../models/post_api_v1_admin_moderation_cases_id_actions_response.dart';
import '../models/post_api_v1_admin_moderation_cases_id_assign_response.dart';
import '../models/report_status.dart';
import '../models/report_target_type.dart';
import '../models/update_group_dto.dart';

part 'admin_community_client.g.dart';

@RestApi()
abstract class AdminCommunityClient {
  factory AdminCommunityClient(Dio dio, {String? baseUrl}) =
      _AdminCommunityClient;

  @GET('/api/v1/admin/reports')
  Future<GetApiV1AdminReportsResponse> adminListReports({
    @Query('status') ReportStatus? status,
    @Query('targetType') ReportTargetType? targetType,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  /// [open] - Only cases that still need a decision (not resolved or dismissed).
  ///
  /// [olderThanHours] - Only cases open for at least this many hours (the backlog view uses 48).
  @GET('/api/v1/admin/moderation-cases')
  Future<GetApiV1AdminModerationCasesResponse> adminListCases({
    @Query('status') ReportStatus? status,
    @Query('priority') ModerationPriority? priority,
    @Query('targetType') ReportTargetType? targetType,
    @Query('assigneeId') String? assigneeId,
    @Query('open') bool? open,
    @Query('olderThanHours') num? olderThanHours,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/admin/moderation-cases/{id}')
  Future<GetApiV1AdminModerationCasesIdResponse> adminGetCase({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/moderation-cases/{id}/assign')
  Future<PostApiV1AdminModerationCasesIdAssignResponse> adminAssignCase({
    @Path('id') required String id,
    @Body() required AssignCaseBodyDto body,
  });

  @POST('/api/v1/admin/moderation-cases/{id}/actions')
  Future<PostApiV1AdminModerationCasesIdActionsResponse> adminDecideCase({
    @Path('id') required String id,
    @Body() required ModerationActionBodyDto body,
  });

  /// [includeArchived] - Include archived groups.
  @GET('/api/v1/admin/groups')
  Future<GetApiV1AdminGroupsResponse> adminListGroups({
    @Query('type') GroupType? type,
    @Query('q') String? q,
    @Query('includeArchived') bool? includeArchived,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/groups')
  Future<PostApiV1AdminGroupsResponse> adminCreateGroup({
    @Body() required CreateGroupDto body,
  });

  @GET('/api/v1/admin/groups/{id}')
  Future<GetApiV1AdminGroupsIdResponse> adminGetGroup({
    @Path('id') required String id,
  });

  @PATCH('/api/v1/admin/groups/{id}')
  Future<PatchApiV1AdminGroupsIdResponse> adminUpdateGroup({
    @Path('id') required String id,
    @Body() required UpdateGroupDto body,
  });

  @DELETE('/api/v1/admin/groups/{id}')
  Future<void> adminArchiveGroup({@Path('id') required String id});

  @POST('/api/v1/admin/groups/{id}/moderators')
  Future<PostApiV1AdminGroupsIdModeratorsResponse> adminAssignGroupModerator({
    @Path('id') required String id,
    @Body() required GroupModeratorBodyDto body,
  });

  @DELETE('/api/v1/admin/groups/{id}/moderators/{userId}')
  Future<DeleteApiV1AdminGroupsIdModeratorsUserIdResponse>
  adminRemoveGroupModerator({
    @Path('id') required String id,
    @Path('userId') required String userId,
  });

  @POST('/api/v1/admin/groups/{id}/pins')
  Future<PostApiV1AdminGroupsIdPinsResponse> adminPinGroupPost({
    @Path('id') required String id,
    @Body() required PinPostBodyDto body,
  });

  @DELETE('/api/v1/admin/groups/{id}/pins/{postId}')
  Future<DeleteApiV1AdminGroupsIdPinsPostIdResponse> adminUnpinGroupPost({
    @Path('id') required String id,
    @Path('postId') required String postId,
  });

  @POST('/api/v1/admin/announcements')
  Future<PostApiV1AdminAnnouncementsResponse> adminCreateAnnouncement({
    @Body() required CreateAnnouncementDto body,
  });

  @GET('/api/v1/admin/announcements')
  Future<GetApiV1AdminAnnouncementsResponse> adminListAnnouncements({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });
}
