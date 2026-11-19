// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'enquiry_thread_dto.dart';

part 'post_api_v1_marketplace_listings_id_enquiries_response.g.dart';

@JsonSerializable()
class PostApiV1MarketplaceListingsIdEnquiriesResponse {
  const PostApiV1MarketplaceListingsIdEnquiriesResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MarketplaceListingsIdEnquiriesResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MarketplaceListingsIdEnquiriesResponseFromJson(json);
  
  final EnquiryThreadDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MarketplaceListingsIdEnquiriesResponseToJson(this);
}
