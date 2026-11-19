// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_marketplace_listings_id_enquiries_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MarketplaceListingsIdEnquiriesResponse
_$PostApiV1MarketplaceListingsIdEnquiriesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MarketplaceListingsIdEnquiriesResponse(
  data: EnquiryThreadDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MarketplaceListingsIdEnquiriesResponseToJson(
  PostApiV1MarketplaceListingsIdEnquiriesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
