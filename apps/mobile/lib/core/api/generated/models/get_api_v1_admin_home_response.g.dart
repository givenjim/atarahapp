// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminHomeResponse _$GetApiV1AdminHomeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminHomeResponse(
  data: HomeConfigDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminHomeResponseToJson(
  GetApiV1AdminHomeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
