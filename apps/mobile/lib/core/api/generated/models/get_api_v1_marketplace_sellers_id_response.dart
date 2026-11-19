// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'seller_profile_dto.dart';

part 'get_api_v1_marketplace_sellers_id_response.g.dart';

@JsonSerializable()
class GetApiV1MarketplaceSellersIdResponse {
  const GetApiV1MarketplaceSellersIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MarketplaceSellersIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MarketplaceSellersIdResponseFromJson(json);
  
  final SellerProfileDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MarketplaceSellersIdResponseToJson(this);
}
