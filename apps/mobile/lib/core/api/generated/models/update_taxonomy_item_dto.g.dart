// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_taxonomy_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTaxonomyItemDto _$UpdateTaxonomyItemDtoFromJson(
  Map<String, dynamic> json,
) => UpdateTaxonomyItemDto(
  name: json['name'] as String?,
  icon: json['icon'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UpdateTaxonomyItemDtoToJson(
  UpdateTaxonomyItemDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'icon': instance.icon,
  'isActive': instance.isActive,
};
