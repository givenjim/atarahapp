// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_card_dto.dart';

part 'get_api_v1_learning_search_response.g.dart';

@JsonSerializable()
class GetApiV1LearningSearchResponse {
  const GetApiV1LearningSearchResponse({required this.data, this.meta});

  factory GetApiV1LearningSearchResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1LearningSearchResponseFromJson(json);

  final List<LearningCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1LearningSearchResponseToJson(this);
}
