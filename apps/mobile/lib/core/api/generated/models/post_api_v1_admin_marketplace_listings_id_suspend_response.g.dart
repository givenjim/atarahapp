// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_listings_id_suspend_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceListingsIdSuspendResponse
_$PostApiV1AdminMarketplaceListingsIdSuspendResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceListingsIdSuspendResponse(
  data: AdminListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMarketplaceListingsIdSuspendResponseToJson(
  PostApiV1AdminMarketplaceListingsIdSuspendResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
