// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesResponse _$GetApiV1CreativesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1CreativesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CreativeCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1CreativesResponseToJson(
  GetApiV1CreativesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
