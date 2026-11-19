// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_content_type.dart';

part 'learning_analytics_row_dto.g.dart';

@JsonSerializable()
class LearningAnalyticsRowDto {
  const LearningAnalyticsRowDto({
    required this.contentId,
    required this.title,
    required this.type,
    required this.starts,
    required this.completions,
    required this.completionRate,
  });
  
  factory LearningAnalyticsRowDto.fromJson(Map<String, Object?> json) => _$LearningAnalyticsRowDtoFromJson(json);
  
  final String contentId;
  final String title;
  final LearningContentType type;
  final num starts;
  final num completions;

  /// completions over starts, 0 to 100.
  final num completionRate;

  Map<String, Object?> toJson() => _$LearningAnalyticsRowDtoToJson(this);
}
