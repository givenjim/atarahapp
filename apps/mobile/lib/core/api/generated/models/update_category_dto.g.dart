// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCategoryDto _$UpdateCategoryDtoFromJson(Map<String, dynamic> json) =>
    UpdateCategoryDto(
      name: json['name'] as String,
      group: LearningCategoryGroup.fromJson(json['group'] as String),
      sortOrder: json['sortOrder'] as num,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$UpdateCategoryDtoToJson(UpdateCategoryDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'group': instance.group,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
