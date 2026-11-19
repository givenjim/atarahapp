// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_marketplace_category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMarketplaceCategoryDto _$UpdateMarketplaceCategoryDtoFromJson(
  Map<String, dynamic> json,
) => UpdateMarketplaceCategoryDto(
  name: json['name'] as String?,
  icon: json['icon'] as String?,
  tone: json['tone'] == null
      ? null
      : UpdateMarketplaceCategoryDtoTone.fromJson(json['tone'] as String),
  sortOrder: json['sortOrder'] as num?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UpdateMarketplaceCategoryDtoToJson(
  UpdateMarketplaceCategoryDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'icon': instance.icon,
  'tone': instance.tone,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};
