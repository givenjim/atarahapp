// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryFieldsDto _$CategoryFieldsDtoFromJson(Map<String, dynamic> json) =>
    CategoryFieldsDto(
      name: json['name'] as String,
      group: LearningCategoryGroup.fromJson(json['group'] as String),
      sortOrder: json['sortOrder'] as num?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$CategoryFieldsDtoToJson(CategoryFieldsDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'group': instance.group,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
