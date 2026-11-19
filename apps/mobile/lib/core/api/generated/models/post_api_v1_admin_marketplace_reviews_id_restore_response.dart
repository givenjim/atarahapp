// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_review_dto.dart';

part 'post_api_v1_admin_marketplace_reviews_id_restore_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMarketplaceReviewsIdRestoreResponse {
  const PostApiV1AdminMarketplaceReviewsIdRestoreResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminMarketplaceReviewsIdRestoreResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminMarketplaceReviewsIdRestoreResponseFromJson(json);
  
  final AdminReviewDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminMarketplaceReviewsIdRestoreResponseToJson(this);
}
