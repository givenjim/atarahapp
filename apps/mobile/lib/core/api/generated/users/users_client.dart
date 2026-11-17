// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_me_preferences_response.dart';
import '../models/get_api_v1_me_security_response.dart';
import '../models/get_api_v1_users_me_response.dart';
import '../models/patch_api_v1_me_preferences_response.dart';
import '../models/put_api_v1_me_device_response.dart';
import '../models/register_session_device_dto.dart';
import '../models/update_account_preferences_dto.dart';

part 'users_client.g.dart';

@RestApi()
abstract class UsersClient {
  factory UsersClient(Dio dio, {String? baseUrl}) = _UsersClient;

  @GET('/api/v1/users/me')
  Future<GetApiV1UsersMeResponse> currentUser();

  @GET('/api/v1/me/preferences')
  Future<GetApiV1MePreferencesResponse> getPreferences();

  @PATCH('/api/v1/me/preferences')
  Future<PatchApiV1MePreferencesResponse> updatePreferences({
    @Body() required UpdateAccountPreferencesDto body,
  });

  @GET('/api/v1/me/security')
  Future<GetApiV1MeSecurityResponse> securityOverview();

  @PUT('/api/v1/me/device')
  Future<PutApiV1MeDeviceResponse> registerDevice({
    @Body() required RegisterSessionDeviceDto body,
  });
}
