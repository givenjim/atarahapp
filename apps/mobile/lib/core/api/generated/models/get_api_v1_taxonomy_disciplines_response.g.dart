// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_taxonomy_disciplines_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1TaxonomyDisciplinesResponse
_$GetApiV1TaxonomyDisciplinesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1TaxonomyDisciplinesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => DisciplineDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1TaxonomyDisciplinesResponseToJson(
  GetApiV1TaxonomyDisciplinesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
