// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/apply_mentor_dto.dart';
import '../models/get_api_v1_me_mentor_application_prefill_response.dart';
import '../models/get_api_v1_me_mentor_application_response.dart';
import '../models/get_api_v1_mentors_id_response.dart';
import '../models/get_api_v1_mentors_id_slots_response.dart';
import '../models/get_api_v1_mentors_response.dart';
import '../models/get_api_v1_mentorship_home_response.dart';
import '../models/mentor_sort.dart';
import '../models/post_api_v1_me_mentor_application_response.dart';
import '../models/post_api_v1_me_mentor_application_withdraw_response.dart';

part 'mentorship_client.g.dart';

@RestApi()
abstract class MentorshipClient {
  factory MentorshipClient(Dio dio, {String? baseUrl}) = _MentorshipClient;

  @GET('/api/v1/mentorship/home')
  Future<GetApiV1MentorshipHomeResponse> home();

  /// [q] - Name, headline or expertise.
  ///
  /// [verified] - Identity-verified mentors only.
  ///
  /// [availableThisWeek] - Has a bookable slot in the next 7 days.
  ///
  /// [maxPriceMinor] - Has a session type at or under this price (minor units).
  ///
  /// [videoCall] - Offers video call sessions.
  @GET('/api/v1/mentors')
  Future<GetApiV1MentorsResponse> list({
    @Query('q') String? q,
    @Query('disciplineId') String? disciplineId,
    @Query('verified') bool? verified,
    @Query('availableThisWeek') bool? availableThisWeek,
    @Query('maxPriceMinor') num? maxPriceMinor,
    @Query('videoCall') bool? videoCall,
    @Query('sort') MentorSort? sort,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/mentors/{id}')
  Future<GetApiV1MentorsIdResponse> detail({
    @Path('id') required String id,
  });

  /// [from] - Defaults to now.
  ///
  /// [to] - Defaults to 14 days after `from`; at most 60.
  ///
  /// [timeZone] - The member time zone for `localDate`.
  @GET('/api/v1/mentors/{id}/slots')
  Future<GetApiV1MentorsIdSlotsResponse> slots({
    @Path('id') required String id,
    @Query('sessionTypeId') required String sessionTypeId,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
    @Query('timeZone') String? timeZone,
  });

  @GET('/api/v1/me/mentor-application/prefill')
  Future<GetApiV1MeMentorApplicationPrefillResponse> prefill();

  @GET('/api/v1/me/mentor-application')
  Future<GetApiV1MeMentorApplicationResponse> mine();

  @POST('/api/v1/me/mentor-application')
  Future<PostApiV1MeMentorApplicationResponse> apply({
    @Body() required ApplyMentorDto body,
  });

  @POST('/api/v1/me/mentor-application/withdraw')
  Future<PostApiV1MeMentorApplicationWithdrawResponse> withdraw();
}
