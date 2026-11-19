// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_listings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceListingsResponse
_$GetApiV1MarketplaceListingsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MarketplaceListingsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ListingCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MarketplaceListingsResponseToJson(
  GetApiV1MarketplaceListingsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
