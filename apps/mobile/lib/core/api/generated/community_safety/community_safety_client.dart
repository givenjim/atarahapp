// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/block_member_dto.dart';
import '../models/create_report_dto.dart';
import '../models/delete_api_v1_mutes_target_type_target_id_response.dart';
import '../models/get_api_v1_me_blocks_response.dart';
import '../models/get_api_v1_me_reports_response.dart';
import '../models/mute_target_dto.dart';
import '../models/post_api_v1_blocks_response.dart';
import '../models/post_api_v1_mutes_response.dart';
import '../models/post_api_v1_reports_response.dart';
import '../models/target_type.dart';

part 'community_safety_client.g.dart';

@RestApi()
abstract class CommunitySafetyClient {
  factory CommunitySafetyClient(Dio dio, {String? baseUrl}) = _CommunitySafetyClient;

  @POST('/api/v1/blocks')
  Future<PostApiV1BlocksResponse> blockMember({
    @Body() required BlockMemberDto body,
  });

  @DELETE('/api/v1/blocks/{userId}')
  Future<void> unblockMember({
    @Path('userId') required String userId,
  });

  @GET('/api/v1/me/blocks')
  Future<GetApiV1MeBlocksResponse> listBlockedMembers({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/mutes')
  Future<PostApiV1MutesResponse> muteTarget({
    @Body() required MuteTargetDto body,
  });

  @DELETE('/api/v1/mutes/{targetType}/{targetId}')
  Future<DeleteApiV1MutesTargetTypeTargetIdResponse> unmuteTarget({
    @Path('targetType') required TargetType targetType,
    @Path('targetId') required String targetId,
  });

  @POST('/api/v1/reports')
  Future<PostApiV1ReportsResponse> submitReport({
    @Body() required CreateReportDto body,
  });

  @GET('/api/v1/me/reports')
  Future<GetApiV1MeReportsResponse> listMyReports({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });
}
