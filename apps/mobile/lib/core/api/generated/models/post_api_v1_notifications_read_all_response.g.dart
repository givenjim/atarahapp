// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_notifications_read_all_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1NotificationsReadAllResponse
_$PostApiV1NotificationsReadAllResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1NotificationsReadAllResponse(
      data: MarkedReadDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1NotificationsReadAllResponseToJson(
  PostApiV1NotificationsReadAllResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
