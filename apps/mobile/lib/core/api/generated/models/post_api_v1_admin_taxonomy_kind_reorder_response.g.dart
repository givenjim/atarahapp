// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_taxonomy_kind_reorder_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminTaxonomyKindReorderResponse
_$PostApiV1AdminTaxonomyKindReorderResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminTaxonomyKindReorderResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminTaxonomyItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminTaxonomyKindReorderResponseToJson(
  PostApiV1AdminTaxonomyKindReorderResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
