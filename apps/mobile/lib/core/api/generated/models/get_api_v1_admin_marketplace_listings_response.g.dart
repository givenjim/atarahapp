// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_marketplace_listings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMarketplaceListingsResponse
_$GetApiV1AdminMarketplaceListingsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminMarketplaceListingsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminListingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminMarketplaceListingsResponseToJson(
  GetApiV1AdminMarketplaceListingsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
