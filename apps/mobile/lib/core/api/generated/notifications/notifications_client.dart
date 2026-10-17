// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_notifications_preferences_response.dart';
import '../models/post_api_v1_devices_response.dart';
import '../models/put_api_v1_notifications_preferences_response.dart';
import '../models/register_device_dto.dart';
import '../models/update_preferences_dto.dart';

part 'notifications_client.g.dart';

@RestApi()
abstract class NotificationsClient {
  factory NotificationsClient(Dio dio, {String? baseUrl}) =
      _NotificationsClient;

  @GET('/api/v1/notifications/preferences')
  Future<GetApiV1NotificationsPreferencesResponse> preferences();

  @PUT('/api/v1/notifications/preferences')
  Future<PutApiV1NotificationsPreferencesResponse> updatePreferences({
    @Body() required UpdatePreferencesDto body,
  });

  @POST('/api/v1/devices')
  Future<PostApiV1DevicesResponse> registerDevice({
    @Body() required RegisterDeviceDto body,
  });

  @DELETE('/api/v1/devices/{id}')
  Future<void> removeDevice({@Path('id') required String id});
}
