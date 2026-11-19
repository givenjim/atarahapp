// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_marketplace_listings_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMarketplaceListingsIdResponse
_$GetApiV1AdminMarketplaceListingsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminMarketplaceListingsIdResponse(
  data: AdminListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminMarketplaceListingsIdResponseToJson(
  GetApiV1AdminMarketplaceListingsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
