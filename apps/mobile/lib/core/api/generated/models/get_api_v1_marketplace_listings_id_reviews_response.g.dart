// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_listings_id_reviews_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceListingsIdReviewsResponse
_$GetApiV1MarketplaceListingsIdReviewsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MarketplaceListingsIdReviewsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ListingReviewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MarketplaceListingsIdReviewsResponseToJson(
  GetApiV1MarketplaceListingsIdReviewsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
