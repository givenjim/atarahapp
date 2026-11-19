// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_seller_dto.dart';

part 'post_api_v1_admin_marketplace_sellers_id_reinstate_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMarketplaceSellersIdReinstateResponse {
  const PostApiV1AdminMarketplaceSellersIdReinstateResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminMarketplaceSellersIdReinstateResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminMarketplaceSellersIdReinstateResponseFromJson(json);
  
  final AdminSellerDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminMarketplaceSellersIdReinstateResponseToJson(this);
}
