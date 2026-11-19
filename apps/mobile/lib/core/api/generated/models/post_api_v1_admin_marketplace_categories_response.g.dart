// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_categories_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceCategoriesResponse
_$PostApiV1AdminMarketplaceCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceCategoriesResponse(
  data: AdminMarketplaceCategoryDto.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMarketplaceCategoriesResponseToJson(
  PostApiV1AdminMarketplaceCategoriesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
