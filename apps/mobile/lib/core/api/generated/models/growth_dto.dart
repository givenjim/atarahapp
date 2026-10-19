// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'growth_bar_dto.dart';
import 'growth_dto_strength.dart';

part 'growth_dto.g.dart';

@JsonSerializable()
class GrowthDto {
  const GrowthDto({
    required this.score,
    required this.strength,
    required this.bars,
  });

  factory GrowthDto.fromJson(Map<String, Object?> json) =>
      _$GrowthDtoFromJson(json);

  final num score;
  final GrowthDtoStrength strength;
  final List<GrowthBarDto> bars;

  Map<String, Object?> toJson() => _$GrowthDtoToJson(this);
}
