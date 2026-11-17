// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_learning_categories_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminLearningCategoriesIdResponse
_$PatchApiV1AdminLearningCategoriesIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminLearningCategoriesIdResponse(
  data: AdminCategoryDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminLearningCategoriesIdResponseToJson(
  PatchApiV1AdminLearningCategoriesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
