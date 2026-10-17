// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'county_dto.dart';

part 'county_match_dto.g.dart';

@JsonSerializable()
class CountyMatchDto {
  const CountyMatchDto({required this.county, required this.countryId});

  factory CountyMatchDto.fromJson(Map<String, Object?> json) =>
      _$CountyMatchDtoFromJson(json);

  final CountyDto? county;
  final String? countryId;

  Map<String, Object?> toJson() => _$CountyMatchDtoToJson(this);
}
