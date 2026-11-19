// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_listings_id_reject_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceListingsIdRejectResponse
_$PostApiV1AdminMarketplaceListingsIdRejectResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceListingsIdRejectResponse(
  data: AdminListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMarketplaceListingsIdRejectResponseToJson(
  PostApiV1AdminMarketplaceListingsIdRejectResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
