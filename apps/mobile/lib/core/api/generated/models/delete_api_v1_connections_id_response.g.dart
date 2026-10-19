// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_connections_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1ConnectionsIdResponse _$DeleteApiV1ConnectionsIdResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1ConnectionsIdResponse(
  data: ConnectionStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$DeleteApiV1ConnectionsIdResponseToJson(
  DeleteApiV1ConnectionsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
