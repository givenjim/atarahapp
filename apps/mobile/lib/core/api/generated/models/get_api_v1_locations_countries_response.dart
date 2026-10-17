// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'country_dto.dart';

part 'get_api_v1_locations_countries_response.g.dart';

@JsonSerializable()
class GetApiV1LocationsCountriesResponse {
  const GetApiV1LocationsCountriesResponse({required this.data, this.meta});

  factory GetApiV1LocationsCountriesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1LocationsCountriesResponseFromJson(json);

  final List<CountryDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1LocationsCountriesResponseToJson(this);
}
