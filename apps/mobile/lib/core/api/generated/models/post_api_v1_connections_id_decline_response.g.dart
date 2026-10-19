// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_connections_id_decline_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1ConnectionsIdDeclineResponse
_$PostApiV1ConnectionsIdDeclineResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1ConnectionsIdDeclineResponse(
      data: ConnectionStateDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1ConnectionsIdDeclineResponseToJson(
  PostApiV1ConnectionsIdDeclineResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
