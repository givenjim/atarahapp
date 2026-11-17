// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_detail_dto.dart';

part 'get_api_v1_learning_id_response.g.dart';

@JsonSerializable()
class GetApiV1LearningIdResponse {
  const GetApiV1LearningIdResponse({required this.data, this.meta});

  factory GetApiV1LearningIdResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1LearningIdResponseFromJson(json);

  final LearningDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1LearningIdResponseToJson(this);
}
