// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_taxonomy_kind_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminTaxonomyKindResponse _$GetApiV1AdminTaxonomyKindResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminTaxonomyKindResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminTaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminTaxonomyKindResponseToJson(
  GetApiV1AdminTaxonomyKindResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
