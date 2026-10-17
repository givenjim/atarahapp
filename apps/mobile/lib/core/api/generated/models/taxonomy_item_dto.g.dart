// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxonomyItemDto _$TaxonomyItemDtoFromJson(Map<String, dynamic> json) =>
    TaxonomyItemDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$TaxonomyItemDtoToJson(TaxonomyItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
    };
