// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_taxonomy_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaxonomyItemDto _$AdminTaxonomyItemDtoFromJson(
  Map<String, dynamic> json,
) => AdminTaxonomyItemDto(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String?,
  disciplineId: json['disciplineId'] as String?,
  disciplineName: json['disciplineName'] as String?,
  sortOrder: json['sortOrder'] as num,
  isActive: json['isActive'] as bool,
  usage: json['usage'] as num,
);

Map<String, dynamic> _$AdminTaxonomyItemDtoToJson(
  AdminTaxonomyItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'icon': instance.icon,
  'disciplineId': instance.disciplineId,
  'disciplineName': instance.disciplineName,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'usage': instance.usage,
};
