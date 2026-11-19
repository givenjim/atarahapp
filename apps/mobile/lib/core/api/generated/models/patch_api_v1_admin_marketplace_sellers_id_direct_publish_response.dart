// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_seller_dto.dart';

part 'patch_api_v1_admin_marketplace_sellers_id_direct_publish_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminMarketplaceSellersIdDirectPublishResponse {
  const PatchApiV1AdminMarketplaceSellersIdDirectPublishResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1AdminMarketplaceSellersIdDirectPublishResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1AdminMarketplaceSellersIdDirectPublishResponseFromJson(json);
  
  final AdminSellerDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminMarketplaceSellersIdDirectPublishResponseToJson(this);
}
