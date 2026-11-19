// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_seller_dto.dart';

part 'get_api_v1_admin_marketplace_sellers_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMarketplaceSellersResponse {
  const GetApiV1AdminMarketplaceSellersResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMarketplaceSellersResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMarketplaceSellersResponseFromJson(json);
  
  final List<AdminSellerDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMarketplaceSellersResponseToJson(this);
}
