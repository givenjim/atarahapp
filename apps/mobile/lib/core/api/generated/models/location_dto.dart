// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'location_dto.g.dart';

@JsonSerializable()
class LocationDto {
  const LocationDto({
    required this.countryName,
    required this.countyName,
    required this.town,
  });

  factory LocationDto.fromJson(Map<String, Object?> json) =>
      _$LocationDtoFromJson(json);

  final String? countryName;
  final String? countyName;
  final String? town;

  Map<String, Object?> toJson() => _$LocationDtoToJson(this);
}
