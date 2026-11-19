// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'seller_terms_dto.dart';

part 'get_api_v1_marketplace_seller_terms_response.g.dart';

@JsonSerializable()
class GetApiV1MarketplaceSellerTermsResponse {
  const GetApiV1MarketplaceSellerTermsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MarketplaceSellerTermsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MarketplaceSellerTermsResponseFromJson(json);
  
  final SellerTermsDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MarketplaceSellerTermsResponseToJson(this);
}
