// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_listing_dto.dart';

part 'get_api_v1_admin_marketplace_listings_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMarketplaceListingsIdResponse {
  const GetApiV1AdminMarketplaceListingsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMarketplaceListingsIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMarketplaceListingsIdResponseFromJson(json);
  
  final AdminListingDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMarketplaceListingsIdResponseToJson(this);
}
