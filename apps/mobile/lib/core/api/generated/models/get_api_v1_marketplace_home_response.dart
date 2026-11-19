// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'marketplace_home_dto.dart';

part 'get_api_v1_marketplace_home_response.g.dart';

@JsonSerializable()
class GetApiV1MarketplaceHomeResponse {
  const GetApiV1MarketplaceHomeResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MarketplaceHomeResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MarketplaceHomeResponseFromJson(json);
  
  final MarketplaceHomeDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MarketplaceHomeResponseToJson(this);
}
