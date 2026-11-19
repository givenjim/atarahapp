// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_category_dto.dart';

part 'patch_api_v1_admin_learning_categories_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminLearningCategoriesIdResponse {
  const PatchApiV1AdminLearningCategoriesIdResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1AdminLearningCategoriesIdResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1AdminLearningCategoriesIdResponseFromJson(json);
  
  final AdminCategoryDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminLearningCategoriesIdResponseToJson(this);
}
