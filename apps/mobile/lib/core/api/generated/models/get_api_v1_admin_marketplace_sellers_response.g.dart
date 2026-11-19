// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_marketplace_sellers_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMarketplaceSellersResponse
_$GetApiV1AdminMarketplaceSellersResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminMarketplaceSellersResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminSellerDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminMarketplaceSellersResponseToJson(
  GetApiV1AdminMarketplaceSellersResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
