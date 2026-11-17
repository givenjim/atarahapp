// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_learning_item_dto.dart';

part 'get_api_v1_me_learning_response.g.dart';

@JsonSerializable()
class GetApiV1MeLearningResponse {
  const GetApiV1MeLearningResponse({required this.data, this.meta});

  factory GetApiV1MeLearningResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeLearningResponseFromJson(json);

  final List<MyLearningItemDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeLearningResponseToJson(this);
}
