// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'seller_card_dto.dart';

part 'get_api_v1_marketplace_sellers_response.g.dart';

@JsonSerializable()
class GetApiV1MarketplaceSellersResponse {
  const GetApiV1MarketplaceSellersResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MarketplaceSellersResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MarketplaceSellersResponseFromJson(json);
  
  final List<SellerCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MarketplaceSellersResponseToJson(this);
}
