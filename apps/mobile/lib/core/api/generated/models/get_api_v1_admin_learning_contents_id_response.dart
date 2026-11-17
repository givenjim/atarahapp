// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_content_dto.dart';

part 'get_api_v1_admin_learning_contents_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminLearningContentsIdResponse {
  const GetApiV1AdminLearningContentsIdResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1AdminLearningContentsIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminLearningContentsIdResponseFromJson(json);

  final AdminContentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminLearningContentsIdResponseToJson(this);
}
