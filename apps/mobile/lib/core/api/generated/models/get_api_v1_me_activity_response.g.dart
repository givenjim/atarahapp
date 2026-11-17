// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_activity_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeActivityResponse _$GetApiV1MeActivityResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeActivityResponse(
  data: ActivityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeActivityResponseToJson(
  GetApiV1MeActivityResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
