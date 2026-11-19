// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_listings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeListingsResponse _$GetApiV1MeListingsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeListingsResponse(
  data: MyListingsDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeListingsResponseToJson(
  GetApiV1MeListingsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
