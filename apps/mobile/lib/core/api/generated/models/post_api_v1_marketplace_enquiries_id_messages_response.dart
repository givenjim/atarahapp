// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'enquiry_thread_dto.dart';

part 'post_api_v1_marketplace_enquiries_id_messages_response.g.dart';

@JsonSerializable()
class PostApiV1MarketplaceEnquiriesIdMessagesResponse {
  const PostApiV1MarketplaceEnquiriesIdMessagesResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MarketplaceEnquiriesIdMessagesResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MarketplaceEnquiriesIdMessagesResponseFromJson(json);
  
  final EnquiryThreadDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MarketplaceEnquiriesIdMessagesResponseToJson(this);
}
