// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_marketplace_categories_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMarketplaceCategoriesResponse
_$GetApiV1AdminMarketplaceCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminMarketplaceCategoriesResponse(
  data: (json['data'] as List<dynamic>)
      .map(
        (e) => AdminMarketplaceCategoryDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminMarketplaceCategoriesResponseToJson(
  GetApiV1AdminMarketplaceCategoriesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
