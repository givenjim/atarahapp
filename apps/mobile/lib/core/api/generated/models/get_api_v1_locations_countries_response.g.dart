// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_locations_countries_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LocationsCountriesResponse _$GetApiV1LocationsCountriesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1LocationsCountriesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => CountryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1LocationsCountriesResponseToJson(
  GetApiV1LocationsCountriesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
