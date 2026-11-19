// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_sellers_id_reinstate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceSellersIdReinstateResponse
_$PostApiV1AdminMarketplaceSellersIdReinstateResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceSellersIdReinstateResponse(
  data: AdminSellerDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminMarketplaceSellersIdReinstateResponseToJson(
  PostApiV1AdminMarketplaceSellersIdReinstateResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
