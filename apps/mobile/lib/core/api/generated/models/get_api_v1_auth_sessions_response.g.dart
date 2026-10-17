// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_auth_sessions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AuthSessionsResponse _$GetApiV1AuthSessionsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AuthSessionsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => SessionViewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AuthSessionsResponseToJson(
  GetApiV1AuthSessionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
