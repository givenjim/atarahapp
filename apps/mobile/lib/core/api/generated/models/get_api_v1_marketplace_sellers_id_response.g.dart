// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_sellers_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceSellersIdResponse
_$GetApiV1MarketplaceSellersIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MarketplaceSellersIdResponse(
      data: SellerProfileDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MarketplaceSellersIdResponseToJson(
  GetApiV1MarketplaceSellersIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
