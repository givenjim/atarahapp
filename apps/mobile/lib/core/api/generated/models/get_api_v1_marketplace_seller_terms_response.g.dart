// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_seller_terms_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceSellerTermsResponse
_$GetApiV1MarketplaceSellerTermsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MarketplaceSellerTermsResponse(
      data: SellerTermsDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MarketplaceSellerTermsResponseToJson(
  GetApiV1MarketplaceSellerTermsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
