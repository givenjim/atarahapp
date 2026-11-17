// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_card_dto.dart';

part 'get_api_v1_learning_categories_slug_response.g.dart';

@JsonSerializable()
class GetApiV1LearningCategoriesSlugResponse {
  const GetApiV1LearningCategoriesSlugResponse({required this.data, this.meta});

  factory GetApiV1LearningCategoriesSlugResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1LearningCategoriesSlugResponseFromJson(json);

  final List<LearningCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1LearningCategoriesSlugResponseToJson(this);
}
