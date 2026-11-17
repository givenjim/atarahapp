// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_security_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeSecurityResponse _$GetApiV1MeSecurityResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeSecurityResponse(
  data: SecurityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeSecurityResponseToJson(
  GetApiV1MeSecurityResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
