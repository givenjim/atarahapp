// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_sellers_id_suspend_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceSellersIdSuspendResponse
_$PostApiV1AdminMarketplaceSellersIdSuspendResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceSellersIdSuspendResponse(
  data: AdminSellerDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMarketplaceSellersIdSuspendResponseToJson(
  PostApiV1AdminMarketplaceSellersIdSuspendResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
