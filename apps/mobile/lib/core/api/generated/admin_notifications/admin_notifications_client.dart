// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/broadcast_fields_dto.dart';
import '../models/broadcast_status.dart';
import '../models/get_api_v1_admin_notifications_broadcasts_id_response.dart';
import '../models/get_api_v1_admin_notifications_broadcasts_response.dart';
import '../models/get_api_v1_admin_privacy_requests_response.dart';
import '../models/kind2.dart';
import '../models/post_api_v1_admin_notifications_broadcasts_id_cancel_response.dart';
import '../models/post_api_v1_admin_notifications_broadcasts_preview_response.dart';
import '../models/post_api_v1_admin_notifications_broadcasts_response.dart';

part 'admin_notifications_client.g.dart';

@RestApi()
abstract class AdminNotificationsClient {
  factory AdminNotificationsClient(Dio dio, {String? baseUrl}) = _AdminNotificationsClient;

  @GET('/api/v1/admin/notifications/broadcasts')
  Future<GetApiV1AdminNotificationsBroadcastsResponse> list({
    @Query('status') BroadcastStatus? status,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });

  @POST('/api/v1/admin/notifications/broadcasts')
  Future<PostApiV1AdminNotificationsBroadcastsResponse> create({
    @Body() required BroadcastFieldsDto body,
  });

  @POST('/api/v1/admin/notifications/broadcasts/preview')
  Future<PostApiV1AdminNotificationsBroadcastsPreviewResponse> preview({
    @Body() required BroadcastFieldsDto body,
  });

  /// null.
  ///
  /// The name has been replaced because it contains a keyword. Original name: `get`.
  @GET('/api/v1/admin/notifications/broadcasts/{id}')
  Future<GetApiV1AdminNotificationsBroadcastsIdResponse> getApiV1AdminNotificationsBroadcastsId({
    @Path('id') required String id,
  });

  @POST('/api/v1/admin/notifications/broadcasts/{id}/cancel')
  Future<PostApiV1AdminNotificationsBroadcastsIdCancelResponse> cancel({
    @Path('id') required String id,
  });

  /// [status] - A status of either kind, e.g. READY, PENDING, PURGED.
  @GET('/api/v1/admin/privacy-requests')
  Future<GetApiV1AdminPrivacyRequestsResponse> privacyRequests({
    @Query('kind') Kind2? kind,
    @Query('status') String? status,
    @Query('page') num? page = 1,
    @Query('limit') num? limit = 20,
  });
}
