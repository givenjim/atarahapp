// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_hub_dto.dart';

part 'get_api_v1_learning_response.g.dart';

@JsonSerializable()
class GetApiV1LearningResponse {
  const GetApiV1LearningResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1LearningResponse.fromJson(Map<String, Object?> json) => _$GetApiV1LearningResponseFromJson(json);
  
  final LearningHubDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1LearningResponseToJson(this);
}
