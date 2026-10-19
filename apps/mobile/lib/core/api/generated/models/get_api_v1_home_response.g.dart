// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1HomeResponse _$GetApiV1HomeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1HomeResponse(
  data: HomeDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1HomeResponseToJson(
  GetApiV1HomeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
