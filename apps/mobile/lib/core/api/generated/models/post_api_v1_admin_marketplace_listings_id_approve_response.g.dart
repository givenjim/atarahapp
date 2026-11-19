// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_listings_id_approve_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceListingsIdApproveResponse
_$PostApiV1AdminMarketplaceListingsIdApproveResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceListingsIdApproveResponse(
  data: AdminListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMarketplaceListingsIdApproveResponseToJson(
  PostApiV1AdminMarketplaceListingsIdApproveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
