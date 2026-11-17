// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_learning_categories_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminLearningCategoriesResponse
_$GetApiV1AdminLearningCategoriesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminLearningCategoriesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminLearningCategoriesResponseToJson(
  GetApiV1AdminLearningCategoriesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
