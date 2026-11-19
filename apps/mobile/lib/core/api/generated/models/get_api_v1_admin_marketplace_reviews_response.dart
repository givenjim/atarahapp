// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_review_dto.dart';

part 'get_api_v1_admin_marketplace_reviews_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMarketplaceReviewsResponse {
  const GetApiV1AdminMarketplaceReviewsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMarketplaceReviewsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMarketplaceReviewsResponseFromJson(json);
  
  final List<AdminReviewDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMarketplaceReviewsResponseToJson(this);
}
