// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_marketplace_sellers_id_direct_publish_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminMarketplaceSellersIdDirectPublishResponse
_$PatchApiV1AdminMarketplaceSellersIdDirectPublishResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminMarketplaceSellersIdDirectPublishResponse(
  data: AdminSellerDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PatchApiV1AdminMarketplaceSellersIdDirectPublishResponseToJson(
  PatchApiV1AdminMarketplaceSellersIdDirectPublishResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
