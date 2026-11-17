// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCategoryDto _$AdminCategoryDtoFromJson(Map<String, dynamic> json) =>
    AdminCategoryDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      group: LearningCategoryGroup.fromJson(json['group'] as String),
      sortOrder: json['sortOrder'] as num,
      isActive: json['isActive'] as bool,
      contentCount: json['contentCount'] as num,
    );

Map<String, dynamic> _$AdminCategoryDtoToJson(AdminCategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'group': instance.group,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'contentCount': instance.contentCount,
    };
