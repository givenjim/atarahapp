// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'enquiry_thread_dto.dart';

part 'post_api_v1_marketplace_enquiries_id_review_response.g.dart';

@JsonSerializable()
class PostApiV1MarketplaceEnquiriesIdReviewResponse {
  const PostApiV1MarketplaceEnquiriesIdReviewResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MarketplaceEnquiriesIdReviewResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MarketplaceEnquiriesIdReviewResponseFromJson(json);
  
  final EnquiryThreadDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MarketplaceEnquiriesIdReviewResponseToJson(this);
}
