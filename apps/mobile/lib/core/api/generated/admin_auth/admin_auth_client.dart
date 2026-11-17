// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_admin_auth_me_response.dart';

part 'admin_auth_client.g.dart';

@RestApi()
abstract class AdminAuthClient {
  factory AdminAuthClient(Dio dio, {String? baseUrl}) = _AdminAuthClient;

  @GET('/api/v1/admin/auth/me')
  Future<GetApiV1AdminAuthMeResponse> adminMe();
}
