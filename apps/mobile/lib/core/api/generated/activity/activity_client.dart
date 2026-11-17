// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_me_activity_response.dart';
import '../models/get_api_v1_me_applications_response.dart';

part 'activity_client.g.dart';

@RestApi()
abstract class ActivityClient {
  factory ActivityClient(Dio dio, {String? baseUrl}) = _ActivityClient;

  @GET('/api/v1/me/activity')
  Future<GetApiV1MeActivityResponse> hub();

  @GET('/api/v1/me/applications')
  Future<GetApiV1MeApplicationsResponse> applications({
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });
}
