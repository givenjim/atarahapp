// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_admin_home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1AdminHomeResponse _$PutApiV1AdminHomeResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1AdminHomeResponse(
  data: HomeConfigDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1AdminHomeResponseToJson(
  PutApiV1AdminHomeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
