// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_marketplace_enquiries_id_messages_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MarketplaceEnquiriesIdMessagesResponse
_$PostApiV1MarketplaceEnquiriesIdMessagesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MarketplaceEnquiriesIdMessagesResponse(
  data: EnquiryThreadDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MarketplaceEnquiriesIdMessagesResponseToJson(
  PostApiV1MarketplaceEnquiriesIdMessagesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
