// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'plan_row_dto.g.dart';

@JsonSerializable()
class PlanRowDto {
  const PlanRowDto({
    required this.label,
    required this.free,
    required this.pro,
  });
  
  factory PlanRowDto.fromJson(Map<String, Object?> json) => _$PlanRowDtoFromJson(json);
  
  final String label;

  /// Included in the Free plan.
  final bool free;

  /// Included in Pro.
  final bool pro;

  Map<String, Object?> toJson() => _$PlanRowDtoToJson(this);
}
