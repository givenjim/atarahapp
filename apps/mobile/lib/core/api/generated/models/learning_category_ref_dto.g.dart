// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_category_ref_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningCategoryRefDto _$LearningCategoryRefDtoFromJson(
  Map<String, dynamic> json,
) => LearningCategoryRefDto(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  group: LearningCategoryGroup.fromJson(json['group'] as String),
);

Map<String, dynamic> _$LearningCategoryRefDtoToJson(
  LearningCategoryRefDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'group': instance.group,
};
