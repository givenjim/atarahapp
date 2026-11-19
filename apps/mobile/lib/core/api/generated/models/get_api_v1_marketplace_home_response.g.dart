// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_marketplace_home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MarketplaceHomeResponse _$GetApiV1MarketplaceHomeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MarketplaceHomeResponse(
  data: MarketplaceHomeDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MarketplaceHomeResponseToJson(
  GetApiV1MarketplaceHomeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
