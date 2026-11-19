// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'enquiry_thread_dto.dart';

part 'post_api_v1_marketplace_enquiries_id_close_response.g.dart';

@JsonSerializable()
class PostApiV1MarketplaceEnquiriesIdCloseResponse {
  const PostApiV1MarketplaceEnquiriesIdCloseResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MarketplaceEnquiriesIdCloseResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MarketplaceEnquiriesIdCloseResponseFromJson(json);
  
  final EnquiryThreadDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MarketplaceEnquiriesIdCloseResponseToJson(this);
}
