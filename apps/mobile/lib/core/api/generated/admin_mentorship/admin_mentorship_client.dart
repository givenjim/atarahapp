// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/decide_application_dto.dart';
import '../models/feature_mentor_dto.dart';
import '../models/get_api_v1_admin_mentor_applications_id_response.dart';
import '../models/get_api_v1_admin_mentor_applications_response.dart';
import '../models/get_api_v1_admin_mentor_session_types_response.dart';
import '../models/get_api_v1_admin_mentors_response.dart';
import '../models/mentor_application_status.dart';
import '../models/mentor_status.dart';
import '../models/mentor_status_change_dto.dart';
import '../models/patch_api_v1_admin_mentor_session_types_id_response.dart';
import '../models/patch_api_v1_admin_mentors_id_featured_response.dart';
import '../models/post_api_v1_admin_mentor_applications_id_approve_response.dart';
import '../models/post_api_v1_admin_mentor_applications_id_reject_response.dart';
import '../models/post_api_v1_admin_mentors_id_pause_response.dart';
import '../models/post_api_v1_admin_mentors_id_remove_response.dart';
import '../models/post_api_v1_admin_mentors_id_resume_response.dart';
import '../models/staff_session_type_dto.dart';

part 'admin_mentorship_client.g.dart';

@RestApi()
abstract class AdminMentorshipClient {
  factory AdminMentorshipClient(Dio dio, {String? baseUrl}) = _AdminMentorshipClient;

  @GET('/api/v1/admin/mentor-applications')
  Future<GetApiV1AdminMentorApplicationsResponse> applications({
    @Query('status') MentorApplicationStatus? status,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/admin/mentor-applications/{id}')
  Future<GetApiV1AdminMentorApplicationsIdResponse> application({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/mentor-applications/{id}/approve')
  Future<PostApiV1AdminMentorApplicationsIdApproveResponse> approve({
    @Path('id') required String id,
    @Body() required DecideApplicationDto body,
  });

  @POST('/api/v1/admin/mentor-applications/{id}/reject')
  Future<PostApiV1AdminMentorApplicationsIdRejectResponse> reject({
    @Path('id') required String id,
    @Body() required DecideApplicationDto body,
  });

  @GET('/api/v1/admin/mentors')
  Future<GetApiV1AdminMentorsResponse> mentors({
    @Query('status') MentorStatus? status,
    @Query('q') String? q,
    @Query('featured') bool? featured,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/mentors/{id}/pause')
  Future<PostApiV1AdminMentorsIdPauseResponse> pause({
    @Path('id') required String id,
    @Body() required MentorStatusChangeDto body,
  });

  @POST('/api/v1/admin/mentors/{id}/resume')
  Future<PostApiV1AdminMentorsIdResumeResponse> resume({
    @Path('id') required String id,
    @Body() required MentorStatusChangeDto body,
  });

  @POST('/api/v1/admin/mentors/{id}/remove')
  Future<PostApiV1AdminMentorsIdRemoveResponse> remove({
    @Path('id') required String id,
    @Body() required MentorStatusChangeDto body,
  });

  @PATCH('/api/v1/admin/mentors/{id}/featured')
  Future<PatchApiV1AdminMentorsIdFeaturedResponse> feature({
    @Path('id') required String id,
    @Body() required FeatureMentorDto body,
  });

  @GET('/api/v1/admin/mentor-session-types')
  Future<GetApiV1AdminMentorSessionTypesResponse> sessionTypes({
    @Query('mentorId') String? mentorId,
    @Query('disabledByStaff') bool? disabledByStaff,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @PATCH('/api/v1/admin/mentor-session-types/{id}')
  Future<PatchApiV1AdminMentorSessionTypesIdResponse> setDisabled({
    @Path('id') required String id,
    @Body() required StaffSessionTypeDto body,
  });
}
