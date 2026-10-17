// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_taxonomy_development_areas_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1TaxonomyDevelopmentAreasResponse
_$GetApiV1TaxonomyDevelopmentAreasResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1TaxonomyDevelopmentAreasResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1TaxonomyDevelopmentAreasResponseToJson(
  GetApiV1TaxonomyDevelopmentAreasResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
