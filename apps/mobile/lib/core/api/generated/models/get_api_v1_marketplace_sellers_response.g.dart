// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_sellers_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceSellersResponse _$GetApiV1MarketplaceSellersResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MarketplaceSellersResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => SellerCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MarketplaceSellersResponseToJson(
  GetApiV1MarketplaceSellersResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
