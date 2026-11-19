// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/add_exception_dto.dart';
import '../models/get_api_v1_me_mentor_availability_response.dart';
import '../models/get_api_v1_me_mentor_booking_requests_response.dart';
import '../models/get_api_v1_me_mentor_response.dart';
import '../models/patch_api_v1_me_mentor_profile_response.dart';
import '../models/patch_api_v1_me_mentor_session_types_id_response.dart';
import '../models/post_api_v1_me_mentor_availability_exceptions_response.dart';
import '../models/post_api_v1_me_mentor_session_types_response.dart';
import '../models/put_api_v1_me_mentor_availability_response.dart';
import '../models/put_api_v1_me_mentor_paused_response.dart';
import '../models/session_type_fields_dto.dart';
import '../models/set_mentor_paused_dto.dart';
import '../models/set_weekly_availability_dto.dart';
import '../models/update_mentor_profile_dto.dart';
import '../models/update_session_type_dto.dart';

part 'mentor_tools_client.g.dart';

@RestApi()
abstract class MentorToolsClient {
  factory MentorToolsClient(Dio dio, {String? baseUrl}) = _MentorToolsClient;

  @GET('/api/v1/me/mentor')
  Future<GetApiV1MeMentorResponse> me();

  @PATCH('/api/v1/me/mentor/profile')
  Future<PatchApiV1MeMentorProfileResponse> updateProfile({
    @Body() required UpdateMentorProfileDto body,
  });

  @PUT('/api/v1/me/mentor/paused')
  Future<PutApiV1MeMentorPausedResponse> setPaused({
    @Body() required SetMentorPausedDto body,
  });

  @GET('/api/v1/me/mentor/availability')
  Future<GetApiV1MeMentorAvailabilityResponse> availability();

  @PUT('/api/v1/me/mentor/availability')
  Future<PutApiV1MeMentorAvailabilityResponse> setWeekly({
    @Body() required SetWeeklyAvailabilityDto body,
  });

  @POST('/api/v1/me/mentor/availability/exceptions')
  Future<PostApiV1MeMentorAvailabilityExceptionsResponse> addException({
    @Body() required AddExceptionDto body,
  });

  @DELETE('/api/v1/me/mentor/availability/exceptions/{id}')
  Future<void> removeException({
    @Path('id') required String id,
  });

  @POST('/api/v1/me/mentor/session-types')
  Future<PostApiV1MeMentorSessionTypesResponse> createSessionType({
    @Body() required SessionTypeFieldsDto body,
  });

  @PATCH('/api/v1/me/mentor/session-types/{id}')
  Future<PatchApiV1MeMentorSessionTypesIdResponse> updateSessionType({
    @Path('id') required String id,
    @Body() required UpdateSessionTypeDto body,
  });

  @DELETE('/api/v1/me/mentor/session-types/{id}')
  Future<void> deactivateSessionType({
    @Path('id') required String id,
  });

  @GET('/api/v1/me/mentor/booking-requests')
  Future<GetApiV1MeMentorBookingRequestsResponse> bookingRequests({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });
}
