// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'county_dto.g.dart';

@JsonSerializable()
class CountyDto {
  const CountyDto({required this.id, required this.code, required this.name});

  factory CountyDto.fromJson(Map<String, Object?> json) =>
      _$CountyDtoFromJson(json);

  final String id;
  final String code;
  final String name;

  Map<String, Object?> toJson() => _$CountyDtoToJson(this);
}
