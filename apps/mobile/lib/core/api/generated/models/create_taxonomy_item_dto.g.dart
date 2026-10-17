// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_taxonomy_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTaxonomyItemDto _$CreateTaxonomyItemDtoFromJson(
  Map<String, dynamic> json,
) => CreateTaxonomyItemDto(
  name: json['name'] as String,
  icon: json['icon'] as String?,
  disciplineId: json['disciplineId'] as String?,
);

Map<String, dynamic> _$CreateTaxonomyItemDtoToJson(
  CreateTaxonomyItemDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'icon': instance.icon,
  'disciplineId': instance.disciplineId,
};
