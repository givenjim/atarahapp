// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_notifications_id_read_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1NotificationsIdReadResponse
_$PostApiV1NotificationsIdReadResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1NotificationsIdReadResponse(
      data: UnreadDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1NotificationsIdReadResponseToJson(
  PostApiV1NotificationsIdReadResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
