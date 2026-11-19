// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) => CategoryDto(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  tone: json['tone'] as String,
  count: json['count'] as num,
);

Map<String, dynamic> _$CategoryDtoToJson(CategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'icon': instance.icon,
      'tone': instance.tone,
      'count': instance.count,
    };
