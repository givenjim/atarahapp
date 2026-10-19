// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_growth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeGrowthResponse _$GetApiV1MeGrowthResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeGrowthResponse(
  data: GrowthDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeGrowthResponseToJson(
  GetApiV1MeGrowthResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
