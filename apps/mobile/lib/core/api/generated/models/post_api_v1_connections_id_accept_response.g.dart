// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_connections_id_accept_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1ConnectionsIdAcceptResponse
_$PostApiV1ConnectionsIdAcceptResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1ConnectionsIdAcceptResponse(
      data: ConnectionStateDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1ConnectionsIdAcceptResponseToJson(
  PostApiV1ConnectionsIdAcceptResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
