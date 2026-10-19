// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'growth_bar_dto.g.dart';

@JsonSerializable()
class GrowthBarDto {
  const GrowthBarDto({
    required this.key,
    required this.label,
    required this.percent,
  });

  factory GrowthBarDto.fromJson(Map<String, Object?> json) =>
      _$GrowthBarDtoFromJson(json);

  final String key;
  final String label;
  final num percent;

  Map<String, Object?> toJson() => _$GrowthBarDtoToJson(this);
}
