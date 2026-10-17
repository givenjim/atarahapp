// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_taxonomy_kind_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminTaxonomyKindIdResponse
_$PatchApiV1AdminTaxonomyKindIdResponseFromJson(Map<String, dynamic> json) =>
    PatchApiV1AdminTaxonomyKindIdResponse(
      data: AdminTaxonomyItemDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PatchApiV1AdminTaxonomyKindIdResponseToJson(
  PatchApiV1AdminTaxonomyKindIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
