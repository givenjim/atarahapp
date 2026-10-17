// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_taxonomy_skills_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1TaxonomySkillsResponse _$GetApiV1TaxonomySkillsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1TaxonomySkillsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1TaxonomySkillsResponseToJson(
  GetApiV1TaxonomySkillsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
