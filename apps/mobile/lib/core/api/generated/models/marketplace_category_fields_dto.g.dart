// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_category_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceCategoryFieldsDto _$MarketplaceCategoryFieldsDtoFromJson(
  Map<String, dynamic> json,
) => MarketplaceCategoryFieldsDto(
  name: json['name'] as String,
  icon: json['icon'] as String,
  tone: MarketplaceCategoryFieldsDtoTone.fromJson(json['tone'] as String),
  sortOrder: json['sortOrder'] as num?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$MarketplaceCategoryFieldsDtoToJson(
  MarketplaceCategoryFieldsDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'icon': instance.icon,
  'tone': instance.tone,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};
