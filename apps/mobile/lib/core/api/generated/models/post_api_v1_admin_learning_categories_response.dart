// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_category_dto.dart';

part 'post_api_v1_admin_learning_categories_response.g.dart';

@JsonSerializable()
class PostApiV1AdminLearningCategoriesResponse {
  const PostApiV1AdminLearningCategoriesResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminLearningCategoriesResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminLearningCategoriesResponseFromJson(json);
  
  final AdminCategoryDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminLearningCategoriesResponseToJson(this);
}
