// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_listing_dto.dart';

part 'get_api_v1_admin_marketplace_listings_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMarketplaceListingsResponse {
  const GetApiV1AdminMarketplaceListingsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMarketplaceListingsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMarketplaceListingsResponseFromJson(json);
  
  final List<AdminListingDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMarketplaceListingsResponseToJson(this);
}
