// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_learning_categories_slug_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LearningCategoriesSlugResponse
_$GetApiV1LearningCategoriesSlugResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1LearningCategoriesSlugResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => LearningCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1LearningCategoriesSlugResponseToJson(
  GetApiV1LearningCategoriesSlugResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
