// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_analytics_row_dto.dart';

part 'learning_analytics_dto.g.dart';

@JsonSerializable()
class LearningAnalyticsDto {
  const LearningAnalyticsDto({
    required this.publishedItems,
    required this.totalStarts,
    required this.totalCompletions,
    required this.certificatesIssued,
    required this.items,
  });

  factory LearningAnalyticsDto.fromJson(Map<String, Object?> json) =>
      _$LearningAnalyticsDtoFromJson(json);

  final num publishedItems;
  final num totalStarts;
  final num totalCompletions;
  final num certificatesIssued;
  final List<LearningAnalyticsRowDto> items;

  Map<String, Object?> toJson() => _$LearningAnalyticsDtoToJson(this);
}
