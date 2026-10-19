// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_connections_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeConnectionsResponse _$GetApiV1MeConnectionsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeConnectionsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ConnectionListItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeConnectionsResponseToJson(
  GetApiV1MeConnectionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
