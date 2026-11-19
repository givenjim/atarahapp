// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_listings_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceListingsIdResponse
_$GetApiV1MarketplaceListingsIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MarketplaceListingsIdResponse(
      data: ListingDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MarketplaceListingsIdResponseToJson(
  GetApiV1MarketplaceListingsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
