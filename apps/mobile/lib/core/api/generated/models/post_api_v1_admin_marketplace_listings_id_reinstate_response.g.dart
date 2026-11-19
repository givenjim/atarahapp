// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_listings_id_reinstate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceListingsIdReinstateResponse
_$PostApiV1AdminMarketplaceListingsIdReinstateResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceListingsIdReinstateResponse(
  data: AdminListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminMarketplaceListingsIdReinstateResponseToJson(
  PostApiV1AdminMarketplaceListingsIdReinstateResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
