// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_marketplace_categories_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminMarketplaceCategoriesIdResponse
_$PatchApiV1AdminMarketplaceCategoriesIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminMarketplaceCategoriesIdResponse(
  data: AdminMarketplaceCategoryDto.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminMarketplaceCategoriesIdResponseToJson(
  PatchApiV1AdminMarketplaceCategoriesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
