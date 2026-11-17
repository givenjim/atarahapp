// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_admin_feature_flags_response.dart';
import '../models/get_api_v1_admin_settings_response.dart';
import '../models/patch_api_v1_admin_feature_flags_key_response.dart';
import '../models/put_api_v1_admin_settings_key_response.dart';
import '../models/set_flag_dto.dart';
import '../models/set_setting_dto.dart';

part 'admin_platform_client.g.dart';

@RestApi()
abstract class AdminPlatformClient {
  factory AdminPlatformClient(Dio dio, {String? baseUrl}) =
      _AdminPlatformClient;

  @GET('/api/v1/admin/feature-flags')
  Future<GetApiV1AdminFeatureFlagsResponse> listFlags();

  @PATCH('/api/v1/admin/feature-flags/{key}')
  Future<PatchApiV1AdminFeatureFlagsKeyResponse> setFlag({
    @Path('key') required String key,
    @Body() required SetFlagDto body,
  });

  @GET('/api/v1/admin/settings')
  Future<GetApiV1AdminSettingsResponse> listSettings();

  @PUT('/api/v1/admin/settings/{key}')
  Future<PutApiV1AdminSettingsKeyResponse> setSetting({
    @Path('key') required String key,
    @Body() required SetSettingDto body,
  });
}
