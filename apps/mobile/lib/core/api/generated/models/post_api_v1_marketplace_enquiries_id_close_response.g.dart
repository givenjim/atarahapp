// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_marketplace_enquiries_id_close_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MarketplaceEnquiriesIdCloseResponse
_$PostApiV1MarketplaceEnquiriesIdCloseResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MarketplaceEnquiriesIdCloseResponse(
  data: EnquiryThreadDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MarketplaceEnquiriesIdCloseResponseToJson(
  PostApiV1MarketplaceEnquiriesIdCloseResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
