// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'county_dto.dart';

part 'get_api_v1_locations_counties_response.g.dart';

@JsonSerializable()
class GetApiV1LocationsCountiesResponse {
  const GetApiV1LocationsCountiesResponse({required this.data, this.meta});

  factory GetApiV1LocationsCountiesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1LocationsCountiesResponseFromJson(json);

  final List<CountyDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1LocationsCountiesResponseToJson(this);
}
