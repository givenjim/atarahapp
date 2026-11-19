// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_stats_dto.dart';

part 'get_api_v1_me_learning_stats_response.g.dart';

@JsonSerializable()
class GetApiV1MeLearningStatsResponse {
  const GetApiV1MeLearningStatsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeLearningStatsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeLearningStatsResponseFromJson(json);
  
  final LearningStatsDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeLearningStatsResponseToJson(this);
}
