// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'country_dto.g.dart';

@JsonSerializable()
class CountryDto {
  const CountryDto({
    required this.id,
    required this.isoCode,
    required this.name,
    required this.callingCode,
  });

  factory CountryDto.fromJson(Map<String, Object?> json) =>
      _$CountryDtoFromJson(json);

  final String id;
  final String isoCode;
  final String name;
  final String callingCode;

  Map<String, Object?> toJson() => _$CountryDtoToJson(this);
}
