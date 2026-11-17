// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_learning_categories_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminLearningCategoriesResponse
_$PostApiV1AdminLearningCategoriesResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminLearningCategoriesResponse(
      data: AdminCategoryDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminLearningCategoriesResponseToJson(
  PostApiV1AdminLearningCategoriesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
