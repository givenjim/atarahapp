// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_users_me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1UsersMeResponse _$GetApiV1UsersMeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1UsersMeResponse(
  data: MeDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1UsersMeResponseToJson(
  GetApiV1UsersMeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
