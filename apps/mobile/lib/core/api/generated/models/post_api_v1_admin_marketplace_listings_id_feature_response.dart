// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_listing_dto.dart';

part 'post_api_v1_admin_marketplace_listings_id_feature_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMarketplaceListingsIdFeatureResponse {
  const PostApiV1AdminMarketplaceListingsIdFeatureResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminMarketplaceListingsIdFeatureResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminMarketplaceListingsIdFeatureResponseFromJson(json);
  
  final AdminListingDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminMarketplaceListingsIdFeatureResponseToJson(this);
}
