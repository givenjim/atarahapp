// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_taxonomy_interests_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1TaxonomyInterestsResponse _$GetApiV1TaxonomyInterestsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1TaxonomyInterestsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => TaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1TaxonomyInterestsResponseToJson(
  GetApiV1TaxonomyInterestsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
