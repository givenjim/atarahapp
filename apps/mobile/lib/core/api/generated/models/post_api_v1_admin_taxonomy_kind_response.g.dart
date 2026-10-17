// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_taxonomy_kind_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminTaxonomyKindResponse _$PostApiV1AdminTaxonomyKindResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminTaxonomyKindResponse(
  data: AdminTaxonomyItemDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminTaxonomyKindResponseToJson(
  PostApiV1AdminTaxonomyKindResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
