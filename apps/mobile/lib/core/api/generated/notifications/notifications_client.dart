// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_api_v1_notifications_preferences_response.dart';
import '../models/get_api_v1_notifications_response.dart';
import '../models/get_api_v1_notifications_unread_count_response.dart';
import '../models/mark_all_read_dto.dart';
import '../models/notification_category.dart';
import '../models/post_api_v1_devices_response.dart';
import '../models/post_api_v1_notifications_id_read_response.dart';
import '../models/post_api_v1_notifications_read_all_response.dart';
import '../models/put_api_v1_notifications_preferences_response.dart';
import '../models/register_device_dto.dart';
import '../models/update_preferences_dto.dart';

part 'notifications_client.g.dart';

@RestApi()
abstract class NotificationsClient {
  factory NotificationsClient(Dio dio, {String? baseUrl}) =
      _NotificationsClient;

  /// [unreadOnly] - Only the ones not read yet.
  @GET('/api/v1/notifications')
  Future<GetApiV1NotificationsResponse> list({
    @Query('category') NotificationCategory? category,
    @Query('unreadOnly') bool? unreadOnly,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @GET('/api/v1/notifications/unread-count')
  Future<GetApiV1NotificationsUnreadCountResponse> unreadCount();

  @POST('/api/v1/notifications/read-all')
  Future<PostApiV1NotificationsReadAllResponse> readAll({
    @Body() required MarkAllReadDto body,
  });

  @POST('/api/v1/notifications/{id}/read')
  Future<PostApiV1NotificationsIdReadResponse> markRead({
    @Path('id') required String id,
  });

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
