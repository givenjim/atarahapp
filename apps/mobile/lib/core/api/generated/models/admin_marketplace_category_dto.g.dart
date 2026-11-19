// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_marketplace_category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminMarketplaceCategoryDto _$AdminMarketplaceCategoryDtoFromJson(
  Map<String, dynamic> json,
) => AdminMarketplaceCategoryDto(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  tone: json['tone'] as String,
  count: json['count'] as num,
  sortOrder: json['sortOrder'] as num,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$AdminMarketplaceCategoryDtoToJson(
  AdminMarketplaceCategoryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'icon': instance.icon,
  'tone': instance.tone,
  'count': instance.count,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};
