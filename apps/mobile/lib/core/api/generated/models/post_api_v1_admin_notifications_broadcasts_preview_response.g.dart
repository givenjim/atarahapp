// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_notifications_broadcasts_preview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminNotificationsBroadcastsPreviewResponse
_$PostApiV1AdminNotificationsBroadcastsPreviewResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminNotificationsBroadcastsPreviewResponse(
  data: AudiencePreviewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminNotificationsBroadcastsPreviewResponseToJson(
  PostApiV1AdminNotificationsBroadcastsPreviewResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
