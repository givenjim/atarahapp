// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_analytics_dto.dart';

part 'get_api_v1_admin_learning_analytics_response.g.dart';

@JsonSerializable()
class GetApiV1AdminLearningAnalyticsResponse {
  const GetApiV1AdminLearningAnalyticsResponse({required this.data, this.meta});

  factory GetApiV1AdminLearningAnalyticsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminLearningAnalyticsResponseFromJson(json);

  final LearningAnalyticsDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminLearningAnalyticsResponseToJson(this);
}
