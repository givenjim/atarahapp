// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_listings_id_feature_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceListingsIdFeatureResponse
_$PostApiV1AdminMarketplaceListingsIdFeatureResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceListingsIdFeatureResponse(
  data: AdminListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMarketplaceListingsIdFeatureResponseToJson(
  PostApiV1AdminMarketplaceListingsIdFeatureResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
