// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_enquiries_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceEnquiriesResponse
_$GetApiV1MarketplaceEnquiriesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MarketplaceEnquiriesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => EnquiryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MarketplaceEnquiriesResponseToJson(
  GetApiV1MarketplaceEnquiriesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
