// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_seller_dto.dart';

part 'get_api_v1_admin_marketplace_sellers_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMarketplaceSellersIdResponse {
  const GetApiV1AdminMarketplaceSellersIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMarketplaceSellersIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMarketplaceSellersIdResponseFromJson(json);
  
  final AdminSellerDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMarketplaceSellersIdResponseToJson(this);
}
