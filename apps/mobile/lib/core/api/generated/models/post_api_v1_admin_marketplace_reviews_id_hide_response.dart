// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_review_dto.dart';

part 'post_api_v1_admin_marketplace_reviews_id_hide_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMarketplaceReviewsIdHideResponse {
  const PostApiV1AdminMarketplaceReviewsIdHideResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminMarketplaceReviewsIdHideResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminMarketplaceReviewsIdHideResponseFromJson(json);
  
  final AdminReviewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminMarketplaceReviewsIdHideResponseToJson(this);
}
