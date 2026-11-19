// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_enquiries_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceEnquiriesIdResponse
_$GetApiV1MarketplaceEnquiriesIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MarketplaceEnquiriesIdResponse(
      data: EnquiryThreadDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MarketplaceEnquiriesIdResponseToJson(
  GetApiV1MarketplaceEnquiriesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
