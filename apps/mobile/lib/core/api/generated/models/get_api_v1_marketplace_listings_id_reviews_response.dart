// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_review_dto.dart';

part 'get_api_v1_marketplace_listings_id_reviews_response.g.dart';

@JsonSerializable()
class GetApiV1MarketplaceListingsIdReviewsResponse {
  const GetApiV1MarketplaceListingsIdReviewsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MarketplaceListingsIdReviewsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MarketplaceListingsIdReviewsResponseFromJson(json);
  
  final List<ListingReviewDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MarketplaceListingsIdReviewsResponseToJson(this);
}
