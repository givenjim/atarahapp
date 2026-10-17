// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_auth_me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminAuthMeResponse _$GetApiV1AdminAuthMeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminAuthMeResponse(
  data: AdminMeDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminAuthMeResponseToJson(
  GetApiV1AdminAuthMeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
