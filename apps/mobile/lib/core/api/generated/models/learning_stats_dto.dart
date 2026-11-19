// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'learning_stats_dto.g.dart';

@JsonSerializable()
class LearningStatsDto {
  const LearningStatsDto({
    required this.inProgress,
    required this.completed,
    required this.minutesThisMonth,
    required this.hoursThisMonth,
  });
  
  factory LearningStatsDto.fromJson(Map<String, Object?> json) => _$LearningStatsDtoFromJson(json);
  
  final num inProgress;
  final num completed;
  final num minutesThisMonth;

  /// minutesThisMonth as hours with one decimal.
  final num hoursThisMonth;

  Map<String, Object?> toJson() => _$LearningStatsDtoToJson(this);
}
