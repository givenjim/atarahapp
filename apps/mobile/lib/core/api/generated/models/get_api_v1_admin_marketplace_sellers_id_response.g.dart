// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_marketplace_sellers_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMarketplaceSellersIdResponse
_$GetApiV1AdminMarketplaceSellersIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminMarketplaceSellersIdResponse(
  data: AdminSellerDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminMarketplaceSellersIdResponseToJson(
  GetApiV1AdminMarketplaceSellersIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
