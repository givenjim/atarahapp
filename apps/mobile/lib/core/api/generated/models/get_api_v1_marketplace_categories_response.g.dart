// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_categories_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceCategoriesResponse
_$GetApiV1MarketplaceCategoriesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MarketplaceCategoriesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MarketplaceCategoriesResponseToJson(
  GetApiV1MarketplaceCategoriesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
