// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hub_category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HubCategoryDto _$HubCategoryDtoFromJson(Map<String, dynamic> json) =>
    HubCategoryDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      group: LearningCategoryGroup.fromJson(json['group'] as String),
      count: json['count'] as num,
    );

Map<String, dynamic> _$HubCategoryDtoToJson(HubCategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'group': instance.group,
      'count': instance.count,
    };
