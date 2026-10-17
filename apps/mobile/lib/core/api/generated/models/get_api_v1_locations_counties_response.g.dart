// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_locations_counties_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LocationsCountiesResponse _$GetApiV1LocationsCountiesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LocationsCountiesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CountyDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LocationsCountiesResponseToJson(
  GetApiV1LocationsCountiesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
