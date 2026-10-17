// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'county_match_dto.dart';

part 'get_api_v1_locations_counties_match_response.g.dart';

@JsonSerializable()
class GetApiV1LocationsCountiesMatchResponse {
  const GetApiV1LocationsCountiesMatchResponse({required this.data, this.meta});

  factory GetApiV1LocationsCountiesMatchResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1LocationsCountiesMatchResponseFromJson(json);

  final CountyMatchDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1LocationsCountiesMatchResponseToJson(this);
}
