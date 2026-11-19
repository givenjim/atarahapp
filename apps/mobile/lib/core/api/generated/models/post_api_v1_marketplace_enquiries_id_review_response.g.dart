// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_marketplace_enquiries_id_review_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MarketplaceEnquiriesIdReviewResponse
_$PostApiV1MarketplaceEnquiriesIdReviewResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MarketplaceEnquiriesIdReviewResponse(
  data: EnquiryThreadDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MarketplaceEnquiriesIdReviewResponseToJson(
  PostApiV1MarketplaceEnquiriesIdReviewResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
